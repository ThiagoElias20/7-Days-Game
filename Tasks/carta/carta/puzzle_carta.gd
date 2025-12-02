extends Control

const RESPOSTA_CORRETA = "QUEIMAR ARQUIVOS"

signal puzzle_concluido
signal puzzle_falhou

@onready var campo_resposta = $VBoxContainer/CampoResposta   # verificar nome/path no editor
@onready var botao_enviar = $VBoxContainer/BotaoEnviar
@onready var texto_cifrado = $Bilhete/TextoCifrado

func _ready():
	# --- Verifique no editor se os paths acima existem! ---
	texto_cifrado.text = "QPSBP EB SFJUPSJB" # texto encriptado de exemplo

	# Conecta sinais (usando os nós já carregados)
	botao_enviar.pressed.connect(_verificar_resposta)
	# Em Godot 4 o signal que envia o texto ao apertar Enter é "text_submitted"
	if campo_resposta.has_signal("text_submitted"):
		campo_resposta.text_submitted.connect(_ao_apertar_enter)
	# Foca no campo de resposta
	campo_resposta.grab_focus()

# Chama quando pressiona Enter no LineEdit
func _ao_apertar_enter(_texto_digitado: String) -> void:
	_verificar_resposta()

# Verifica a resposta usando o nó campo_resposta (NUNCA $LineEdit)
func _verificar_resposta() -> void:
	# defensive: confirma que o nó existe
	if campo_resposta == null:
		push_error("campo_resposta é null — verifique o caminho no scene tree (VBoxContainer/CampoResposta).")
		return

	var tentativa = campo_resposta.text.to_upper().strip_edges()
	if tentativa == RESPOSTA_CORRETA:
		_sucesso()
	else:
		_erro()

func _sucesso() -> void:
	print("Decifrado com sucesso!")
	campo_resposta.editable = false
	# Deixa o texto com aspecto de sucesso
	campo_resposta.modulate = Color(0, 1, 0) # verde
	await get_tree().create_timer(1.5).timeout
	emit_signal("puzzle_concluido")
	queue_free()

func _erro() -> void:
	print("Resposta errada!")
	campo_resposta.text = ""
	campo_resposta.placeholder_text = "Código Incorreto..."
	
	# efeito visual rápido (vermelho)
	var cor_original = campo_resposta.modulate
	campo_resposta.modulate = Color.RED
	
	# Efeito shake usando "position" (Godot 4)
	var original_x = campo_resposta.position.x
	var tween = create_tween()

	tween.tween_property(campo_resposta, "position:x", original_x + 10, 0.05)
	tween.tween_property(campo_resposta, "position:x", original_x - 10, 0.05)
	tween.tween_property(campo_resposta, "position:x", original_x, 0.05)
	tween.tween_property(campo_resposta, "modulate", cor_original, 0.2)
