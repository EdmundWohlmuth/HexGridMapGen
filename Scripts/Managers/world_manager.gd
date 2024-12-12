extends Node

## === LAND MATS === ##
const GRASSLAND = preload("res://Assets/Materials/Temperate_Grassland.tres")
const BOREAL_FOREST = preload("res://Assets/Materials/Boreal_Forest.tres")
const DESERT = preload("res://Assets/Materials/Desert.tres")
const SHRUBLAND = preload("res://Assets/Materials/Shrubland.tres")
const SEASONAL_FOREST = preload("res://Assets/Materials/Grass_Mat.tres")
const RAIN_FOREST = preload("res://Assets/Materials/RainForest.tres")
const SAVANNA = preload("res://Assets/Materials/Savanna.tres")
const TEMPERATE_GRASSLAND = preload("res://Assets/Materials/Temperate_Grassland.tres")
const TEMPERATE_RAINFOREST = preload("res://Assets/Materials/Temperate_Rainforest.tres")
const TUNDRA = preload("res://Assets/Materials/Tundra.tres")
## === WATER MATS === ##
const SALT_LITTORAL = preload("res://Assets/Materials/Shallow_Water.tres")
const OPEN_OCEAN = preload("res://Assets/Materials/DEEP_WATERtres.tres")
## === FEATURE MATS === ##
const MOUNTAIN = preload("res://Assets/Materials/Feature_Mats/Mountain.tres")

enum terrain_features
{
  FORESTED,         # Multually exclusive with: RANGELANDS, CROPLANDS, DENSE SETTLEMENT
  NAVIGABLE_RIVER,  # Multually exclusive with: HILLS, MOUNTAINS
  HILLS,            # Multually exclusive with: NAVIGABLE RIVER, CROPLANDS, DENSE SETTLEMENT, MOUNTAINS
  MOUNTAINS,        # Multually exclusive with: NAVIGABLE RIVER, CROPLANDS, DENSE SETTLEMENT, HILLS, RANGELANDS
  RANGELANDS,       # Multually exclusive with: FORESTED, CROPLANDS, DENSE SETTLEMENT, MOUNTAINS
  CROPLANDS,        # Multually exclusive with: FORESTED, RANGELANDS, DENSE SETTLEMENT, HILLS, MOUNTAINS
  DENSE_SETTLEMENTS # Multually exclusive with: FORESTED, CROPLANDS, RANGELANDS, MOUNTAINS
}
enum biomes
{
  TUNDRA,
  BOREAL_FOREST,
  SHRUBLAND,
  GRASSLAND,
  SEASONAL_FOREST,
  TEMPERATE_RAINFOREST,
  DESERT,
  SAVANNA,
  RAINFOREST,
  SALT_WATER_LITTORAL,
  FRESH_WATER_LITTORAL,
  OPEN_OCEAN,
  ICE
}
