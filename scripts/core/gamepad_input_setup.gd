class_name GamepadInputSetup
extends RefCounted

static var configured: bool = false


static func ensure_configured() -> void:
	if configured:
		return
	configured = true
	
	ensure_action("move_up")
	ensure_action("move_down")
	ensure_action("move_left")
	ensure_action("move_right")
	ensure_action("pause_game")
	ensure_action("restart_run")
	ensure_action("menu_previous")
	ensure_action("menu_next")
	
	add_key("pause_game", KEY_ESCAPE)
	add_key("pause_game", KEY_P)
	add_key("restart_run", KEY_R)
	
	add_joy_button("pause_game", JOY_BUTTON_START)
	add_joy_button("restart_run", JOY_BUTTON_X)
	add_joy_button("menu_previous", JOY_BUTTON_LEFT_SHOULDER)
	add_joy_button("menu_next", JOY_BUTTON_RIGHT_SHOULDER)
	
	add_joy_motion("move_left", JOY_AXIS_LEFT_X, -1.0)
	add_joy_motion("move_right", JOY_AXIS_LEFT_X, 1.0)
	add_joy_motion("move_up", JOY_AXIS_LEFT_Y, -1.0)
	add_joy_motion("move_down", JOY_AXIS_LEFT_Y, 1.0)
	add_joy_button("move_left", JOY_BUTTON_DPAD_LEFT)
	add_joy_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	add_joy_button("move_up", JOY_BUTTON_DPAD_UP)
	add_joy_button("move_down", JOY_BUTTON_DPAD_DOWN)
	
	ensure_ui_action("ui_accept")
	ensure_ui_action("ui_cancel")
	ensure_ui_action("ui_left")
	ensure_ui_action("ui_right")
	ensure_ui_action("ui_up")
	ensure_ui_action("ui_down")
	add_joy_button("ui_accept", JOY_BUTTON_A)
	add_joy_button("ui_cancel", JOY_BUTTON_B)
	add_joy_button("ui_left", JOY_BUTTON_DPAD_LEFT)
	add_joy_button("ui_right", JOY_BUTTON_DPAD_RIGHT)
	add_joy_button("ui_up", JOY_BUTTON_DPAD_UP)
	add_joy_button("ui_down", JOY_BUTTON_DPAD_DOWN)
	add_joy_motion("ui_left", JOY_AXIS_LEFT_X, -1.0)
	add_joy_motion("ui_right", JOY_AXIS_LEFT_X, 1.0)
	add_joy_motion("ui_up", JOY_AXIS_LEFT_Y, -1.0)
	add_joy_motion("ui_down", JOY_AXIS_LEFT_Y, 1.0)


static func ensure_ui_action(action: String) -> void:
	ensure_action(action)


static func ensure_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.25)


static func add_key(action: String, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	add_event_if_missing(action, event)


static func add_joy_button(action: String, button_index: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	add_event_if_missing(action, event)


static func add_joy_motion(action: String, axis: JoyAxis, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	add_event_if_missing(action, event)


static func add_event_if_missing(action: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.25)
	
	var event_text := event.as_text()
	for existing_event in InputMap.action_get_events(action):
		if existing_event.as_text() == event_text:
			return
	InputMap.action_add_event(action, event)
