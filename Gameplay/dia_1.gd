extends Node2D

@onready var bg_song = $BackGroundSong 

func _ready():
	GlobalVar.dia = 1
	GlobalVar.total_time = 0
	GlobalVar.score = 0
	GlobalVar.is_day_completed = false
	GlobalVar.is_secondary_task_completed = false
	#bg_song.play()

func _on_time_counter_timeout() -> void:
	GlobalVar.time_elapsed_day += 1
