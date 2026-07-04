extends Node3D

const TERRAIN_HEX = preload("res://Scenes/Terrain/terrain_hex.tscn")
const HEX_WIDTH:float = 2 # sqrt(3) * 1 (hex radius)
const HEX_HEIGHT:float = 1.73205080757 # 2 * 1 (hex radius)

@export var world_size:float = 64
@export var terrain_array:Array[Array]
@export var large_continents_num:int
@export var small_continents_num:int

@export var continents_list:Array[Array]

@export var noise_tex:NoiseTexture2D

@export_category("World Gen Settings")
enum gen_types
{
  random,
  continents,
  noise_gen,
  blank
}
@export var gen_type:gen_types = gen_types.noise_gen

@export var inital_land_ratio:int = 60
@export var _seed:int
@export var is_rand:bool = true
@export var should_smooth:bool
@export var gen_passes:int = 6
@export var gen_weight:int = 2
@export var climate_passes:int = 2
@export var sea_level:float = -0.5

var world_scale:float = 1.0

var rng = RandomNumberGenerator.new()
var total_continents:int

var world_x:int
var world_y:int

var first_gen:bool = true

@onready var camera = $Camera3D

func _ready():
  SignalManager.connect("_regenerate_terrain", ready_map_maker)
  ready_map_maker()
  if !is_rand: is_rand = true
  
  print("seed: " + str(WorldManager.seed))

func ready_size_dependant_vars():
  world_scale = world_size / 80.0
  print("scale " + str(world_scale))

func ready_map_maker():
  var temp_terrain_array = terrain_array
  
  world_size = WorldManager.size
  gen_passes = WorldManager.gen_passes
  gen_weight = WorldManager.gen_weight
  climate_passes = WorldManager.climate_passes
  sea_level = WorldManager.sea_level
  inital_land_ratio = WorldManager.inital_land_ratio
  _seed = WorldManager.seed
  ready_size_dependant_vars()
  
  for x in temp_terrain_array.size():
    for y in temp_terrain_array[x].size():
      terrain_array[x][y].queue_free()
  
  terrain_array = []
  
  generate_map()
  
  match WorldManager.gen_type:
    gen_types.random:
      random_fill_land()
      should_smooth = true
    gen_types.continents:
      pass
    gen_types.noise_gen:
      noise_fill_land()
      #border_smooth_pass()
    gen_types.blank:
      pass
  
  if gen_passes > 0 && should_smooth:
    for p in gen_passes:
      smooth_terrain_pass(p)
   
  coastline_pass()
  generate_latitude_pass()
  for x in climate_passes:
    generate_climate_pass()
    generate_biome_pass()

func generate_map():
  world_x = world_size
  world_y = roundi(world_size / 2)
  
  for x in world_x:
    terrain_array.append([])     
  
  var x_offset:int = 0
  #print("map size: " + str(world_x) + " x " + str(world_y))
  
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
      hex.set_biome(WorldManager.biomes.OPEN_OCEAN)
      

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
 
func noise_fill_land():
  #noise_tex.set_width(world_x)
  #noise_tex.set_height(world_y)
  noise_tex.noise.seed = WorldManager.seed
  
  #print(str(Vector2(noise_tex.width, noise_tex.height)))
  
  for y in world_y:
    var y_float:float = y / world_scale
    for x in world_x:
      var x_float:float = x / world_scale
      var hex = terrain_array[x][y]
      if noise_tex.noise.get_noise_2d(x_float,y_float) > sea_level: hex.set_biome(WorldManager.biomes.GRASSLAND)
      else: hex.set_biome(WorldManager.biomes.OPEN_OCEAN)



# Smooths out the terrain generation by looking for nearby terrains to fill out the map
func smooth_terrain_pass(_pass:int): # LOOK INTO - can probably be multi-purpose
  var temp_array:Array[Array]
  
  for y in terrain_array.size():
    temp_array.append([])
    for x in terrain_array[y].size():
     
      #print(str(terrain_array.size()) + " x " + str(terrain_array[y].size()))
    
      var neighbors:Array = get_neighbor_array(Vector2(y, x))
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

func border_smooth_pass():
  for hex in terrain_array[0].size():
    var neighbor = terrain_array[world_size-1][hex]
    if neighbor.is_land: terrain_array[0][hex].set_biome(WorldManager.biomes.GRASSLAND)

  for hex in terrain_array[world_size-1].size():
    var neighbor = terrain_array[0][hex]
    if neighbor.is_land: terrain_array[0][hex].set_biome(WorldManager.biomes.GRASSLAND)
   
# Sets any deep water hex that borders a land hex to a littoral_salt_water biome     
func coastline_pass():
  var temp_array:Array[Array]
  
  for y in terrain_array.size():
    temp_array.append([])
    for x in terrain_array[y].size():
      var neighbors = get_neighbor_array(Vector2(y, x))
      var neighbor_count:int = 0
      
      for n:terrain_hex in neighbors:
        if n.hex_biome == WorldManager.biomes.GRASSLAND: 
          neighbor_count += 1
        
      if neighbor_count >= 1 && !terrain_array[y][x].is_land: terrain_array[y][x].set_biome(WorldManager.biomes.SALT_WATER_LITTORAL)
 
# generates hex climates based on latitude     
func generate_latitude_pass():
  if WorldManager.end_latitude < 0: WorldManager.end_latitude *= -1
  
  var total_latitude:float = WorldManager.start_latitude + (WorldManager.end_latitude)
  var latitude_step:float = total_latitude / world_y
  var current_latitude:float = WorldManager.start_latitude
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
      
      if terrain_array[x][y].is_land: 
        var neighbors:Array[terrain_hex] = get_neighbor_array(Vector2(x,y))
        for n in neighbors:
          if !n.is_land: 
            terrain_array[x][y].annual_percipitation = 500
            break
      else: terrain_array[x][y].annual_percipitation = 700

func generate_climate_pass():
  var neighbors:Array[terrain_hex]

  for y in world_y:
    # get neighbors
    for x in world_x: 
      #if terrain_array[x][y].is_land:
        neighbors = get_prevailing_wind_hexes(Vector2(x, y))
        
        var total_precip:float
        var total_temp:float
        var water_count:int = 0
        
        # get average temperature
        for n in neighbors:
          total_temp += n.average_annual_temp
          total_precip += n.annual_percipitation
          if !n.is_land: water_count += 1
        
        if water_count >= 3: terrain_array[x][y].annual_percipitation = 700
        else: terrain_array[x][y].annual_percipitation = (total_precip / neighbors.size()) * (world_scale) 
        if water_count >= 1: terrain_array[x][y].average_annual_temp = (total_temp / neighbors.size()) * (world_scale)
        


# checks the bottom right or top left hexes of given coord depending on prevailing winds
func get_prevailing_wind_hexes(coord:Vector2) -> Array[terrain_hex]: # this whole this is kinda gross
  # easterlies == less precipitation, westerlies == more precipitation # NOT YET

  var temp_hex_array:Array[terrain_hex]
  var lat = terrain_array[coord.x][coord.y].hex_latitude
  
  # check latitude to determine which direction to check
  if lat >= 60: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [1,6,2]) # POLAR CELL
  elif lat >= 30: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [1,2,3]) # N WESTERLIES CELL
  elif lat >= 0: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [6,5,4]) # NORTHEASTERLY TRADE
  elif lat >= -30: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [2,3,4]) # SOUTHEASTERLY TRADE
  elif lat >= -60: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [1,6,2]) # S WESTERLIES
  else: temp_hex_array = get_neighbor_array(Vector2(coord.x, coord.y), [6,1,2]) # POLAR CELL

  return temp_hex_array

func generate_biome_pass():
  for y in world_y:
    for x in world_x:
      var temp:float = terrain_array[x][y].average_annual_temp
      var precip:float = terrain_array[x][y].annual_percipitation

      # This is probably the worst code here - try and figure out something like Voroni mapping
      for b in WorldManager.biomes.size():
        if terrain_array[x][y].is_land:
          if temp > target_wobble(30, 2):
            if precip > target_wobble(500, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.RAINFOREST)
              break
            elif precip > target_wobble(300, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SAVANNA)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
              break
          elif temp > target_wobble(25, 1):
            if precip > target_wobble(450, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.RAINFOREST)
              break
            elif precip > target_wobble(300, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SAVANNA)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
              break
          elif temp > target_wobble(20, 1):
            if precip > target_wobble(250, 75):
              terrain_array[x][y].set_biome(WorldManager.biomes.SAVANNA)
              break
            elif precip > target_wobble(200, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SHRUBLAND)
              break
            elif precip > target_wobble(100, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.GRASSLAND)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
              break
          elif temp > target_wobble(15, 1):
            if precip > target_wobble(200, 75): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SEASONAL_FOREST)
              break
            elif precip > target_wobble(140, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SHRUBLAND)
              break
            elif precip > target_wobble(50, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.GRASSLAND)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
              break
          elif temp > target_wobble(10, 1):
            if precip > target_wobble(400, 75): 
              terrain_array[x][y].set_biome(WorldManager.biomes.TEMPERATE_RAINFOREST)
              break
            elif precip > target_wobble(180, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SEASONAL_FOREST)
              break
            elif precip > target_wobble(120, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SHRUBLAND)
              break
            elif precip > target_wobble(80, 15): 
              terrain_array[x][y].set_biome(WorldManager.biomes.GRASSLAND)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.DESERT)
              break
          elif temp > target_wobble(5, 1):
            if precip > target_wobble(300, 75):
              terrain_array[x][y].set_biome(WorldManager.biomes.SEASONAL_FOREST)
              break
            if precip > target_wobble(220, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.BOREAL_FOREST)
              break
            elif precip > target_wobble(205, 25): 
              terrain_array[x][y].set_biome(WorldManager.biomes.SHRUBLAND)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.GRASSLAND)
              break
          elif temp > target_wobble(0, 1):
            if precip > target_wobble(100, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.BOREAL_FOREST)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.TUNDRA)
              break
          elif temp > -5:
            terrain_array[x][y].set_biome(WorldManager.biomes.TUNDRA)
            break
          elif temp > target_wobble(-10, 8):
            if precip > target_wobble(100, 50): 
              terrain_array[x][y].set_biome(WorldManager.biomes.TUNDRA)
              break
            else: 
              terrain_array[x][y].set_biome(WorldManager.biomes.ICE)
              break   
          else:
            terrain_array[x][y].set_biome(WorldManager.biomes.ICE)
            break                

# returns a random float with between +wobble & -wobble around the target float
func target_wobble(target:float, wobble:float) -> float:
  var return_float = randf_range((target - wobble), (target + wobble))
  return return_float

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
