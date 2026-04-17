extends Control

const PLAYER_PANEL_SCENE = preload("res://scenes/ui/player_panel.tscn")

@onready var game_manager = $GameManager

@onready var dealer_label: Label = $TableLayer/DealerSpot/DealerLabel
@onready var dealer_cards: HBoxContainer = $TableLayer/DealerSpot/DealerCards
@onready var deck_card: AnimatedSprite2D = $TableLayer/DealerSpot/DealerCards/DeckCard
@onready var third_card_sprite: AnimatedSprite2D = $TableLayer/DealerSpot/DealerCards/ThirdCard

@onready var pot_label: Label = $TableLayer/PotContainer/PotLabel

@onready var player: Control = $TableLayer/Player
@onready var player_2: Control = $TableLayer/Player2
@onready var player_3: Control = $TableLayer/Player3
@onready var player_4: Control = $TableLayer/Player4
@onready var player_5: Control = $TableLayer/Player5

@onready var continue_button: Button = $MarginContainer/CenterContainer/ContinueButton
@onready var action_bar: HBoxContainer = $MarginContainer/CenterContainer/ActionBar
@onready var bet_button: Button = $MarginContainer/CenterContainer/ActionBar/BetButton
@onready var fold_button: Button = $MarginContainer/CenterContainer/ActionBar/FoldButton
@onready var all_in_button: Button = $MarginContainer/CenterContainer/ActionBar/AllInButton

@onready var bet_panel: HBoxContainer = $MarginContainer/CenterContainer/BetPanel
@onready var bet_amount_spin_box: SpinBox = $MarginContainer/CenterContainer/BetPanel/BetAmountSpinBox
@onready var confirm_bet_button: Button = $MarginContainer/CenterContainer/BetPanel/ConfirmBetButton
@onready var cancel_bet_button: Button = $MarginContainer/CenterContainer/BetPanel/CancelBetButton

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
	_setup_dealer_cards()

	continue_button.pressed.connect(_on_continue_pressed)
	bet_button.pressed.connect(_on_bet_pressed)
	fold_button.pressed.connect(_on_fold_pressed)
	all_in_button.pressed.connect(_on_all_in_pressed)
	confirm_bet_button.pressed.connect(_on_confirm_bet_pressed)
	cancel_bet_button.pressed.connect(_on_cancel_bet_pressed)

	game_manager.start_new_game()
	await build_player_seats()
	game_manager.start_new_round()
	update_ui()

	if game_manager.process_human_auto_turn_if_needed():
		update_ui()

func _setup_seat_sizes() -> void:
	for seat in seat_nodes:
		seat.custom_minimum_size = Vector2(160, 130)
		seat.size = Vector2(160, 130)

func _setup_dealer_cards() -> void:
	deck_card.frame = 0
	third_card_sprite.frame = 0
	deck_card.visible = true
	third_card_sprite.visible = true

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

		var panel: Control = seat_nodes[i].get_child(0)
		panel.position = (seat_nodes[i].size - panel.size) / 2.0

func update_ui() -> void:
	var current_text: String = "None"

	if game_manager.current_player_index >= 0 and game_manager.current_player_index < game_manager.players.size() and not game_manager.is_round_over():
		current_text = game_manager.players[game_manager.current_player_index].player_name

	pot_label.text = "Pot: %d\nUsed: %d\nLeft: %d\nTurn: %s" % [
		game_manager.pot,
		game_manager.deck_manager.get_used_count(),
		game_manager.deck_manager.get_remaining_count(),
		current_text
	]

	for i in range(min(game_manager.players.size(), seat_nodes.size())):
		if seat_nodes[i].get_child_count() == 0:
			continue

		var panel = seat_nodes[i].get_child(0)
		var player_data: PlayerData = game_manager.players[i]

		var show_faces: bool = false

		if i == game_manager.current_player_index:
			show_faces = true

		if game_manager.has_pending_jackpot_reveal() and i == game_manager.pending_jackpot_player_index:
			show_faces = true

		if game_manager.has_pending_pair_choice() and i == game_manager.pending_pair_player_index:
			show_faces = true

		if game_manager.is_waiting_after_reveal() and i == game_manager.waiting_after_reveal_player_index:
			show_faces = true

		var is_current: bool = (i == game_manager.current_player_index)
		var is_first_bettor: bool = (i == game_manager.starting_player_index)

		if game_manager.has_pending_jackpot_reveal():
			is_current = false

		if game_manager.has_pending_pair_choice():
			is_current = (i == game_manager.pending_pair_player_index)

		panel.set_player_data(player_data, show_faces, is_current, is_first_bettor)

	_update_dealer_cards()
	_update_action_area()

func _update_dealer_cards() -> void:
	deck_card.visible = game_manager.deck_manager.get_remaining_count() > 0

	if game_manager.revealed_third_card != null:
		third_card_sprite.visible = true
		third_card_sprite.frame = _card_to_frame(game_manager.revealed_third_card)
	else:
		third_card_sprite.visible = true
		third_card_sprite.frame = 0

func _reset_action_bar_labels() -> void:
	bet_button.text = "Bet"
	fold_button.text = "Fold"
	all_in_button.text = "All In"
	all_in_button.visible = true

func _update_action_area() -> void:
	continue_button.visible = false
	action_bar.visible = false
	bet_panel.visible = false
	_reset_action_bar_labels()

	if game_manager.is_waiting_after_reveal():
		continue_button.visible = true
		continue_button.disabled = false
		continue_button.text = "Continue"
		return

	if game_manager.has_pending_jackpot_reveal():
		continue_button.visible = true
		continue_button.disabled = false
		continue_button.text = "Continue"
		return

	if game_manager.has_pending_pair_choice():
		if game_manager.pending_pair_player_index == game_manager.HUMAN_PLAYER_INDEX:
			action_bar.visible = true
			bet_button.text = "Higher"
			fold_button.text = "Lower"
			all_in_button.visible = false
			bet_button.disabled = false
			fold_button.disabled = false
		else:
			continue_button.visible = true
			continue_button.disabled = false
			continue_button.text = "Continue"
		return

	if game_manager.is_round_over():
		continue_button.visible = true
		continue_button.disabled = false
		continue_button.text = "Next Round"
		return

	if game_manager.is_human_turn():
		action_bar.visible = true
		bet_button.disabled = false
		fold_button.disabled = false
		all_in_button.disabled = not game_manager.can_current_player_all_in()

		if game_manager.get_max_bet_for_current_player() <= 0:
			bet_button.disabled = true

		if game_manager._is_auto_fold_hand(game_manager.get_current_player()):
			bet_button.disabled = true
			all_in_button.disabled = true

		if game_manager._is_jackpot_hand(game_manager.get_current_player()):
			bet_button.disabled = true
			fold_button.disabled = true
			all_in_button.disabled = true

		return

	continue_button.visible = true
	continue_button.disabled = false
	continue_button.text = "Continue"

func _open_bet_panel() -> void:
	var min_bet: int = game_manager.get_min_bet()
	var max_bet: int = game_manager.get_max_bet_for_current_player()

	bet_amount_spin_box.min_value = float(min_bet)
	bet_amount_spin_box.max_value = float(max_bet)
	bet_amount_spin_box.step = 1.0
	bet_amount_spin_box.value = float(min_bet)

	action_bar.visible = false
	bet_panel.visible = true

func _close_bet_panel() -> void:
	bet_panel.visible = false
	_update_action_area()

func _on_continue_pressed() -> void:
	if game_manager.is_waiting_after_reveal():
		game_manager.continue_after_reveal()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	if game_manager.has_pending_jackpot_reveal():
		game_manager.continue_pending_jackpot()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	if game_manager.has_pending_pair_choice():
		game_manager.advance_ai_turn()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	if game_manager.is_round_over():
		game_manager.start_new_round()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	game_manager.advance_ai_turn()
	update_ui()

	if game_manager.process_human_auto_turn_if_needed():
		update_ui()

func _on_bet_pressed() -> void:
	if game_manager.has_pending_pair_choice():
		game_manager.choose_pair_higher()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	_open_bet_panel()

func _on_fold_pressed() -> void:
	if game_manager.has_pending_pair_choice():
		game_manager.choose_pair_lower()
		update_ui()

		if game_manager.process_human_auto_turn_if_needed():
			update_ui()
		return

	game_manager.player_fold()
	update_ui()

	if game_manager.process_human_auto_turn_if_needed():
		update_ui()

func _on_all_in_pressed() -> void:
	if game_manager.has_pending_pair_choice():
		return

	game_manager.player_all_in()
	update_ui()

	if game_manager.process_human_auto_turn_if_needed():
		update_ui()

func _on_confirm_bet_pressed() -> void:
	var amount: int = int(bet_amount_spin_box.value)
	var success: bool = game_manager.player_bet(amount)

	if success:
		_close_bet_panel()

	update_ui()

	if game_manager.process_human_auto_turn_if_needed():
		update_ui()

func _on_cancel_bet_pressed() -> void:
	_close_bet_panel()

func _card_to_frame(card: Card) -> int:
	var rank_map = {
		"2": 1,
		"3": 2,
		"4": 3,
		"5": 4,
		"6": 5,
		"7": 6,
		"8": 7,
		"9": 8,
		"10": 9,
		"Jack": 10,
		"Queen": 11,
		"King": 12,
		"Ace": 13
	}

	var suit_offset = {
		"Clubs": 0,
		"Spades": 13,
		"Hearts": 26,
		"Diamonds": 39
	}

	return suit_offset[card.suit] + rank_map[card.rank]
