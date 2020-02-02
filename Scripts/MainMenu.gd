extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_name = ""
var ip_adress = ""

func _on_name_changed(new_text):
	player_name = new_text

func _on_ip_changed(new_text):
	ip_adress = new_text
	
# Called when the node enters the scene tree for the first time.
func _on_host_pressed():
	Network.start_server(player_name)
	load_game()

func _on_join_pressed():
	Network.join_server(player_name, ip_adress)
	load_game()

func load_game():
	get_tree().change_scene("res://Scenes/Game.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
