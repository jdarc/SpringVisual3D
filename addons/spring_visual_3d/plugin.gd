# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT

@tool
extends EditorPlugin


var inspector_plugin


func _enter_tree() -> void:
	var node := load(SpringVisual3D.path_to(get_script(), &"spring.gd"))
	var icon := load(SpringVisual3D.path_to(get_script(), &"spring.svg"))
	var prop := load(SpringVisual3D.path_to(get_script(), &"inspector.gd"))
	add_custom_type(&"SpringVisual3D", &"MeshInstance3D", node, icon)

	inspector_plugin = prop.new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	remove_custom_type(&"SpringVisual3D")


func _handles(object: Object) -> bool:
	return object is SpringVisual3D


func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseMotion and event.button_mask == MouseButton.MOUSE_BUTTON_LEFT:
		return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS
