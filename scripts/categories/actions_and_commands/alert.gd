extends VBoxContainer

@export var word_bank = "res://assets/wordBank.txt"
@export var max_attempts: int = 6

var success = false
var words: String = "alert"
# checking letters
var cur_guess: String = ""
var cur_row: int = 0
var cur_col: int = 0

@onready var letters = preload("res://scenes/letters.tscn")
@onready var Board: VBoxContainer = $"."


func _ready() -> void:
	generate_puzzle()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return

	if event is InputEventKey:
		var key_text = OS.get_keycode_string(event.keycode)

		if event.keycode == KEY_BACKSPACE:
			delete_letter()
		elif event.keycode == KEY_ENTER:
			submit_guess()
		elif key_text.length() == 1 and key_text.is_valid_filename():
			type_letter(key_text)


func generate_puzzle() -> void:
	# to clear the board
	for child in get_children():
		child.queue_free()

	var word_length = words.length()

	# we make the rows based on the max attempts and place an hbox container in it, and for the column, we use the letters scene to create boxed based on the length of the word
	for rowsIndex in max_attempts:
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		add_child(row)

		for columnIndex in word_length:
			row.add_child(letters.instantiate())


func delete_letter() -> void:
	if cur_col > 0:
		cur_col -= 1
		cur_guess = cur_guess.left(cur_guess.length() - 1)
		get_box_at(cur_row, cur_col).set_letter("")


func submit_guess() -> void:
	if cur_col < words.length():
		# Dialogic.start("fill_in_the_blank")
		await get_tree().create_timer(2.0).timeout
		# Dialogic.clear()
		return

	check_wordle_logic()
	if cur_guess == words.to_upper():
		prints("you win")
		success = true
		# queue_free()
		set_process_unhandled_input(false)

		# if success == true:
		# 	# get_tree().change_scene_to_file("res://scenes/words/combo_w.tscn")
		# 	Dialogic.start("success")
		# return

	cur_row += 1
	cur_col = 0
	cur_guess = ""

	if cur_row >= max_attempts and success == false:
		print("you lose")
		set_process_unhandled_input(false)

		# if success == false:
		# 	Dialogic.start("failure")
		# return


func type_letter(letter: String) -> void:
	if cur_col < words.length():
		var active_box = get_box_at(cur_row, cur_col)
		active_box.set_letter(letter)
		cur_guess += letter.to_upper()
		cur_col += 1


func get_box_at(rowIndex: int, colIndex: int) -> PanelContainer:
	var raw_node = Board.get_child(rowIndex)
	return raw_node.get_child(colIndex)


func check_wordle_logic() -> void:
	var target = words.to_upper()
	var guess = cur_guess

	# Target what has been found
	var target_pool = []
	for i in target.length():
		target_pool.append(target[i])

	#
	var results = []
	results.resize(target.length()) #.resize is faster than calling .append
	results.fill(0)

	for i in words.length():
		if guess[i] == target[i]:
			results[i] = 2
			target_pool[i] = ""

	for i in words.length():
		if results[i] == 2:
			continue

		var letter_index = target_pool.find((guess[i]))
		if letter_index != -1:
			results[i] = 1
			target_pool[letter_index] = ""

	for i in words.length():
		if results[i] == 2:
			get_box_at(cur_row, i).set_color(Color.GREEN)
		elif results[i] == 1:
			get_box_at(cur_row, i).set_color(Color.YELLOW)
		else:
			get_box_at(cur_row, i).set_color(Color.MEDIUM_VIOLET_RED)
