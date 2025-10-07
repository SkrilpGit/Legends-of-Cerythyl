extends Control

@export var PlayScene: PackedScene
@export var OptionsScene: PackedScene
@export var CreditsScene: PackedScene


func _on_play_button_pressed() -> void:
	if PlayScene == null:
		return
	get_tree().change_scene_to_packed(PlayScene)


func _on_options_button_pressed() -> void:
	if OptionsScene == null:
		return
	get_tree().change_scene_to_packed(OptionsScene)


func _on_credits_button_pressed() -> void:
	if CreditsScene == null:
		return
	get_tree().change_scene_to_packed(CreditsScene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
