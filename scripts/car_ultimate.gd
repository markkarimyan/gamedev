extends Area2D

const DAMAGE := 45
const TELEGRAPH_SECONDS := 0.45
const SPEED := 1120.0
const LIFETIME := 1.85
const KNOCKBACK_FORCE := Vector2(720.0, -230.0)

var owner_id := 1
var direction := 1
var age := 0.0
var has_hit := false
var car_parts: Array[CanvasItem] = []

@onready var warning: ColorRect = %Warning

func _ready() -> void:
	add_to_group("car_ultimate")
	add_to_group("player_%d_car_ultimate" % owner_id)
	for child in get_children():
		if child is CanvasItem and child != warning:
			car_parts.append(child)
	body_entered.connect(_on_body_entered)
	scale.x = direction
	_set_warning_visible(true)
	_set_car_visible(false)


func _physics_process(delta: float) -> void:
	if get_parent().has_method("is_match_cinematic_frozen") and get_parent().is_match_cinematic_frozen():
		return

	age += delta
	if age < TELEGRAPH_SECONDS:
		warning.modulate.a = 0.28 + 0.2 * sin(age * 34.0)
		return

	_set_warning_visible(false)
	_set_car_visible(true)
	position.x += SPEED * direction * delta
	for body in get_overlapping_bodies():
		_try_hit_body(body)
	if age >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node) -> void:
	_try_hit_body(body)


func _try_hit_body(body: Node) -> void:
	if has_hit or age < TELEGRAPH_SECONDS:
		return
	var target_player_id = body.get("player_id")
	if target_player_id == owner_id:
		return
	if target_player_id == null or not get_parent().has_method("apply_player_hit"):
		return

	var hit_applied: bool = get_parent().apply_player_hit(owner_id, target_player_id, DAMAGE, global_position)
	if hit_applied:
		has_hit = true
		if body is Player:
			body.velocity = Vector2(KNOCKBACK_FORCE.x * direction, KNOCKBACK_FORCE.y)
			body.knockback_left = 0.28


func _set_car_visible(is_visible: bool) -> void:
	for part in car_parts:
		part.visible = is_visible


func _set_warning_visible(is_visible: bool) -> void:
	warning.visible = is_visible
