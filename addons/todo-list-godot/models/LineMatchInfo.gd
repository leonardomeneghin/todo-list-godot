class_name LineMatchInfo extends Node

var _script_name : String
var _pos_match_ini : int
# GETTERS AND SETTERS ON
var script_name: String:
	get:
		return _script_name
	set(value):
		if not value == null or not value == "":
			_script_name = value
		else:
			push_warning("script_name cannot be null or empty.")

var pos_match_ini: int:
	get:
		return _pos_match_ini
	set(value):
		if value >=0:
			_pos_match_ini = value
		else:
			push_warning("pos_match_ini cannot be negative.")
# GETTERS AND SETTERS OFF
func _init(String:) -> void:
	pass
