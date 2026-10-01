extends CanvasLayer

"""
TODO:
	SuggestionListNode
	Inputfunctions:
		_input_esc()
		_input_up()
		_input_down()


"""
signal line_edit_update()#text: String)

var source_id:= "IndependentConsole"

@export var backend: ConsoleBackend

@export var native_commands: Array[Command]

@onready var text_field := $%TextField
@onready var line_edit := $%LineEdit
@onready var suggestion_list: VBoxContainer = %SuggestionList

@export var user_input_color: Color = Color.WHITE
@export var scroll_bar_color: Color = Color.BLACK
@export var scroll_bar_corners: int = 0
@export var suggestions: bool = false

var input_history: Array = [""]
var ihp: int = 0
var input_cache: String = ""
var first_cycling: bool = true



func add_command():
	pass

func remove_command():
	pass

func remove_directory():
	pass



func _ready() -> void:
	backend.frontend = self
	backend.suggestion_list_update.connect(_on_suggestion_list_update)
	backend._frontend_ready()
	_adjust_scrollbar_color()
	suggestion_list.hide()

func _adjust_scrollbar_color():#	Vittu tää on paska moottori oikeesti
	var the_bar = text_field.get_v_scroll_bar()
	var the_new_look = StyleBoxFlat.new()
	the_new_look.bg_color = scroll_bar_color
	the_new_look.set_corner_radius_all(scroll_bar_corners)
	var the_rails = StyleBoxFlat.new()
	the_rails.bg_color = scroll_bar_color
	the_bar.add_theme_stylebox_override("grabber", the_new_look)
	the_bar.add_theme_stylebox_override("scroll", the_rails)





func _input(event: InputEvent)-> void:
	if event.is_action_pressed("toggle_console", false, false):
		_toggle_visibility()
		get_viewport().set_input_as_handled()

	if self.visible == false:
		return

	if event.is_action_pressed("ui_cancel"):
		_input_esc()
	if event.is_action_pressed("ui_up"):
		_input_up()
	if event.is_action_pressed("ui_down"):
		_input_down()
	

func _input_esc():
	if suggestion_list.is_visible_in_tree():
		for child in suggestion_list.get_children():
			child.queue_free()
		suggestion_list.hide()
		return


func _input_up():
	if _suggestion_up() == true:
		return
	_history_cycle(1)


func _input_down():
	if _suggestion_down() == true:
		return
	_history_cycle(-1)


func _suggestion_up():
	pass

func _suggestion_down():
	pass


func _history_cycle(maneuver: int):
	#var original_ihp = ihp
	ihp = ihp + maneuver
	var history_index = posmod(ihp, input_history.size())
	print(history_index)
	if first_cycling == true:
		if line_edit.text == null:
			input_history[0] = ""
		else:
			input_history[0] = line_edit.text
		first_cycling = false
	line_edit.text = input_history[history_index]
	_move_caret_to_end()


func _history_reset_search():
	ihp = 0
	input_history[0] = ""
	first_cycling = true


func _history_clear():
	input_history = [""]
	ihp = 0


func _print_text(...text):
	if text.is_empty():
		return
	_new_line()
	text_field.append_text("".join(text))



func _new_line():
	text_field.newline()


func _toggle_visibility():
	if self.visible == true:
		self.hide()
		line_edit.unedit()
	else:
	#	Ses.update_command_suggestion_array()
		self.show()
		line_edit.edit()


func _move_caret_to_end():
	line_edit.caret_column = line_edit.text.length()


func _on_line_edit_text_changed(text: String = "", from_signal: bool = true):
	var history_index = posmod(ihp, input_history.size())
	if history_index == 0:
		input_history[0] = text
	print("Line edit text updated")
	_move_caret_to_end()
	line_edit_update.emit(text)


func _on_line_edit_text_submitted(new_text: String = "") -> void:
	if new_text == "":
		return
	line_edit.clear()
	_new_line()
	_print_text(Ses.varcon.colorize_text(new_text, user_input_color))
	input_history.insert(1, new_text)
	_history_reset_search()


func _on_suggestion_list_update(list: Dictionary):
	#print("Frontend: Suggestion list update signal received. Parameters: ", list)
	for child in suggestion_list.get_children():
		child.queue_free()

	if list["options"].is_empty():
		suggestion_list.hide()
		return
	else:
		suggestion_list.show()

	for cmd in list["options"]:
		var btn = Button.new()
		btn.text = str(cmd)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_apply_suggestion.bind(btn.text))
		suggestion_list.add_child(btn)
		print("Adding a button should have worked...")

func _apply_suggestion(text: String):
	print("Button pressed: ", text)
#	Make sure that the suggestion is appended correctly after the already inputted text
	var current_text = line_edit.text
	print(current_text)
	if current_text.ends_with("."):
		pass
	else:
		var arr: Array = backend.parse_command_path(text)
		var input_text: String = arr.back()
		print(input_text)
		var added_text: String = text.substr(0,input_text.length())
		print(added_text)
		line_edit.text = current_text + added_text
		_on_line_edit_text_changed(line_edit.text, false)
