@tool
extends Button
class_name StageCard

const CARD_WIDTH := 360
const CARD_HEIGHT := 78

@export var stage_name: String = "MACAU":
	set(value):
		stage_name = value
		update_ui()

@export var prize_text: String = "$1,000":
	set(value):
		prize_text = value
		update_ui()

@export var buy_in_text: String = "$1,000":
	set(value):
		buy_in_text = value
		update_ui()

@export var background_texture: Texture2D:
	set(value):
		background_texture = value
		update_ui()

@export_file("*.tscn") var target_scene: String = "res://scenes/main/Main.tscn"

@onready var card_background: TextureRect = get_node_or_null("CardBackground")
@onready var content_margin: MarginContainer = get_node_or_null("ContentMargin")
@onready var card_vbox: VBoxContainer = get_node_or_null("ContentMargin/VBoxContainer")
@onready var title_panel: Panel = get_node_or_null("ContentMargin/VBoxContainer/TitlePanel")
@onready var title_label: Label = get_node_or_null("ContentMargin/VBoxContainer/TitlePanel/TitleLabel")
@onready var prize_label: Label = get_node_or_null("ContentMargin/VBoxContainer/PrizeLabel")
@onready var buy_in_label: Label = get_node_or_null("ContentMargin/VBoxContainer/BuyInLabel")


func _ready() -> void:
	text = ""
	flat = true
	clip_contents = true

	_apply_size()
	update_ui()

	if not Engine.is_editor_hint():
		if not pressed.is_connected(_on_pressed):
			pressed.connect(_on_pressed)


func _apply_size() -> void:
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	clip_contents = true

	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	if card_background != null:
		card_background.set_anchors_preset(Control.PRESET_FULL_RECT)
		card_background.offset_left = 0
		card_background.offset_top = 0
		card_background.offset_right = 0
		card_background.offset_bottom = 0
		card_background.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		card_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	if content_margin != null:
		content_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		content_margin.offset_left = 0
		content_margin.offset_top = 0
		content_margin.offset_right = 0
		content_margin.offset_bottom = 0
		content_margin.add_theme_constant_override("margin_left", 10)
		content_margin.add_theme_constant_override("margin_top", 3)
		content_margin.add_theme_constant_override("margin_right", 10)
		content_margin.add_theme_constant_override("margin_bottom", 3)

	if card_vbox != null:
		card_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		card_vbox.add_theme_constant_override("separation", 0)
		card_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	if title_panel != null:
		title_panel.custom_minimum_size = Vector2(0, 20)
		title_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	if title_label != null:
		title_label.add_theme_font_size_override("font_size", 18)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if prize_label != null:
		prize_label.add_theme_font_size_override("font_size", 11)
		prize_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prize_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if buy_in_label != null:
		buy_in_label.add_theme_font_size_override("font_size", 11)
		buy_in_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buy_in_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func update_ui() -> void:
	if not is_inside_tree():
		return

	_apply_size()

	if card_background != null:
		card_background.texture = background_texture

	if title_label != null:
		title_label.text = stage_name

	if prize_label != null:
		prize_label.text = "1ST PRIZE\n" + prize_text

	if buy_in_label != null:
		buy_in_label.text = "Buy-in: " + buy_in_text


func _on_pressed() -> void:
	if target_scene.strip_edges() != "":
		get_tree().change_scene_to_file(target_scene)
