Switches between MenuScene and GameScene

lazily load scene when switching (no need to keep PackedScenes around for both scenes, as switching is infrequent)
# Interface
- begin_game(level: LevelData):
	- load_threaded GameScene
	- unload MenuScene
	- await next frame
	- instantiate GameScene
	- pass level to GameScene
	- add_child
- exit_game():
	- save game
	- load_threaded MenuScene
	- unload GameScene
	- await next frame
	- instantiate MenuScene
	- add_child