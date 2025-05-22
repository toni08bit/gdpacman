extends Node2D

signal world_ready

var points: PackedVector2Array = []
var network: Array = [] # [right, down, left, up] per point

func _ready() -> void:
	var point_map := {}
	for path: Path2D in get_node("PATHS").get_children():
		var curve := path.curve
		for i in curve.point_count:
			var local_p := curve.get_point_position(i)
			var p := path.to_global(local_p) # Convert to global position

			if not point_map.has(p):
				point_map[p] = points.size()
				points.append(p)
				network.append([
					PackedInt32Array(), PackedInt32Array(),
					PackedInt32Array(), PackedInt32Array()
				])

			if i > 0:
				var local_prev := curve.get_point_position(i - 1)
				var p_prev := path.to_global(local_prev)

				if not point_map.has(p_prev):
					point_map[p_prev] = points.size()
					points.append(p_prev)
					network.append([
						PackedInt32Array(), PackedInt32Array(),
						PackedInt32Array(), PackedInt32Array()
					])

				_connect(point_map[p_prev], point_map[p])
	emit_signal("world_ready")


func _connect(i1: int, i2: int) -> void:
	var p1 := points[i1]
	var p2 := points[i2]
	var d := p2 - p1
	var a = network[i1]
	var b = network[i2]
	if abs(d.x) > abs(d.y):
		if d.x > 0:
			a[0].append(i2); b[2].append(i1) # right, left
		else:
			a[2].append(i2); b[0].append(i1) # left, right
	else:
		if d.y > 0:
			a[1].append(i2); b[3].append(i1) # down, up
		else:
			a[3].append(i2); b[1].append(i1) # up, down
