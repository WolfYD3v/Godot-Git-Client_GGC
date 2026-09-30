@tool
extends Control
class_name GGC_BranchItem

signal notify_update_for_branch_menu

@export var branch_name: String = ""

@onready var container: VBoxContainer = %Container
@onready var branch_name_label: Label = $Container/BranchNameLabel
@onready var switch_button: Button = $Container/ActionsContainer/SwitchButton
@onready var delete_button: Button = $Container/ActionsContainer/DeleteButton

@onready var create_new_branch_form_container: VBoxContainer = %CreateNewBranchFormContainer
@onready var new_branch_name_line_edit: LineEdit = $CreateNewBranchFormContainer/NewBranchNameLineEdit
@onready var create_button: Button = $CreateNewBranchFormContainer/ActionsContainer/CreateButton
@onready var create_and_switch_button: Button = $CreateNewBranchFormContainer/ActionsContainer/CreateAndSwitchButton
@onready var cancel_button: Button = $CreateNewBranchFormContainer/ActionsContainer/CancelButton

@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell

const FORBIDDEN_CHARACTERS_IN_BRANCH_NAME: Array[String] = [
	' ', '\t', '\n', '\r', '\\', ':', '*', '?', '"', '<', '>',
	'|', '~', '^', '[', ']', '{', '}', '@', '#', '%', '`', ".."
]

var currently_selected: bool = false
var stashing: bool = false
var creating: bool = false



func _ready() -> void:
	toggle_containers()
	
	if creating: a()
	else: init_container()



func toggle_containers() -> void:
	container.visible = not(creating)
	create_new_branch_form_container.visible = creating
	if creating: new_branch_name_line_edit.text = ""

func init_container() -> void:
	creating = false
	toggle_containers()
	
	var _name: String = branch_name.right(-2)
	if _name in ["main", "master"]: delete_button.queue_free()
	if branch_name_label: branch_name_label.text = _name
	
	print(branch_name)
	currently_selected = branch_name.begins_with("*")
	print(currently_selected)
	switch_button.disabled = currently_selected
	delete_button.disabled = currently_selected

func a() -> void:
	for btn: Button in [create_button, create_and_switch_button]:
		btn.disabled = new_branch_name_line_edit.text == ""
		for _e: String in FORBIDDEN_CHARACTERS_IN_BRANCH_NAME: if new_branch_name_line_edit.text.contains(_e): btn.disabled = true
		for _f: String in [".", "/"]: if new_branch_name_line_edit.text.begins_with(_f): btn.disabled = true
		for _g: String in [".", "/"]: if new_branch_name_line_edit.text.ends_with(_g): btn.disabled = true
		for _h: String in ["..", "//", "@{"]: if new_branch_name_line_edit.text.contains(_h): btn.disabled = true



func _on_create_button_pressed() -> void:
	branch_name = "  %s" % new_branch_name_line_edit.text
	init_container()
	ggc_execute_shell.execute("git", ["branch", new_branch_name_line_edit.text])

func _on_create_and_switch_button_pressed() -> void:
	branch_name = "  %s" % new_branch_name_line_edit.text
	init_container()
	ggc_execute_shell.execute("git", ["switch", "-C", new_branch_name_line_edit.text])

func _on_cancel_button_pressed() -> void:
	notify_update_for_branch_menu.emit()
	queue_free()

func _on_switch_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["stash"])

func _on_delete_button_pressed() -> void:
	ggc_execute_shell.execute("git", ["branch", "-D", branch_name_label.text])

func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git stash":
			stashing = not(stashing)
			if stashing: ggc_execute_shell.execute("git", ["switch", branch_name_label.text])
		"git switch":
			ggc_execute_shell.execute("git", ["stash", "pop"])
			notify_update_for_branch_menu.emit()
		"git branch": notify_update_for_branch_menu.emit()


func _on_new_branch_name_line_edit_text_changed(_new_text: String) -> void:
	a()

func _on_new_branch_name_line_edit_text_submitted(_new_text: String) -> void:
	a()
