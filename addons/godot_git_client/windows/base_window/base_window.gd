@tool
extends Control
class_name GGC_BaseWindow

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_tool_button("POPUP", "Button") var action_popup = popup
@export_tool_button("CLOSE", "Button") var action_close = close

var _opened: bool = false
var _mouse_entered: bool = false
var dashboard: GGC_Dashboard = null

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _mouse_entered:
		take_focus()



func popup() -> void:
	take_focus()
	if animation_player.is_playing() or _opened: return
	
	show()
	animation_player.play("popup")
	_opened = true

func close() -> void:
	if animation_player.is_playing(): return
	
	animation_player.play("close")
	await animation_player.animation_finished
	_opened = false
	hide()

func take_focus() -> void:
	var parent_node: Control = get_parent()
	parent_node.move_child(self, parent_node.get_child_count() - 1)



func _on_mouse_entered() -> void: _mouse_entered = true

func _on_mouse_exited() -> void: _mouse_entered = false
