extends Node3D
class_name terrain_hex

@onready var hex_mesh = $HexMesh

@onready var hills_mesh: Node3D = $HillsMesh
@onready var mountains_mesh: Node3D = $MountainsMesh

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
var hex_mat:Material


enum wind_dir
{
  WEST,
  EAST,
  NORTH_WEST,
  NORTH_EAST,
  SOUTH_WEST,
  SOUTH_EAST
}
var current_wind_dir:wind_dir

## sets the hex's biome to the passed biome
func set_biome(biome:WorldManager.biomes):
  if biome == hex_biome: return
  if hex_mesh == null: return
  match biome:
    WorldManager.biomes.GRASSLAND:
      hex_mesh.material_override = WorldManager.GRASSLAND
      hex_mat = WorldManager.GRASSLAND
      is_land = true
    WorldManager.biomes.BOREAL_FOREST:
      hex_mesh.material_override = WorldManager.BOREAL_FOREST
      hex_mat = WorldManager.BOREAL_FOREST
      is_land = true
    WorldManager.biomes.DESERT:
      hex_mesh.material_override = WorldManager.DESERT
      hex_mat = WorldManager.DESERT
      is_land = true
    WorldManager.biomes.RAINFOREST:
      hex_mesh.material_override = WorldManager.RAIN_FOREST
      hex_mat = WorldManager.RAIN_FOREST
      is_land = true
    WorldManager.biomes.SAVANNA:
      hex_mesh.material_override = WorldManager.SAVANNA
      hex_mat = WorldManager.SAVANNA
      is_land = true
    WorldManager.biomes.SHRUBLAND:
      hex_mesh.material_override = WorldManager.SHRUBLAND
      hex_mat = WorldManager.SHRUBLAND
      is_land = true
    WorldManager.biomes.SEASONAL_FOREST:
      hex_mesh.material_override = WorldManager.SEASONAL_FOREST
      hex_mat = WorldManager.SEASONAL_FOREST
      is_land = true
    WorldManager.biomes.TEMPERATE_RAINFOREST:
      hex_mesh.material_override = WorldManager.TEMPERATE_RAINFOREST
      is_land = true
      hex_mat = WorldManager.TEMPERATE_RAINFOREST
    WorldManager.biomes.SALT_WATER_LITTORAL:
      hex_mesh.material_override = WorldManager.SALT_LITTORAL
      is_land = false
      hex_mat = WorldManager.SALT_LITTORAL
    WorldManager.biomes.OPEN_OCEAN:
      hex_mesh.material_override = WorldManager.OPEN_OCEAN
      is_land = false
      hex_mat = WorldManager.OPEN_OCEAN
    WorldManager.biomes.ICE:
      hex_mesh.material_override = WorldManager.ICE
      hex_mat = WorldManager.ICE
    WorldManager.biomes.TUNDRA:
      hex_mesh.material_override = WorldManager.TUNDRA
      hex_mat = WorldManager.TUNDRA
    
  hex_biome = biome

## Adds the passed terrain_feature to the hex
func set_feature(feature:WorldManager.terrain_features):
  match feature:
    WorldManager.terrain_features.HILLS: 
      hills_mesh.visible = true
      hills_mesh.rotation.y = randi_range(0, 360)
      hex_features.append(WorldManager.terrain_features.HILLS)
      
      for x in hills_mesh.get_children():
        x.material_override = hex_mat
        
    WorldManager.terrain_features.MOUNTAINS: 
      mountains_mesh.visible = true
      hex_features.append(WorldManager.terrain_features.MOUNTAINS)
    
