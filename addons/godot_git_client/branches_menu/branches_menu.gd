@tool
extends MarginContainer
class_name GGC_BranchesMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var logs_nodes: VBoxContainer = $LogsMenuMarginContainer/NODES/LogsContainer/LogsMarginContainer/ScrollContainer/NODES
@onready var toggle_logs_button: Button = $LogsMenuMarginContainer/ToggleLogsButton
@onready var logs_label: Label = $LogsMenuMarginContainer/NODES/LogsLabel

@export_tool_button("TOGGLE", "Button") var action_toggle = _on_toggle_logs_button_pressed

var toggled: bool = true
var saved_toggled_size: Vector2 = Vector2.ZERO
var untoggled_size: Vector2 = Vector2.ZERO
var tween: Tween = null

func _ready() -> void:
	saved_toggled_size = custom_minimum_size
	untoggled_size = Vector2(saved_toggled_size.x, logs_label.size.y)
	set_toggled_logs_menu_state()
	clear_logs()



func update_logs(input: Array, clear_before: bool = true) -> void:
	var text_input: String = input[0]
	text_input = text_input.replace("fatal: ", "")
	var logs_list: PackedStringArray = text_input.split("\n", false)
	
	if clear_before: clear_logs()
	
	for log: String in logs_list:
		var ggc_log_item: GGC_LogItem = GGC_LogItem.new()
		ggc_log_item.text = log
		logs_nodes.add_child(ggc_log_item)

func clear_logs() -> void:
	for log_item in logs_nodes.get_children(): log_item.queue_free()

func set_toggled_logs_menu_state() -> void:
	if toggled:
		toggle_logs_button.text = "⮝"
		tween_logs_menu(saved_toggled_size)
	else:
		toggle_logs_button.text = "⮟"
		tween_logs_menu(untoggled_size)

func tween_logs_menu(_new_size: Vector2, _duration: float = 1.0) -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.set_parallel()
	tween.tween_property(self, "custom_minimum_size", _new_size, _duration)
	tween.tween_property(self, "size", _new_size, _duration)



func _on_toggle_logs_button_pressed() -> void:
	toggled = not(toggled)
	set_toggled_logs_menu_state()
