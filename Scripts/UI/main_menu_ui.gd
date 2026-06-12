extends Control


func _on_new_game_button_pressed() -> void:
  SceneManager.load_scene(SceneManager.scenes.GAMEPLAY)

func _on_exit_button_pressed() -> void:
  get_tree().quit()
