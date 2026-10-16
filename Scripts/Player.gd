extends CharacterBody2D
class_name Player

@export var movement_data : MovementData

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var starting_position := global_position
@onready var chain: Node2D = $Chain
@onready var chest_check: Area2D = $ChestCheck
@onready var head_check: Area2D = $HeadCheck
@onready var jumps: AudioStreamPlayer2D = $JUMP
@onready var grapple: AudioStreamPlayer2D = $GRAPPLE
@onready var modeswitch: AudioStreamPlayer2D = $MODESWITCH
@onready var mode_label: Label = $Label


signal player_damaged
signal player_died

var alive = true

var is_ledge_grabbing = false

var pull_mode = false

var just_wall_jumped = false
var was_wall_normal := Vector2.ZERO
var jump := 0

var hook_pos = Vector2()
var rope_length = 475
var current_rope_length = 0
var hooked = false

var extravariableinsideprocesscommonmistake= false



func _ready():
	current_rope_length = rope_length



func _physics_process(delta: float) -> void:
	# Direction
	var direction := Input.get_axis("left", "right")
# ----------------------check if alive-------------------------
	if not alive:
		alive_check()
		return
# ----------------------if alive then move onto hook check-----------------------------
	mode_check()
	hook()
	if hooked and hook_pos != null:
		handle_hook(direction, delta)
		return
	# ----------------------Ledge Grab----------------------
	check_ledge_grab(direction)
	if is_ledge_grabbing:
		if Input.is_action_just_pressed("jump"):
			jumps.play()
			is_ledge_grabbing = false
			velocity.y = movement_data.jump_velocity
			move_and_slide()
		return
	# ------------------Main Movement-------------------------
	apply_gravity(delta)
	handle_wall_jump(direction)
	handle_jump_check()
	just_wall_jumped = false
	handle_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	handle_air_acceleration(direction,delta)
	update_animations(direction)
	wall_slide(direction, delta)
	var was_on_floor = is_on_floor()
	var was_on_wall := is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_floor = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_floor:
		coyote_jump_timer.start()
	var just_left_wall := was_on_wall and not is_on_wall_only()
	if just_left_wall:
		wall_jump_timer.start()
	# detecting a collison
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "HazardLayer":
			# kills the player waaayy too fast right now, but I need to move on
			player_damaged.emit()
# --------------------------Alive Check----------------------------

func alive_check():
	if not extravariableinsideprocesscommonmistake:
		extravariableinsideprocesscommonmistake = true
		deathanimation()
		
# -----------------------mode check-------------------------------
func mode_check():
	if Input.is_action_just_pressed("Switch Modes"):
		modeswitch.play()
		pull_mode = !pull_mode  # flips between true and false
		show_mode_label()

func show_mode_label():
	mode_label.text = "Pull Mode" if pull_mode else "Swing Mode"
	mode_label.visible = true
	await get_tree().create_timer(1.5).timeout
	mode_label.visible = false
#--------------------------- Grapple Handling ----------
func hook():
	var point = get_global_mouse_position()
	var point_angle = get_angle_to(point) - (PI/2)
	$RayCast.rotation = point_angle
	if Input.is_action_just_pressed("action"):
		grapple.play()
		if hooked:
			hooked = false
			queue_redraw()
			return
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			current_rope_length = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("action"):
		hooked = false
		velocity *= 1.2
		
func get_hook_pos():
	for raycast in $RayCast.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()

func handle_hook(direction, delta):
	if pull_mode:
		pull(delta)
		handle_acceleration(direction,delta)
		move_and_slide()
	else:
		swing(direction, delta)
		apply_gravity(delta)
		move_and_slide()

func swing(direction, delta):
	var to_hook = hook_pos - global_position
	var rope_dir = to_hook.normalized()
	
	var is_swinging_forward = velocity.dot(to_hook.rotated(PI/2).normalized()) > 0
	if direction and is_swinging_forward:
		velocity += to_hook.rotated(PI/2).normalized() * 300 * delta
	
	var radial_vel = velocity.dot(-rope_dir)  # how much vel is pointing away
	if radial_vel > 0:
		velocity += rope_dir * radial_vel  # cancel it out
	
	# If character drifted past rope length, snap them back
	if global_position.distance_to(hook_pos) > current_rope_length:
		global_position = hook_pos - rope_dir * current_rope_length
	
	if direction:
		handle_hook_acceleration(direction,delta)

func pull(delta):
	var to_hook = hook_pos - global_position
	var rope_dir = to_hook.normalized()
	# Change player's velocity depending on angle and direction to hook_pos
	velocity = velocity.move_toward(rope_dir * 800, 1200 * delta)

# ---------------------------Chain/Links Animation--------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var dir = (get_global_mouse_position() - global_position).normalized()
			$Chain.shoot(dir)
		else:
			$Chain.release()
			
# ---------------------MOVEMENT SYSTEM IF NOT HOOKED---------------------------

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * movement_data.gravity_scale * delta
	
func handle_jump_check():
	if is_on_floor():
		jump = 0
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			jumps.play()
			velocity.y = movement_data.jump_velocity
			jump += 1
	elif not is_on_floor(): # Edits jump height after it has left the ground
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity/2 and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity / 2
			jumps.play()
		if Input.is_action_just_pressed("jump") and jump < movement_data.jump_num:
			velocity.y = movement_data.jump_velocity * 0.8
			jump += 1
			jumps.play()

func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(direction, delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
		
func handle_acceleration(direction, delta):
	if direction != 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.acceleration * delta) # Parameters go like (From which position, to what speed, in how many frames)

func handle_air_acceleration(direction,delta):
	if direction != 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.air_acceleration * delta)

func handle_hook_acceleration(direction,delta):
	if direction != 0 and hooked:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, 100 * delta)
		

func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("Walk")
	else:
		animated_sprite_2d.play("Idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("Jump")

# ---------------------EVERYTHING WALL RELATED------------------------------------

func handle_wall_jump(direction):
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: # is_on_wall returns true if its strictly on the wall, this function returns true if player is ONLY on the wall and not on the ground or something
		return
	var wall_normal := get_wall_normal()
	var direction_bool = false # returns direction the wall is facing
	if Input.is_action_pressed("left") and get_wall_normal().x == 1:
		direction_bool = true
	if Input.is_action_pressed("right") and get_wall_normal().x == -1:
		direction_bool = true
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	if Input.is_action_just_pressed("jump") and direction_bool:
		velocity.x = wall_normal.x * movement_data.speed 
		# sends player velocity x away from wall
		jumps.play()
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
		direction_bool = false

func wall_slide(direction, delta):
	if not is_on_floor() and is_on_wall_only() and velocity.y >= 0.0 and direction:
		velocity.y = move_toward(velocity.y, 20, 50)
		return true
	return false

func check_ledge_grab(direction):
	var offset = 18
	if not animated_sprite_2d.flip_h:
		offset = 18 
	else: 
		offset = -18
	$ChestCheck.position.x = offset
	$HeadCheck.position.x = offset
	
	var chest_hitting = not chest_check.get_overlapping_bodies().is_empty()
	var head_clear = head_check.get_overlapping_bodies().is_empty()
	
	if chest_hitting and head_clear and not is_on_floor():
		is_ledge_grabbing = true
		velocity = Vector2.ZERO
		animated_sprite_2d.play("Ledge")
		
	else:
		is_ledge_grabbing = false

# ---------------------------DEATH FUNCTIONALITY-----------------------------
func died():
	alive = false
func deathanimation():
	animated_sprite_2d.play("Death")
	await animated_sprite_2d.animation_finished
	player_died.emit()
