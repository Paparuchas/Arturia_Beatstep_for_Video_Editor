;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;-----------------------------------------------------------------------------------------------
;--------------------- ARTURIA'S BEATSTEP ADOBE PREMIERE MIDI CONTROLLER -----------------------
;-----------------------------------------------------------------------------------------------
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

; As I am writing sown this I don't actually know when or if I'll actually make this file public
; still, I write this aknowledging the people that, without knoing, help me made this script.
; I am not, by any means, a programmer, and you will probably find errors and bugs in this, for 
; that I apologize and hope you can help me fix them, and make a better script, for all the
; community.
; ALSO, VERY IMPORTANT. I have scripted a lot of commands based on my keyboard config. If you have
; (an you probably do) a different config for keyboard shortcuts, this will probably not work as
; intended, so, feel free to change as you please. But if you choose to keep my settings, remember
; to use the same shortcuts and KB config (which I will probably also share).

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; This file was made following the help of Ruud Boer's file and videos, January 2022
; The videos:
; 1: https://www.youtube.com/watch?v=Y3gow1TlL78
; 2: https://www.youtube.com/watch?v=D-Wvf4HNBnU
; 3: https://www.youtube.com/watch?v=h0IZiYEkvLg
; The scripts: https://github.com/RudyB24/AutoHotKey_Bome_MIDI_2_Key
; MIDI events received from the Behringer X Touch One are transferred into
; keyboard shortcuts for DaVinci Resolve (or any other app you'd wish to use)
; Based on https://github.com/genmce/AHK_Midi2Keypress ... author unknown.
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Also Taran van Hemert's tutorials, videos and scripts. Huge shout out to him and his amazing channel.
; 1: https://www.youtube.com/watch?v=T3vG8U5RoFw&t=5048s
; 2: https://github.com/TaranVH/2nd-keyboard/blob/1960e5c326d4accd1c9096b77a884e20d7d32692/Almost_All_Premiere_Functions.ahk
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Menu, Tray, Icon, shell32.dll, 283 ; this changes the tray icon to a little keyboard!
#Persistent
#SingleInstance, force
SetTitleMatchMode, 2
SendMode Input              	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% 	; Ensures a consistent starting directory.
; =============== 
version = Beatstep_V01.4.8
; THIS IS SET TO WORK WITH THE CUSTOM MIDI PROFILE FROM ARTURIA'S CONTROL CENTER
; =============== 
readini()					            ; load midi port from .ini file 
gosub, MidiPortRefresh        ; used to refresh the input and output port lists - see label below 
port_test(numports)   		    ; test the ports - check for valid ports?
gosub, midiin_go              ; opens the midi input port listening routine
gosub, midiMon           	    ; see below - a midi monitor gui - for learning mostly - comment this line eventually.

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; MidiMsgDetect is called each time a MIDI message is received.
; The MIDI message is broken up into 5 variables: statusbyte, chan, data1, data2 ,pitchb.
; See http://www.midi.org/techspecs/midimessages.php (decimal values).
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
MidiMsgDetect(hInput, midiMsg, wMsg) ; !!!! Midi input section in calls this function each time a midi message is received. Then the midi message is broken up into parts for manipulation.  See http://www.midi.org/techspecs/midimessages.php (decimal values).
{
	global statusbyte, chan, note, cc, data1, data2, stb ;Make these vars global to be used in other functions
	statusbyte :=  midiMsg & 0xFF          ; Extract statusbyte = what type of MIDI message and what channel
	chan       := (statusbyte & 0x0f) + 1  ; The MIDI channel
	data1      := (midiMsg >> 8) & 0xFF    ; data1 is Note # or CC #
	data2      := (midiMsg >> 16) & 0xFF   ; data2 is Velocity or CC value
	pitchb     := (data2 << 7) | data1     ; (midiMsg >> 8) & 0x7F7F  masking to extract the pitchbends  

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;--- THIS NEXT SECTION DETERMINES KNOBS AND PADS BEHAIOUR WHEN IN CHANNEL 1 IN ADOBE PREMIERE ---
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IfWinActive ahk_exe Adobe Premiere Pro.exe ;The code below will only work if Premiere Pro is active. (In theory, it's not working as intended)

if statusbyte between 176 and 191  ; MIDI CC
  {
    stb := "CC" ;The stb variable is used for the MIDI Monitor display
    if (data1=17 and data2= 127) ; Jog wheel left 
		loop, 6
		{
			Send +{Left} ; Left 1M
		}
	if (data1=17 and data2= 1) ; Jog wheel right
		loop, 6
		{
			Send +{Right} ; Scroll FWD 1m
		}
	if (chan=1 and data1=1 and data2= 127) ; Knob #1 Left = Move 1 frame Backward in timeline
		Send {Up} ; 
	if (chan=1 and data1=1 and data2= 1) ; Knob #1 Right = Move 1 frame forward in timeline
		Send {Down} ; 
    if (chan=1 and data1=2 and data2= 127) ; Knob #2 Left = Navigate backward timeline through clips
		Send {Left} ;   
	if (chan=1 and data1=2 and data2= 1) ; Knob #2 Right = Navigate forward timeline through clips
		Send {Right} ; 
	if (chan=1 and data1=3 and data2= 127) ; Knob #3: Position H Left
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ;
			sleep 10
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Position_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Scale" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Loop, 5
					Send, {Down}
					sleep 10
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=3 and data2= 1) ; Knob #3: Position H Right
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4
			sleep 10
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Position_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Scale" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Loop, 5
					Send, {Up}
					sleep 10
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=4 and data2= 127)
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Position_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+140, FoundY+10, 0 ;this moves the cursor onto "Position" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Loop, 5
					Send, {Up}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=4 and data2= 1)
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Position_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+140, FoundY+10, 0 ;this moves the cursor onto "Position" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Loop, 5
					Send, {Down}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=5 and data2= 127)
		Send ^{Left} ; Knob #11 Left = Trim selection to the left
	if (chan=1 and data1=5 and data2= 1)
		Send ^{Right} ; Knob #11 Right = Trim selection to the right
	if (chan=1 and data1=6 and data2= 127) ; Knob #3 Left
		Send ^!, ; Slide Clip Selection to the Left
	if (chan=1 and data1=6 and data2= 1) ; Knob #3 Right
		Send ^!. ; Slide Clip Selection to the Right
	if (chan=1 and data1=7 and data2= 127) ; Knob #7 = Volume Down
		Send, ^!ñ
	if (chan=1 and data1=7 and data2= 1) ; Knob #7 = Volume Up
		Send, ^!p
    if (chan=1 and data1=8 and data2= 127) ; Knob #8 = System Volume Down
		Soundset, -5
	if (chan=1 and data1=8 and data2= 1) ; Knob #8 = System Volume Down
		Soundset, +5
    if (chan=1 and data1=9 and data2= 127)
		Send {NumpadSub} ; Knob #9 Left = Zoom Out
	if (chan=1 and data1=9 and data2= 1)
		Send {NumpadAdd} ; Knob #9 Right = Zoom In
    if (chan=1 and data1=10 and data2= 127)
		Send {WheelUp} ; Knob #10 Left = Shows back in timeline
	if (chan=1 and data1=10 and data2= 1)
		Send {WheelDown} ; Knob #10 Right = Shows ahead in timeline
	if (chan=1 and data1=11 and data2= 127) ; Knob #5: Scale Down.
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			sleep 10
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Scale_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Scale" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Down}
					sleep 10
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}	
	if (chan=1 and data1=11 and data2= 1) ; Knob #5: Scale Up.
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			sleep 10
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Scale_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Scale" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Up}
					sleep 10
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
    if (chan=1 and data1=12 and data2= 127)
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			sleep 20
			ImageSearch, FoundX, Foundy, 0, 0, 150, 550, %A_WorkingDir%\Ref_Pics\Opacity_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+100, FoundY+10, 0 ;this moves the cursor onto "Position" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Down}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=12 and data2= 1)
		{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			sleep 20
			ImageSearch, FoundX, Foundy, 0, 0, 150, 550, %A_WorkingDir%\Ref_Pics\Opacity_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+100, FoundY+10, 0 ;this moves the cursor onto "Position" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Up}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
    if (chan=1 and data1=13 and data2= 127) ;KNOB #13: IT'S ACTUALLY PRETTY BUGGY. Rotation R
      	{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Rotation_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Rotation" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Down}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
	if (chan=1 and data1=13 and data2= 1) ;KNOB #5: IT'S ACTUALLY PRETTY BUGGY. Rotation L
      	{
			BlockInput, On
			BlockInput, MouseMove
			MouseGetPos, xpos, ypos
			Send ^!+4 ; Knob #5 =
			ImageSearch, FoundX, Foundy, 0, 0, 150, 350, %A_WorkingDir%\Ref_Pics\Rotation_V01.PNG ; In theory you could just write "A_ScreenWidth" instead of 150, and "A_ScreenHeight" instead of 350, and it would search the entire screen.
				{
					MouseMove, FoundX+80, FoundY+10, 0 ;this moves the cursor onto "Rotation" text.
					Sleep 1
					MouseGetPos, , , Window, classNN
					WinGetClass, class, ahk_id %Window%
					SendInput {LButton}
					Send, {Up}
				}
			MouseMove, %xpos%, %ypos%, 0
			BlockInput, Off
			BlockInput, MouseMoveOff
		}
    if (chan=1 and data1=14 and data2= 127) ; Knob #4 Left
		Send ^!{Right} ; Slip Clip Selection to the Left
	if (chan=1 and data1=14 and data2= 1) ; Knob #4 Right
		Send ^!{Left} ; Slip Clip Selection to the Right
    ;if (chan=1 and data1=15 and data2= 127)
      ;Send ; Knob #12 Left = ?  TO MAKE THIS PARAMETER WORK, REMOVE THE ;
	;if (chan=1 and data1=15 and data2= 1)
      ;Send ; Knob #12 Right = ? TO MAKE THIS PARAMETER WORK, REMOVE THE ;
    ;if (chan=1 and data1=16 and data2= 127)
      ;Send ; Knob #12 Left = ?  TO MAKE THIS PARAMETER WORK, REMOVE THE ;
	;if (chan=1 and data1=16 and data2= 1)
      ;Send ; Knob #12 Right = ? TO MAKE THIS PARAMETER WORK, REMOVE THE ;	  

  }
  
  IfWinActive ahk_exe Adobe Premiere Pro.exe ;The code below will only work if Premiere Pro is active. (I had to put it twicec since it wasn't working propertly on the pads)
  
;if statusbyte between 144 and 159  ; MIDI NoteOn 
;I turned this off because it was interfering whith the values being recived by the MIDI code and the actions.
  {
    stb := "NoteOn"
    if (chan=1 and data1=21 and data2=127) ; Button #1 = Ripple Delete BW
		Send, ^!+3
    if (chan=1 and data1=22 and data2=127) ; Button #2 = Add Edit
		Send, ^!+4
	if (chan=1 and data1=23 and data2=127) ; Button #3 = Ripple Delete FW
		Send, ^!+5
    if (chan=1 and data1=24 and data2=127) ; Button #4 = Set In Point
		Send, i
    if (chan=1 and data1=25 and data2=127) ; Button #5 = Insert
		Send, o
    if (chan=1 and data1=26 and data2=127) ; Button #6 = Insert Green Marker
		{
			Send, ^!+7
			Sleep, 10
			Send, ^+{Del}
			Sleep, 10
			Send, ^+{F5}
		}
    if (chan=1 and data1=27 and data2=127) ; Button #7 = Insert Orange Marker
		{
			Send, ^!+7
			Sleep, 10
			Send, ^+{Del}
			Sleep, 10
			Send, ^+{F6}
		}
    if (chan=1 and data1=28 and data2=127) ; Button #8 = Insert Red Marker
		{
			Send, ^!+7
			Sleep, 10
			Send, ^+{Del}
			Sleep, 10
			Send, ^+{F7}
		}
    if (chan=1 and data1=29 and data2= 127) ; Button #9 = Shuttle FBW
		Loop, 2
		Send j
	if (chan=1 and data1=30 and data2=127) ; Button #10 = Play/Pause
		Send, {Space}
    if (chan=1 and data1=31 and data2=127) ; Button #11 = Shuttle FFW
		Loop, 2
		Send, l
    if (chan=1 and data1=32 and data2=127) ; Button #12 = Set Out Point
		Send, q
    if (chan=1 and data1=33 and data2=127) ; Button #13 = Overwrite
		Send, <
    if (chan=1 and data1=34 and data2=127) ; Button #14 = ?
		Send w
    if (chan=1 and data1=35 and data2=127) ; Button #15 = Undo
		Send, ^z
    if (chan=1 and data1=36 and data2=127) ; Button #16 = Redo
		Send, ^+z
  }
if statusbyte between 128 and 143 ; MIDI NoteOff
  {
    stb := "NoteOff"
  }
if statusbyte between 192 and 208 ; MIDI Program Change
  {
    stb := "PC"
  }
if statusbyte between 224 and 254 ; MIDI Pitch Bend
  {
    stb := "PitchB"
  }

MidiInDisplay(stb, statusbyte, chan, data1, data2) ; midi display function called when message received *THIS IS FOR THE MIDI MONITOR. REMEMBER TO TURN IT ON ALONG WITH THE REST OF THE MONITOR'S SETTINGS.
} ; end of MidiMsgDetect funciton
return

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;THIS IS THE CODE FOR THE FOCUS PANEL SCRIPT, WHERE AHK RECOGNISES WHICH PANEL OF PREMIERE PRO YOU ARE ON, AFTER THAT THE SCRIP "GOTO" SENDS THE SCRIP TO THE END OF IT OMMITING ALL THE REST OF THE SCRIPT.

prFocus(panel)
{
Sendinput, ^!+2 ;bring focus to the Effects panel... OR, if any panel had been maximized (using the `~ key by default) this will unmaximize that panel, but sadly, that panel will still be the one in focus.
;Note that if the effects panel is ALREADY maximized, then sending the shortcut to switch to it will NOT un-maximize it. This is OK, though, because I never maximize the Effects Panel. If you do, then you might want to switch to the Effect Controls panel first, and THEN the Effects panel after this line.
;note that sometimes I use ^+! instead... it makes no difference compared to ^!+

sleep 12 ;waiting for Premiere to actaully do the above.

Sendinput, ^!+2 ;Bring focus to the Effects panel AGAIN. Just in case some panel somewhere was maximized, THIS will now guarantee that the Effects panel is ACTAULLY in focus.

sleep 5 ;waiting for Premiere to actaully do the above.

if (panel = "Effects")
	goto theEnd ;do nothing. The shortcut has already been sent.
else if (panel = "Timeline")
	Sendinput, ^!+7 ;if focus had already been on the timeline, this would have switched to the "next" sequence (in some unpredictable order.)
else if (panel = "program") ;program monitor. If focus had already been here, this would have switched to the "next" sequence.
	Sendinput, ^!+6
else if (panel = "source") ;source monitor. If focus had already been here, this would have switched to the next loaded item.
	Sendinput, ^!+3	;tippy("send ^!+2") ;tippy() was something I used for debugging. you don't need it.
else if (panel = "project") ;AKA a "bin" or "folder"
	Sendinput, ^!+1
else if (panel = "effect controls")
	Sendinput, ^!+4
else if (panel = "audio track mixer")
	Sendinput, ^!+5

theEnd:
}
;end of prFocus()


;F2::preset("Crop Test") ; This is an example of how to assign presets to a command like F2 and it will execute this preset in premiere, first you need the preset created inside Premiere Pro.
;F3::preset("Lumetri Basic") ; Idem

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;PRESET FOR THE SCALE KNOB OF A CLIP... MAYBE?
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

F1:: ;THIS IS FOR DEBUGGING AND READING INFO FOR THE POSITION, CLASS AND OTHER IMPORTANT THINGS FOR TAHK TO KNOW WHAT OR WHERE TO APPLY A CHANGE. (TEMPORARY F1, REMEMBER TO DEACTIVATE!!!)
MouseGetPos, xposP, yposP
MouseGetPos, , , Window, classNN
WinGetClass, class, ahk_id %Window%
tooltip, 2 - ahk_class =   %class% `nClassNN =     %classNN% `nTitle= %Window%
sleep 2000
return

preset(item)
{
keywait, %A_PriorHotKey% ;keywait is quite important.
;Let's pretend that you called this function using the following line:
;F1::preset("crop 50")
;In that case, F1 is the prior hotkey, and the script will WAIT until F4 has been physically RELEASED (up) before it will continue. 
;https://www.autohotkey.com/docs/commands/KeyWait.htm
;Using keywait is probably WAY cleaner than allowing the physical key UP event to just happen WHENEVER during the following function, which can disrupt commands like sendinput, and cause cross-talk with modifier keys.

ifWinNotActive ahk_exe Adobe Premiere Pro.exe ;the exe is more reliable than the class, since it will work even if you're not on the primary Premiere window.
	{
	goto theEnding ;and this line is here just in case the function is called while not inside premiere. In my case, this is because of my secondary keyboards, which aren't usually using #ifwinactive in addition to #if getKeyState(whatever). Don't worry about it.
	}

;Setting the coordinate mode is really important. This ensures that pixel distances are consistant for everything, everywhere.
; https://www.autohotkey.com/docs/commands/CoordMode.htm
coordmode, pixel, Window
coordmode, mouse, Window
coordmode, Caret, Window

;This (temporarily) blocks the mouse and keyboard from sending any information, which could interfere with the funcitoning of the script.
BlockInput, SendAndMouse
BlockInput, MouseMove
BlockInput, On
;The mouse will be unfrozen at the end of this function. Note that if you do get stuck while debugging this or any other function, CTRL SHIFT ESC will allow you to regain control of the mouse. You can then end the AHK script from the Task Manager.

SetKeyDelay, 0 ;NO DELAY BETWEEN STUFF sent using the "send"command! I thought it might actually be best to put this at "1," but using "0" seems to work perfectly fine.
; https://www.autohotkey.com/docs/commands/SetKeyDelay.htm


Sendinput, ^!+k ;in Premiere's shortcuts panel, ASSIGN "shuttle stop" to CTRL ALT SHIFT K.
sleep 10
Sendinput, ^!+k ; another shortcut for Shuttle Stop. Sometimes, just one is not enough.
;so if the video is playing, this will stop it. Othewise, it can mess up the script.
sleep 5

;msgbox, ahk_class =   %class% `nClassNN =     %classNN% `nTitle= %Window%
;;This was my debugging to check if there are lingering variables from last time the script was run. You do not need that line.

MouseGetPos, xposP, yposP ;------------------stores the cursor's current coordinates at X%xposP% Y%yposP%
;KEEP IN MIND that this function should only be called when your cursor is hovering over a clip, or a group of selected clips, on the timeline. That's because the cursor will be returned to that exact location, carrying the desired preset, which it will drop there. MEANING, that this function won't work if you select clips, but don't have the cursor hovering over them.

sendinput, {mButton} ;this will MIDDLE CLICK to bring focus to the panel underneath the cursor (which must be the timeline). I forget exactly why, but if you create a nest, and immediately try to apply a preset to it, it doesn't work, because the timeline wasn't in focus...? Or something. IDK.
sleep 5

prFocus("effects") ;Brings focus to the effects panel. You must find, then copy/paste the prFocus() function definition into your own .ahk script as well. ALTERNATIVELY, if you don't want to do that, you can delete this line, and "comment in" the 3 lines below:

Sendinput, ^+! 2 ;CTRL SHIFT ALT 7 --- In Premiere's Keyboard Shortcuts panel, you nust find the "Effects" panel and assign the shortcut CTRL SHIFT ALT 7 to it. (The default shortcut is SHIFT 7. Because Premiere does allow multiple shortcuts per command, you can keep SHIFT 7 as well, or you can delete it. I have deleted it.)
;sleep 12
;Sendinput, ^!+7 ;you must send this shortcut again, because there are some edge cases where it may not have worked the first time.

sleep 15 ;"sleep" means the script will wait for 15 milliseconds before the next command. This is done to give Premiere some time to load its own things.

Sendinput, +f ;CTRL B ------- set in premiere's shortcuts panel to "select find box"
sleep 5
;Alternatively, it also works to click on the magnifying glass if you wish to select the find box... but this is unnecessary and sloppy.

;The Effects panel's find box should now be activated.
;If there is text contained inside, it has now been highlighted. There is also a blinking vertical line at the end of any text, which is called the "text insertion point", or "caret".

if (A_CaretX = "")
{
;No Caret (blinking vertical line) can be found.

;The following loop is waiting until it sees the caret. THIS IS SUPER IMPORTANT, because Premiere is sometimes quite slow to actually select the find box, and if the function tries to proceed before that has happened, it will fail. This would happen to me about 10% of the time.
;Using the loop is also way better than just ALWAYS waiting 60 milliseconds like I was before. With the loop, this function can continue as soon as Premiere is ready.

;sleep 60 ;<—Use this line if you don't want to use the loop below. But the loop should work perfectly fine as-is, without any modification from you.

waiting2 = 0
loop
	{
	waiting2 ++
	sleep 33
	tooltip, counter = (%waiting2% * 33)`nCaret = %A_CaretX%
	if (A_CaretX <> "")
		{
		tooltip, CARET WAS FOUND
		break
		}
	if (waiting2 > 40)
		{
		;tooltip, FAIL - no caret found. `nIf your cursor will not move`, hit the button to call the preset() function again.`nTo remove this tooltip`, refresh the script using its icon in the taskbar.`n`nIt's possible Premiere tried to AUTOSAVE at just the wrong moment!
		;Note to self, need much better way to debug this than screwing the user. As it stands, that tooltip will stay there forever.
		;USER: Running the function again, or reloading the script, will remove that tooltip.
		;sleep 200
		;tooltip,
		sleep 20
		GOTO theEnding
		}
	}
sleep 1
tooltip,
}
;The loop has now ended.
;yeah, I've seen this go all the way up to "8," which is 264 milliseconds

MouseMove, %A_CaretX%, %A_CaretY%, 0 ;this moves the cursor, instantly, to the position of the caret.
sleep 5 ;waiting while Windows does this. Just in case it takes longer than 0 milliseconds.
;;;and fortunately, AHK knows the exact X and Y position of this caret. So therefore, we can find the effects panel find box, no matter what monitor it is on, with 100% consistency!

;tooltip, 1 - mouse should be on the caret X= %A_CaretX% Y= %A_CaretY% now ;;this debugging line was super helpful in me solving this one! Connent this line in if you want to use it, but comment it out after you've gotten the whole function working.

;;;msgbox, caret X Y is %A_CaretX%, %A_CaretY%

MouseGetPos, , , Window, classNN
WinGetClass, class, ahk_id %Window%

;tooltip, 2 - ahk_class =   %class% `nClassNN =     %classNN% `nTitle= %Window%
;sleep 2000
;;;note to self, I think ControlGetPos is not affected by coordmode??  Or at least, it gave me the wrong coordinates if premiere is not fullscreened... IDK. https://autohotkey.com/docs/commands/ControlGetPos.htm

ControlGetPos, XX, YY, Width, Height, %classNN%, ahk_class %class%, SubWindow, SubWindow 

;note to self, I tried to exclude subwindows but I don't think it works...?
;;my results:  59, 1229, 252, 21,     Edit1,     ahk_class Premiere Pro
;tooltip, classNN = %classNN%

;; https://www.autohotkey.com/docs/commands/MouseMove.htm

;MouseMove, XX-25, YY+10, 0 ;--------------------for 150% UI scaling, this moves the cursor onto the magnifying glass
MouseMove, XX-15, YY+6, 0 ;--------------------for 100% UI scaling, this moves the cursor onto the magnifying glass

;msgbox, should be in the center of the magnifying glass now. ;;<--comment this in for help with debugging.

sleep 5

Sendinput, %item%
;This types in the text you wanted to search for, like "crop 50". We can do this because the entire find box (and any included text) was already selected.
;Premiere will now display your preset at the top of the list. There is no need to press "enter" to search.


sleep 5

;MouseMove, 62, 95, 0, R ;----------------------(for 150% UI.)
MouseMove, 41, 63, 0, R ;----------------------(for 100% UI)
;;relative to the position of the magnifying glass (established earlier,) this moves the cursor down and directly onto the preset's icon.

;;In my case, all of my presets are contained inside of folders, which themselves are inside the "presets" folder. Your preset's written name should be completely unique so that it is the first and only item.

;msgbox, The cursor should be directly on top of the preset's icon. `n If not, the script needs modification.

sleep 5


;;At this point in the function, I used to use the line "MouseClickDrag, Left, , , %xposP%, %yposP%, 0" to drag the preset back onto the clip on the timeline. HOWEVER, because of a Premiere bug (which may or may not still exist) involving the duplicated displaying of single presets (in the wrong positions) I have to click on the Effects panel AGAIN, which will "fix" it, bringing it back to normal.
;+++++++ If this bug is ever resolved, then the lines BELOW are no longer necessary.+++++
MouseGetPos, iconX, iconY, Window, classNN ;---now we have to figure out the ahk_class of the current panel we are on. It might be "DroverLord - Window Class14", but the number changes anytime you move panels around... so i must always obtain the information anew.
sleep 5
WinGetClass, class, ahk_id %Window% ;----------"ahk_id %Window%" is important for SOME REASON. if you delete it, this doesn't work.
;tooltip, ahk_class =   %class% `nClassNN =     %classNN% `nTitle= %Window%
;sleep 50
ControlGetPos, xxx, yyy, www, hhh, %classNN%, ahk_class %class%, SubWindow, SubWindow ;;-I tried to exclude subwindows but I don't think it works...?
MouseMove, www/4, hhh/2, 0, R ;-----------------moves to roughly the CENTER of the Effects panel. Clicking here will clear the displayed presets from any duplication errors. VERY important. Without this, the script fails 20% of the time. This is also where the script can go wrong, by trying to do this on the timeline, meaning it didn't get the Effects panel window information as it should have.
sleep 5
MouseClick, left, , , 1 ;-----------------------the actual click
sleep 5
MouseMove, iconX, iconY, 0 ;--------------------moves cursor BACK onto the preset's icon
;tooltip, should be back on the preset's icon
sleep 5
;;+++++If this bug is ever resolved, then the lines ABOVE are no longer necessary.++++++


MouseClickDrag, Left, , , %xposP%, %yposP%, 0 ;---clicks the left button down, drags this effect to the cursor's pervious coordinates and releases the left mouse button, which should be above a clip, on the TIMELINE panel.
sleep 5
MouseClick, middle, , , 1 ;this returns focus to the panel the cursor is hovering above, WITHOUT selecting anything. great! And now timeline shortcuts like JKL will work.

blockinput, MouseMoveOff ;returning mouse movement ability
BlockInput, off ;do not comment out or delete this line -- or you won't regain control of the keyboard!! However, CTRL ALT DELETE will still work if you get stuck!! Cool.

;The line below is where all those GOTOs are going to.
theEnding:
}
;END of preset(). The two lines above this one are super important.

 ----------------------------------------------------------------

;All this next part is for the MidiMonitor.

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; NO NEED TO EDIT ANYTHING BELOW HERE
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

MidiInDisplay(stb, statusbyte, chan, data1, data2) ; update the midimonitor gui
{
Gui,3:default
Gui,3:ListView, In1 					; see the first listview midi in monitor
  LV_Add("",stb,statusbyte,chan,data1,data2)
  LV_ModifyCol(1,"center")
  LV_ModifyCol(2,"center")
  LV_ModifyCol(3,"center")
  LV_ModifyCol(4,"center")
  LV_ModifyCol(5,"center")
  If (LV_GetCount() > 10)
    {
      LV_Delete(1)
    }
}
return

midiMon: ; midi monitor gui with listviews
gui,3:destroy
gui,3:default
Gui,3:Add, ListView, x5 r11 w220 Backgroundblack cyellow Count10 vIn1,  EventType|StatB|Ch|data1|data2| 
gui,3:Show, autosize x2300 y780, MidiMonitor ; THIS IS THE LOCATION OF THE MIDI MONITOR IN YOUR SCREEN. IN MY CASE, I HAVE AN ULTRA WIDE. REMEMBER TO CHANGE IT DEPPENDING ON THE SCREEN SIZE.

return
*/
;-----------------------------------------------------------------


MidiPortRefresh: 				; get the list of ports !!!! nothing to edit here

MIlist := MidiInsList(NumPorts) 
Loop Parse, MIlist, | 
{
}
TheChoice := MidiInDevice + 1
return

;-----------------------------------------------------------------

ReadIni() ; also set up the tray Menu !!!! Nothing to edit here
{
	Menu, tray, add, MidiSet            ; set midi ports tray item 
	Menu, tray, add, ResetAll           ; Delete the ini file for testing --------------------------------
	
	global MidiInDevice, version ; version var is set at the beginning.
	IfExist, %version%.ini
	{
		IniRead, MidiInDevice, %version%.ini, Settings, MidiInDevice , %MidiInDevice%     ; read the midi In port from ini file
	}
	Else ; no ini exists and this is either the first run or reset settings.
	{
		MsgBox, 1, No ini file found, Select midi ports?
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, yes
			gosub, midiset
	}
}

;CALLED TO UPDATE INI WHENEVER SAVED PARAMETERS CHANGE - !!!! nothing to edit here
WriteIni()
{
	global MidiInDevice, version 		; global vars needed
	
	IfNotExist, %version%.ini 		; does .ini file exist? 
		FileAppend,, %version%.ini 	; make one with name of the .ahk file and the following entries.
	IniWrite, %MidiInDevice%, %version%.ini, Settings, MidiInDevice
}

;------------ port testing to make sure selected midi port is valid --------------------------------

port_test(numports) ; confirm selected ports exist - !!!!! nothing to edit here

{
	global midiInDevice, midiok ;midiOutDevice
	
	; ----- In port selection test based on numports
	If MidiInDevice not Between 0 and %numports% 
		{
			MidiIn := 0 ; this var is just to show if there is an error - set if the ports are valid = 1, invalid = 0
			;MsgBox, 0, , midi in port Error ; (this is left only for testing)
			If (MidiInDevice = "")              ; if there is no midi in device 
				MidiInerr = Midi In Port EMPTY. ; set this var = error message
			;MsgBox, 0, , midi in port EMPTY
			If (midiInDevice > %numports%)          ; if greater than the number of ports on the system.
				MidiInnerr = Midi In Port Invalid.  ; set this error message
			;MsgBox, 0, , midi in port out of range
		}
	Else
		{
			MidiIn := 1 ; setting var to non-error state or valid
		}

	If (%MidiIn% = 0)
	{
		MsgBox, 49, Midi Port Error!,%MidiInerr%`nLaunch Midi Port Selection!
		IfMsgBox, Cancel
			ExitApp
		midiok = 0 ; Not sure if this is really needed now....
		Gosub, MidiSet ;Gui, show Midi Port Selection
	}
	Else
	{
		midiok = 1
		Return ; DO NOTHING - PERHAPS DO THE NOT TEST INSTEAD ABOVE.
	}
}
return

; ------------------ end of port testing ---------------------------

MidiSet: ; midi port selection gui

; ------------- MIDI INPUT SELECTION -----------------------

Gui, 1: +LastFound +AlwaysOnTop   +Caption +ToolWindow ;-SysMenu
Gui, 1: Font, s12
Gui, 1: add, text, x10 y8 w200 cmaroon, Select Midi Input ; Text title
Gui, 1: Font, s9
Gui, 1: font, s9
Gui, 1: Add, ListBox, x10 w175 h100  Choose%TheChoice% vMidiInPort gDoneInChange AltSubmit, %MiList% ; --- midi in listing of ports

Gui, 1: add, Button, x10 w80 gSet_Done, Done - Reload
Gui, 1: add, Button, xp+80 w80 gCancel, Cancel
Gui, 1: show , , %version% Midi Input ; main window title and command to show it.

Return

;~ ------------------------------- methods to save midi port selection -----------------------------

DoneInChange:
Gui, 1: Submit, NoHide
Gui, 1: Flash
If %MidiInPort%
	UDPort:= MidiInPort - 1, MidiInDevice:= UDPort ; probably a much better way do this, I took this from JimF's qwmidi without out editing much.... it does work same with doneoutchange below.
GuiControl, 1:, UDPort, %MidiIndevice%
WriteIni()		; Write .ini file in same folder as ahk file 
Return

Set_Done: 		; aka reload program, called from midi selection gui
Gui, 1: Destroy
sleep, 100
Reload
Return

Cancel:
Gui, Destroy
Gui, 2: Destroy
Return

ResetAll: 		; for development only, leaving this in for a program reset if needed by user
MsgBox, 33, %version% - Reset All?, This will delete ALL settings`, and restart this program!
IfMsgBox, OK
{
	FileDelete, %version%.ini   ; delete the ini file to reset ports, probably a better way to do this ...
	Reload                      ; restart the app.
}
IfMsgBox, Cancel
	Return

GuiClose: 		; on x exit app
Suspend, Permit 	; allow Exit to work Paused. I just added this yesterday 3.16.09 Can now quit when Paused.

MsgBox, 4, Exit %version%, Exit %version% %ver%? ; 
IfMsgBox No
	Return
Else IfMsgBox Yes
Gui, 6: Destroy
Gui, 2: Destroy
Gui, 3: Destroy
Sleep 100

ExitApp


;~ -------------------------------------------------------------------------------------------------
;~ -----------------------        Original work by lots of ahk gurus        ------------------------
;~ ----------------------- DO NOT EDIT - unless you know what you are doing ------------------------
;~ -----------------------                                                  ------------------------
;~ -------------------------------------------------------------------------------------------------

;############################################## MIDI LIB from orbik and lazslo#############
;-------- orbiks midi input code --------------
; Set up midi input and callback_window based on the ini file above.
; This code copied from ahk forum Orbik's post on midi input

; nothing below here to edit. !!!!!!!!!!!!
; =============== midi in =====================

Midiin_go:
DeviceID := MidiInDevice      ; midiindevice from IniRead above assigned to deviceid
CALLBACK_WINDOW := 0x10000    ; from orbiks code for midi input

Gui, +LastFound 	; set up the window for midi data to arrive.
hWnd := WinExist()	;MsgBox, 32, , line 176 - mcu-input  is := %MidiInDevice% , 3 ; this is just a test to show midi device selection

hMidiIn =
VarSetCapacity(hMidiIn, 4, 0)
result := DllCall("winmm.dll\midiInOpen", UInt,&hMidiIn, UInt,DeviceID, UInt,hWnd, UInt,0, UInt,CALLBACK_WINDOW, "UInt")
If result
	{
		MsgBox, Error, midiInOpen Returned %result%`n
		;GoSub, sub_exit
	}

hMidiIn := NumGet(hMidiIn) ; because midiInOpen writes the value in 32 bit binary Number, AHK stores it as a string
result := DllCall("winmm.dll\midiInStart", UInt,hMidiIn)
If result
	{
		MsgBox, Error, midiInStart Returned %result%`nRight Click on the Tray Icon - Left click on MidiSet to select valid midi_in port.
		;GoSub, sub_exit
	}

OpenCloseMidiAPI()

; ----- the OnMessage listeners ----

; #define MM_MIM_OPEN 0x3C1 /* MIDI input */
; #define MM_MIM_CLOSE 0x3C2
; #define MM_MIM_DATA 0x3C3
; #define MM_MIM_LONGDATA 0x3C4
; #define MM_MIM_ERROR 0x3C5
; #define MM_MIM_LONGERROR 0x3C6

OnMessage(0x3C1, "MidiMsgDetect")  ; calling the function MidiMsgDetect in get_midi_in.ahk
OnMessage(0x3C2, "MidiMsgDetect")  
OnMessage(0x3C3, "MidiMsgDetect")
;OnMessage(0x3C4, "MidiMsgDetect")
;OnMessage(0x3C5, "MidiMsgDetect")
;OnMessage(0x3C6, "MidiMsgDetect")

Return

;*************************************************
;*          MIDI IN PORT HANDLING
;*************************************************

MidiInsList(ByRef NumPorts)                                             ; should work for unicode now... 
  { ; Returns a "|"-separated list of midi output devices
	local List, MidiInCaps, PortName, result, midisize
	(A_IsUnicode)? offsetWordStr := 64: offsetWordStr := 32
	midisize := offsetWordStr + 18
	VarSetCapacity(MidiInCaps, midisize, 0)
	VarSetCapacity(PortName, offsetWordStr)                       ; PortNameSize 32

	NumPorts := DllCall("winmm.dll\midiInGetNumDevs") ; #midi output devices on system, First device ID = 0

	Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiInGetDevCaps", "UInt",A_Index-1, "Ptr",&MidiInCaps, "UInt",midisize)
    
        If (result OR ErrorLevel) {
            List .= "|-Error-"
            Continue
          }
    PortName := StrGet(&MidiInCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }

MidiInGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiInGetNumDevs")
  }
MidiInNameGet(uDeviceID = 0) {                  ; Get name of a midiOut device for a given ID

;MIDIOUTCAPS struct
;    WORD      wMid;
;    WORD      wPid;
;    MMVERSION vDriverVersion;
;    CHAR      szPname[MAXPNAMELEN];
;    WORD      wTechnology;
;    WORD      wVoices;
;    WORD      wNotes;
;    WORD      wChannelMask;
;    DWORD     dwSupport;

    VarSetCapacity(MidiInCaps, 50, 0)               ; allows for szPname to be 32 bytes
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiInGetDevCapsA", UInt,uDeviceID, UInt,&MidiInCaps, UInt,50, UInt)

    If (result OR ErrorLevel) {
        MsgBox Error %result% (ErrorLevel = %ErrorLevel%) in retrieving the name of midi Input %uDeviceID%
        Return -1
      }

    VarSetCapacity(PortName, PortNameSize)
    DllCall("RtlMoveMemory", Str,PortName, Uint,&MidiInCaps+OffsettoPortName, Uint,PortNameSize)
    Return PortName
  }

MidiInsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiInPortName =
    NumPorts := MidiInGetNumDevs()

    Loop %NumPorts% {
        PortID := A_Index -1
        MidiInPortName%PortID% := MidiInNameGet(PortID)
      }
    Return NumPorts
  }


OpenCloseMidiAPI() {  ; at the beginning to load, at the end to unload winmm.dll
	static hModule
	If hModule
		DllCall("FreeLibrary", UInt,hModule), hModule := ""
	If (0 = hModule := DllCall("LoadLibrary",Str,"winmm.dll")) {
		MsgBox Cannot load libray winmm.dll
		Exit
	}
}

