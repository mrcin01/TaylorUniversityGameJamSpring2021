extends Node2D

onready var music : AudioStreamPlayer2D = get_node("Music")


func _ready():
	music.playing = true

func _on_ResetButton_pressed():
	get_tree().reload_current_scene()


func _on_BackToMenuButton_pressed():
	music.playing = false
	get_tree().change_scene("res://Main-Menu.tscn")


func _process(delta):
	if self.get_node("CanvasLayer/ResetButton").visible and Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	if self.get_node("CanvasLayer/BackToMenuButton").visible and Input.is_action_pressed("menu"):
		get_tree().change_scene("res://Main-Menu.tscn")
