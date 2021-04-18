extends Area2D

onready var sprite : AnimatedSprite = get_node("AnimatedSprite")


func _on_SwordPlayer_level_exit():
	sprite.playing = true
