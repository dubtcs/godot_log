extends Node

# Add this file as an Autoload, then access the functions through that.

var MAX_HISTORY: int = 256;

## Used to customize log messages. Use placeholders to mark where you want specific information.
## LOG_TIME : Current runtime in MMM:SS.SSS
## LOG_STACK : Current frame info as FOLDER/../FOLDER/SOURCE:LINE_NUMBER
## LOG_SOURCE : Script source path as FOLDER/../FOLDER/SOURCE
## LOG_TEXT : Message text. You want this in every format.
const DEFAULT_FORMAT: String = "[{LOG_TIME}] {LOG_STACK} - {LOG_TEXT}";

var FORMAT_PRINT: String = DEFAULT_FORMAT;
var FORMAT_INFO: String = DEFAULT_FORMAT;
var FORMAT_WARN: String = DEFAULT_FORMAT;
var FORMAT_ERROR: String = DEFAULT_FORMAT;

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
	__Push(__Format(FORMAT_PRINT, content), MSG_PRINT);
	return;
	
## Push an info message. Effectively Print(), but with a different token for differentiation if you want
func Info(content: Variant) -> void:
	__Push(__Format(FORMAT_INFO, content), MSG_INFO);
	return;
	
## Push a warning with timestamp. Format [mmm:ss.sss] - msg
func Warn(content: Variant) -> void:
	__Push(__Format(FORMAT_WARN, content), MSG_WARN);
	return;
	
## Push an error with timestamp. Format [mmm:ss.sss] - msg
func Error(content: Variant) -> void:
	__Push(__Format(FORMAT_ERROR, content), MSG_ERROR);
	return;
	
## Returns an array of all current log messages. Used to fill an in game console
func GetHistory() -> Array[LogItem]:
	return history;
	
func __VarStr(v: Variant) -> String:
	if(not (v is String)):
		return str(v);
	return v;

func __Format(fmat: String, text: String) -> String:
	fmat = __Timestamp(fmat);
	fmat = __Stack(fmat);
	fmat = __Source(fmat);
	fmat = __Content(fmat, text);
	return fmat;

func __Push(text: String, priority: LogPriority) -> void:
	while(history.size() >= MAX_HISTORY):
		history.pop_front();
	match priority:
		MSG_ERROR:	printerr(text);
		_:			print(text);
	history.push_back(LogItem.new(text, priority));
	on_message.emit(history.back());
	return;

func __Content(s: String, text: String) -> String:
	return s.format({ "LOG_TEXT": text });

func __Timestamp(text: String) -> String:
	var ticks: int = Time.get_ticks_msec();
	var seconds: float = (float(ticks) / 1000.0);
	var minu: int = seconds / 60;
	seconds -= 60 * ((ticks / 1000) / 60);
	var tstr: String = ("%3d:%6.3f" % [minu, seconds]);
	return text.format({ "LOG_TIME": tstr });
	
func __Stack(text: String) -> String:
	# get_stack only works in debug, so to prevent returning empty ": - msg" strings, just ignore if not debug
	if(OS.is_debug_build()):
		var stk: Array[Dictionary] = get_stack();
		if(stk.size() >= 3):
			var frame: Dictionary = stk[2];
			var stext: String = ("{src}:{ln}").format({ "src":frame.get("source"), "ln":frame.get("line") });
			return text.format({ "LOG_STACK": stext });
	return text.format({ "LOG_STACK": "" });

func __Source(text: String) -> String:
	return text.format({ "LOG_SOURCE": get_script().get_path() });
