extends Sprite2D

const SPEED: float = 30
const ANGLE_TOLERANCE: float = 5

var move_ref: int = 0
var move_ref_line_pos: float = -1
var move_ref_line_dir: int = 0
var move_next_input: int = 0 # 1 = UP; 2 = DOWN; 3 = LEFT; 4 = RIGHT;
var move_ref_last_input: int = 0

var world: Node2D

func _ready() -> void:
	world = get_parent()

func _process(delta: float) -> void:
	if move_ref_line_pos == -1:
		if move_next_input != 0:
			var next_lines: Array[PackedInt32Array] = world._get_lines_at_point(move_ref)
			var lines_reversed: bool = false
			var ref_changed: bool = false
			for line_array in next_lines:
				print(line_array)
				for line in line_array:
					var line_angle: float
					if !lines_reversed:
						line_angle = world.points[world.lines[line][0]].angle_to_point(world.points[world.lines[line][1]])
					else:
						line_angle = world.points[world.lines[line][1]].angle_to_point(world.points[world.lines[line][0]])
					if	(abs(angle_difference(deg_to_rad(-90),line_angle)) <= deg_to_rad(ANGLE_TOLERANCE) && move_next_input == 1) || \
						(abs(angle_difference(deg_to_rad(90),line_angle)) <= deg_to_rad(ANGLE_TOLERANCE) && move_next_input == 2) || \
						(abs(angle_difference(deg_to_rad(180),line_angle)) <= deg_to_rad(ANGLE_TOLERANCE) && move_next_input == 3) || \
						(abs(angle_difference(deg_to_rad(0),line_angle)) <= deg_to_rad(ANGLE_TOLERANCE) && move_next_input == 4):
							print(line)
							move_ref = line
							if !lines_reversed:
								move_ref_line_dir = 1
								move_ref_line_pos = 0
							else:
								move_ref_line_dir = -1
								move_ref_line_pos = 1
							move_ref_last_input = move_next_input
							ref_changed = true
							print("reference changed")
							break
						
				if ref_changed:
					#_process(delta)
					break
				lines_reversed = true
			position = world.unit_to_world(world.points[move_ref])
	else:
		var line: PackedInt32Array = world.lines[move_ref]
		var line_points: PackedVector2Array = [
			world.points[line[0]],
			world.points[line[1]]
		]
		
		move_ref_line_pos += SPEED * delta * move_ref_line_dir / (line_points[1] - line_points[0]).length()
		if move_ref_line_pos > 1:
			move_ref_line_pos = -1
			move_ref_line_dir = 0
			move_ref = line[1]
			#_process(delta)
		elif move_ref_line_pos < 0:
			move_ref_line_pos = -1
			move_ref_line_dir = 0
			move_ref = line[0]
			#_process(delta)
		else:
			position = world.unit_to_world(line_points[0].lerp(line_points[1],move_ref_line_pos))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		move_next_input = 1
	elif event.is_action_pressed("move_down"):
		move_next_input = 2
	elif event.is_action_pressed("move_left"):
		move_next_input = 3
	elif event.is_action_pressed("move_right"):
		move_next_input = 4

func spawn(point_id: int) -> void:
	move_ref_line_pos = -1
	move_ref = point_id
