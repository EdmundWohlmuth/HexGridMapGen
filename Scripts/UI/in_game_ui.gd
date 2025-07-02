extends Control

@onready var panel = $Panel

@onready var province_name_label = $Panel/ProvinceNameLabel
@onready var biome_label = $Panel/BiomeLabel
@onready var latitude_label = $Panel/LatitudeLabel
@onready var temperature_label = $Panel/TemperatureLabel
@onready var precipitation_label = $Panel/PrecipitationLabel
@onready var continent_label = $Panel/ContinentLabel

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  pass
  
func display_hex_data(_name:String, _biome:String, _latitude:float, _temperature:float, _precip:float, _id:int):
  panel.visible = true
  province_name_label.text = "Terra Nova"
  biome_label.text = "Biome: " + _biome
  
  if _latitude < 0: latitude_label.text = "Latitude: " + str(_latitude * -1) + " S"
  elif _latitude == 0: latitude_label.text = "Latitude: " + str(_latitude)
  else: latitude_label.text = "Latitude: " + str(_latitude) + " N"

  temperature_label.text = "Temp: " + str(_temperature) + " C"
  precipitation_label.text = "Precipitation: " + str(_precip) + " mm"
  continent_label.text = "ID: " + str(_id)

func hide_hex_data():
  panel.visible = false
