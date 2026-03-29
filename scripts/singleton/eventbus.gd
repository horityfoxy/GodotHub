extends Node

## WINDOWS SIGNALS ##
@warning_ignore("unused_signal")
signal settings_window_enable
@warning_ignore("unused_signal")
signal drag_and_drop_window_enable
@warning_ignore("unused_signal")
signal godot_engine_download_window_enable
@warning_ignore("unused_signal")
signal activate_window_or_switch

## SCANING SYSTEM ##
@warning_ignore("unused_signal")
signal project_found(project_file_path: String)
@warning_ignore("unused_signal")
signal project_removed

## BUTTON HEADER SIGNALS ##
@warning_ignore("unused_signal")
signal switch_window_body(value: String)
@warning_ignore("unused_signal")
signal edit_button_pressed

## TAGS SIGNALS ##
@warning_ignore("unused_signal")
signal tag_count_change(project_id: String)

## VIRSION MANAGER ##
@warning_ignore("unused_signal")
signal version_update
@warning_ignore("unused_signal")
signal godot_installed_version_changed

## PROJECTS SIGNALS ##
@warning_ignore("unused_signal")
signal ui_project_list_updated

## PATH FIX SIGNALS ##
@warning_ignore("unused_signal")
signal fix_path_activate(id : String, is_engine_mode)

## VERSION CHANGER ##
@warning_ignore("unused_signal")
signal version_change(id : String)

## ICONS CHANGER SIGNAL ##
@warning_ignore("unused_signal")
signal change_icon_required(id : String)
