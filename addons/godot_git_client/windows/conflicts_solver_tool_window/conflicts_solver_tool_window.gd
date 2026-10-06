@tool
extends GGC_BaseWindow
class_name GGC_ConflictsSolverToolWindow

@onready var conflicted_files_code_edit: CodeEdit = %ConflictedFilesCodeEdit
@onready var files_list: VBoxContainer = %FilesList
@onready var ggc_execute_shell: GGC_Execute_Shell = $GGC_ExecuteShell
@onready var save_file_button: Button = %SaveFileButton

var current_file_path: String = ""

func _ready() -> void:
	super()
	var action_popup = popup
	var action_close = close
	ggc_execute_shell.execute("git", ["ls-files", "-u"])
	
	conflicted_files_code_edit.text_set.connect(set_save_file_button_clickability)
	conflicted_files_code_edit.text_changed.connect(set_save_file_button_clickability)
	set_save_file_button_clickability()



func cmd_output_to_array(cmd_output: String) -> PackedStringArray:
	var output: PackedStringArray = cmd_output.split("\n", false)
	return output

func try_clear_files_list() -> void:
	for file: Control in files_list.get_children(): file.queue_free()

func fill_files_list(files: PackedStringArray) -> void:
	try_clear_files_list()
	
	for file: String in files:
		var button: Button = Button.new()
		button.text = file.get_file()
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(set_conflicted_file_code_edit.bind(file))
		files_list.add_child(button)

func set_conflicted_file_code_edit(file_path: String) -> void:
	print(file_path)
	current_file_path = file_path
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		conflicted_files_code_edit.text = file.get_as_text()
		file.close()

func set_save_file_button_clickability() -> void:
	var empty: bool = conflicted_files_code_edit.text == ""
	save_file_button.disabled = empty



func _on_ggc_execute_shell_execution_done(ggc_execute_sheel_output: GGC_ExecuteSheelOutput) -> void:
	match ggc_execute_sheel_output.action:
		"git lsfiles":
			var temp_conflicted_files_array: PackedStringArray = cmd_output_to_array(ggc_execute_sheel_output.output[0])
			print(temp_conflicted_files_array)
			var real_conflicted_files_array: PackedStringArray = []
			for file: String in temp_conflicted_files_array:
				var e = file.split(" ")[2].split("\t")[1]
				if not e in real_conflicted_files_array: real_conflicted_files_array.append(e)
			print(real_conflicted_files_array)
			fill_files_list(real_conflicted_files_array)
		_: pass


func _on_save_file_button_pressed() -> void:
	var file = FileAccess.open(current_file_path, FileAccess.WRITE)
	if file:
		file.store_string(conflicted_files_code_edit.text)
		file.close()
