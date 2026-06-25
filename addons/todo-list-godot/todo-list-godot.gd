@tool
extends EditorPlugin
# @icon("path/to/icon.svg")
const dock_scene = preload("res://addons/todo-list-godot/list-view/list-view.tscn")
const title: String = "TODO-List"
var dock # membro da classe que guarda o comportamento do dock durante o ciclo de vida do plugin

func _enter_tree() -> void:
	dock = EditorDock.new()
	var list_scene = dock_scene.instantiate()
	dock.add_child(list_scene)
	
	dock.title = title
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	dock.available_layouts = EditorDock.DOCK_LAYOUT_ALL
	add_dock(dock)

func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
	dock = null
