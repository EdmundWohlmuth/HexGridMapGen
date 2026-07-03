extends Control


func _on_new_game_button_pressed() -> void:
  UiManager.set_world_gen()

func _on_exit_button_pressed() -> void:
  get_tree().quit()
