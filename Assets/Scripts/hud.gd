extends CanvasLayer

@onready var clock_label: Label = $ClockLabel
@onready var task_list: VBoxContainer = $TaskContainer/TaskList

func _ready() -> void:
	# Espera um frame para garantir que os Autoloads estão prontos
	await get_tree().process_frame
	
	# 1. O HUD ouve o TimeManager (Global)
	if not TimeManager.is_connected("time_updated", _on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)
	
	# 2. O HUD ouve o TaskManager (Global)
	if not TaskManager.is_connected("tasks_updated", _on_tasks_updated):
		TaskManager.tasks_updated.connect(_on_tasks_updated)
	
	# Pega os valores iniciais
	_on_time_updated(TimeManager.get_current_hour(), TimeManager.current_minute)
	_on_tasks_updated(TaskManager.current_tasks)

# Esta função é chamada pelo TimeManager
func _on_time_updated(hour: int, minute: int) -> void:
	if clock_label:
		clock_label.text = "%02d:%02d" % [hour, minute]

# Esta função é chamada pelo TaskManager
func _on_tasks_updated(tasks: Array[String]) -> void:
	if task_list:
		for child in task_list.get_children():
			child.queue_free()
			
		for task_text in tasks:
			var new_label = Label.new()
			new_label.text = "- " + task_text
			new_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			task_list.add_child(new_label)
