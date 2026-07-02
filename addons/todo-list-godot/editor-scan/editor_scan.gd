@tool
class_name EditorScan extends Node

# ########################SIGNALS#######################
signal _script_founded_sign(script :Array[String])
########################################################

# #####################PRIVATE_VARS#####################
var _watch : Dictionary[String, Script] #format: resource path -> script
var _current_path : String = ""
var _regex_scan : RegexScan
########################################################

#######################PUBLIC_VARS######################
# script pool é para load externo
var script_pool : Array[String] = [] # guarda o path do script
# TODO: Sempre que tiver uma mudança no current, devo enviar um sinal
# TODO: AVISAR O ListView quando algo está mudando e deixa-lo renderizar.
# TODO: _on_resource_reload deve avisar uma vez ao ListView quando algo carregar
func _enter_tree() -> void:
	_regex_scan = RegexScan.new()
	var script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(_on_editor_script_changed)
	EditorInterface.get_resource_filesystem().resources_reload.connect(_on_resource_reload)
	_try_hook_current_editor()
	pass

func _exit_tree() -> void:
	_regex_scan = null
	var script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
	EditorInterface.get_resource_filesystem().resources_reload.disconnect(_on_resource_reload)
	for s : Script in _watch.values(): #Desconectar cada script do sistema de script changed
		if s.changed.is_connected(_on_editor_script_changed):
			s.changed.disconnect(_on_editor_script_changed)
	pass

func _on_editor_script_changed(script: Script) -> void:
	_current_path = script.resource_path if script else ""
	if script == null or script in _watch.values():
		return
	if not script.changed.is_connected(_on_editor_script_changed):
		_watch[script.resource_path] = script
	_try_hook_current_editor()
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

#cobre salvamento via editor externo
func _on_resource_reload(paths: PackedStringArray) -> void:
	for path in paths:
		if path.get_extension() in ["gd", "cs"]:
			add_to_file_pool(path)
	pass

	
func _on_text_changed() -> void:
	if _regex_scan == null:
		push_error("%s has _regex_scan null" % name)
	var value_dict := _watch.get(_current_path)
	if value_dict:
		var matches := _regex_scan.MatchCaseTodo(_current_path)
		# do a if a else b
		if not matches == null:
			_script_founded_sign.emit(matches)
		# now we need to populate our list view
	
# adiciona o arquivo na pool de arquivos para processar pelo regex
func add_to_file_pool(path: String) -> void:
	if path not in script_pool:
		script_pool.append(path)
	pass
