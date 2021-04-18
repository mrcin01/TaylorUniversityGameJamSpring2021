extends Node2D

onready var startButton : TextureButton = get_node("Start")
onready var exitButton : TextureButton = get_node("Exit")
onready var level1Button : TextureButton = get_node("Level1")
onready var level2Button : TextureButton = get_node("Level2")
onready var backButton : TextureButton = get_node("BackToMain")
onready var music : AudioStreamPlayer2D = get_node("Music")


func _ready():
	music.playing = true

func _on_Start_pressed():
	startButton.visible = false
	exitButton.visible = false
	level1Button.visible = true
	level2Button.visible = true
	backButton.visible = true


func _on_Exit_pressed():
	music.playing = false
	get_tree().quit()


func _on_Level1_pressed():
	music.playing = false
	get_tree().change_scene("res://Level1.tscn")


func _on_BackToMain_pressed():
	startButton.visible = true
	exitButton.visible = true
	level1Button.visible = false
	level2Button.visible = false
	backButton.visible = false


func _on_Level2_pressed():
	music.playing = false
	get_tree().change_scene("res://Level2.tscn")
