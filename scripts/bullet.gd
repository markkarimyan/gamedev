extends Area2D

const SPEED := 560.0
const LIFETIME := 1.4
const DAMAGE := 12

var direction := 1
var owner_id := 0
var speed := SPEED
var damage := DAMAGE
var bullet_color := Color(1, 0.87451, 0.27451, 1)
var age := 0.0

@onready var visual: Polygon2D = %Visual
@onready var core: Polygon2D = %Core
@onready var trail: Polygon2D = %Trail

func _ready() -> void:
	add_to_group("cinematic_freeze_pauses")
	body_entered.connect(_on_body_entered)
	visual.scale.x = direction
	core.scale.x = direction
	trail.scale.x = direction
	visual.color = bullet_color
	core.color = bullet_color.lightened(0.45)
	trail.color = Color(bullet_color.r, bullet_color.g * 0.65, bullet_color.b * 0.35, 0.5)


func _physics_process(delta: float) -> void:
	if get_parent().has_method("is_match_cinematic_frozen") and get_parent().is_match_cinematic_frozen():
		return
	position.x += speed * direction * delta
	age += delta
	if age >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if get_parent().has_method("is_match_cinematic_frozen") and get_parent().is_match_cinematic_frozen():
		return
	var target_player_id = body.get("player_id")
	if target_player_id == owner_id:
		return
	if target_player_id != null and get_parent().has_method("apply_player_hit"):
		get_parent().apply_player_hit(owner_id, target_player_id, damage, global_position)
		queue_free()
		return
	if body.has_method("take_hit"):
		body.take_hit(damage, global_position)
	queue_free()
