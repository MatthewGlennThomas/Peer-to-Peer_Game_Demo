# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
extends Node

var ADDRESS = "localhost"
var PORT = 135

@onready var host_button = $HostButton
@onready var join_button = $JoinButton

var player_scene = preload("res://scenes/player.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")
var peer

var player_ids = []
var next_enemy_id: int = 1

func _on_host_button_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	rpc("_add_player", multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			rpc("_add_player", new_peer_id)
			print("Player ", new_peer_id, " joined")
	)
	rpc("_add_enemy", next_enemy_id)
	next_enemy_id += 1
	$HostButton.set_deferred("disabled", true)

func _on_join_button_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	print("We were assigned ID: ", multiplayer.get_unique_id())
	$JoinButton.set_deferred("disabled", true)

@rpc("call_local")
func _add_player(id):
	if multiplayer.is_server():
		player_ids.append(id)
		var player = player_scene.instantiate()
		player.name = "Player_" + str(id)
		print(player.name, " Created")
		player.set_multiplayer_authority(id)
		call_deferred("add_child", player)

@rpc("call_local")
func _add_enemy(id):
	if multiplayer.is_server():
		var enemy = enemy_scene.instantiate()
		enemy.name = "Enemy_" + str(id)
		print(enemy.name, " Created")
		enemy.set_multiplayer_authority(id)
		call_deferred("add_child", enemy)

func _input(_event):
	if Input.is_action_just_pressed("move"):
		print("Multiplayer peer: ", multiplayer.multiplayer_peer)
		print("Is server? ", multiplayer.is_server())  
		print("ID: ", multiplayer.get_unique_id())
		rpc("move", multiplayer.get_unique_id())
	if Input.is_action_just_pressed("attack"):
		print("Multiplayer peer: ", multiplayer.multiplayer_peer)
		print("Is server? ", multiplayer.is_server())  
		print("ID: ", multiplayer.get_unique_id())
		rpc("attack", multiplayer.get_unique_id())
	if Input.is_action_just_pressed("ability_one"):
		print("Multiplayer peer: ", multiplayer.multiplayer_peer)
		print("Is server? ", multiplayer.is_server())  
		print("ID: ", multiplayer.get_unique_id())
		rpc("ability_one", multiplayer.get_unique_id())

#IMPORTANT NOTE: "call_local" just means that it will also execute on the peer that sent the rcp request (doesn't normally)
#IMPORTANT NOTE: "any_peer" tells you the permission settings of who is allowed to request/use this rpc
@rpc("any_peer", "call_local")
func move(id):
	if id != 1:
		print(id, " updated their position on the server")
	elif id == 0:
		print(id, " updated their position as the server")
	var player_name = "Player_" + str(id)
	print("Do they have a player node: ", valid_name(player_name))
	if valid_name(player_name):
		var player_node = get_node(player_name)
		if player_node.get_node("Health").value > 0:
			player_node.target_position = player_node.get_global_mouse_position()
			player_node.is_moving = true # process() calls move() every frame which only executes while this variable is true
		else:
			print("Can't move while eliminated")

@rpc("any_peer", "call_local")
func attack(id):
	if id != 1:
		print(id, " attacked on the server")
	elif id == 1:
		print(id, " attacked as the server")
	var player_name = "Player_" + str(id)
	print("Do they have a player node: ", valid_name(player_name))
	if valid_name(player_name):
		var player_node = get_node(player_name)
		if player_node.get_node("Health").value > 0:
			player_node.attack()
		else:
			print("Can't attack while eliminated")

@rpc("any_peer", "call_local")
func ability_one(id):
	if id != 1:
		print(id, " did ability one on the server")
	elif id == 1:
		print(id, " did ability one as the server")
	var player_name = "Player_" + str(id)
	print("Do they have a player node: ", valid_name(player_name))
	if valid_name(player_name):
		var player_node = get_node(player_name)
		if player_node.get_node("Health").value > 0:
			player_node.ability_one()
		else:
			print("Can't do ability one while eliminated")

func valid_name(node_name) -> bool:
	if get_node(node_name) != null:
		return true
	else:
		return false

# ALL CODE IS THE PROPERTY AND PRODUCT OF MATTHEW GLENN THOMAS
# ONLY SHARED FOR PROSPECTIVE EMPLOYERS, RECRUITERS, HR, AND OTHER APPLICABLE PERSONNEL'S VIEWING AND EVALUATION
