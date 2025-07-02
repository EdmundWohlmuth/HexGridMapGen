extends Node3D

const TERRAIN_HEX = preload("res://Scenes/Terrain/terrain_hex.tscn")
const HEX_WIDTH:float = 2 # sqrt(3) * 1 (hex radius)
const HEX_HEIGHT:float = 1.73205080757 # 2 * 1 (hex radius)

@export var world_size:int
@export var terrain_array:Array[Array]
@export var gen_passes:int
@export var gen_weight:int
@export var large_continents_num:int
@export var small_continents_num:int
@export var inital_land_ratio:int
@export var _seed:int
@export var is_rand:bool

@export var continents_list:Array[Array]

enum gen_types
{
  random,
  continents
}
@export var gen_type:gen_types

var rng = RandomNumberGenerator.new()
var total_continents:int

var world_x:int
var world_y:int

@onready var camera = $Camera3D

func _ready():
  terrain_array = []
  
  if is_rand: 
    _seed = rng.randi()
  else: _seed = _seed
  seed(_seed)
  print("seed = " + str(_seed))
  
  generate_map()
  
  match gen_type:
    gen_types.random:
      random_fill_land()
    gen_types.continents:
      pass
  
  if gen_passes > 0 && gen_type == gen_types.random:
    for p in gen_passes:
      generate_continents_pass(p)
    generate_latitude_pass()
    generate_biome_pass()
    generate_climate_pass()

func generate_map():
  world_x = world_size
  world_y = roundi(world_size / 2)
  
  for x in world_x:
    terrain_array.append([])     
  
  var x_offset:int = 0
  print("map size: " + str(world_x) + " x " + str(world_y))
  
  var actual_x = (world_y / 2) * -1
  var actual_z = actual_x
  
  ## === GENERATE MAP === ##
  for y in world_y:
    
    if y % 2 == 0: 
      x_offset = 0
    elif y % 2 != 0: 
      x_offset = -1
      
    actual_x = world_y * -1
    actual_z += HEX_HEIGHT   
    
    for x in world_x:
      
      actual_x += HEX_WIDTH
      var hex:terrain_hex = TERRAIN_HEX.instantiate()
      hex.name = "hex " + str(world_x) + ", " + str(world_y)
      hex.position = Vector3(actual_x + x_offset, 0, actual_z)
      $TerrainHolder.add_child(hex)
      terrain_array[x].append(hex)
      hex.cord = Vector2(x, y)
      

  ## ============================================================= ##     

# randomly sets terrain hexes to be either land or water
func random_fill_land():
  for y in world_y:
    for x in world_x:
      var hex = terrain_array[x][y]
      if randi_range(0, 100) >= inital_land_ratio: 
        hex.set_biome(WorldManager.biomes.GRASSLAND)
      else: 
        hex.set_biome(WorldManager.biomes.OPEN_OCEAN)
 

# Smooths out the terrain generation by looking for nearby terrains to fill out the map
func generate_continents_pass(_pass:int): # LOOK INTO - can probably be multi-purpose
  var temp_array:Array[Array]
  
  for y in terrain_array.size():
    temp_array.append([])
    for x in terrain_array[y].size():
     
      print(str(terrain_array.size()) + " x " + str(terrain_array[y].size()))
    
      var neighbors:Array = get_neighbor_array(Vector2(x, y))
      var neighbor_count:int = 0
      var biome_to_smooth:Array[WorldManager.biomes] = [0, 0]
      
      if (_pass % 2 == 0): 
        biome_to_smooth[0] = WorldManager.biomes.GRASSLAND
        biome_to_smooth[1] = WorldManager.biomes.OPEN_OCEAN
      else: 
        biome_to_smooth[0] = WorldManager.biomes.OPEN_OCEAN
        biome_to_smooth[1] = WorldManager.biomes.GRASSLAND
      
      for n:terrain_hex in neighbors:
        if n.hex_biome == biome_to_smooth[0]: neighbor_count += 1
      
      if neighbor_count > gen_weight: temp_array[y].append(biome_to_smooth[0])
      else: temp_array[y].append(biome_to_smooth[1])

  for a in temp_array.size():
    for b in temp_array[a].size():
      terrain_array[a][b].set_biome(temp_array[a][b])
 
# Sets any deep water hex that borders a land hex to a littoral_salt_water biome     
func coastline_pass():
  var temp_array:Array[Array]
  
  for y in terrain_array.size():
    temp_array.append([])
    for x in terrain_array[y].size():
      var neighbors = get_neighbor_array(Vector2(y, x))
      var neighbor_count:int = 0
      
      for n:terrain_hex in neighbors:
        if n.hex_biome == WorldManager.biomes.GRASSLAND: neighbor_count += 1
        elif world_size >= 64 && (n.hex_biome == WorldManager.biomes.GRASSLAND || n.hex_biome == WorldManager.biomes.SALT_WATER_LITTORAL):
          neighbor_count += 1
 
# generates hex climates based on latitude     
func generate_latitude_pass():
  var total_latitude:float = 180 # 180 degrees from 90N to -90S
  var latitude_step:float = total_latitude / world_y
  var current_latitude:float = 90 # 90 degrees for 90N
  var current_temperature:float = -24
  var northern_temp_step:float = 0.7 * (latitude_step)
  var southern_temp_step:float = 0.5 * (latitude_step)
  
  for y in world_y:
    current_latitude -= latitude_step
    for x in world_x:
      terrain_array[x][y].hex_latitude = current_latitude
      if terrain_array[x][y].hex_latitude > 0:
        if terrain_array[x][y].hex_latitude >= terrain_array[x - 1][y].hex_latitude + 1:
          current_temperature += northern_temp_step
      else:
        if terrain_array[x][y].hex_latitude <= terrain_array[x - 1][y].hex_latitude - 1:
          current_temperature -= southern_temp_step
          
      terrain_array[x][y].hex_temperature = current_temperature
      terrain_array[x][y].average_annual_temp = current_temperature
      
      if terrain_array[x][y].is_land: terrain_array[x][y].annual_percipitation = 700
      else: terrain_array[x][y].annual_percipitation = 900

func generate_climate_pass():
  var neighbors:Array[terrain_hex]
  var ave_temp:float = 0
  var neighbor_temps:Array[float]
  
  for y in world_y:
    # get neighbors
    for x in world_x: 
      neighbors = get_prevailing_wind_hexes(Vector2(x, y))
      
      # get average temperature
      for n in neighbors:
        neighbor_temps.append(terrain_array[x][y].average_annual_temp)
      for a in neighbor_temps:
        ave_temp += a 
      ave_temp /= neighbor_temps.size()
    
    

# checks the bottom right or top left hexes of given coord depending on prevailing winds
func get_prevailing_wind_hexes(coord:Vector2) -> Array[terrain_hex]: # this whole this is kinda gross
  # easterlies == less precipitation, westerlies == more precipitation

  var temp_hex_array:Array[terrain_hex]
  var lat = terrain_array[coord.x][coord.y].hex_latitude
  
  # check latitude to determine which direction to check
  if lat >= 60: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [6,5,4])
  elif lat >= 30: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [1,2,3])
  elif lat >= 0: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [6,5,4])
  elif lat >= -30: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [2,3,4])
  elif lat >= -60: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [1,6,5])
  else: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [2,3,4])

  return temp_hex_array

func generate_biome_pass():
  for y in world_y:
    for x in world_x:
      var temp = terrain_array[x][y].average_annual_temp
      if terrain_array[x][y].is_land != false:
        if temp > 30:
          terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
        elif temp > 21:
          terrain_array[x][y].set_biome(WorldManager.biomes.RAINFOREST)
        elif temp > 8:
          terrain_array[x][y].set_biome(WorldManager.biomes.SEASONAL_FOREST)
        elif temp >= 0:
          terrain_array[x][y].set_biome(WorldManager.biomes.BOREAL_FOREST)
        elif temp < 0:
          terrain_array[x][y].set_biome(WorldManager.biomes.TUNDRA)
      else:
        var neighbors = get_neighbor_array(Vector2(x, y))
        var neighbor_count:int = 0
        for n in neighbors:
          if n.is_land:
            terrain_array[x][y].set_biome(WorldManager.biomes.SALT_WATER_LITTORAL)
            break

func hadley_cell_pass(coord:Vector2):
  pass

# Gets a count of the number of neighboring hexes for the choosen hex
func get_neighbor_array(coord:Vector2, to_check:Array = [1, 2, 3, 4, 5, 6]) -> Array[terrain_hex]:
  var temp_hex_array:Array[terrain_hex]
  # digits in the array represent sides of the hex, starting from the left working counter-clockwise
  # 1 == left, 2 == bottom left, 3 == bottom right, 4 == right, 5 == top right, 6 == top left
  
  # ---HORIZONTAL NEIGHBORS---------
  # elif(s) check for map wrapping
  if !coord.x - 1 < 0 && to_check.has(1): temp_hex_array.append(terrain_array[coord.x - 1][coord.y])
  elif coord.x - 1 < 0 && to_check.has(1): temp_hex_array.append(terrain_array[world_x - 1][coord.y])
  if !coord.x + 1 > world_x - 1 && to_check.has(4): temp_hex_array.append(terrain_array[coord.x + 1][coord.y])
  elif coord.x + 1 > world_x - 1 && to_check.has(4): temp_hex_array.append(terrain_array[0][coord.y])
  # ---VERTICAL NEIGHBORS----------- 
  # check if row is offset or not to account for adjecency
  if int(coord.y) % 2 == 0:
    if !coord.x < 0 && !coord.y - 1 < 0 && to_check.has(6): temp_hex_array.append(terrain_array[coord.x][coord.y - 1])
    
    if !coord.x + 1 > world_x - 1 && !coord.y - 1 < 0 && to_check.has(5): temp_hex_array.append(terrain_array[coord.x + 1][coord.y - 1])
    elif coord.x + 1 > world_x - 1 && !coord.y - 1 < 0 && to_check.has(5): temp_hex_array.append(terrain_array[0][coord.y - 1])
    
    if !coord.x < 0 && !coord.y + 1 > world_y - 1 && to_check.has(2): temp_hex_array.append(terrain_array[coord.x][coord.y + 1])
    
    if !coord.x + 1 > world_x - 1 && !coord.y + 1 > world_y - 1 && to_check.has(3): temp_hex_array.append(terrain_array[coord.x + 1][coord.y + 1])
    elif coord.x + 1 > world_x - 1 && !coord.y + 1 > world_y - 1 && to_check.has(3): temp_hex_array.append(terrain_array[0][coord.y + 1])
  # diffrent check for offset rows to account for the offset
  else:
    if !coord.x - 1 < 0 && !coord.y - 1 < 0 && to_check.has(6): temp_hex_array.append(terrain_array[coord.x - 1][coord.y - 1])
    elif coord.x - 1 < 0 && !coord.y - 1 < 0 && to_check.has(6): temp_hex_array.append(terrain_array[world_x - 1][coord.y - 1]) 
     
    if !coord.x < 0 && !coord.y - 1 < 0 && to_check.has(5): temp_hex_array.append(terrain_array[coord.x][coord.y - 1])
    
    if !coord.x - 1 < 0 && !coord.y + 1 > world_y - 1 && to_check.has(2): temp_hex_array.append(terrain_array[coord.x - 1][coord.y + 1])
    elif coord.x - 1 < 0 && !coord.y + 1 > world_y - 1 && to_check.has(2): temp_hex_array.append(terrain_array[world_x - 1][coord.y + 1])
    
    if !coord.x < 0 && !coord.y + 1 > world_y - 1 && to_check.has(3): temp_hex_array.append(terrain_array[coord.x][coord.y + 1])
  
  return temp_hex_array
