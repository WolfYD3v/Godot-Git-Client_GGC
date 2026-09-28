@tool
extends VBoxContainer
class_name GGC_BaseError

@onready var error_text_label: Label = $ErrorTextLabel

@export var text: String = "TEXT":
	set(value):
		text = value
		if is_node_ready(): update_error_text()

func _ready() -> void:
	hide()

func update_error_text() -> void:
	error_text_label.text = text

func set_display(displayble: bool) -> void:
	visible = displayble
