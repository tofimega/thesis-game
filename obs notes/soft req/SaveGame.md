
- Loading a file

	- before loading:
		- begin_load is emitted

	- IF file exists:
		1. file is loaded
		2. game state is initialized
		3. finish_load is emitted (OK)
		4. header (from file) is returned

	- IF no file:
		1. game state is initialized
		2. finish_load is emitted (OK)
		3. header (new) is returned

	- IF error:
		1. game state is left uninitialized
		2. error is pushed
		3. finish_load is emitted (relevant error (CHECK FOR THIS))
		4. NULL is returned

- Saving file

	- before saving:
		- begin_save is emitted

	- IF game state is initialized:
		1. old file is backed up
		2. game state contents are written to file
		3. backup is deleted
		4. finish_save is emitted (OK)
		5. OK is returned

	- IF game state is uninitialized:
		1. nothing happens (begin_save is not emitted)
		2. error is pushed
		3. ERR_UNCONFIGURED is returned

	- IF file error:
		1. error is pushed
		2. backup is restored
		3. finish_save (ERROR)
		4. ERROR is returned

- parse header

	- IF file exists:
		1. contents are parsed
		2. header (from file) is returned

	- IF no file:
		1. header (new) is returned

	- IF parse error:
		1. push relevant error
		2. NULL is returned

- set flags:

	- IF game state is initialized:
		1. flag is set

	- IF game state is unintizoltade:
		1. push error (UNCONF)

	- IF invalid index:
		1. push error (PARAMETER_RANGE)