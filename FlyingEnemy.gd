extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var starting_pos := global_position

signal kill_player

var target: Player = null  #if we defined the players position at this point it would save the players position for specifically that point
const SPEED = 75

func _ready() -> void:
	animated_sprite_2d.play("Idle")
	navigation_agent_2d.target_position = starting_pos

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player: # Player class we created
		target = body # updates alongside the players position

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null

func _physics_process(delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = navigation_agent_2d.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		
	move_and_slide()
	


func _on_kill_area_body_entered(body: Node2D) -> void:
	kill_player.emit()


func _on_navigation_timer_timeout() -> void:
	if target == null:
		animated_sprite_2d.play("Idle")
		navigation_agent_2d.target_position = starting_pos
	else:
		animated_sprite_2d.play("Attacking")
		navigation_agent_2d.target_position = target.global_position
