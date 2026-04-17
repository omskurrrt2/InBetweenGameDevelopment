extends Node
class_name DeckManager

var deck: Array[Card] = []
var discard_pile: Array[Card] = []

const SUITS := ["Clubs", "Diamonds", "Hearts", "Spades"]
const RANKS := [
	{"rank": "2", "value": 2},
	{"rank": "3", "value": 3},
	{"rank": "4", "value": 4},
	{"rank": "5", "value": 5},
	{"rank": "6", "value": 6},
	{"rank": "7", "value": 7},
	{"rank": "8", "value": 8},
	{"rank": "9", "value": 9},
	{"rank": "10", "value": 10},
	{"rank": "Jack", "value": 11},
	{"rank": "Queen", "value": 12},
	{"rank": "King", "value": 13},
	{"rank": "Ace", "value": 14}
]

func setup_new_shoe() -> void:
	build_full_deck()
	shuffle_deck()

func build_full_deck() -> void:
	deck.clear()
	discard_pile.clear()

	for suit in SUITS:
		for rank_data in RANKS:
			var card := Card.new(suit, rank_data.rank, rank_data.value)
			deck.append(card)

func shuffle_deck() -> void:
	deck.shuffle()

func draw_card() -> Card:
	if deck.is_empty():
		reshuffle_if_needed()

	if deck.is_empty():
		return null

	return deck.pop_back()

func draw_multiple(count: int) -> Array[Card]:
	var cards: Array[Card] = []

	for i in range(count):
		var card := draw_card()
		if card != null:
			cards.append(card)

	return cards

func discard_cards(cards: Array[Card]) -> void:
	for card in cards:
		if card != null:
			discard_pile.append(card)

func reshuffle_if_needed() -> void:
	if deck.is_empty() and not discard_pile.is_empty():
		deck = discard_pile.duplicate()
		discard_pile.clear()
		deck.shuffle()

func get_remaining_count() -> int:
	return deck.size()

func get_used_count() -> int:
	return discard_pile.size()
