extends Control

@onready var base_gen_options_holder: Control = $BaseGenOptionsHolder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


func _on_tab_bar_tab_clicked(tab: int) -> void:
  match tab:
    0: base_gen_options_holder.visible = true
