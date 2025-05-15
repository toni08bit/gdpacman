extends Node2D

const MAX_X: float = 0.5
const MAX_Y: float = 0.5

var map_loaded: bool = false

var points: PackedVector2Array = []
var lines: Array[PackedInt32Array] = []
var portals: Array[PackedInt32Array] = []
var features: PackedInt32Array = []

var map_bounds: PackedVector2Array
var map_scale: float
var tl_diff: Vector2

func _ready() -> void:
	load_map(null)

func load_map(map_resource: Resource) -> void:
	assert(!map_loaded,"Map already loaded")
	var map_data_array := _extract_map_resource(map_resource)
	points = map_data_array[0]
	lines = map_data_array[1]
	portals = map_data_array[2]
	features = map_data_array[3]
	
	var viewport_size := get_viewport().get_visible_rect().size
	map_bounds = _get_map_bounds()
	map_scale = min(
		viewport_size.x * MAX_X / (map_bounds[1].x - map_bounds[0].x),
		viewport_size.y * MAX_Y / (map_bounds[1].y - map_bounds[0].y)
	)
	tl_diff = Vector2(
		map_bounds[1] - map_bounds[0]
	) * map_scale / 2
	
	for line in lines:
		var new_line2d := Line2D.new()
		new_line2d.width = 2
		new_line2d.add_point(unit_to_world(points[line[0]]))
		new_line2d.add_point(unit_to_world(points[line[1]]))
		add_child(new_line2d)
	
	$PlayerSprite.spawn(features[0])

func _extract_map_resource(map_resource: Resource) -> Array[Variant]: # TODO load from file
	var points: PackedVector2Array = [
		Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
		Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
		Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)
	]

	var lines: Array[PackedInt32Array] = [
		[0, 1], [1, 2],  # Top row
		[3, 4], [4, 5],  # Middle row
		[6, 7], [7, 8],  # Bottom row
		[0, 3], [3, 6],  # Left column
		[1, 4], [4, 7],  # Middle column
		[2, 5], [5, 8]   # Right column
	]

	var portals: Array[PackedInt32Array] = [
		#[0, 1]  # Left/Right tunnel teleport
	]

	var features: PackedInt32Array = [
		4,  # Player spawn
		0   # Ghost spawn
	]

	return [points, lines, portals, features]

func _get_map_bounds() -> PackedVector2Array:
	var min_x: float = points[0].x
	var min_y: float = points[0].y
	var max_x: float = points[0].x
	var max_y: float = points[0].y
	
	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.x > max_x:
			max_x = point.x
		if point.y > max_y:
			max_y = point.y
	
	return PackedVector2Array([
		Vector2(min_x,min_y),
		Vector2(max_x,max_y)
	])

func _get_lines_at_point(point_id: int) -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = [PackedInt32Array(),PackedInt32Array()]
	var line_i: int = 0
	for line in lines:
		if line[0] == point_id:
			result[0].append(line_i)
		if line[1] == point_id:
			result[1].append(line_i)
		line_i += 1
	return result

func unit_to_world(unit_pos: Vector2) -> Vector2:
	return (unit_pos - map_bounds[0]) * map_scale - tl_diff

func world_to_unit(world_pos: Vector2) -> Vector2:
	return Vector2() # TODO
