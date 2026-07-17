// Copyright © 2026 Jean d'Arc
// SPDX-License-Identifier: MIT
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo: source_color = vec4(1.0);
uniform float metallic: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float specular: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float roughness: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float wire_radius: hint_range(0.001, 0.5) = 0.05;
uniform float coil_radius: hint_range(0.01, 2.0) = 0.3;
uniform float total_coils : hint_range(1.0, 100.0) = 10.0;
uniform float current_length = 1.0;

void vertex() {
	float base_mesh_radius = max(0.0001, length(VERTEX.xz));
	vec2 wire_offset = (VERTEX.xz / base_mesh_radius) * wire_radius;
	float mesh_progress = VERTEX.y * 999.9;
	vec3 path_pos1 = vec3(0.0, mesh_progress * current_length, 0.0);
	vec3 path_pos2 = vec3(0.0, (mesh_progress + 0.0001) * current_length, 0.0);
	vec3 path_normal = vec3(1.0, 0.0, 0.0);
	vec3 path_tangent = normalize(path_pos2 - path_pos1);
	vec3 path_binormal = normalize(cross(path_tangent, path_normal));
	float angle = mesh_progress * total_coils * TAU;
	vec3 coil_center = path_pos1;
	coil_center += path_normal * cos(angle) * coil_radius;
	coil_center += path_binormal * sin(angle) * coil_radius;
	float helical_pitch = current_length / (total_coils * TAU * coil_radius);
	vec3 spring_tangent = path_tangent * helical_pitch + (-path_normal * sin(angle) + path_binormal * cos(angle));
	vec3 spring_normal = normalize(-path_normal * cos(angle) - path_binormal * sin(angle));
	vec3 spring_binormal = -cross(normalize(spring_tangent), spring_normal);
	vec2 normal_direction = normalize(wire_offset);
	VERTEX = coil_center + spring_normal * wire_offset.x + spring_binormal * wire_offset.y;
	NORMAL = normalize(spring_normal * normal_direction.x + spring_binormal * normal_direction.y);
}

void fragment() {
	ALBEDO = albedo.rgb;
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
}
