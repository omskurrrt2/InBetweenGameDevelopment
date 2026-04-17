extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var money_label: Label = $VBoxContainer/MoneyLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var card_1: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card1
@onready var card_2: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card2

func set_player_data(player_data, show_faces: bool = false) -> void:
	name_label.text = player_data.player_name
	money_label.text = "Money: %d" % player_data.money
	status_label.text = _get_status_text(player_data)

	var cards = player_data.hand

	if cards.size() > 0:
		card_1.visible = true
		card_1.frame = _card_to_frame(cards[0]) if show_faces else 0
	else:
		card_1.visible = false

	if cards.size() > 1:
		card_2.visible = true
		card_2.frame = _card_to_frame(cards[1]) if show_faces else 0
	else:
		card_2.visible = false

func _get_status_text(player_data) -> String:
	if player_data.eliminated:
		return "Eliminated"
	if player_data.folded:
		return "Folded"
	if player_data.all_in:
		return "All-In"
	return "Active"

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
