extends RefCounted
class_name PlayerData

var player_id: int
var player_name: String
var money: int
var hand: Array[Card] = []
var folded: bool = false
var all_in: bool = false
var eliminated: bool = false

func _init(_player_id: int, _player_name: String, _money: int) -> void:
	player_id = _player_id
	player_name = _player_name
	money = _money

func clear_for_new_round() -> void:
	hand.clear()
	folded = false
	all_in = false

func can_act() -> bool:
	return not folded and not all_in and not eliminated and money > 0
