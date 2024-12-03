
# Logger

A simple log I got tired of writing for my godot projects so I made it into a repo.

It stores message history to be used as an in game console if you'd like.

## Usage

Register ```log.gd``` as an Autoload in prject settings. Then, simply call any of the functions to send a message with a given priority.


```
func Example() -> void:
    ...
    Log.Print("This is a message");
    ...
    return;

func Example2() -> void:
    ...
    Log.Warn("HOLY SHIT!");
    ...
    return;
```

The class has one signal, ```on_message```, which dispatches each time any message is sent. You can hook into this to do something with said messages as they come through.

```
...
# Connect the signal
Log.on_message.connect(OnMessage);
...

func OnMessage(item: Log.LogItem) -> void:
    match item.priority:
        Log.MSG_PRINT: print(item.text);
        Log.MSG_INFO: ...;
        ...
```

## Functionality

### `Print(content: Variant) -> void`

Takes any argument and stores it as text with a timestamp. Prints this message to the godot console.

### `Info(content: Variant) -> void`

Effectively Print(). Takes any argument and stores it as text with a timestamp. Prints this message to the godot console.

### `Warn(content: Variant) -> void`

Takes any argument and stores it as text with a timestamp and script location. Prints this message to the godot console.

### `Error(content: Variant) -> void`

Takes any argument and stores it as text with a timestamp and script location. **Prints an error to the godot console.**

### `GetHistory() -> Array[LogItem]`

Returns all current log items in history.

### `signal on_message(item: LogItem)`

Fired each time any message is sent. Includes a `LogItem` of the message, which contains the message string itself and its priority.

### `MAX_HISTORY: int`

Maximum history length. Default 256.

### `LogItem`

Internal class used to storing messages and their priority/type. This is sent with each `on_message` signal and the array from `GetHistory()`.

```
class LogItem:
    var text: String;
    var priority: LogPriority;
```
