extends Node3D

@onready var target: Marker3D = $Target
@onready var spring_visual_3d: SpringVisual3D = $SpringVisual3D

var _t: float = 0.0
var _s: float = 1.0
var _r: float = 1.0

func _ready() -> void:
	_t = randf_range(0.0, TAU)
	_s = randf_range(1.0, 10.0)
	_r = randf_range(1.0, 4.0)
	spring_visual_3d.albedo = Color.from_hsv(randf_range(0.0, 1.0), 0.5, 0.8)
	spring_visual_3d.total_coils = floori(sqrt(_r * 20.0))
	spring_visual_3d.wire_radius = 0.3 / spring_visual_3d.total_coils

func _process(delta: float) -> void:
	_t = wrapf(_t + delta * _s, 0.0, TAU)
	target.global_position.y = _r + _r * sin(_t) * 0.5
