extends Node
class_name Sestem
"""
Rules:
	- The purpose of this architecture is to keep Sestem easy to expand and edit, not to make every module work independently.
	- Modules should not be dependent on each other.
	- Error handling should be handled by Sestem if possible.
	- Return variables should always be types if possible. (Exceptions include variable converion functions.)
	- All internal functions of a module or the the whole framework should always be prefixed with a '_'.

"""



@export var telemetry: SesTelemetry
@export var file: SesFileSaver
@export var time: SesTime
@export var varcon: SesVarConverter

@onready var console: Node = $Console

func out(source, color: Color,...text):
	if telemetry:
		print_to_console(telemetry.out_from_arr.call(source, color, text))

func print_to_console(text: String):
	console._print_text(text)

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


func _shit_pants(dev_message: String = "Unavailable"):
	push_error("A SES-Framework component or a related function has malfunctioned unrecoverably.",
	" Additional info: ", dev_message)

func next_frame():
	await get_tree().process_frame
