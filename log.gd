extends Node

# Add this file as an Autoload, then access the functions through that.

@export var MAX_HISTORY: int = 256;

## Dispatches an alert containing the message and priorty
## Passed argument is of type Log.LogItem := <String, Log.LogPriority>
## Usage:
## [codeblock lang=gdscript]
## Log.on_message.connect(func(item: Log.LogItem):
## 		match item.priorty:
##			Log.MSG_PRINT: print(item.text);
##			Log.MSG_INFO: ...;
## [/codeblock]
signal on_message(item: LogItem);

enum LogPriority{ PRINT, INFO, WARN, ERROR };

const MSG_PRINT: LogPriority = LogPriority.PRINT;
const MSG_INFO: LogPriority = LogPriority.INFO;
const MSG_WARN: LogPriority = LogPriority.WARN;
const MSG_ERROR: LogPriority = LogPriority.ERROR;

class LogItem:
	func _init(txt: String, prior: LogPriority) -> void:
		text = txt;
		priority = prior;
	var text: String;
	var priority: LogPriority;

var history: Array[LogItem] = [];

## Push a standard message
func Print(content: Variant) -> void:
	content = __Tag(content);
	__Push(content, MSG_PRINT);
	return;
	
## Push an info message. Effectively Print(), but with a different token for differentiation if you want
func Info(content: Variant) -> void:
	content = __Tag(content);
	__Push(content, MSG_INFO);
	return;
	
## Push a warning with timestamp. Format [mmm:ss.sss] - msg
func Warn(content: Variant) -> void:
	content = __Tag(content);
	content = __Timestamp(content);
	__Push(content, MSG_WARN);
	return;
	
## Push an error with timestamp. Format [mmm:ss.sss] - msg
func Error(content: Variant) -> void:
	content = __Tag(content);
	content = __Timestamp(content);
	__Push(content, MSG_ERROR);
	return;
	
## Returns an array of all current log messages. Used to fill an in game console
func GetHistory() -> Array[LogItem]:
	return history;
	
func __Tag(content: Variant) -> String:
	return __Stack(__VarStr(content));
	
func __VarStr(v: Variant) -> String:
	if(not (v is String)):
		return str(v);
	return v;
	
func __Push(text: String, priority: LogPriority) -> void:
	while(history.size() >= MAX_HISTORY):
		history.pop_front();
	match priority:
		MSG_ERROR:	printerr(text);
		_:			print(text);
	history.push_back(LogItem.new(text, priority));
	on_message.emit(history.back());
	return;
	
func __Timestamp(text: String) -> String:
	var ticks: int = Time.get_ticks_msec();
	var seconds: float = (float(ticks) / 1000.0);
	var minu: int = seconds / 60;
	seconds -= 60 * ((ticks / 1000) / 60);
	var tstr: String = ("%3d:%6.3f" % [minu, seconds]);
	return ("[{t}] {msg}").format({ "t":tstr, "msg":text });
	
func __Stack(text: String) -> String:
	# get_stack only works in debug, so to prevent returning empty ": - msg" strings, just ignore if not debug
	if(OS.is_debug_build()):
		var stk: Array[Dictionary] = get_stack();
		if(stk.size() >= 3):
			var frame: Dictionary = stk[2];
			text = ("{src}:{ln} - {msg}").format({ "src":frame.get("source"), "fn":frame.get("function"), "ln":frame.get("line"), "msg":text });
	return text;
