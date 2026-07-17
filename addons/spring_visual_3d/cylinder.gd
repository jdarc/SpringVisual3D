# Copyright © 2026 Jean d'Arc
# SPDX-License-Identifier: MIT

class_name SpringVisual3DCylinder

const radial_segments: int = 16

var arr_mesh := ArrayMesh.new()
var arrays := []
var vertices := PackedVector3Array()
var indices := PackedInt32Array()

var last_radius := 0.0
var last_height := 0.0


func _init() -> void:
	vertices.resize((radial_segments + 1) * 2)
	arrays.resize(Mesh.ARRAY_MAX)
	for i: int in radial_segments:
		var v0 := i * 2
		var v1 := v0 + 1
		var v2 := v0 + 2
		var v3 := v0 + 3
		indices.append(v0)
		indices.append(v2)
		indices.append(v1)
		indices.append(v1)
		indices.append(v2)
		indices.append(v3)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices


func generate(radius: float = 0.5, height: float = 1.0) -> ArrayMesh:
	if radius != last_radius or height != last_height:
		last_radius = radius
		last_height = height
		var half_h := height * 0.5
		var step := TAU / radial_segments
		for i: int in radial_segments + 1:
			var angle := float(i) * step
			var x := cos(angle)
			var y := sin(angle)
			vertices[i * 2 + 0] = Vector3(x * radius, y * radius, half_h)
			vertices[i * 2 + 1] = Vector3(x * radius, y * radius,-half_h)
		arr_mesh.clear_surfaces()
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return arr_mesh
