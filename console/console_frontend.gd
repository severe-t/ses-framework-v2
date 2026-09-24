extends CanvasLayer

"""
TODO:
	SuggestionListNode
	Inputfunctions:
		input_esc()
		input_up()
		input_down()


"""
signal line_edit_update

var source_id:= "IndependentConsole"

@export var backend: ConsoleBackend

#@export var Ses

@onready var text_field := $%TextField
@onready var line_edit := $%LineEdit
#@onready var suggestion_panel = $%SuggestionPanel
@onready var suggestion_list: ItemList = $%SuggestionList

@export var user_input_color: Color = Color.WHITE
@export var scroll_bar_color: Color = Color.BLACK
@export var scroll_bar_corners: int = 0
@export var suggestions: bool = false

var input_history: Array = [""]
var ihp: int = 0
var input_cache: String = ""
var first_cycling: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backend.frontend = self
	backend._frontend_ready()
	adjust_scrollbar_color()


func adjust_scrollbar_color():#	Vittu tää on paska moottori oikeesti
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
		toggle_visibility()
		get_viewport().set_input_as_handled()

	if self.visible == false:
		return

	if event.is_action_pressed("ui_cancel"):
		input_esc()
	if event.is_action_pressed("ui_up"):
		input_up()
	if event.is_action_pressed("ui_down"):
		input_down()
	

func input_esc():
	pass

func input_up():
	if suggestion_up() == true:
		return
	history_cycle(1)

func input_down():
	if suggestion_down() == true:
		return
	history_cycle(-1)


func suggestion_up()->bool:
	if !suggestion_list.is_valid():
		return false


	return true

func suggestion_down():
	if !suggestion_list.is_valid():
		return false


	return true




func history_cycle(maneuver: int):
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
	move_caret_to_end()


func history_reset_search():
	ihp = 0
	input_history[0] = ""
	first_cycling = true


func history_clear():
	input_history = [""]
	ihp = 0


func print_text(...text):
	if text.is_empty():
		return
	new_line()
	text_field.append_text("".join(text))



func new_line():
	text_field.newline()


func toggle_visibility():
	if self.visible == true:
		self.hide()
		line_edit.unedit()
	else:
	#	Ses.update_command_suggestion_array()
		self.show()
		line_edit.edit()


func move_caret_to_end():
	line_edit.caret_column = line_edit.text.length()


func _on_line_edit_text_changed(text):
	var history_index = posmod(ihp, input_history.size())
	if history_index == 0:
		input_history[0] = text
	line_edit_update.emit(text)


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	line_edit.clear()
	new_line()
	print_text(Ses.colorize_text(new_text, user_input_color))
	input_history.insert(1, new_text)
	history_reset_search()
