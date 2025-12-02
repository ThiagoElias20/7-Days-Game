extends Control


@onready var pontos = $Pontos
var pontos_text = ""


func _on_timer_timeout() -> void:
	if pontos_text.length() == 12:
		pontos_text = ""
	else:
		pontos_text += ". "
	pontos.text = pontos_text
	

func _ready():
	carregar()

func carregar():
	var path = GlobalVar.proxima_cena
	var loader = ResourceLoader.load_threaded_request(path)
	var status = ResourceLoader.load_threaded_get_status(path)

	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(path)

	var cena = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(cena)
