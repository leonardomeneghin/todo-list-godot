@tool
class_name EditorScan extends Node

var script_pool : Array[String] = []
var _watch : Dictionary #format: resource path -> script
var _current_path : String

func _enter_tree() -> void:
	var script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_editor_script_changed)
	EditorInterface.get_resource_filesystem().resources_reload.connect(_on_resource_reload)
	_try_hook_current_editor()
	pass

func _exit_tree() -> void:
	var script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
	EditorInterface.get_resource_filesystem().resources_reload.disconnect(_on_resource_reload)
	for s : Script in _watch.values(): #Desconectar cada script do sistema de script changed
		if s.changed.is_connected(_on_editor_script_changed):
			s.changed.disconnect(_on_editor_script_changed)
	pass

func _on_editor_script_changed(script: Script) -> void:
	print("Script loaded by editor script change")
	_current_path = script.resource_path if script else ""
	if script == null or script in _watch.values():
		return
	if not script.changed.is_connected(_on_editor_script_changed):
		_watch[script.resource_path] = script
	_try_hook_current_editor()
	pass

#cobre salvamento via editor externo
func _on_resource_reload(paths: PackedStringArray) -> void:
	for path in paths:
		if path.get_extension() in ["gd", "cs"]:
			add_to_file_pool(path)
	pass


# adiciona o arquivo na pool de arquivos para processar pelo regex
func add_to_file_pool(path: String) -> void:
	if path not in script_pool:
		script_pool.append(path)
	pass

# faz o hook pra conectar o sinal do text_changed
func _try_hook_current_editor() -> void:
	var script_editor := EditorInterface.get_script_editor()
	var current_editor := script_editor.get_current_editor()
	if current_editor == null: # Se não tiver nada no current editor, não faz hook
		return
	var base_editor := current_editor.get_base_editor() as CodeEdit
	if base_editor and base_editor is CodeEdit:
		if not base_editor.text_changed.is_connected(_on_text_changed):
			base_editor.text_changed.connect(_on_text_changed)
	pass

func _on_text_changed() -> void:
	add_to_file_pool(_current_path)
