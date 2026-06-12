extends Control

@onready var in_game_ui:Control = $InGame_UI
@onready var main_menu_ui:Control = $Main_Menu_UI
@onready var loading_screen:Control = $loading_screen

func _ready() -> void:
  SignalManager.connect("_load_gameplay_ui", set_gameplay)
  SignalManager.connect("_load_main_menu_ui", set_main_menu)

func set_gameplay():
  main_menu_ui.visible = false
  in_game_ui.visible = true

func set_main_menu():
  main_menu_ui.visible = true
  in_game_ui.visible = false
