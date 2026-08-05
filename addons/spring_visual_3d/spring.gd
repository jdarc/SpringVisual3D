# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT
@tool
class_name SpringVisual3D extends MeshInstance3D

const SHADER: Shader = preload("uid://1r64xr0q0xy3")

## Optional node defining one end of the spring.
@export var anchor_node: Node3D:
	set(value): anchor_node = value; _mark_all_dirty()
## Optional node defining the opposite end of the spring.
@export var target_node : Node3D:
	set(value): target_node = value; _mark_all_dirty()
## Rotates the spring around the axis running between the anchor and target nodes.
@export_range(0.0, 360.0, 0.01, &"degrees") var twist_degrees: float:
	set(value): twist_degrees = value; _geometry_state_dirty = true;

@export_group(&"Geometry")
## Radius of the circular cross-section of the spring wire.
@export_range(0.0001, 1.0, 0.0001, &"or_greater") var wire_radius: float = 0.05:
	set(value): wire_radius = value; _mark_all_dirty()
## Distance from the spring's central axis to the centre of the wire.
@export_range(0.0001, 2.0, 0.0001, &"or_greater") var coil_radius: float = 0.3:
	set(value): coil_radius = value; _mark_all_dirty()
## Number of complete coils in the spring.
@export_range(1, 50, 1, &"prefer_slider", &"or_greater") var total_coils: int = 10:
	set(value): total_coils = value; _mark_all_dirty()

@export_group(&"Appearance")
## Base color of the spring.
@export var albedo: Color = Color.WHITE:
	set(value): albedo = value; _mark_shader_dirty()
## Metallic strength of the spring's surface.
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.9:
	set(value): metallic = value; _mark_shader_dirty()
## Strength of specular reflections.
@export_range(0.0, 1.0, 0.01) var specular: float = 0.5:
	set(value): specular = value; _mark_shader_dirty()
## Surface roughness, where 0 is smooth and 1 is rough.
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.2:
	set(value): roughness = value; _mark_shader_dirty()

@export_group(&"")
## Aligns the anchor and target nodes with the spring's axis,
## allowing them to be easily stretched using local transforms
## regardless of the spring's orientation.
@export_tool_button(&"Align Control Nodes") var _align_action = _align_handles

var _current_length := 2.0
var _geometry_state_dirty := true
var _shader_state_dirty := true
var _cached_direction := Vector3.UP
var _cached_basis := Basis.IDENTITY
var _previous_anchor_transform := Transform3D()
var _previous_target_transform := Transform3D()
var _material: ShaderMaterial


func _ready() -> void:
	top_level = true
	_on_mesh_resource_changed(mesh)


func _process(_delta: float) -> void:
	_update_control_node_state()

	if _geometry_state_dirty:
		_update_geometry()

	if _shader_state_dirty:
		_update_shader()


func _update_control_node_state() -> void:
	if _is_anchor_node_valid() and not anchor_node.global_transform.is_equal_approx(_previous_anchor_transform):
		_previous_anchor_transform = anchor_node.global_transform
		_mark_all_dirty()

	if _is_target_node_valid() and not target_node.global_transform.is_equal_approx(_previous_target_transform):
		_previous_target_transform = target_node.global_transform
		_mark_all_dirty()


func _is_anchor_node_valid() -> bool:
	return is_instance_valid(anchor_node) and anchor_node.is_inside_tree()


func _is_target_node_valid() -> bool:
	return is_instance_valid(target_node) and target_node.is_inside_tree()


func _update_geometry() -> void:
	_geometry_state_dirty = false
	_update_spring_transform()
	_update_spring_scale()


func _update_spring_scale() -> void:
	if mesh is not CylinderMesh:
		return
	var cylinder: CylinderMesh = mesh
	var base_radius := maxf(cylinder.top_radius, 0.00001)
	var base_height := maxf(cylinder.height, 0.00001)
	var radius := (coil_radius + wire_radius) / base_radius
	var height := (_current_length + wire_radius * 2.0) / base_height
	scale = Vector3(radius, height, radius)


func _update_spring_transform() -> void:
	var anchor_position := (anchor_node.global_position if _is_anchor_node_valid() else global_position - Vector3.UP)
	var target_position := (target_node.global_position if _is_target_node_valid() else global_position + Vector3.UP)

	_current_length = maxf(0.001, anchor_position.distance_to(target_position))

	if anchor_position.is_equal_approx(target_position):
		return

	var direction := anchor_position.direction_to(target_position)
	if not _cached_direction.is_equal_approx(direction):
		_cached_basis = _get_spring_basis(direction)
		_cached_direction = direction

	var new_origin := (anchor_position + target_position) * 0.5
	global_transform = Transform3D(_cached_basis, new_origin)


func _get_spring_basis(y_axis: Vector3) -> Basis:
	var target_valid := _is_target_node_valid()
	var up_axis := target_node.basis.x if target_valid else Vector3.UP
	if absf(up_axis.dot(y_axis)) > 0.99:
		up_axis = target_node.basis.y if target_valid else Vector3.FORWARD
	var x_axis := up_axis.cross(y_axis).normalized()
	var z_axis := x_axis.cross(y_axis)
	return Basis(x_axis, y_axis, z_axis).rotated(y_axis, deg_to_rad(twist_degrees))

func _align_handles() -> void:
	if _is_anchor_node_valid():
		anchor_node.look_at(global_position)
	if _is_target_node_valid():
		target_node.look_at(global_position)


func _update_shader() -> void:
	_shader_state_dirty = false
	if not _material or not mesh is CylinderMesh:
		return
	_material.set_shader_parameter(&"wire_radius", wire_radius)
	_material.set_shader_parameter(&"coil_radius", coil_radius)
	_material.set_shader_parameter(&"total_coils", total_coils)
	_material.set_shader_parameter(&"spring_length", _current_length)
	_material.set_shader_parameter(&"mesh_height", mesh.height)
	_material.set_shader_parameter(&"inv_scale", scale.inverse())
	_material.set_shader_parameter(&"albedo", albedo)
	_material.set_shader_parameter(&"metallic", metallic)
	_material.set_shader_parameter(&"specular", specular)
	_material.set_shader_parameter(&"roughness", roughness)


# Intercept MeshInstance3D.mesh assignments so the spring can
# update its shader material when the backing mesh changes.
func _set(property: StringName, value) -> bool:
	if property == &"mesh":
		if value != mesh:
			_geometry_state_dirty = true
			_shader_state_dirty = true
			mesh = value
			_on_mesh_resource_changed(mesh)
			return true
	return false


func _on_mesh_resource_changed(the_mesh: Mesh) -> void:
	if the_mesh is CylinderMesh:
		_material = _create_material()
		set_surface_override_material(0, _material)
	else:
		set_surface_override_material(0, null)


func _create_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_local_to_scene = true
	material.shader = SHADER
	return material


func _mark_geometry_dirty() -> void:
	_geometry_state_dirty = true


func _mark_shader_dirty() -> void:
	_shader_state_dirty = true


func _mark_all_dirty() -> void:
	_geometry_state_dirty = true
	_shader_state_dirty = true


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if mesh != null and not mesh is CylinderMesh:
		warnings.append(&"SpringVisual3D requires a CylinderMesh.")
	return warnings
