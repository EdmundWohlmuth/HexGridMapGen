extends Control

@onready var base_gen_options_holder: Control = $BaseGenOptionsHolder

@onready var base_box_container: VBoxContainer = $BaseGenOptionsHolder/VBoxContainer
@onready var climate_box_container: VBoxContainer = $BaseGenOptionsHolder/ClimateBoxContainer
@onready var oceans_box_container: VBoxContainer = $BaseGenOptionsHolder/OceansBoxContainer
@onready var world_box_container: VBoxContainer = $BaseGenOptionsHolder/WorldBoxContainer


@onready var rand_check_button: CheckButton = $BaseGenOptionsHolder/VBoxContainer/RandCheckButton
@onready var seed_text_edit: TextEdit = $BaseGenOptionsHolder/VBoxContainer/SeedTextEdit

@onready var rand_box_container: VBoxContainer = $BaseGenOptionsHolder/RandVBoxContainer
@onready var noise_box_container: VBoxContainer = $BaseGenOptionsHolder/NoiseVBoxContainer


@onready var h_slider: HSlider = $BaseGenOptionsHolder/VBoxContainer/HSlider
@onready var size_label: Label = $BaseGenOptionsHolder/VBoxContainer/SizeLabel

@onready var passes_h_slider_2: HSlider = $BaseGenOptionsHolder/VBoxContainer/PassesHSlider2
@onready var passes_num_label: Label = $BaseGenOptionsHolder/VBoxContainer/PassesNumLabel

@onready var weight_h_slider: HSlider = $BaseGenOptionsHolder/VBoxContainer/WeightHSlider
@onready var weight_num_label: Label = $BaseGenOptionsHolder/VBoxContainer/WeightNumLabel

@onready var climate_pass_num_label: Label = $BaseGenOptionsHolder/ClimateBoxContainer/ClimatePassNumLabel
@onready var climate_pass_slider: HSlider = $BaseGenOptionsHolder/ClimateBoxContainer/ClimatePassSlider

@onready var sea_levels_label: Label = $BaseGenOptionsHolder/OceansBoxContainer/SeaLevelsLabel
@onready var sea_ratio_label: Label = $BaseGenOptionsHolder/OceansBoxContainer/SeaRatioLabel
@onready var sea_level_slider: HSlider = $BaseGenOptionsHolder/OceansBoxContainer/SeaLevelsLabel/SeaLevelSlider
@onready var sea_ratio_slider: HSlider = $BaseGenOptionsHolder/OceansBoxContainer/SeaRatioLabel/SeaRatioSlider


var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  size_label.text = str(h_slider.value)
  WorldManager.size = h_slider.value
  
  passes_num_label.text =  "Passes: " + str(passes_h_slider_2.value)
  WorldManager.gen_passes = passes_h_slider_2.value
  
  weight_num_label.text =  "Weight: " + str(weight_h_slider.value)
  WorldManager.gen_weight = weight_h_slider.value
  
  WorldManager.seed = rng.randi()
  
  climate_pass_num_label.text =  "Passes: " + str(climate_pass_slider.value)
  WorldManager.climate_passes = climate_pass_slider.value
  
  WorldManager.sea_level = sea_level_slider.value
  WorldManager.inital_land_ratio = sea_ratio_slider.value

## TAB BAR IS SELECTED
func _on_tab_bar_tab_clicked(tab: int) -> void:
  match tab:
    0: 
      base_box_container.visible = true
      climate_box_container.visible = false
      oceans_box_container.visible = false
      world_box_container.visible = false
    1: 
      base_box_container.visible = false
      climate_box_container.visible = true
      oceans_box_container.visible = false
      world_box_container.visible = false
    2: 
      base_box_container.visible = false
      climate_box_container.visible = false
      oceans_box_container.visible = true
      world_box_container.visible = false
    3: 
      base_box_container.visible = false
      climate_box_container.visible = false
      oceans_box_container.visible = false
      world_box_container.visible = true

## CHOOSING RANDOM SEEDS
func _on_rand_check_button_toggled(toggled_on: bool) -> void:
  if !toggled_on: 
    seed_text_edit.visible = true
    seed_text_edit.text = str(WorldManager.seed)
  else: 
    seed_text_edit.visible = false
    WorldManager.seed = rng.randi()

## LOADS SCENE AND GENERATES WORLD BASED ON CHOSEN PARAMETERS
func _on_generate_button_pressed() -> void:
  SceneManager.load_scene(SceneManager.scenes.GAMEPLAY)

## SELECTING WORLD SIZE
func _on_h_slider_value_changed(value: float) -> void:
  size_label.text = str(value)
  if value < 64: size_label.text += " (SMALL)"
  elif value >= 240: size_label.text += " (WARNING VERY LARGE)"
  elif value >= 128: size_label.text += " (LARGE)"
  else: size_label.text = str(value)
  WorldManager.size = value

## SELECTING GEN TYPE - REVEALS GEN SPECIFIC OPTIONS
func _on_gen_option_button_item_selected(index: int) -> void:
  match index:
    0: 
      WorldManager.gen_type = WorldManager.gen_types.random
      sea_levels_label.visible = false
      sea_ratio_label.visible = true
    1: 
      WorldManager.gen_type = WorldManager.gen_types.noise_gen
      sea_levels_label.visible = true
      sea_ratio_label.visible = false
      


func _on_passes_h_slider_2_value_changed(value: float) -> void:
  passes_num_label.text = "Passes: " + str(value)
  WorldManager.gen_passes = value

func _on_weight_h_slider_value_changed(value: float) -> void:
  weight_num_label.text = "Weight: " + str(value)
  WorldManager.gen_weight = value

func _on_climate_pass_slider_value_changed(value: float) -> void:
  climate_pass_num_label.text = str(value)
  WorldManager.climate_passes = value


func _on_sea_level_slider_value_changed(value: float) -> void:
  WorldManager.sea_level = sea_level_slider.value

func _on_sea_ratio_slider_value_changed(value: float) -> void:
  WorldManager.inital_land_ratio = sea_ratio_slider.value
