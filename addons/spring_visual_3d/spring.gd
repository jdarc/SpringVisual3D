# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT
@tool
class_name SpringVisual3D extends MeshInstance3D

const SHADER = preload("uid://1r64xr0q0xy3")

@export var anchor_node: Node3D:
	set(value): anchor_node = value; _geometry_state_dirty = true
@export var target_node : Node3D:
	set(value): target_node = value; _geometry_state_dirty = true
@export_range(0.0, 1.0, 0.01) var offset: float:
	set(value): offset = value; _geometry_state_dirty = true; _shader_state_dirty = true
@export_range(0.0, 360.0, 0.01) var twist_degrees: float:
	set(value): twist_degrees = value; _geometry_state_dirty = true;

@export_group(&"Geometry")
@export_range(4, 64, 1, &"or_greater") var radial_segments: int = 12:
	set(value): radial_segments = value; _geometry_state_dirty = true; _shader_state_dirty = true
@export_range(0, 512, 1, &"or_greater") var rings: int = 200:
	set(value): rings = value; _geometry_state_dirty = true; _shader_state_dirty = true
@export_range(0.0001, 1.0, 0.0001, &"or_greater") var wire_radius: float = 0.05:
	set(value): wire_radius = value; _geometry_state_dirty = true; _shader_state_dirty = true
@export_range(0.0001, 2.0, 0.0001, &"or_greater") var coil_radius: float = 0.3:
	set(value): coil_radius = value; _geometry_state_dirty = true; _shader_state_dirty = true
@export_range(1, 50, 1, &"prefer_slider") var total_coils: int = 10:
	set(value): total_coils = value; _geometry_state_dirty = true; _shader_state_dirty = true

@export_group(&"Appearance")
@export var albedo: Color = Color.WHITE:
	set(value): albedo = value; _shader_state_dirty = true
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.9:
	set(value): metallic = value; _shader_state_dirty = true
@export_range(0.0, 1.0, 0.01) var specular: float = 0.5:
	set(value): specular = value; _shader_state_dirty = true
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.2:
	set(value): roughness = value; _shader_state_dirty = true

@export_group(&"")
@export_tool_button(&"Align Control Nodes") var _align_action = _align_handles

var _current_length := 1.0
var _current_up_axis := Vector3.UP
var _geometry_state_dirty := true
var _shader_state_dirty := true
var _previous_anchor_origin := Vector3.INF
var _previous_target_origin := Vector3.INF

func _ready() -> void:
	_on_mesh_resource_changed(mesh)


func _process(delta: float) -> void:
	if anchor_node and anchor_node.global_position != _previous_anchor_origin:
		_previous_anchor_origin = anchor_node.global_position
		_geometry_state_dirty = true
		_shader_state_dirty = true

	if target_node and target_node.global_position != _previous_target_origin:
		_previous_target_origin = target_node.global_position
		_geometry_state_dirty = true
		_shader_state_dirty = true

	if _geometry_state_dirty:
		_update_geometry()

	if _shader_state_dirty:
		_update_shader()


func _update_geometry() -> void:
	if not is_node_ready():
		return

	_handle_anchor_target_changes()
	_update_bounding_box()
	_update_spring_geometry_for_editor()

	_geometry_state_dirty = false

func _update_spring_geometry_for_editor() -> void:
	if not Engine.is_editor_hint() or mesh is not CylinderMesh:
		return
	var cylinder: CylinderMesh = mesh
	var radius := coil_radius + wire_radius
	var height := _current_length + wire_radius + wire_radius
	if not is_equal_approx(cylinder.top_radius, radius): cylinder.top_radius = radius
	if not is_equal_approx(cylinder.bottom_radius, radius): cylinder.bottom_radius = radius
	if not is_equal_approx(cylinder.height, height): cylinder.height = height


func _handle_anchor_target_changes() -> void:
	var anchor_alive := anchor_node and anchor_node.is_node_ready()
	var target_alive := target_node and target_node.is_node_ready()
	var origin := anchor_node.global_position if anchor_alive else -Vector3.UP
	var target := target_node.global_position if target_alive else Vector3.UP
	_current_length = origin.distance_to(target) - offset
	if not origin.is_equal_approx(target):
		var y_axis := origin.direction_to(target)
		if absf(_current_up_axis.dot(y_axis)) > 0.99:
			_current_up_axis = Vector3.FORWARD if absf(y_axis.y) > 0.9 else Vector3.UP
		var x_axis := _current_up_axis.cross(y_axis).normalized()
		var z_axis := x_axis.cross(y_axis).normalized()
		var tx := Basis(x_axis, y_axis, z_axis).rotated(y_axis, deg_to_rad(twist_degrees))
		global_transform = Transform3D(tx.orthonormalized(), (target + origin) * 0.5)
		_current_up_axis = y_axis


func _update_bounding_box() -> void:
	var radius := coil_radius + wire_radius
	var height := _current_length + wire_radius * 2.0
	custom_aabb.position = Vector3(-radius, -height * 0.5, -radius)
	custom_aabb.size = Vector3(radius * 2.0, height, radius * 2.0)


func _align_handles() -> void:
	if anchor_node and anchor_node.is_node_ready():
		anchor_node.look_at(global_position)
	if target_node and target_node.is_node_ready():
		target_node.look_at(global_position)


func _update_shader() -> void:
	if not is_node_ready():
		return

	var cylinder := mesh as CylinderMesh
	if cylinder:
		if not is_equal_approx(cylinder.rings, rings):
			cylinder.rings = rings
		if not is_equal_approx(cylinder.radial_segments, radial_segments):
			cylinder.radial_segments = radial_segments

		var active_material := cylinder.material as ShaderMaterial
		if not active_material:
			return

		active_material.set_shader_parameter(&"wire_radius", wire_radius)
		active_material.set_shader_parameter(&"coil_radius", coil_radius)
		active_material.set_shader_parameter(&"total_coils", total_coils)
		active_material.set_shader_parameter(&"height_normalize", 1.0 / cylinder.height)
		active_material.set_shader_parameter(&"current_length", _current_length)
		active_material.set_shader_parameter(&"albedo", albedo)
		active_material.set_shader_parameter(&"metallic", metallic)
		active_material.set_shader_parameter(&"specular", specular)
		active_material.set_shader_parameter(&"roughness", roughness)

	_shader_state_dirty = false

func _set(property: StringName, value) -> bool:
	if property == &"mesh":
		if value != mesh:
			_geometry_state_dirty = true
			_shader_state_dirty = true
			#if value and value is CylinderMesh and value.changed.is_connected(_update_shader):
				#value.changed.disconnect(_update_shader)
			mesh = value
			_on_mesh_resource_changed(mesh)
			return true
	return false


func _on_mesh_resource_changed(the_mesh: Mesh) -> void:
	if the_mesh and the_mesh is CylinderMesh:
		var material := ShaderMaterial.new()
		material.shader = SHADER
		(the_mesh as CylinderMesh).material = material
