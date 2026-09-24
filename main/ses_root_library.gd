extends Node
class_name SesLibrary

static func out(source, color: Color = Color.WHITE, data_1 = "", data_2 = "", data_3 = "", data_4 = "", data_5 = ""):
	var source_name: String
	source_name = "Unknown"
	if "source_id" in source:
		source_name = source.source_id
	elif "inherits_ses_library" in source:
		source_name = "SesLibrary"
		#else vielä? vitun dementia
	var bracketed_source: String = "[" + source_name + "]"

	var colorized_name = colorize_text(bracketed_source, color)
	var text_array:= [colorized_name, " ", data_1, data_2, data_3, data_4, data_5] 
	var final_print = "".join(text_array)
	print_rich(final_print)
#	if sestem_ready == true:
#		Ses.print_to_console(final_print)
	#	Ses.ses_out_log.append(create_log_entry(LogEntry.ClassificationType.MESSAGE, final_print, ""))



static func colorize_text(text:String, color:Color):
	var color_hex: String = color.to_html(false)
	
	var color_start := "[color="+color_hex+"]"
	var color_end := "[/color]"

	var colorized_text = color_start + text + color_end
	return colorized_text