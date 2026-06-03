
Three panels:
1. Title screen:
	- any button pressed: switch to save select
2. Save select:
	- parse save files (3)
	- show save files
	- save file selected:
		- if new file: 
			- switch to gameScene
		- else:
			- load file
			- switch to level select
3. Level select:
	- display unlocked levels
	- maybe also show locked ones
	- level selected: 
		- send info to SceneControl (through func param?)
		- switch to game scene
