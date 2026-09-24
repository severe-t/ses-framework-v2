extends Resource
class_name SesVarConverter

enum SortOrder{
	ASCENDING,
	DESCENDING,
	RANDOM,
	STALIN,
}


func auto_match(callable: Callable, ...args):#	Does NOT support Arrays or Dictionaries!
	auto_match_arr(callable, args)


func auto_match_arr(callable: Callable, args: Array):
	var types = get_arg_types(callable)
	if args.size() < get_required_arg_count(callable):
		return
	var margs = match_array(args, types)
	if margs == null:
		return
	callable.callv(margs)
	

func match_args(callable: Callable, ...args):
	var types = get_arg_types(callable)
	if args.size() < get_required_arg_count(callable):
		return null
	var margs = match_array(args, types)
	if margs == null:
		return null
	return margs


func get_arg_types(callable: Callable) -> Array:
	var types: Array[Variant.Type]
	var obj: Object = callable.get_object()
	
	if callable.is_valid() == false:
		return types
	
	for method in obj.get_method_list():
		if method["name"] == callable.get_method():
			for arg in method["args"]:
				types.append(arg["type"] as Variant.Type)
				break

	return types


func get_required_arg_count(callable: Callable) -> int:
	if not callable.is_valid():
		return 0
	var obj: Object = callable.get_object()
	var method_name: StringName = callable.get_method()
	var total_args: int = obj.get_method_argument_count(method_name)
	var default_args: int = 0
	if obj.get_script():
		for method in obj.get_script().get_script_method_list():
			if method["name"] == method_name:
				default_args = method["default_args"].size()
				break
	return total_args - default_args


func convert_type_strict(input, wanted_type: int):
	if typeof(input) == wanted_type:
		return input
	match wanted_type:
		TYPE_BOOL:
			if input is int or input is float:
				if input == 1 or input >= 1.0: return true
				if input == 0 or input < 1.0: return false
			elif input is String:
				var clean: String = input.strip_edges().to_lower()
				if clean in ["true", "1"]: return true
				if clean in ["false", "0"]: return false
		TYPE_INT:
			if input is float:
				return int(input)
			if input is String and input.is_valid_int():
				return input.to_int()
		TYPE_FLOAT:
			if input is int:
				return float(input)
			if input is String and input.is_valid_float():
				return input.to_float()
		TYPE_STRING:
			return str(input)
		TYPE_VECTOR2:
			if input is String:
				var parsed = str_to_var("Vector2" + input if not input.begins_with("Vector2") else input)
				if parsed is Vector2: return parsed
		TYPE_NIL:
			pass
		_:
			pass
	return null


func match_array(args: Array, types: Array):
	if args.size() > types.size():
		return null
	var result: Array
	for i in args.size():
		var matched_arg = convert_type(args[i], types[i])
		if matched_arg == null:
			return null
		result.append(matched_arg)
	return result


func convert_type(input, type: int):
	return type_convert(input, type)


func sort_string_array(input: Array, order: SortOrder):
	var result = sort_packed_string_array(PackedStringArray(input), order)
	return Array(result)


func sort_packed_string_array(input: Array, order: SortOrder = SortOrder.ASCENDING) -> Array:
	var sorted_list = input.duplicate()
	match order:
		SortOrder.ASCENDING:
			sorted_list.sort_custom(func(a,b): return a.casecmp_to(b) < 0)
			return sorted_list
		SortOrder.DESCENDING:	
			sorted_list.sort_custom(func(a,b): return a.casecmp_to(b) > 0)
			return sorted_list
		SortOrder.RANDOM:
			sorted_list.shuffle()
			return sorted_list
		SortOrder.STALIN:
			return _stalin_sort_strings(input)
		_:
			return []


func _stalin_sort_strings(input: Array):
	var new_input = input.duplicate()
	var i: int = 0
	while i + 1 < new_input.size():
		if new_input[i].casecmp_to(new_input[i + 1]) > 0:
			new_input.remove_at(i + 1)
		else:
			i += 1
	return new_input


func sort_alphabetically_case_sensitive(list: Array, order: bool = true):
	var sorted_list = list.duplicate()
	sorted_list.sort()
	if order == false:
		sorted_list.reverse()
	return sorted_list


func sort_resources_by_string(list: Array, property_name: String, order: SortOrder):
	var sorted_list = list.duplicate()
	match order:
		SortOrder.ASCENDING:
			sorted_list.sort_custom(func(a,b):
				return a.get(property_name).casecmp_to(b.get(property_name)) < 0)
			return sorted_list

		SortOrder.DESCENDING:
			sorted_list.sort_custom(func(a,b):
				return a.get(property_name).casecmp_to(b.get(property_name)) > 0)
			return sorted_list
		
		SortOrder.RANDOM:
			sorted_list.shuffle()
			return sorted_list
		SortOrder.STALIN:	
			var i: int = 0
			while i + 1 < sorted_list.size():############################################################### MIKÄ VITUN HAS
				if sorted_list[i].get(property_name) > sorted_list[i + 1].get(property_name):
					sorted_list.erase(i+1)
				else:
					i += 1
			return sorted_list


func sort_resources_by_string_var(list: Array, property_name: String, order:= true):
	var sorted_list = list.duplicate()
	if order == true:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) < 0)
		return sorted_list
	else:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) > 0)
		return sorted_list

func colorize_text(text:String, color:Color):
	var color_hex: String = color.to_html(false)
	
	var color_start := "[color="+color_hex+"]"
	var color_end := "[/color]"

	var colorized_text = color_start + text + color_end
	return colorized_text