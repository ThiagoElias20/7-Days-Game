extends Node2D

# Referências para as cenas que instanciamos
@onready var clock: Node2D = $Clock
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	# --- A MÁGICA DA SINCRONIZAÇÃO ---
	
	# 1. Conecta o sinal "time_updated" do Relógio...
	#    ...à função "_on_time_updated" do HUD.
	clock.time_updated.connect(hud._on_time_updated)
	
	# 2. Conecta o mesmo sinal "time_updated" do Relógio...
	#    ...à função "_on_time_updated" do TaskManager (o nosso Autoload).
	clock.time_updated.connect(TaskManager._on_time_updated)
