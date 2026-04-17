extends Control

@onready var bettor_label: Label = $VBoxContainer/BettorLabel
@onready var first_bettor_label: Label = $VBoxContainer/FirstBettorLabel
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var money_label: Label = $VBoxContainer/MoneyLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var card_1: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card1
@onready var card_2: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card2

func set_player_data(player_data, show_faces: bool, is_current: bool, is_first_bettor: bool) -> void:
	if player_data == null:
		bettor_label.visible = false
		first_bettor_label.visible = false
		name_label.text = ""
		money_label.text = ""
		status_label.text = ""
		card_1.frame = 0
		card_2.frame = 0
		return

	bettor_label.visible = is_current
	bettor_label.text = "Bettor"

	first_bettor_label.visible = is_first_bettor
	first_bettor_label.text = "First Bettor"

	name_label.text = player_data.player_name
	money_label.text = "Money: %d" % player_data.money
	status_label.text = player_data.round_result_text

	if player_data.hand.size() >= 2 and show_faces:
		card_1.frame = _card_to_frame(player_data.hand[0])
		card_2.frame = _card_to_frame(player_data.hand[1])
	else:
		card_1.frame = 0
		card_2.frame = 0

func _card_to_frame(card) -> int:
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
