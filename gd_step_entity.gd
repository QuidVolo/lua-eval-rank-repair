# gd_step_entity.gd — GDScript port of fixed_spawn step_entity
# Godot 4.x style (typed for clarity)
class_name StepEntity

static func step_entity(e: Dictionary, target: Dictionary, dt: float) -> Array:
	var pos := e.get("pos", {"x": 0.0, "y": 0.0})
	var x: float = pos["x"]
	var y: float = pos["y"]
	var dx: float = target["x"] - x
	var dy: float = target["y"] - y
	var dist_sq: float = dx*dx + dy*dy
	if dist_sq == 0.0:
		return [x, y, true]
	var dist := sqrt(dist_sq)
	var speed := float(e.get("speed", 0.0))
	var step := speed * dt
	if step >= dist:
		pos["x"] = target["x"]
		pos["y"] = target["y"]
		return [pos["x"], pos["y"], true]
	var nx := dx / dist
	var ny := dy / dist
	pos["x"] = x + nx * step
	pos["y"] = y + ny * step
	return [pos["x"], pos["y"], false]
