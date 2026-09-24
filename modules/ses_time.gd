extends Resource
class_name SesTime


func get_datetime_string(utc: bool = false, spacing: String = "-", splitter: String = "T"):
	var dt = Time.get_datetime_dict_from_system(utc)
	var dt_str: String = "%04d"+spacing+"%02d"+spacing+"%02d"+splitter+"%02d"+spacing+"%02d"+spacing+"%02d" % [
		dt.year, dt.month, dt.day,	dt.hour, dt.minute, dt.second
	]
	return dt_str


func add_timedicts(...timedicts):
	var result_seconds: int = 0
	for i in timedicts:
		result_seconds += timedict_to_seconds(i)
	return seconds_to_timedict(result_seconds)


func subtract_timedicts(allow_negative: bool, ...timedicts):
	var result: int = timedict_to_seconds(timedicts.pop_front())
	for i in timedicts:
		result -= timedict_to_seconds(i)
	if allow_negative == false and result < 0:
		result = 0
	return seconds_to_timedict(result)


func add_seconds(timedict: Dictionary, seconds: int):
	var time_conversion: int = timedict_to_seconds(timedict)
	return seconds_to_timedict(time_conversion + seconds)


func subtract_seconds(allow_negative: bool, timedict: Dictionary, seconds: int):
	var time_conversion: int = timedict_to_seconds(timedict)
	if allow_negative == false and time_conversion < 0:
		time_conversion = 0
	return seconds_to_timedict(time_conversion - seconds)


func timedict_to_seconds(a: Dictionary):
	var total_seconds = (a.get("hour, 0") * 3600) + (a.get("minute", 0) * 60) + (a.get("second", 0))
	return total_seconds


func seconds_to_timedict(a: int):
	var hours: int = int(a / 3600)
	var minutes: int = int((a % 3600) / 60)
	var seconds: int = a % 60
	var timedictionary: Dictionary = {"hour": hours, "minute": minutes, "second": seconds}
	return timedictionary


func time_addition(a: Dictionary, b: Dictionary):
	var total_seconds = timedict_to_seconds(a) + timedict_to_seconds(b)
	return seconds_to_timedict(total_seconds)


func time_subtraction(a: Dictionary, b: Dictionary, allow_negative_result: bool = false) -> Dictionary:
	var total_seconds: int = timedict_to_seconds(a) - timedict_to_seconds(b)
	if total_seconds < 0 and allow_negative_result == true:
		var zero_dict: Dictionary = {"hour": 0, "minute": 0, "second": 0}
		return zero_dict
	return seconds_to_timedict(total_seconds)