extends Node3D

@export var speed:float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  rotation_degrees.y += speed * delta
