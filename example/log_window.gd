extends Control

# Simple example if using the Log class to build an in game console window

# Scene used to create labels for log items
var labelScene: PackedScene = preload("res://example/log_label.tscn");

# Relevant child nodes
@onready var scrollFrame: ScrollContainer = $"MarginContainer/VBoxContainer/ScrollContainer";
@onready var contentFrame: VBoxContainer = $"MarginContainer/VBoxContainer/ScrollContainer/Content";

# Colors for each statement. Print is default.
const COLOR_INFO: String = "#a8e4a0";
const COLOR_WARN: String = "#fab74a";
const COLOR_ERROR: String = "#ff5050";

func _ready() -> void:
	Log.on_message.connect(OnLogMessage);
	# If the UI is loaded after some messages, you can use GetHistory to add previous messages
	for item: Log.LogItem in Log.GetHistory():
		OnLogMessage(item);
	return;
	
# Read response and take action based on item.priortiy
func OnLogMessage(item: Log.LogItem) -> void:
	var label: RichTextLabel = labelScene.instantiate();
	match item.priority:
		Log.MSG_PRINT:
			label.text = item.text;
		Log.MSG_INFO:
			label.text = ("[color={COLOR}]{TEXT}[/color]").format({ "COLOR": COLOR_INFO, "TEXT": item.text });
		Log.MSG_WARN:
			label.text = ("[color={COLOR}]{TEXT}[/color]").format({ "COLOR": COLOR_WARN, "TEXT": item.text });
		Log.MSG_ERROR:
			label.text = ("[color={COLOR}]{TEXT}[/color]").format({ "COLOR": COLOR_ERROR, "TEXT": item.text });
	PushLabel(label);
	return;

# Add the label to the history container, and remove elements beyond the MAX_HISTORY (optional)
func PushLabel(label: RichTextLabel) -> void:
	while(contentFrame.get_child_count() >= Log.MAX_HISTORY):
		var child: Node = contentFrame.get_child(0);
		contentFrame.remove_child(child);
		child.queue_free();
	contentFrame.add_child(label);
	return;

# Connected to ScrollContainer.child_entered_tree
# Automatically scrolls the container down when a new child is added
func AdjustScroll(_child: Node) -> void:
	var scrollbar: VScrollBar = scrollFrame.get_v_scroll_bar();
	scrollFrame.scroll_vertical = scrollbar.max_value;
	return;
