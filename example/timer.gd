extends Timer

# Sends a message at a random level every second.
func timeout() -> void:
	var key: int = randi() % 4;
	match key:
		0: Log.Print("This is a print. {ii}".format({ "ii": randi() }));
		1: Log.Info("This is an info. {ii}".format({ "ii": randi() }));
		2: Log.Warn("This is a warn. {ii}".format({ "ii": randi() }));
		3: Log.Error("This is a warn. {ii}".format({ "ii": randi() }));
