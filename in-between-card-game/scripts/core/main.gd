extends Control

const PLAYER_PANEL_SCENE = preload("res://scenes/ui/player_panel.tscn")

@onready var game_manager = $GameManager

@onready var dealer_label: Label = $TableLayer/DealerSpot/DealerLabel
@onready var pot_label: Label = $TableLayer/PotContainer/PotLabel

@onready var player: Control = $TableLayer/Player
@onready var player_2: Control = $TableLayer/Player2
@onready var player_3: Control = $TableLayer/Player3
@onready var player_4: Control = $TableLayer/Player4
@onready var player_5: Control = $TableLayer/Player5

@onready var continue_button: Button = $MarginContainer/CenterContainer/ContinueButton

var seat_nodes: Array[Control] = []

func _ready() -> void:
	seat_nodes = [
		player,
		player_2,
		player_3,
		player_4,
		player_5
	]

	dealer_label.text = "Dealer"

	_setup_seat_sizes()

	game_manager.start_new_game()
	game_manager.start_new_round()

	await build_player_seats()
	update_ui()

	continue_button.pressed.connect(_on_continue_pressed)

func _setup_seat_sizes() -> void:
	for seat in seat_nodes:
		seat.custom_minimum_size = Vector2(160, 130)
		seat.size = Vector2(160, 130)

func build_player_seats() -> void:
	for seat in seat_nodes:
		for child in seat.get_children():
			child.queue_free()

	for i in range(min(game_manager.players.size(), seat_nodes.size())):
		var panel = PLAYER_PANEL_SCENE.instantiate()
		seat_nodes[i].add_child(panel)

	await get_tree().process_frame

	for i in range(min(game_manager.players.size(), seat_nodes.size())):
		if seat_nodes[i].get_child_count() == 0:
			continue

		var panel = seat_nodes[i].get_child(0)
		panel.position = (seat_nodes[i].size - panel.size) / 2

func update_ui() -> void:
	pot_label.text = "Total Pot: %d" % game_manager.pot

	for i in range(min(game_manager.players.size(), seat_nodes.size())):
		if seat_nodes[i].get_child_count() == 0:
			continue

		var panel = seat_nodes[i].get_child(0)
		var player_data = game_manager.players[i]

		var show_faces := false

		# You always see your own cards
		if i == 0:
			show_faces = true
		# Reveal only the current player's cards during their turn
		elif i == game_manager.current_player_index:
			show_faces = true

		panel.set_player_data(player_data, show_faces)

	if game_manager.is_round_over():
		continue_button.text = "Next Round"
	else:
		continue_button.text = "Next Turn"

func _on_continue_pressed() -> void:
	if game_manager.is_round_over():
		game_manager.start_new_round()
	else:
		game_manager.advance_turn()

	update_ui()
