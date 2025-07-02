extends Node3D
class_name terrain_hex

@onready var hex_mesh = $HexMesh
var cord:Vector2

var annual_percipitation:float
var average_annual_temp:float
var is_land:bool
var continent_id:int

var hex_biome:WorldManager.biomes
var hex_features:Array[WorldManager.terrain_features]
var hex_temperature:float
var hex_latitude:float
var is_north:bool

func set_biome(biome:WorldManager.biomes):
  if biome == hex_biome: return
  if hex_mesh == null: return
  match biome:
    WorldManager.biomes.GRASSLAND:
      hex_mesh.material_override = WorldManager.GRASSLAND
      is_land = true
    WorldManager.biomes.BOREAL_FOREST:
      hex_mesh.material_override = WorldManager.BOREAL_FOREST
      is_land = true
    WorldManager.biomes.DESERT:
      hex_mesh.material_override = WorldManager.DESERT
      is_land = true
    WorldManager.biomes.RAINFOREST:
      hex_mesh.material_override = WorldManager.RAIN_FOREST
      is_land = true
    WorldManager.biomes.SAVANNA:
      hex_mesh.material_override = WorldManager.SAVANNA
      is_land = true
    WorldManager.biomes.SHRUBLAND:
      hex_mesh.material_override = WorldManager.SHRUBLAND
      is_land = true
    WorldManager.biomes.SEASONAL_FOREST:
      hex_mesh.material_override = WorldManager.SEASONAL_FOREST
      is_land = true
    WorldManager.biomes.TEMPERATE_RAINFOREST:
      hex_mesh.material_override = WorldManager.TEMPERATE_RAINFOREST
      is_land = true
    WorldManager.biomes.SALT_WATER_LITTORAL:
      hex_mesh.material_override = WorldManager.SALT_LITTORAL
      is_land = false
    WorldManager.biomes.OPEN_OCEAN:
      hex_mesh.material_override = WorldManager.OPEN_OCEAN
      is_land = false
    
  hex_biome = biome
