extends Area2D

@export_enum("famas", "ak", "rapid", "jump_boost", "medkit") var pickup_type := "rapid"
@export var respawn_time := 9.0

@onready var label: Label = %Label
@onready var body_visual: Polygon2D = %BodyVisual
@onready var icon: Polygon2D = %Icon
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visuals()


func _on_body_entered(body: Node) -> void:
	var match_root := _find_match_root()
	if match_root != null and match_root.is_match_cinematic_frozen():
		return
	if not body.has_method("collect_pickup"):
		return
	body.collect_pickup(pickup_type)
	_hide_then_respawn()


func _hide_then_respawn() -> void:
	visible = false
	monitoring = false
	collision_shape.set_deferred("disabled", true)
	await get_tree().create_timer(respawn_time).timeout
	visible = true
	monitoring = true
	collision_shape.disabled = false


func _update_visuals() -> void:
	match pickup_type:
		"famas":
			label.text = "FR"
			body_visual.color = Color(0.2, 0.62, 1.0, 1.0)
			icon.polygon = PackedVector2Array([Vector2(-11, -4), Vector2(6, -4), Vector2(14, 1), Vector2(-2, 3), Vector2(-2, 8), Vector2(-8, 8), Vector2(-8, 3), Vector2(-11, 3)])
		"ak":
			label.text = "RU"
			body_visual.color = Color(0.95, 0.22, 0.18, 1.0)
			icon.polygon = PackedVector2Array([Vector2(-12, -3), Vector2(8, -5), Vector2(13, -1), Vector2(-4, 3), Vector2(-6, 8), Vector2(-11, 8), Vector2(-9, 3), Vector2(-12, 2)])
		"rapid":
			label.text = "RF"
			body_visual.color = Color(1.0, 0.78, 0.18, 1.0)
			icon.polygon = PackedVector2Array([Vector2(-12, 0), Vector2(-2, -9), Vector2(-4, -2), Vector2(12, -2), Vector2(0, 9), Vector2(3, 2)])
		"jump_boost":
			label.text = "J+"
			body_visual.color = Color(0.35, 1.0, 0.62, 1.0)
			icon.polygon = PackedVector2Array([Vector2(-11, 6), Vector2(-4, -7), Vector2(0, -2), Vector2(5, -12), Vector2(12, 1), Vector2(6, -2), Vector2(2, 8), Vector2(-2, 1)])
		"medkit":
			label.text = "+"
			body_visual.color = Color(1.0, 1.0, 1.0, 1.0)
			icon.polygon = PackedVector2Array([Vector2(-4, -11), Vector2(4, -11), Vector2(4, -4), Vector2(11, -4), Vector2(11, 4), Vector2(4, 4), Vector2(4, 11), Vector2(-4, 11), Vector2(-4, 4), Vector2(-11, 4), Vector2(-11, -4), Vector2(-4, -4)])


func _find_match_root() -> Node:
	var node := get_parent()
	while node != null:
		if node.has_method("is_match_cinematic_frozen"):
			return node
		node = node.get_parent()
	return null
