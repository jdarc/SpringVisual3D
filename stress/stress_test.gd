extends Node3D

@export var spring_scene: PackedScene

@onready var springs: Node3D = $Springs
@onready var camera_control: Node3D = $CameraControl
@onready var camera_3d: Camera3D = $CameraControl/Camera3D

var _time: float = 0.0
var _thread: Thread

func _ready() -> void:
	_boot_strap.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	camera_3d.position.y = 5.1 + 5.0 * sin(_time * 0.5)
	camera_3d.look_at(camera_control.global_position)
	camera_control.rotate_y(delta * 0.05)


func _boot_strap() -> void:
	_thread = Thread.new()
	_thread.start(_generate_mucho_springs, Thread.PRIORITY_LOW)


func _exit_tree():
	if _thread && _thread.is_started():
		_thread.wait_to_finish()


func _generate_mucho_springs() -> void:
	var size := 50
	for z: int in range(-size, size, 2):
		for x: int in range(-size, size, 2):
			var vx := randf_range(-1.0, 1.0)
			var vz := randf_range(-1.0, 1.0)
			var jitter := Vector3(vx, 0, vz).normalized() * 0.5
			var pos := Vector3(x, 0.0, z) + jitter
			if pos.length() < size:
				var thing: Node3D = spring_scene.instantiate()
				thing.visible = false
				thing.position = pos
				springs.call_deferred(&"add_child", thing)
				OS.delay_usec(50)
				thing.visible = true
