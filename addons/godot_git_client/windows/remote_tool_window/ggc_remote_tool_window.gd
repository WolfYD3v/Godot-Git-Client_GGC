@tool
extends GGC_BaseWindow
class_name GGC_RemoteToolWindow

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var remotes_count_label: Label = %RemotesCountLabel
@onready var remotes_list: VBoxContainer = %RemotesList

const GGC_REMOTE_SCENE: PackedScene = preload("res://addons/godot_git_client/windows/remote_tool_window/ggc_remote.tscn")



func _ready() -> void:
	super()
	var action_popup = popup
	var action_close = close
	
	clear_remotes_list()
	ggc_execute_shell.execute("git", ["remote", "-v"])
	
	remotes_list.pre_sort_children.connect(update_remotes_count)
	remotes_list.sort_children.connect(update_remotes_count)



func clear_remotes_list() -> void:
	for _remote: Control in remotes_list.get_children(): _remote.queue_free()

func update_remotes_list(remotes_to_add: PackedStringArray) -> void:
	clear_remotes_list()
	
	var current_remote: String = ""
	for _current_remote: String in remotes_to_add:
		var current_remote_infos: PackedStringArray = _current_remote.replace("	", "€").replace("(", "€").split("€", false)
		if current_remote_infos[0] != current_remote:
			current_remote = current_remote_infos[0]
			create_remote(current_remote_infos[0], current_remote_infos[1])
	
	update_remotes_count()

func update_remotes_count() -> void:
	remotes_count_label.text = str(remotes_list.get_child_count())

func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	
	return output

func create_remote(_remote_name: String, _remote_url: String, editing: bool = false) -> void:
	var ggc_remote: GGC_Remote = GGC_REMOTE_SCENE.instantiate()
	ggc_remote.remote_name = _remote_name
	ggc_remote.remote_url = _remote_url
	remotes_list.add_child(ggc_remote)
	remotes_list.move_child(ggc_remote, 0)
	ggc_remote.update_infos()
	ggc_remote.created = editing



func _on_new_remote_button_pressed() -> void:
	var new_remote_name: String = ""
	if remotes_list.get_child_count() <= 0: new_remote_name = "origin"
	else: new_remote_name = "New_Remote_%s" % remotes_list.get_child_count()
	create_remote(new_remote_name, "", true)
	update_remotes_count()

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git remote": update_remotes_list(cmd_output_to_array(ggc_execute_sheel_output.output[0]))
		_: pass
