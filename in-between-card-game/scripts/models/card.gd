extends RefCounted
class_name Card

var suit: String
var rank: String
var value: int

func _init(_suit: String, _rank: String, _value: int) -> void:
	suit = _suit
	rank = _rank
	value = _value

func get_display_name() -> String:
	return "%s of %s" % [rank, suit]
