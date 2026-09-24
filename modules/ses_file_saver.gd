extends Resource
class_name SesFileSaver

enum {
	ROOT,
	SETTINGS,
	SAVE_DATA,
	SES_FRAMEWORK,
}

const path: Dictionary = {
	ROOT: "user://",
	SETTINGS: "user://settings/",
	SAVE_DATA: "user://save data/",
	SES_FRAMEWORK: "user://ses-framework",
}



var telemetry:= SesTelemetry.new()
var folders: Dictionary[int, String]

func save_as_text(file_name: String, contents, location:= ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".txt"
	else:
		full_path = full_path + ".txt"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		telemetry.out(self, Color.RED, "Error saving text file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(str(contents))
	file.close()
	return true


func save_as_binary(file_name: String, contents, location:  = ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".bin"
	else:
		full_path = full_path + ".bin"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		telemetry.out(self, Color.RED, "Error saving binary file: Could not open path ", full_path, " for writing.")
		return false
	file.store_buffer(var_to_bytes(contents))
	file.flush()
	file.close()
	return true



func load_file(file_name: String, location:  = ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)
	var file
	var file_types: Array = ["txt", "bin"]
	var file_type: String
	var result

	if split.size() == 1:
		for t in file_types.size():
			file = FileAccess.open(full_path+"."+file_types[t], FileAccess.READ)
			if file != null:
				file_type = file_types[t]
				break
	
	elif split.size() == 2:
		file = FileAccess.open(full_path, FileAccess.READ)
		file_type = split[1]

	else:
		telemetry.out(self, Color.RED, "This shouldn't happen. What the fuck... (File loading error. More than two dots in file path.)")
		return null
	
	if file == null:
		telemetry.out(self, Color.RED, "Could not load file at ", full_path, ": File was not found.")
		return null

	match file_type:
		"txt":
			result = file.get_as_text()

		"bin":
			var bytes = FileAccess.get_file_as_bytes(full_path+"."+file_type)
			result = bytes_to_var(bytes)
		_:
			telemetry.out(self, Color.RED,"Error loading file: format '", file_type, "' is not supported.")
			return null
	file.close()
	return result


func create_text_file(file_path:String, data: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		telemetry.out(self, Color.RED, "Error at create_text_file():", file_path, "was null")
		return 1
	if data is String:
		file.store_string(data)
		return 0
	else:
		telemetry.out(self, Color.RED, "Failed to create text file: parameter 'data' needs to be String")
		return 1


func save_text_file(file_name:String, text: String, path: String = path.ROOT):
	var full_path = path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".txt"
	else:
		full_path = full_path + ".txt"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		telemetry.out(self, Color.RED, "Error saving text file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(text)
	file.close()
	return true
