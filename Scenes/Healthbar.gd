extends PanelContainer


const Hearts = preload("res://Assets/pngs/Pixel Heart Animation GIFs & Spritesheets, 32x32 and 16x16/Pixel Heart Sprite Sheet 16x16.png")

var HEARTSIZE = Vector2i(16,16)
var HEARTREGION := {
	"full": Vector2i(0,0),
	"half": Vector2i(16,0),
	"empty": Vector2i(32,0),
	}

var heart := "full"

func _ready():
	set_icon(heart)
	
func set_icon(icon_name):
	var atlas: = AtlasTexture.new()
	heart = icon_name
	atlas.atlas = Hearts
	atlas.region = Rect2(HEARTREGION[icon_name], HEARTSIZE)
	$Control/TextureRect.texture = atlas
