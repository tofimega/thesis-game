@abstract
class_name Submenu
extends Control

@warning_ignore("unused_signal")
signal switch_to(panel: MenuScene.MenuPanel)


@abstract func _gui_input(event: InputEvent) -> void


@abstract func on_show() -> void


@abstract func on_hide() -> void
