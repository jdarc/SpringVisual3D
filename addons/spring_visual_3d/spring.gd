# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT
@tool
class_name SpringVisual3D extends MeshInstance3D

@export var anchor_node: Node3D:
	set(value): anchor_node = value; _update_spring()

@export var target_node : Node3D:
	set(value): target_node = value; _update_spring()

@export_range(0.0, 360.0, 0.01) var twist_degrees: float:
	set(value): twist_degrees = value; _handle_twist_changed()

@export_group(&"Geometry")
@export_range(4, 64, 1, &"or_greater") var radial_segments: int = 12:
	set(value): radial_segments = value; _update_shader()
@export_range(0, 512, 1, &"or_greater") var rings: int = 200:
	set(value): rings = value; _update_shader()
@export_range(0.0001, 1.0, 0.0001, &"or_greater") var wire_radius: float = 0.05:
	set(value): wire_radius = value; _update_shader()
@export_range(0.0001, 2.0, 0.0001, &"or_greater") var coil_radius: float = 0.3:
	set(value): coil_radius = value; _update_shader()
@export_range(1, 50, 1, &"prefer_slider") var total_coils: int = 10:
	set(value): total_coils = value; _update_shader()

@export_group(&"Appearance")
@export var albedo: Color = Color.WHITE:
	set(value): albedo = value; _update_shader()
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.8:
	set(value): metallic = value; _update_shader()
@export_range(0.0, 1.0, 0.01) var specular: float = 0.5:
	set(value): specular = value; _update_shader()
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.2:
	set(value): roughness = value; _update_shader()

static var _cached_shader: Shader
static var _cached_tube_shader: Shader
static var _cached_tube_material: ShaderMaterial

var current_length: float:
	set(value): current_length = maxf(0.0001, value); _update_shader()

var _mesh_container: Node3D
var _debug_box_instance: MeshInstance3D
var _spring_mesh_instance: MeshInstance3D
var _shader_material: ShaderMaterial
var _current_up_axis: Vector3 = Vector3.UP
var _target_last_position := Vector3.ZERO
var _origin_last_position := Vector3.ZERO
var _cylinder_maker := SpringVisual3DCylinder.new()


func _init() -> void:
	if not _cached_tube_shader:
		_cached_tube_shader = load(path_to(get_script(), &"tube.gdshader"))
		_cached_tube_material = ShaderMaterial.new()
		_cached_tube_material.shader = _cached_tube_shader

	if not _cached_shader:
		_cached_shader = load(path_to(get_script(), &"spring.gdshader"))

	_shader_material = ShaderMaterial.new()
	_shader_material.resource_local_to_scene = true
	_shader_material.shader = _cached_shader

	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.height = 0.001
	cylinder_mesh.top_radius = 0.001
	cylinder_mesh.bottom_radius = 0.001
	_spring_mesh_instance = MeshInstance3D.new()
	_spring_mesh_instance.rotate_x(PI * 0.5)
	_spring_mesh_instance.mesh = cylinder_mesh
	_spring_mesh_instance.set_surface_override_material(0, _shader_material)
	_spring_mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC

	_mesh_container = Node3D.new()
	_mesh_container.add_child(_spring_mesh_instance)
	add_child(_mesh_container)

	if Engine.is_editor_hint():
		mesh = _cylinder_maker.generate()
		set_surface_override_material(0, _cached_tube_material)
	else:
		mesh = null


func _ready() -> void:
	current_length = 1.0
	_handle_twist_changed()
	_update_spring()


func _process(delta: float) -> void:
	_update_spring()


func _handle_twist_changed() -> void:
	if not _mesh_container or not _mesh_container.is_inside_tree(): return
	_mesh_container.rotation_degrees = Vector3(0.0, 0.0, twist_degrees)


func _update_spring() -> void:
	if not is_inside_tree() \
		or not target_node or not target_node.is_inside_tree() \
		or not anchor_node or not anchor_node.is_inside_tree() :
		return

	var origin := anchor_node.global_position
	var target := target_node.global_position

	if origin != _origin_last_position or target != _target_last_position:
		_origin_last_position = origin
		_target_last_position = target

		var distance := origin.distance_to(target)
		if not origin.is_equal_approx(target):
			var z_axis := origin.direction_to(target)
			if absf(_current_up_axis.dot(z_axis)) > 0.99:
				_current_up_axis = Vector3.RIGHT if absf(z_axis.y) > 0.9 else Vector3.UP

			var x_axis := _current_up_axis.cross(z_axis).normalized()
			var y_axis := z_axis.cross(x_axis).normalized()
			_current_up_axis = y_axis
			global_transform = Transform3D(Basis(x_axis, y_axis, z_axis).orthonormalized(), (origin + target) * 0.5)

		current_length = distance


func _update_shader() -> void:
	if not is_inside_tree() or not _spring_mesh_instance:
		return

	var radius := coil_radius + wire_radius
	var coil_diameter := radius * 2.0
	var height := current_length + wire_radius * 2.0
	_spring_mesh_instance.custom_aabb.position = Vector3(-radius, -height * 0.5, -radius)
	_spring_mesh_instance.custom_aabb.size = Vector3(coil_diameter, height, coil_diameter)

	var cylinder := _spring_mesh_instance.mesh as CylinderMesh
	if cylinder:
		cylinder.rings = rings
		cylinder.radial_segments = radial_segments

	if not _shader_material:
		return

	_shader_material.set_shader_parameter(&"albedo", albedo)
	_shader_material.set_shader_parameter(&"metallic", metallic)
	_shader_material.set_shader_parameter(&"specular", specular)
	_shader_material.set_shader_parameter(&"roughness", roughness)
	_shader_material.set_shader_parameter(&"wire_radius", wire_radius)
	_shader_material.set_shader_parameter(&"coil_radius", coil_radius)
	_shader_material.set_shader_parameter(&"total_coils", total_coils)
	_shader_material.set_shader_parameter(&"current_length", current_length)

	if Engine.is_editor_hint():
		mesh = _cylinder_maker.generate(coil_radius + wire_radius * 0.5, current_length)
		set_surface_override_material(0, _cached_tube_material)
	else:
		mesh = null


static func path_to(script: Variant, file: String) -> String:
	return script.resource_path.get_base_dir().path_join(file)
