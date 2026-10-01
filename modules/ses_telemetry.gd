extends Resource
class_name SesTelemetry

var source_id: String = "SesTelemetry"


func out(source, color: Color = Color.WHITE, ...text: Array):
	out_from_arr(source, color, text)

func out_from_arr(source, color: Color = Color.WHITE, text: Array = []):
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
	return final_print


func _colorize_text(text:String, color:Color):
	var color_hex: String = color.to_html(false)
	
	var color_start := "[color="+color_hex+"]"
	var color_end := "[/color]"

	var colorized_text = color_start + text + color_end
	return colorized_text
