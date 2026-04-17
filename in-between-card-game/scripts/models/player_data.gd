extends RefCounted
class_name PlayerData

var player_id: int
var player_name: String
var money: int
var hand: Array[Card] = []
var folded: bool = false
var all_in: bool = false
var eliminated: bool = false

var current_bet: int = 0
var choice: String = ""
var third_card: Card = null
var won_turn: bool = false
var has_played_this_round: bool = false
var round_result_text: String = "Waiting"

func _init(_player_id: int, _player_name: String, _money: int) -> void:
	player_id = _player_id
	player_name = _player_name
	money = _money

func clear_for_new_round() -> void:
	hand.clear()
	folded = false
	all_in = false
	current_bet = 0
	choice = ""
	third_card = null
	won_turn = false
	has_played_this_round = false
	round_result_text = "Waiting"

func can_act() -> bool:
	return not folded and not eliminated and money > 0 and not has_played_this_round
