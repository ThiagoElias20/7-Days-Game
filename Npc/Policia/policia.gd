extends CharacterBody2D

# --- Constante de Direção ---
# IMPORTANTE: Confirme que seu sprite "olha" para a DIREITA (Vector2.RIGHT)
const FORWARD_DIRECTION = Vector2.RIGHT

# --- Variáveis de IA ---
enum States { WANDER, CHASE }
var current_state = States.WANDER
var player_target = null 

# --- Variáveis de Movimento ---
@export var wander_speed = 50.0
@export var chase_speed = 120.0
@export var fov_angle = 60.0 
@export var fov_length = 250.0 # <-- NOVO: Comprimento do cone de visão

# --- Referências de Nós ---
@onready var wander_timer = $WanderTimer
@onready var detection_radius = $DetectionRadius
@onready var line_of_sight = $LineOfSight
@onready var detection_shape = $DetectionRadius/CollisionShape2D 
@onready var vision_cone = $VisionCone # <-- NOVO: Referência ao nó Polygon2D

var wander_direction = Vector2.ZERO
# A variável 'debug_draw_color' não é mais necessária

func _ready():
	_on_wander_timer_timeout() 
	_setup_vision_cone() # <-- NOVO: Chama a função para criar o cone

func _physics_process(delta):
	# A linha 'queue_redraw()' foi removida
	
	match current_state:
		States.WANDER:
			_wander_state(delta)
		States.CHASE:
			_chase_state(delta)
			
	move_and_slide()

	# --- INÍCIO DA LÓGICA DE CAPTURA ---
	# Só verifica a colisão se estiver perseguindo
	if current_state == States.CHASE:
		# Loop por todas as colisões que aconteceram neste frame
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision == null: continue # Pula se a colisão for nula
			
			var collider = collision.get_collider()
			
			# Se o corpo que colidimos está no grupo "player"
			if collider != null and collider.is_in_group("player"):
				# PEGOU!
				_go_to_game_over()
				break # Para de checar, pois já pegou
	# --- FIM DA LÓGICA DE CAPTURA ---
	# A linha 'queue_redraw()' foi removida
	
	match current_state:
		States.WANDER:
			_wander_state(delta)
		States.CHASE:
			_chase_state(delta)
			
	move_and_slide()

# --- NOVO: Função para criar a forma do cone ---
func _setup_vision_cone():
	# Define a forma do polígono baseado no ângulo e comprimento
	var radius = fov_length
	var point1 = FORWARD_DIRECTION.rotated(deg_to_rad(fov_angle)) * radius
	var point2 = FORWARD_DIRECTION.rotated(deg_to_rad(-fov_angle)) * radius
	
	# Define a forma do nó Polygon2D
	vision_cone.polygon = PackedVector2Array([Vector2.ZERO, point1, point2])

# --- Lógica dos Estados ---

func _wander_state(delta):
	# Define a cor do cone para BRANCO
	vision_cone.color = Color(1.0, 1.0, 1.0, 0.3) 
	velocity = wander_direction * wander_speed
	
	if velocity.length_squared() > 0: 
		look_at(global_position + velocity)
	
	var target = _find_player_target()
	if target != null:
		player_target = target
		current_state = States.CHASE

func _chase_state(delta):
	# Define a cor do cone para VERMELHO
	vision_cone.color = Color(1.0, 0.0, 0.0, 0.4) 
	
	if player_target != null:
		if _can_see_player(player_target):
			var direction = (player_target.global_position - global_position).normalized()
			velocity = direction * chase_speed
			look_at(player_target.global_position)
		else:
			player_target = null
			current_state = States.WANDER
	else:
		current_state = States.WANDER

# --- Funções Auxiliares de IA ---

func _find_player_target():
	var bodies = detection_radius.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			if _can_see_player(body):
				return body 
				
	return null

func _can_see_player(player):
	var distance_to_player = (player.global_position - global_position).length()

	# --- Teste 1: COMPRIMENTO DO CONE ---
	# O jogador está dentro do comprimento do CONE BRANCO (fov_length)?
	# (O Teste do Círculo 'DetectionRadius' foi removido daqui)
	if distance_to_player > fov_length:
		return false # Falhou (longe demais para o cone)

	# --- Teste 2: FoV (Ângulo do Cone) ---
	var dir_to_player = (player.global_position - global_position).normalized()
	var forward_dir = FORWARD_DIRECTION.rotated(rotation) 
	var angle_to_player = rad_to_deg(forward_dir.angle_to(dir_to_player))
	
	if abs(angle_to_player) > fov_angle:
		return false # Falhou (está nas costas)
		
	# --- Teste 3: LoS (Paredes) ---
	line_of_sight.target_position = to_local(player.global_position) 
	line_of_sight.force_raycast_update()
	
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		# O raio acertou algo... era o jogador?
		if collider == player:
			return true # SUCESSO! Está vendo o jogador.
		else:
			return false # Falhou (Está vendo uma parede)
	else:
		# O raio não acertou NADA (nem o jogador)
		return false 

	# Este 'return true' da versão anterior estava errado e nunca era alcançado.
	# A lógica agora está correta.
# --- Lógica de Vagar (Wander) ---

func _on_wander_timer_timeout():
	if current_state == States.WANDER:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	wander_timer.start()
	
func _go_to_game_over():
	# Para o policial de se mover
	velocity = Vector2.ZERO 
	
	# Carrega a cena de game over
	# !! MUDE "res://game_over.tscn" para o caminho real da sua cena !!
	get_tree().change_scene_to_file("res://ui/main_menu/cena_game_over.tscn")
