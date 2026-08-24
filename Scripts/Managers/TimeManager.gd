extends Control

const MIN_ONE:float = 1
const MIN_ONE_HAlF:float = 0.25
const MIN_TWO:float = 0.1
var current_tick_time:float = 2.0

@onready var tick_timer: Timer = $TickTimer
@onready var clock_label: Label = $ClockLabel

var can_proceed:bool = false

enum time_states {
  PAUSED,
  ONE,
  ONE_HALF,
  TWO
}
var current_time_state:time_states = time_states.PAUSED

#region months
var month_numerical:Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12]
var days_per_month:Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var earth_months:Array[StringName] = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "Septemeber", "October", "November", "December"]
var current_day:int = 1
var current_month:int = 1
var current_year:int = -3000
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  set_clock_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if current_time_state != time_states.PAUSED && can_proceed:
    tick_process()

func tick_process():
  if current_time_state == time_states.PAUSED: return
  can_proceed = false
  tick_timer.start()
  read_clock()
  await tick_timer.timeout
  can_proceed = true

func read_clock():
  if current_day + 1 > days_per_month[current_month -1]:
    current_day = 1
    if current_month + 1 > 12:
      current_month = 1
      if current_year + 1 == 0: current_year += 2
      else: current_year += 1
    else: current_month += 1
  else: current_day += 1

  set_clock_ui()
  
func set_clock_ui():
  clock_label.text = str(current_day) + " / " + earth_months[current_month -1] + " / " + str(current_year)

#region time control
func _on_pause_button_pressed() -> void:
  current_time_state = time_states.PAUSED

func _on_speed_1_button_pressed() -> void:
  tick_timer.wait_time = MIN_ONE
  if current_time_state == time_states.PAUSED:
    current_time_state = time_states.ONE
    tick_process()
  else:
    current_time_state = time_states.ONE

func _on_speed_2_button_pressed() -> void:
  tick_timer.wait_time = MIN_ONE_HAlF
  if current_time_state == time_states.PAUSED:
    current_time_state = time_states.ONE_HALF
    tick_process()
    
  else:
    current_time_state = time_states.ONE_HALF

func _on_speed_2_button_2_pressed() -> void:
  tick_timer.wait_time = MIN_TWO
  if current_time_state == time_states.PAUSED:
    current_time_state = time_states.TWO 
    tick_process()
    
  else:
    current_time_state = time_states.TWO
#endregion
