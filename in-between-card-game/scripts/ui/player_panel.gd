extends Control

const PANEL_WIDTH := 95
const PANEL_HEIGHT := 78
const CARD_SCALE := Vector2(0.32, 0.32)

@onready var bettor_label: Label = $VBoxContainer/BettorLabel
@onready var first_bettor_label: Label = $VBoxContainer/FirstBettorLabel
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var money_label: Label = $VBoxContainer/MoneyLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var cards_box: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var card_1: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card1
@onready var card_2: AnimatedSprite2D = $VBoxContainer/HBoxContainer/Card2


func _ready() -> void:
	_apply_small_layout()


func _apply_small_layout() -> void:
	custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)

	var vbox: VBoxContainer = $VBoxContainer
	vbox.add_theme_constant_override("separation", 0)

	if cards_box:
		cards_box.add_theme_constant_override("separation", 2)
		cards_box.alignment = BoxContainer.ALIGNMENT_BEGIN

	_setup_label(bettor_label, 10)
	_setup_label(first_bettor_label, 10)
	_setup_label(name_label, 13)
	_setup_label(money_label, 13)
	_setup_label(status_label, 12)

	_setup_card_sprite(card_1)
	_setup_card_sprite(card_2)


func _setup_label(label: Label, font_size: int) -> void:
	if label == null:
		return

	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _setup_card_sprite(sprite: AnimatedSprite2D) -> void:
	if sprite == null:
		return

	sprite.scale = CARD_SCALE


func set_player_data(player_data, show_faces: bool, is_current: bool, is_first_bettor: bool) -> void:
	_apply_small_layout()

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
	first_bettor_label.text = "First"

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
