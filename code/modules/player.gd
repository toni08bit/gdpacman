extends AnimatedSprite2D

const directions: PackedStringArray = ["right","down","left","up"]

@onready var world := get_tree().current_scene.get_node("Node2D")

var current_point_i: int = 0
var target_point_i: int = -1

var move_speed: float = 100.0

var current_dir: int = -1
var desired_dir: int = -1

func _ready() -> void:
	world.connect("world_ready",Callable(self,"_on_world_ready"))

func _on_world_ready() -> void:
	global_position = world.points[current_point_i]

func _process(delta: float) -> void:
	if world.points.size() == 0:
		return
	
	var last_global_position: Vector2 = global_position
	for dir in directions:
		if Input.is_action_just_pressed("move_" + dir):
			desired_dir = directions.find(dir)
	
	if target_point_i == -1:
		global_position = world.points[current_point_i] # force snap to grid
		
		if desired_dir != -1 and _can_move(desired_dir):
			_start_move(desired_dir)
		elif current_dir != -1 and _can_move(current_dir):
			_start_move(current_dir)
		else:
			current_dir = -1
	else:
		var target_pos = world.points[target_point_i]
		var distance = global_position.distance_to(target_pos)
		
		if distance < move_speed * delta:
			global_position = target_pos
			current_point_i = target_point_i
			target_point_i = -1
		else:
			global_position = global_position.move_toward(target_pos, move_speed * delta)
	if global_position.distance_squared_to(last_global_position) != 0:
		rotation = atan2(
			global_position.y - last_global_position.y,
			global_position.x - last_global_position.x
		)

func _can_move(dir: int) -> bool:
	if current_point_i < 0 or current_point_i >= world.network.size():
		return false
	var targets = world.network[current_point_i][dir]
	return targets.size() > 0

func _start_move(dir: int) -> void:
	var targets = world.network[current_point_i][dir]
	if targets.size() > 0:
		target_point_i = targets[0]
		current_dir = dir
