@tool
extends HBoxContainer
class_name GGC_Remote

@onready var infos_container: VBoxContainer = %InfosContainer
@onready var remote_name_rich_text_label: RichTextLabel = %RemoteNameRichTextLabel
@onready var remote_fetch_url_rich_text_label: RichTextLabel = %RemoteFetchURLRichTextLabel
@onready var remote_pull_url_rich_text_label: RichTextLabel = %RemotePullURLRichTextLabel
@onready var edit_infos_container: VBoxContainer = %EditInfosContainer
@onready var remote_name_text_edit: TextEdit = %RemoteNameTextEdit
@onready var remote_url_text_edit: TextEdit = %RemoteURLTextEdit
@onready var edit_action_button: Button = %EditActionButton
@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var remove_action_button: Button = %RemoveActionButton
@onready var cancel_new_remote_action_button: Button = %CancelNewRemoteActionButton

@export var remote_name: String = "Remote_Name":
	set(value):
		remote_name = value
		if is_node_ready(): update_infos()
@export var remote_url: String = "Remote_URL":
	set(value):
		remote_url = value
		if is_node_ready(): update_infos()

const FORBIDDEN_CHARACTERS_IN_REMOTE_NAME: Array[String] = [
	' ', '\t', '\n', '\r', '/', '\\', ':', '*', '?', '"', '<', '>',
	'|', '~', '^', '[', ']', '{', '}', '@', '#', '%', '`', ".."
]

var editing_infos: bool = false
var edit_action_button_texts: Dictionary[bool, String] = {
	true: "UPDATE",
	false: "EDIT"
}
var old_remote_name: String = ""
var git_remote_updating_url: bool = false
var created: bool = false:
	set(value):
		created = value
		cancel_new_remote_action_button.visible = created
		if is_node_ready() and created: toggle_editing()



func _ready() -> void:
	edit_action_button.text = edit_action_button_texts.get(editing_infos)
	infos_container.show()
	edit_infos_container.hide()
	update_infos()
	init_edit_infos_container()
	
	remote_name_text_edit.text_changed.connect(check_if_edited_infos_are_valid)
	remote_name_text_edit.text_set.connect(check_if_edited_infos_are_valid)
	remote_url_text_edit.text_changed.connect(check_if_edited_infos_are_valid)
	remote_url_text_edit.text_set.connect(check_if_edited_infos_are_valid)



func update_infos() -> void:
	remote_name_rich_text_label.text = "[b]%s[/b]" % remote_name
	remote_fetch_url_rich_text_label.text = "%s [i][ fetch ][/i]" % remote_url
	remote_pull_url_rich_text_label.text = "%s [i][ pull ][/i]" % remote_url

func init_edit_infos_container() -> void:
	remote_name_text_edit.text = remote_name
	remote_name_text_edit.placeholder_text = remote_name
	remote_url_text_edit.text = remote_url
	remote_url_text_edit.placeholder_text = remote_url

func apply_changes() -> void:
	old_remote_name = remote_name
	if remote_name_text_edit.text != "": remote_name = remote_name_text_edit.text
	else: remote_name = remote_name_text_edit.placeholder_text
	if remote_url_text_edit.text != "": remote_url = remote_url_text_edit.text
	else: remote_name = remote_url_text_edit.placeholder_text
	
	git_remote_updating_url = false
	ggc_execute_shell.execute("git", ["remote", "rename", old_remote_name, remote_name])
	print(remote_name)
	print(remote_url)

func toggle_editing() -> void:
	editing_infos = not(editing_infos)
	remove_action_button.visible = not(editing_infos)
	remove_action_button.disabled = editing_infos
	if created: edit_action_button.text = "CREATE"
	else: edit_action_button.text = edit_action_button_texts.get(editing_infos)
	infos_container.visible = not(editing_infos)
	edit_infos_container.visible = editing_infos
	if editing_infos: init_edit_infos_container()

func check_if_edited_infos_are_valid() -> void:
	edit_action_button.disabled = remote_name_text_edit.text == "" or remote_url_text_edit.text == ""
	for _e: String in FORBIDDEN_CHARACTERS_IN_REMOTE_NAME:
		if remote_name_text_edit.text.contains(_e): edit_action_button.disabled = true

func _on_edit_action_button_pressed() -> void:
	if editing_infos: apply_changes()
	toggle_editing()
	
	if created:
		remove_action_button.show()
		remove_action_button.disabled = false
		ggc_execute_shell.execute("git", ["remote", "add", remote_name, remote_url])
		edit_action_button.text = edit_action_button_texts.get(false)

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git remote":
			if not git_remote_updating_url and not created:
				print(ggc_execute_sheel_output.output)
				git_remote_updating_url = true
				ggc_execute_shell.execute("git", ["remote", "set-url", remote_name, remote_url])
			elif created:
				print("zed")
				created = false
			else: git_remote_updating_url = false

func _on_remove_action_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["remote", "remove", remote_name])
	queue_free.call_deferred()

func _on_cancel_new_remote_action_button_pressed() -> void:
	queue_free.call_deferred()
