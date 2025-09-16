class_name Player
extends CharacterBody2D

# --- Movement ---
var acceleration: float = 12.0
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN

# --- Nodes ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $PlayerSprite
@onready var state_machine: PlayerStateMachine = $StateMachine

func _ready() -> void:
	state_machine.Initialize(self)

func _process(_delta: float) -> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

func _physics_process(_delta: float) -> void:
	move_and_slide()

# --- Cardinal direction based on input ---
func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var new_dir: Vector2
	if abs(direction.x) > abs(direction.y):
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	else:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	return true

# --- Play animation ---
func UpdateAnimation(state: String) -> void:
	animation_player.play(state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	elif cardinal_direction == Vector2.RIGHT:
		return "right"
	return "down" # fallback
