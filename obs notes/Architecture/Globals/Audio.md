
# Overview
- plays music
- plays one-shot sounds (to decouple them from scene instances)


# Incoming Data
- sound to play

# Outgoing Data
- none

# Interface

- play_one_shot (AudioStream):
	- plays a sound using an AudioStreamPlayer
	- the AudioStreamPlayer is removed once it finishes playing

- play_music (AudioStream s, opt float out, opt float in):
	- replaces the current music with a new one
	- the fade in and out times can be configured

- stop_music(float):
	- stops playing music
	- the fade out time can be configured