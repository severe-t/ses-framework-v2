extends Node
class_name Sestem

@export var telemetry: SesTelemetry
@export var file_saver: SesFileSaver
@export var time: SesTime
@export var varcon: SesVarConverter

@onready var console: Node = $Console

func out(source, color: Color,...text):
	if telemetry:
		telemetry.out.call(source, color, text)

func print_to_console(text: String):
	console.print_text(text)

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


func _shit_pants(dev_message: String = "Unavailable"):
	push_error("A SES-Framework component or a related function has malfunctioned unrecoverably.",
	" Additional info: ", dev_message)

func next_frame():
	await get_tree().process_frame