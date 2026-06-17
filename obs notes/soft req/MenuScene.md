- Title screen

	- IF keyboard or joystick input:
		1. proceed to file select


- File Select

	- all files in SHOW_INFO mode, empty files display EMPTY, existing files display header

	- IF down input:
		1. next file is selected
	
	- IF up input:
		1.  prev file is selected

	- IF left input:
		1. first file is selected

	- IF right input:
		1. last file is selected

	- IF accept input:
		1. proceed to file options on selected file

	- IF cancel input:
		1. proceed to title screen

- File Options

	- selected file in OPTIONS mode, Load, Copy and Delete are displayed

	- IF cancel input:
		1. proceed to File Select

	- IF left input:
		1. next option

	- IF right input:
		1. prev option

	- IF up input:
		1. first option

	- IF down input:
		1. last option

	- IF accept on Load
		1. load game
		2. IF empty file:
			1. proceed to [[GameScene]]
		3. ELSE:
			1. proceed to [[Level Select (MenuScene)|level select]]

	- IF accept on Delete:
		1. proceed to delete choicer

	 - IF accept on copy:
		 1. proceed to copy file

- File Copy

	- navigate and display as file select

	- IF cancel input:
		1. proceed to file options on file to copy

	- IF accept input:
		1. proceed to copy choicer on selected file

- Delete Choicer

	- selected file is in CHOICER mode, text reads DELETE

	- IF cancel input:
		1. proceed to file options on current file

	- IF accept input:
		1. file is deleted
		2. header is parsed
		3. proceed to select file

- Copy Choicer

	- selected file is in choicer mode, text reads COPY HERE

	- IF cancel input:
		1. proceed to file copy

	- IF accept input:
		1. file to copy is copied to selected file
		2. file header is parsed
		3. proceed to file select