extends Control

const MAIN_SCENE_PATH := "res://scenes/main/Main.tscn"

@onready var main_vbox: VBoxContainer = get_node_or_null("ContentMargin/VBoxContainer")
@onready var stage_list: VBoxContainer = get_node_or_null("ContentMargin/VBoxContainer/StageList")
@onready var bottom_buttons: HBoxContainer = get_node_or_null("ContentMargin/VBoxContainer/ButtomButtons")

@onready var back_button: Button = get_node_or_null("ContentMargin/VBoxContainer/ButtomButtons/BackButton")
@onready var more_button: Button = get_node_or_null("ContentMargin/VBoxContainer/ButtomButtons/MoreButton")

@onready var player_name_label: Label = get_node_or_null("TopBar/HBoxContainer/ProfilePanel/NameMoneyBox/PlayerNameLabel")
@onready var money_label: Label = get_node_or_null("TopBar/HBoxContainer/ProfilePanel/NameMoneyBox/CurrencyRow/MoneyLabel")
@onready var gem_label: Label = get_node_or_null("TopBar/HBoxContainer/ProfilePanel/NameMoneyBox/CurrencyRow/GemLabel")

@onready var stage_card_macau: StageCard = get_node_or_null("ContentMargin/VBoxContainer/StageList/StageCard_Macau")
@onready var stage_card_singapore: StageCard = get_node_or_null("ContentMargin/VBoxContainer/StageList/StageCard_Singapore")
@onready var stage_card_las_vegas: StageCard = get_node_or_null("ContentMargin/VBoxContainer/StageList/StageCard_LasVegas")


func _ready() -> void:
	_apply_layout()
	_connect_buttons()
	_load_player_ui()
	_setup_stage_cards()


func _apply_layout() -> void:
	if main_vbox != null:
		main_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		main_vbox.add_theme_constant_override("separation", 10)
		main_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		main_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	if stage_list != null:
		stage_list.alignment = BoxContainer.ALIGNMENT_BEGIN
		stage_list.add_theme_constant_override("separation", 8)
		stage_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		stage_list.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	if bottom_buttons != null:
		bottom_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
		bottom_buttons.add_theme_constant_override("separation", 8)
		bottom_buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		bottom_buttons.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		bottom_buttons.custom_minimum_size = Vector2(140, 28)

	if back_button != null:
		back_button.custom_minimum_size = Vector2(60, 28)

	if more_button != null:
		more_button.custom_minimum_size = Vector2(60, 28)


func _connect_buttons() -> void:
	if back_button != null:
		if not back_button.pressed.is_connected(_on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)

	if more_button != null:
		if not more_button.pressed.is_connected(_on_more_pressed):
			more_button.pressed.connect(_on_more_pressed)


func _load_player_ui() -> void:
	if player_name_label != null:
		player_name_label.text = "Zareth"

	if money_label != null:
		money_label.text = "$1000"

	if gem_label != null:
		gem_label.text = "💎 500"


func _setup_stage_cards() -> void:
	if stage_card_macau != null:
		stage_card_macau.stage_name = "MACAU"
		stage_card_macau.prize_text = "$1,000"
		stage_card_macau.buy_in_text = "$1,000"
		stage_card_macau.target_scene = MAIN_SCENE_PATH
		stage_card_macau.update_ui()

	if stage_card_singapore != null:
		stage_card_singapore.stage_name = "SINGAPORE"
		stage_card_singapore.prize_text = "$10,000"
		stage_card_singapore.buy_in_text = "$10,000"
		stage_card_singapore.target_scene = MAIN_SCENE_PATH
		stage_card_singapore.update_ui()

	if stage_card_las_vegas != null:
		stage_card_las_vegas.stage_name = "LAS VEGAS"
		stage_card_las_vegas.prize_text = "$100,000"
		stage_card_las_vegas.buy_in_text = "$100,000"
		stage_card_las_vegas.target_scene = MAIN_SCENE_PATH
		stage_card_las_vegas.update_ui()


func _on_back_pressed() -> void:
	print("Back pressed")


func _on_more_pressed() -> void:
	print("More pressed")
