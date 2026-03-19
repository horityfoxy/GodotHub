extends Node

## WINDOWS SIGNALS ##
@warning_ignore("unused_signal")
signal settings_window_enable
@warning_ignore("unused_signal")
signal drag_and_drop_window_enable

## SCANING SYSTEM ##
@warning_ignore("unused_signal")
signal project_found(project_file_path: String)

## BUTTON HEADER SIGNALS ##
@warning_ignore("unused_signal")
signal switch_window_body(value: String)
@warning_ignore("unused_signal")
signal edit_button_pressed

## TAGS SIGNALS ##
@warning_ignore("unused_signal")
signal tag_count_change(project_id: String)
