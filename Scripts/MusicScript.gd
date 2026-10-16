extends Node

@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func play_track(track: AudioStream):
	if music.stream != track:
		music.stream = track
		music.play()
