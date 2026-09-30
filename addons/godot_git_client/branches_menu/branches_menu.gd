@tool
extends MarginContainer
class_name GGC_BranchesMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var branches_nodes: VBoxContainer = $BranchessMenuMarginContainer/NODES/BranchesContainer/BranchesMarginContainer/ScrollContainer/NODES/NODES
@onready var toggle_branches_button: Button = $BranchessMenuMarginContainer/ToggleBranchesButton
@onready var branches_label: Label = $BranchessMenuMarginContainer/NODES/BranchesLabel

@export_tool_button("TOGGLE", "Button") var action_toggle = _on_toggle_branches_button_pressed

const GGC_BRANCH_ITEM_PACKED_SCENE: PackedScene = preload("res://addons/godot_git_client/branches_menu/branch_item.tscn")

var toggled: bool = true
var saved_toggled_size: Vector2 = Vector2.ZERO
var untoggled_size: Vector2 = Vector2.ZERO
var tween: Tween = null
var dashboard: GGC_Dashboard = null

func _ready() -> void:
	saved_toggled_size = custom_minimum_size
	untoggled_size = Vector2(saved_toggled_size.x, branches_label.size.y)
	set_toggled_branches_menu_state()
	clear_branches()



func update_branches(input: Array, clear_before: bool = true) -> void:
	var text_input: String = input[0]
	text_input = text_input.replace("fatal: ", "")
	var branches_list: PackedStringArray = text_input.split("\n", false)
	
	if clear_before: clear_branches()
	
	for branch: String in branches_list:
		var ggc_branch_item: GGC_BranchItem = GGC_BRANCH_ITEM_PACKED_SCENE.instantiate()
		ggc_branch_item.branch_name = branch
		ggc_branch_item.notify_update_for_branch_menu.connect(
			func(): if dashboard: dashboard.fire_git_branch_command()
		)
		branches_nodes.add_child(ggc_branch_item)

func clear_branches() -> void:
	for branch_item in branches_nodes.get_children(): branch_item.queue_free()

func set_toggled_branches_menu_state() -> void:
	if toggled:
		toggle_branches_button.text = "⮝"
		tween_branches_menu(saved_toggled_size)
	else:
		toggle_branches_button.text = "⮟"
		tween_branches_menu(untoggled_size)

func tween_branches_menu(_new_size: Vector2, _duration: float = 1.0) -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.set_parallel()
	tween.tween_property(self, "custom_minimum_size", _new_size, _duration)
	tween.tween_property(self, "size", _new_size, _duration)



func _on_toggle_branches_button_pressed() -> void:
	toggled = not(toggled)
	set_toggled_branches_menu_state()

func _on_new_branch_button_pressed() -> void:
	pass
