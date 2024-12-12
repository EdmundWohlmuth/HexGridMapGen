extends Camera3D

@export var move_speed:float
@export var zoom_speed:float
@export var max_zoom:float
@export var min_zoom:float

var current_move_speed:float
var interact_dist:int = 1000

var test:String = "Terra Nova"

signal hex_clicked()
signal clicked_off

func _ready():
  hex_clicked.connect(UiManager.in_game_ui.display_hex_data)
  clicked_off.connect(UiManager.in_game_ui.hide_hex_data)
  
  current_move_speed = move_speed

func _process(delta):
  if Input.is_action_pressed("CamUp"): position += Vector3.MODEL_REAR * current_move_speed * delta
  if Input.is_action_pressed("CamLeft"): position += Vector3.MODEL_RIGHT * current_move_speed * delta
  if Input.is_action_pressed("CamDown"): position += Vector3.MODEL_FRONT * current_move_speed * delta
  if Input.is_action_pressed("CamRight"): position += Vector3.MODEL_LEFT * current_move_speed * delta
  
  if Input.is_action_just_pressed("CamFast"): current_move_speed *= 2
  if Input.is_action_just_released("CamFast"): current_move_speed = move_speed
  
  if Input.is_action_just_released("ZoomIn"): position += Vector3.MODEL_BOTTOM * zoom_speed * delta
  if Input.is_action_just_released("ZoomOut"): position += Vector3.MODEL_TOP * zoom_speed * delta
  
  if Input.is_action_just_pressed("LeftClick"): shoot_ray()
  
func shoot_ray():
  var worldspace = get_world_3d().direct_space_state
  var start = project_ray_origin(get_viewport().get_mouse_position())
  var end = project_position(get_viewport().get_mouse_position(), interact_dist)
  var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
  var final_result
  if result != {}: final_result = result.collider.get_parent()
  
  if final_result != null:
    emit_signal("hex_clicked", test, WorldManager.biomes.find_key(final_result.hex_biome), final_result.hex_latitude, final_result.hex_temperature, final_result.annual_percipitation)
  else: emit_signal("clicked_off")
  


 
  
  
