@tool
class_name ListView extends VBoxContainer
var _current_list : Array[String] = []
var _button : PackedScene = preload("res://addons/todo-list-godot/prefabs/button.tscn")
@export var editor_scan : EditorScan
# TODO HOLA
# TODO Hello
# HELOU
func _enter_tree() -> void:
	editor_scan._script_founded_sign.connect(_update_tree_view)
	pass

func _exit_tree() -> void:
	pass

func _update_tree_view(content: Array[String]):
	if content == null:
		return
	
	content.map(func(line_content):
		var has_item := _current_list.has(line_content)
		if line_content == null or has_item:
			return
		
		_current_list.append(line_content)
		_current_list.map(func(item): print("In my list, have:", item))
		var button = _button.instantiate()
		button.text = line_content
		add_child(button)
		)
	pass
