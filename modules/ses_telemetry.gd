extends Resource
class_name SesTelemetry

var source_id: String = "SesTelemetry"


func out(source, color: Color = Color.WHITE, ...text: Array):
	_out(source, color, text)

func _out(source, color: Color = Color.WHITE, text: Array[String] = [""]):
	if text.is_empty():
		return
	var source_name: String
	source_name = "Unknown"
	if "source_id" in source:
		source_name = source.source_id
	elif "inherits_ses_library" in source:
		source_name = "SesLibrary"
	var bracketed_source: String = "[" + source_name + "]"

	var colorized_name = _colorize_text(bracketed_source, color)
	var text_array:= [colorized_name, " ", "".join(text)] 
	var final_print = "".join(text_array)
	print_rich(final_print)
	if Engine.has_singleton("Console"):
		Ses.print_to_console(final_print)


func _colorize_text(text:String, color:Color):
	var color_hex: String = color.to_html(false)
	
	var color_start := "[color="+color_hex+"]"
	var color_end := "[/color]"

	var colorized_text = color_start + text + color_end
	return colorized_text
