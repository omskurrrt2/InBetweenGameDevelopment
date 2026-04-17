extends Node

const STARTING_MONEY: int = 100
const BASE_BET: int = 20
const HUMAN_PLAYER_INDEX: int = 0

var deck_manager: DeckManager = DeckManager.new()

var players: Array[PlayerData] = []
var pot: int = 0
var current_player_index: int = 0
var starting_player_index: int = 0
var turns_taken_this_round: int = 0
var round_number: int = 0
var round_log: String = ""
var revealed_third_card: Card = null
var rebuild_pot_next_round: bool = false

var pending_jackpot_reveal: bool = false
var pending_jackpot_player_index: int = -1

var pending_pair_choice: bool = false
var pending_pair_player_index: int = -1
var pending_pair_bet_amount: int = 0
var pending_pair_all_in: bool = false

var waiting_after_reveal: bool = false
var waiting_after_reveal_player_index: int = -1

func start_new_game() -> void:
	players.clear()
	players.append(PlayerData.new(1, "P1", STARTING_MONEY))
	players.append(PlayerData.new(2, "P2", STARTING_MONEY))
	players.append(PlayerData.new(3, "P3", STARTING_MONEY))
	players.append(PlayerData.new(4, "P4", STARTING_MONEY))
	players.append(PlayerData.new(5, "P5", STARTING_MONEY))

	deck_manager.setup_new_shoe()
	pot = 0
	current_player_index = 0
	starting_player_index = 0
	turns_taken_this_round = 0
	round_number = 0
	round_log = "Game started."
	revealed_third_card = null
	rebuild_pot_next_round = false

	pending_jackpot_reveal = false
	pending_jackpot_player_index = -1

	pending_pair_choice = false
	pending_pair_player_index = -1
	pending_pair_bet_amount = 0
	pending_pair_all_in = false

	waiting_after_reveal = false
	waiting_after_reveal_player_index = -1

	_collect_new_round_antes()

func start_new_round() -> void:
	_collect_round_cards_to_discard()

	if rebuild_pot_next_round or pot <= 0:
		_collect_new_round_antes()
		rebuild_pot_next_round = false

	turns_taken_this_round = 0
	round_number += 1
	round_log = "Round %d started." % round_number
	revealed_third_card = null

	pending_jackpot_reveal = false
	pending_jackpot_player_index = -1

	pending_pair_choice = false
	pending_pair_player_index = -1
	pending_pair_bet_amount = 0
	pending_pair_all_in = false

	waiting_after_reveal = false
	waiting_after_reveal_player_index = -1

	for p in players:
		if p.money <= 0:
			p.eliminated = true
		p.clear_for_new_round()

	_ensure_cards_for_round()
	_deal_cards()

	current_player_index = _find_next_active_player(starting_player_index)

	if current_player_index == -1:
		round_log = "No active players left."

func _collect_new_round_antes() -> void:
	pot = 0

	for p in players:
		if p.money <= 0:
			p.eliminated = true
			continue

		if p.eliminated:
			continue

		var ante: int = mini(BASE_BET, p.money)
		if ante > 0:
			p.money -= ante
			pot += ante

		if p.money <= 0:
			p.eliminated = true

func should_rebuild_pot() -> bool:
	return rebuild_pot_next_round or pot <= 0

func has_pending_jackpot_reveal() -> bool:
	return pending_jackpot_reveal

func has_pending_pair_choice() -> bool:
	return pending_pair_choice

func is_waiting_after_reveal() -> bool:
	return waiting_after_reveal

func get_pending_pair_player() -> PlayerData:
	if pending_pair_player_index < 0 or pending_pair_player_index >= players.size():
		return null

	return players[pending_pair_player_index]

func get_current_player() -> PlayerData:
	if current_player_index < 0 or current_player_index >= players.size():
		return null

	return players[current_player_index]

func get_pending_jackpot_player() -> PlayerData:
	if pending_jackpot_player_index < 0 or pending_jackpot_player_index >= players.size():
		return null

	return players[pending_jackpot_player_index]

func _collect_round_cards_to_discard() -> void:
	for p in players:
		var cards_to_discard: Array[Card] = []

		for card in p.hand:
			cards_to_discard.append(card)

		if p.third_card != null:
			cards_to_discard.append(p.third_card)

		deck_manager.discard_cards(cards_to_discard)

func _discard_cards_of_player(player: PlayerData) -> void:
	if player == null:
		return

	var cards_to_discard: Array[Card] = []

	for card in player.hand:
		cards_to_discard.append(card)

	if player.third_card != null:
		cards_to_discard.append(player.third_card)

	deck_manager.discard_cards(cards_to_discard)

	player.hand.clear()
	player.third_card = null

func _ensure_cards_for_round() -> void:
	var needed_cards: int = _count_active_players() * 3

	if deck_manager.get_remaining_count() >= needed_cards:
		return

	deck_manager.reshuffle_if_needed()

	if deck_manager.get_remaining_count() < needed_cards:
		deck_manager.setup_new_shoe()
		round_log += " New shoe created."

func _deal_cards() -> void:
	for p in players:
		p.hand.clear()
		p.third_card = null

	for p in players:
		if p.eliminated:
			continue

		var first_card: Card = deck_manager.draw_card()
		var second_card: Card = deck_manager.draw_card()

		if first_card != null:
			p.hand.append(first_card)

		if second_card != null:
			p.hand.append(second_card)

		p.round_result_text = "Waiting"

func is_round_over() -> bool:
	if waiting_after_reveal:
		return false

	if pending_jackpot_reveal:
		return false

	if pending_pair_choice:
		return false

	if pot <= 0:
		return true

	return turns_taken_this_round >= _count_active_players_that_can_act()

func is_human_turn() -> bool:
	if waiting_after_reveal:
		return false

	if pending_jackpot_reveal:
		return false

	if pending_pair_choice:
		return false

	if is_round_over():
		return false

	return current_player_index == HUMAN_PLAYER_INDEX

func can_current_player_all_in() -> bool:
	var player: PlayerData = get_current_player()

	if player == null:
		return false

	if player.money <= 0:
		return false

	if _is_auto_fold_hand(player):
		return false

	if _is_jackpot_hand(player):
		return false

	return player.money >= pot and pot > 0

func get_min_bet() -> int:
	return BASE_BET

func get_max_bet_for_current_player() -> int:
	var player: PlayerData = get_current_player()

	if player == null:
		return 0

	if _is_auto_fold_hand(player):
		return 0

	if _is_jackpot_hand(player):
		return 0

	var max_bet: int = mini(player.money, pot)
	return max_bet

func player_bet(amount: int) -> bool:
	if not is_human_turn():
		return false

	var player: PlayerData = get_current_player()
	if player == null:
		return false

	if _is_auto_fold_hand(player):
		return false

	if _is_jackpot_hand(player):
		return false

	if not _is_valid_bet_amount(player, amount):
		return false

	if _is_pair_hand(player):
		_prepare_pair_choice(player, amount, false)
		return true

	_resolve_bet_action(player, amount)
	_pause_after_reveal(player)
	return true

func player_fold() -> bool:
	if not is_human_turn():
		return false

	var player: PlayerData = get_current_player()
	if player == null:
		return false

	_apply_fold(player)
	_complete_turn_and_advance()
	return true

func player_all_in() -> bool:
	if not is_human_turn():
		return false

	var player: PlayerData = get_current_player()
	if player == null:
		return false

	if _is_auto_fold_hand(player):
		return false

	if _is_jackpot_hand(player):
		return false

	if not can_current_player_all_in():
		return false

	var all_in_amount: int = pot

	if _is_pair_hand(player):
		_prepare_pair_choice(player, all_in_amount, true)
		return true

	_resolve_bet_action(player, all_in_amount, true)
	_pause_after_reveal(player)
	return true

func choose_pair_higher() -> bool:
	if not pending_pair_choice:
		return false

	return _resolve_pending_pair_choice("higher")

func choose_pair_lower() -> bool:
	if not pending_pair_choice:
		return false

	return _resolve_pending_pair_choice("lower")

func _resolve_pending_pair_choice(choice: String) -> bool:
	var player: PlayerData = get_pending_pair_player()
	if player == null:
		pending_pair_choice = false
		pending_pair_player_index = -1
		pending_pair_bet_amount = 0
		pending_pair_all_in = false
		return false

	_resolve_pair_bet_action(player, pending_pair_bet_amount, pending_pair_all_in, choice)

	pending_pair_choice = false
	pending_pair_player_index = -1
	pending_pair_bet_amount = 0
	pending_pair_all_in = false

	_pause_after_reveal(player)
	return true

func continue_pending_jackpot() -> bool:
	if not pending_jackpot_reveal:
		return false

	var player: PlayerData = get_pending_jackpot_player()
	if player == null:
		pending_jackpot_reveal = false
		pending_jackpot_player_index = -1
		return false

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]
	var third: Card = deck_manager.draw_card()

	player.current_bet = 0
	player.all_in = false
	player.third_card = third
	revealed_third_card = third
	player.choice = "jackpot"
	player.has_played_this_round = true

	var won: bool = _did_player_win_jackpot(card_a, card_b, third)
	player.won_turn = won

	if won:
		var payout: int = pot
		player.money += payout
		pot = 0
		player.round_result_text = "Jackpot"
		rebuild_pot_next_round = true
	else:
		player.round_result_text = "Jackpot"

	turns_taken_this_round += 1
	round_log = player.round_result_text

	pending_jackpot_reveal = false
	pending_jackpot_player_index = -1

	_pause_after_reveal(player)
	return true

func continue_after_reveal() -> bool:
	if not waiting_after_reveal:
		return false

	var player: PlayerData = null
	if waiting_after_reveal_player_index >= 0 and waiting_after_reveal_player_index < players.size():
		player = players[waiting_after_reveal_player_index]

	_discard_cards_of_player(player)

	waiting_after_reveal = false
	waiting_after_reveal_player_index = -1
	revealed_third_card = null

	_complete_turn_and_advance()
	return true

func advance_ai_turn() -> void:
	if waiting_after_reveal:
		return

	if pending_jackpot_reveal:
		continue_pending_jackpot()
		return

	if pending_pair_choice:
		var pair_player: PlayerData = get_pending_pair_player()
		if pair_player != null and players.find(pair_player) != HUMAN_PLAYER_INDEX:
			var pair_decision: Dictionary = _get_best_pair_decision(pair_player)
			_resolve_pending_pair_choice(pair_decision["choice"])
		return

	if is_round_over():
		return

	if is_human_turn():
		return

	var player: PlayerData = get_current_player()
	if player == null:
		return

	_process_ai_turn(player)

func _process_ai_turn(player: PlayerData) -> void:
	if player.hand.size() < 2:
		player.round_result_text = ""
		player.has_played_this_round = true
		turns_taken_this_round += 1
		_complete_turn_and_advance()
		return

	if _is_auto_fold_hand(player):
		_apply_fold(player)
		_complete_turn_and_advance()
		return

	if _is_jackpot_hand(player):
		_prepare_jackpot_turn(player)
		return

	if player.money < BASE_BET:
		_apply_fold(player)
		_complete_turn_and_advance()
		return

	if _is_pair_hand(player):
		var pair_decision: Dictionary = _get_best_pair_decision(player)
		var pair_probability: float = pair_decision["probability"]
		var pair_choice: String = pair_decision["choice"]

		if pair_probability > 0.8 and player.money >= pot and pot > 0:
			_resolve_pair_bet_action(player, pot, true, pair_choice)
			_pause_after_reveal(player)
			return

		if pair_probability > 0.5:
			if _is_valid_bet_amount(player, BASE_BET):
				_resolve_pair_bet_action(player, BASE_BET, false, pair_choice)
				_pause_after_reveal(player)
				return

		_apply_fold(player)
		_complete_turn_and_advance()
		return

	var win_probability: float = _get_non_pair_win_probability(player)

	if win_probability > 0.8 and player.money >= pot and pot > 0:
		_resolve_bet_action(player, pot, true)
		_pause_after_reveal(player)
		return

	if win_probability > 0.5:
		if _is_valid_bet_amount(player, BASE_BET):
			_resolve_bet_action(player, BASE_BET, false)
			_pause_after_reveal(player)
			return

	_apply_fold(player)
	_complete_turn_and_advance()

func process_human_auto_turn_if_needed() -> bool:
	if not is_human_turn():
		return false

	var player: PlayerData = get_current_player()
	if player == null:
		return false

	if _is_auto_fold_hand(player):
		_apply_fold(player)
		_complete_turn_and_advance()
		return true

	if _is_jackpot_hand(player):
		_prepare_jackpot_turn(player)
		return true

	return false

func _pause_after_reveal(player: PlayerData) -> void:
	waiting_after_reveal = true
	waiting_after_reveal_player_index = players.find(player)

func _prepare_pair_choice(player: PlayerData, amount: int, is_all_in: bool) -> void:
	player.current_bet = amount
	player.all_in = is_all_in
	player.choice = ""
	player.round_result_text = "Choose Higher or Lower"

	pending_pair_choice = true
	pending_pair_player_index = players.find(player)
	pending_pair_bet_amount = amount
	pending_pair_all_in = is_all_in

	revealed_third_card = null
	round_log = player.round_result_text

func _prepare_jackpot_turn(player: PlayerData) -> void:
	player.current_bet = 0
	player.all_in = false
	player.choice = "jackpot"
	player.round_result_text = "Jackpot"
	player.has_played_this_round = false

	revealed_third_card = null
	pending_jackpot_reveal = true
	pending_jackpot_player_index = players.find(player)
	round_log = "Jackpot"

func _apply_fold(player: PlayerData) -> void:
	player.folded = true
	player.current_bet = 0
	player.round_result_text = "Fold"
	player.has_played_this_round = true

	var fold_cards: Array[Card] = []
	for card in player.hand:
		fold_cards.append(card)

	deck_manager.discard_cards(fold_cards)
	player.hand.clear()
	player.third_card = null

	turns_taken_this_round += 1
	round_log = "%s folded." % player.player_name
	revealed_third_card = null

func _resolve_pair_bet_action(player: PlayerData, amount: int, force_all_in_label: bool, choice: String) -> void:
	if player.hand.size() < 2:
		player.round_result_text = ""
		player.has_played_this_round = true
		turns_taken_this_round += 1
		return

	player.current_bet = amount
	player.money -= amount
	pot += amount
	player.all_in = force_all_in_label
	player.choice = choice

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]
	var third: Card = deck_manager.draw_card()

	player.third_card = third
	revealed_third_card = third

	var won: bool = _did_player_win(card_a, card_b, third, choice)
	player.won_turn = won
	player.has_played_this_round = true

	if force_all_in_label:
		player.round_result_text = "All-in"
	else:
		player.round_result_text = "Bet: %d" % amount

	if won:
		var payout: int = mini(player.current_bet * 2, pot)
		player.money += payout
		pot -= payout

		if force_all_in_label or pot <= 0:
			rebuild_pot_next_round = true

	if player.money <= 0:
		player.eliminated = true

	turns_taken_this_round += 1
	round_log = player.round_result_text

func _resolve_bet_action(player: PlayerData, amount: int, force_all_in_label: bool = false) -> void:
	if player.hand.size() < 2:
		player.round_result_text = ""
		player.has_played_this_round = true
		turns_taken_this_round += 1
		return

	player.current_bet = amount
	player.money -= amount
	pot += amount

	if force_all_in_label:
		player.all_in = true
	else:
		player.all_in = false

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]
	var third: Card = deck_manager.draw_card()

	player.third_card = third
	revealed_third_card = third
	player.choice = _determine_choice(card_a, card_b)

	var won: bool = _did_player_win(card_a, card_b, third, player.choice)
	player.won_turn = won
	player.has_played_this_round = true

	var action_text: String = "Bet: %d" % player.current_bet
	if player.all_in:
		action_text = "All-in"

	player.round_result_text = action_text

	if won:
		var payout: int = mini(player.current_bet * 2, pot)
		player.money += payout
		pot -= payout

		if force_all_in_label or pot <= 0:
			rebuild_pot_next_round = true

	if player.money <= 0:
		player.eliminated = true

	turns_taken_this_round += 1
	round_log = player.round_result_text

func _complete_turn_and_advance() -> void:
	if is_round_over():
		_finish_round()
		starting_player_index = (starting_player_index + 1) % players.size()
		return

	var next_index: int = (current_player_index + 1) % players.size()
	current_player_index = _find_next_active_player(next_index)

	if current_player_index == -1:
		_finish_round()
		starting_player_index = (starting_player_index + 1) % players.size()

func _is_valid_bet_amount(player: PlayerData, amount: int) -> bool:
	if amount < BASE_BET:
		return false

	if amount > pot:
		return false

	if amount > player.money:
		return false

	return true

func _is_pair_hand(player: PlayerData) -> bool:
	if player == null or player.hand.size() < 2:
		return false

	return player.hand[0].value == player.hand[1].value

func _is_auto_fold_hand(player: PlayerData) -> bool:
	if player == null or player.hand.size() < 2:
		return false

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]

	if card_a.value == card_b.value:
		return false

	var gap: int = _get_hand_gap(card_a, card_b)
	return gap == 0

func _is_jackpot_hand(player: PlayerData) -> bool:
	if player == null or player.hand.size() < 2:
		return false

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]

	if card_a.value == card_b.value:
		return false

	var gap: int = _get_hand_gap(card_a, card_b)
	return gap == 1

func _get_hand_gap(card_a: Card, card_b: Card) -> int:
	var low_value: int = mini(card_a.value, card_b.value)
	var high_value: int = maxi(card_a.value, card_b.value)
	return high_value - low_value - 1

func _did_player_win_jackpot(card_a: Card, card_b: Card, third: Card) -> bool:
	if third == null:
		return false

	var low_value: int = mini(card_a.value, card_b.value)
	var high_value: int = maxi(card_a.value, card_b.value)

	return third.value > low_value and third.value < high_value

func _get_non_pair_win_probability(player: PlayerData) -> float:
	if player == null or player.hand.size() < 2:
		return 0.0

	var card_a: Card = player.hand[0]
	var card_b: Card = player.hand[1]

	if card_a.value == card_b.value:
		return 0.0

	var gap: int = _get_hand_gap(card_a, card_b)
	return float(gap) / 12.0

func _get_best_pair_decision(player: PlayerData) -> Dictionary:
	var result := {
		"choice": "higher",
		"probability": 0.0
	}

	if player == null or player.hand.size() < 2:
		return result

	var pair_value: int = player.hand[0].value
	var higher_count: int = 14 - pair_value
	var lower_count: int = pair_value - 2

	var higher_probability: float = float(higher_count) / 12.0
	var lower_probability: float = float(lower_count) / 12.0

	if lower_probability > higher_probability:
		result["choice"] = "lower"
		result["probability"] = lower_probability
	else:
		result["choice"] = "higher"
		result["probability"] = higher_probability

	return result

func _count_active_players() -> int:
	var count: int = 0

	for p in players:
		if not p.eliminated:
			count += 1

	return count

func _count_active_players_that_can_act() -> int:
	var count: int = 0

	for p in players:
		if not p.eliminated and p.money > 0:
			count += 1

	return count

func _find_next_active_player(from_index: int) -> int:
	if players.is_empty():
		return -1

	var idx: int = from_index

	for _i in range(players.size()):
		var p: PlayerData = players[idx]

		if not p.eliminated and p.money > 0 and not p.has_played_this_round:
			return idx

		idx = (idx + 1) % players.size()

	return -1

func _determine_choice(card_a: Card, card_b: Card) -> String:
	if card_a.value == card_b.value:
		return ""

	return "in_between"

func _did_player_win(card_a: Card, card_b: Card, third: Card, choice: String) -> bool:
	if third == null:
		return false

	if card_a.value == card_b.value:
		if third.value == card_a.value:
			return false

		if choice == "lower":
			return third.value < card_a.value

		if choice == "higher":
			return third.value > card_a.value

		return false

	var low_value: int = mini(card_a.value, card_b.value)
	var high_value: int = maxi(card_a.value, card_b.value)

	if third.value == low_value or third.value == high_value:
		return false

	return third.value > low_value and third.value < high_value

func _finish_round() -> void:
	if pot <= 0:
		pot = 0
		round_log = "Pot is empty. All active players ante 20 for the next round."
		return

	if rebuild_pot_next_round:
		round_log = "All-in win. All active players ante 20 for the next round."
		return

	var remaining_players: int = _count_active_players_that_can_act()

	if remaining_players <= 1:
		round_log = "Only one player can continue. Start next round."
	else:
		round_log = "Round %d complete. Start next round." % round_number
