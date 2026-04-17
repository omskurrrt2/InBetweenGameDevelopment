extends Node

var deck_manager: DeckManager = DeckManager.new()

var players: Array[PlayerData] = []
var pot: int = 0
var current_player_index: int = 0
var starting_player_index: int = 0
var turns_taken_this_round: int = 0

func start_new_game() -> void:
	players.clear()
	players.append(PlayerData.new(1, "P1", 100))
	players.append(PlayerData.new(2, "P2", 100))
	players.append(PlayerData.new(3, "P3", 100))
	players.append(PlayerData.new(4, "P4", 100))
	players.append(PlayerData.new(5, "P5", 100))

	pot = 0
	current_player_index = 0
	starting_player_index = 0
	turns_taken_this_round = 0

func start_new_round() -> void:
	pot = 0
	turns_taken_this_round = 0

	for p in players:
		p.clear_for_new_round()

	_deal_cards()

	current_player_index = starting_player_index
	current_player_index = _find_next_active_player(current_player_index)

func _deal_cards() -> void:
	deck_manager.build_full_deck()
	deck_manager.shuffle_deck()

	for p in players:
		p.hand.clear()

	for p in players:
		p.hand.append(deck_manager.draw_card())
		p.hand.append(deck_manager.draw_card())

func advance_turn() -> void:
	if is_round_over():
		return

	var player = players[current_player_index]

	if player.can_act():
		_process_turn(player)

	turns_taken_this_round += 1

	if is_round_over():
		_finish_round()
		starting_player_index = (starting_player_index + 1) % players.size()
		return

	var next_index: int = (current_player_index + 1) % players.size()
	current_player_index = _find_next_active_player(next_index)

func is_round_over() -> bool:
	return turns_taken_this_round >= _count_active_players()

func _count_active_players() -> int:
	var count: int = 0
	for p in players:
		if not p.eliminated:
			count += 1
	return count

func _find_next_active_player(from_index: int) -> int:
	var idx: int = from_index
	for _i in range(players.size()):
		var p = players[idx]
		if not p.eliminated:
			return idx
		idx = (idx + 1) % players.size()
	return from_index

func _process_turn(player: PlayerData) -> void:
	if player.money <= 0:
		player.all_in = true
		return

	var bet: int = min(10, player.money)
	player.money -= bet
	pot += bet

	if player.money == 0:
		player.all_in = true

func _finish_round() -> void:
	var active_players: Array[PlayerData] = []
	for p in players:
		if not p.folded and not p.eliminated:
			active_players.append(p)

	if active_players.size() == 0:
		return

	var winner: PlayerData = active_players[0]
	winner.money += pot
	pot = 0
