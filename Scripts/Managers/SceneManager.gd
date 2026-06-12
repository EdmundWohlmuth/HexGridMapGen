extends Node

@export var minimum_load_time:float = 2.5

var current_scene:Node3D

enum scenes {
  MAIN_MENU,
  GAMEPLAY
}

const MAIN_MENU_PATH:StringName = "res://Scenes/UI/3dScenes/main_menu.tscn"
const GAMEPLAY_PATH:StringName = "res://Scenes/Terrain/map.tscn"

var is_loading:bool = false
var path:StringName

func _ready() -> void:
  process_mode = Node.PROCESS_MODE_ALWAYS
  
func load_scene(scene:scenes):
  # get the scene's path to load
  #var scene_to_load 
  
  match scene:
    scenes.MAIN_MENU: path = MAIN_MENU_PATH
    scenes.GAMEPLAY: path = GAMEPLAY_PATH

  # Call the loading Screen to fade in
  SignalManager.emit_signal("_load_fade_in")
  # Remove the Current Scene
  get_parent().remove_child(current_scene)
  current_scene.queue_free()
  # Async Load the next Scene
  ResourceLoader.load_threaded_request(path)
  is_loading = true

# Using _process to check if we are loading something and if we are finished loading something
func _process(_delta: float) -> void:
  if is_loading:
    if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
      current_scene = ResourceLoader.load_threaded_get(path).instantiate()
      await get_tree().create_timer(minimum_load_time).timeout
      get_parent().add_child(current_scene)
      SignalManager.emit_signal("_load_fade_out")
      is_loading = false
      # emit correct signal
      match path:
        MAIN_MENU_PATH:
          GameManager.current_state = GameManager.gamestates.MENUS
          GameManager.set_game_state(GameManager.gamestates.MENUS)
        GAMEPLAY_PATH:
          GameManager.current_state = GameManager.gamestates.GAMEPLAY
          GameManager.set_game_state(GameManager.gamestates.GAMEPLAY)
