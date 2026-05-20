extends AudioStreamPlayer

const BACKGROUND_MUSIC := preload("res://assets/music/funny_bit.mp3")
const DEFAULT_VOLUME_DB := -8.0


func _ready() -> void:
	stream = BACKGROUND_MUSIC
	volume_db = DEFAULT_VOLUME_DB

	if stream is AudioStreamMP3:
		stream.loop = true

	if not playing:
		play()
