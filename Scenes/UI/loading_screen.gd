extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

@export var fade_time_in:float
@export var fade_time_out:float
@export var fade_to_color:Color
@export var fade_from_color:Color

func _ready() -> void:
  SignalManager.connect("_load_fade_in", fade_in)
  SignalManager.connect("_load_fade_out", fade_out)
  process_mode = Node.PROCESS_MODE_ALWAYS

func fade_in():
  var color_tween = get_tree().create_tween()
  var text_tween = get_tree().create_tween()
  
  color_tween.tween_property(color_rect, "color", fade_to_color, fade_time_in)
  text_tween.tween_property(label, "modulate", Color.WHITE, fade_time_in)

func fade_out():
  var color_tween = get_tree().create_tween()
  var text_tween = get_tree().create_tween()
  
  color_tween.tween_property(color_rect, "color", fade_from_color, fade_time_out)
  text_tween.tween_property(label, "modulate", Color.TRANSPARENT, fade_time_out)
