# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT

@tool
extends EditorInspectorPlugin

const PROPERTIES_TO_REMOVE: PackedStringArray = [
	&"mesh",
	&"skin",
	&"skeleton",
	&"surface_material_override",
	&"material_override",
	&"material_overlay",
	&"transparency",
	&"cast_shadow",
	&"extra_cull_margin",
	&"custom_aabb",
	&"lod_bias",
	&"ignore_occlusion_culling",
	&"gi_mode",
	&"gi_lightmap_texel_scale",
	&"visibility_range_begin",
	&"visibility_range_begin_margin",
	&"visibility_range_end",
	&"visibility_range_end_margin",
	&"visibility_range_fade_mode",
	&"layers",
	&"sorting_offset",
	&"sorting_use_aabb_center",
	&"position",
	&"rotation",
	&"scale",
	&"rotation_edit_mode",
	&"rotation_order",
	&"top_level",
	&"visible",
	&"visibility_parent"
]


func _can_handle(object: Object) -> bool:
	return object is SpringVisual3D


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name.begins_with(&"surface_material_override/"):
		return true
	for test: String in PROPERTIES_TO_REMOVE:
		if name.nocasecmp_to(test) == 0:
			return true
	return false
