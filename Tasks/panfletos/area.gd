extends Area2D

# --- CONFIGURAÇÃO ---
# Marque esta caixa no Inspetor APENAS para o Panfleto 6 (Mural)
@export var eh_o_mural_secreto: bool = false 

@onready var exclamacao = get_node("../Objective")
@onready var panfleto_imagem = get_node("../Panfleto")

func _ready():
	panfleto_imagem.hide() # O panfleto colado sempre começa invisível pra todos
	
	if eh_o_mural_secreto:
		# --- COMPORTAMENTO DO MURAL (Panfleto 6) ---
		exclamacao.hide()        # Começa invisível
		monitoring = false       # Começa desligado
		
		# Fica ouvindo o sinal para aparecer depois
		TaskManager.mural_unlocked.connect(_on_mural_liberado)
		
	else:
		# --- COMPORTAMENTO NORMAL (Panfletos 1 a 5) ---
		exclamacao.show()        # Já começa visível
		monitoring = true        # Já começa ativo

	# Conecta a colisão para todos
	body_entered.connect(_on_body_entered)

# Esta função só serve para o Mural
func _on_mural_liberado():
	if eh_o_mural_secreto:
		print("Mural desbloqueado!")
		exclamacao.show()
		monitoring = true

func _on_body_entered(body):
	if body.name == "Player":
		# Lógica padrão para todos: cola o panfleto e avisa o gerente
		exclamacao.hide()
		panfleto_imagem.show()
		
		TaskManager.place_flyer()
		
		set_deferred("monitoring", false)
