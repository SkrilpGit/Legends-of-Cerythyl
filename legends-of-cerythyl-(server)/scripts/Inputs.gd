extends Node

## this is my pride and joy, because as far as I know godot still doesn't have
## a built in solution for match statements for actions, you can do it for keys
## because of course you can they're enums, but for actions it requires a little
## more effort.

var actions = []

## in the ready function I'm loading all the actions from the action map and removing
## the built in ones that I don't want to use, if I ever do want to use them I have to
## remove them from this beeeeg Array
func _ready() -> void:
	actions = InputMap.get_actions()
	for i in [
	#region system actions
	&"ui_accept", &"ui_select", &"ui_focus_next", &"ui_focus_prev", 
	&"ui_left", &"ui_right", &"ui_up", &"ui_down", &"ui_page_up", &"ui_page_down",
	&"ui_home", &"ui_end", &"ui_cut", &"ui_copy", &"ui_paste", &"ui_undo", &"ui_redo",
	&"ui_text_completion_query", &"ui_text_completion_accept",
	&"ui_text_completion_replace", &"ui_text_newline", &"ui_text_newline_blank",
	&"ui_text_newline_above", &"ui_text_indent", &"ui_text_dedent", &"ui_text_backspace",
	&"ui_text_backspace_word", &"ui_text_backspace_word.macos",
	&"ui_text_backspace_all_to_left", &"ui_text_backspace_all_to_left.macos",
	&"ui_text_delete", &"ui_text_delete_word", &"ui_text_delete_word.macos",
	&"ui_text_delete_all_to_right", &"ui_text_delete_all_to_right.macos",
	&"ui_text_caret_left", &"ui_text_caret_word_left", &"ui_text_caret_word_left.macos",
	&"ui_text_caret_right", &"ui_text_caret_word_right", &"ui_text_caret_word_right.macos",
	&"ui_text_caret_up", &"ui_text_caret_down", &"ui_text_caret_line_start",
	&"ui_text_caret_line_start.macos", &"ui_text_caret_line_end",
	&"ui_text_caret_line_end.macos", &"ui_text_caret_page_up", &"ui_text_caret_page_down",
	&"ui_text_caret_document_start", &"ui_text_caret_document_start.macos",
	&"ui_text_caret_document_end", &"ui_text_caret_document_end.macos",
	&"ui_text_caret_add_below", &"ui_text_caret_add_below.macos", &"ui_text_caret_add_above",
	&"ui_text_caret_add_above.macos", &"ui_text_scroll_up", &"ui_text_scroll_up.macos",
	&"ui_text_scroll_down", &"ui_text_scroll_down.macos", &"ui_text_select_all",
	&"ui_text_select_word_under_caret", &"ui_text_select_word_under_caret.macos",
	&"ui_text_add_selection_for_next_occurrence", &"ui_text_clear_carets_and_selection",
	&"ui_text_toggle_insert_mode", &"ui_menu", &"ui_text_submit", &"ui_graph_duplicate",
	&"ui_graph_delete", &"ui_filedialog_up_one_level", &"ui_filedialog_refresh",
	&"ui_filedialog_show_hidden", &"ui_swap_input_direction",
	&"ui_accessibility_drag_and_drop", &"ui_focus_mode",
	&"ui_text_skip_selection_for_next_occurrence", &"ui_unicode_start",
	&"ui_graph_follow_left", &"ui_graph_follow_left.macos", &"ui_graph_follow_right",
	&"ui_graph_follow_right.macos", &"ui_colorpicker_delete_preset"
	#endregion
	]:
		actions.erase(i)
	#print(actions)

func find_action(event) -> String:
	if event is InputEventMouseMotion:
		return ""
	for action in actions:
		if event.is_action(action):
			return action
	return ""

func find_action_strength(event) -> String:
	if event is InputEventMouseMotion:
		return ""
	for action in actions:
		if event.get_action_strength(action):
			return action
	return ""

## pretty self explanitory, or so you would think, this function doesn't check
## if the action is held down, it acts more like the is_button_just_pressed() function
## for other input types
func find_action_pressed(event) -> String:
	if event is InputEventMouseMotion:
		return ""
	for action in actions:
		if event.is_action_pressed(action):
			return action
	return ""

func find_action_released(event) -> String:
	if event is InputEventMouseMotion:
		return ""
	for action in actions:
		if event.is_action_released(action):
			return action
	return ""
