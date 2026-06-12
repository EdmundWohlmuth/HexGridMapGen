extends Control

@onready var biomes_v_box: VBoxContainer = $Panel/BiomesVBox
@onready var options_v_box: VBoxContainer = $Panel/OptionsVBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func _on_tab_bar_tab_clicked(tab: int) -> void:
  match tab:
    0:
      biomes_v_box.visible = true
      options_v_box.visible = false
    3:
      biomes_v_box.visible = false
      options_v_box.visible = true
