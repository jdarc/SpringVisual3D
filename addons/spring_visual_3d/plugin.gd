# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT
@tool
extends EditorPlugin


func _enter_tree() -> void:
	const SCRIPT = preload("uid://bvj5noihb0fcu")
	const ICON = preload("uid://blmesxk18b0c3")
	add_custom_type(&"SpringVisual3D", &"MeshInstance3D", SCRIPT, ICON)


func _exit_tree() -> void:
	remove_custom_type(&"SpringVisual3D")
