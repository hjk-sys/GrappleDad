extends Node2D
@onready var links: Sprite2D = $Links
var direction := Vector2(0,0)
var tip := Vector2(0,0)

const SPEED = 30

var flying = false
var hooked = false

func _ready() -> void:
	links.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	flying = true
	tip = self.global_position

func release():
	flying = false
	hooked = false
	
func _process(delta: float) -> void:
	if hooked or flying:
		self.visible = true
		links.visible = true
	else:
		self.visible = false
		links.visible = false
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	links.rotation = Vector2.ZERO.angle_to_point(tip_loc) - PI/2
	$ChainTip.rotation = Vector2.ZERO.angle_to_point(tip_loc) + PI/2
	links.position = tip_loc / 2
	links.region_rect.size.y = tip_loc.length() * 1.8
	if tip_loc.length() > 500:
		hooked = false
		links.visible = false
		self.visible = false


func _physics_process(delta: float) -> void:
	$ChainTip.global_position = tip
	if flying:
		if $ChainTip.move_and_collide(direction * SPEED):
			hooked = true
			flying = false
	tip = $ChainTip.global_position

	
