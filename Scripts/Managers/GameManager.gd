extends Node

enum gamestates {
  GAMEPLAY,
  PAUSED,
  MENUS,
  WORLD_BUILDING
}
var current_state:gamestates = gamestates.MENUS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func set_game_state(state:gamestates):
  var last_state:gamestates = current_state
  
  match state:
    gamestates.GAMEPLAY:
      current_state = gamestates.GAMEPLAY
      SignalManager.emit_signal("_load_gameplay_ui")
    gamestates.MENUS: 
      current_state = gamestates.MENUS
      SignalManager.emit_signal("_load_main_menu_ui")
    gamestates.WORLD_BUILDING: 
      current_state = gamestates.WORLD_BUILDING
