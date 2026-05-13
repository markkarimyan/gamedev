extends Area2D

const FIRE_RATE_ICON := preload("res://assets/pickups/fire_rate_boost.png")
const JUMP_BOOST_ICON := preload("res://assets/pickups/jump_boost.png")
const DAMAGE_BOOST_ICON := preload("res://assets/pickups/damage_boost.png")
const MEDKIT_ICON := preload("res://assets/pickups/medkit.png")

@export_enum("rapid", "jump_boost", "medkit", "damage_boost") var pickup_type := "rapid"
@export var respawn_time := 9.0

@onready var label: Label = %Label
@onready var body_visual: Polygon2D = %BodyVisual
@onready var top_line: Polygon2D = $TopLine
@onready var shine: Polygon2D = $Shine
@onready var icon_back: Polygon2D = $IconBack
@onready var icon: Polygon2D = %Icon
@onready var icon_texture: Sprite2D = %IconTexture
@onready var icon_parts: Node2D = %IconParts
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
	icon.visible = false
	icon_texture.visible = false
	icon_texture.texture = null
	label.visible = true
	_set_card_visible(true)
	_clear_icon_parts()
	match pickup_type:
		"rapid":
			label.text = "RF"
			body_visual.color = Color(1.0, 0.78, 0.18, 1.0)
			_use_texture_icon(FIRE_RATE_ICON)
		"jump_boost":
			label.text = "J+"
			body_visual.color = Color(0.35, 1.0, 0.62, 1.0)
			_use_texture_icon(JUMP_BOOST_ICON)
		"medkit":
			label.text = "+"
			body_visual.color = Color(1.0, 1.0, 1.0, 1.0)
			_use_texture_icon(MEDKIT_ICON)
		"damage_boost":
			label.text = "DMG"
			body_visual.color = Color(1.0, 0.2, 0.08, 1.0)
			_use_texture_icon(DAMAGE_BOOST_ICON)


func _clear_icon_parts() -> void:
	for child in icon_parts.get_children():
		child.queue_free()


func _use_texture_icon(texture: Texture2D) -> void:
	label.visible = false
	_set_card_visible(false)
	icon_texture.texture = texture
	icon_texture.visible = true


func _set_card_visible(is_visible: bool) -> void:
	body_visual.visible = is_visible
	top_line.visible = is_visible
	shine.visible = is_visible
	icon_back.visible = is_visible


func _find_match_root() -> Node:
	var node := get_parent()
	while node != null:
		if node.has_method("is_match_cinematic_frozen"):
			return node
		node = node.get_parent()
	return null
