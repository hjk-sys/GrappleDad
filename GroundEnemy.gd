extends CharacterBody2D
const SPEED = 50
var target = null
var is_attacking = false
signal kill_player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var starting_pos := global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 20  # simple gravity
		
	if target is Player:
		var direction = (target.position - position).normalized()
		velocity.x = direction.x * SPEED
	else:
		velocity.x = 0
	
	move_and_slide()
	if is_attacking:
		animated_sprite_2d.play("Attacking")
		await animated_sprite_2d.animation_finished
		is_attacking = false
	else:
		if velocity.x == 0:
			animated_sprite_2d.play("Idle")
		elif velocity.x != 0:
			animated_sprite_2d.flip_h = (velocity.x < 0)
			animated_sprite_2d.play("Walking")
	

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body



func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		is_attacking = true
		kill_player.emit()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target = starting_pos
