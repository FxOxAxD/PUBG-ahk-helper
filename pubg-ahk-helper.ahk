
;PUBG Helper by FxOxAxD

;#########################
;#     Configuration     #
;#########################
#NoEnv ;Improves performance and compatibility with future AHK updates.
#SingleInstance force ;It allows to run only one at the same time.
SetTitleMatchMode, 2 ;Matching for window title.
#ifwinactive, PLAYERUNKNOWN'S BATTLEGROUNDS ;Active only when in PUBG.

;#####################
;#     Variables     #
;#####################
isMouseShown() ;To suspend script when mouse is visible.
ADS = 0 ;Var for fast aiming.
CrouchJump = 1 ;Var for crouch when jumping.
AutoFire = 0 ;Var for autofiring.
Compensation = 0 ;Var for compensation when autofiring.
compVal = 10 ;Compensation value.

;########################################
;#     Suspends if mouse is visible     #
;########################################

isMouseShown() ;It suspends the script when mouse is visible (map, inventory, menu).
{
  StructSize := A_PtrSize + 16
  VarSetCapacity(InfoStruct, StructSize)
  NumPut(StructSize, InfoStruct)
  DllCall("GetCursorInfo", UInt, &InfoStruct)
  Result := NumGet(InfoStruct, 8)

  if Result > 1
    Return 1
  else
    Return 0
}
Loop
{
  if isMouseShown() == 1
    Suspend On
  else
    Suspend Off
    Sleep 1
}

;#######################
;#     Fast Aiming     #
;#######################

*RButton:: ;Fast Aiming [default: Right Button]
if ADS = 1
{ ;If active, clicks once and clicks again when button is released.
  SendInput {RButton Down}
  SendInput {RButton Up}
  KeyWait, RButton
  SendInput {RButton Down}
  SendInput {RButton Up}
} else { ;If not, just keeps holding until button is released.
  SendInput {RButton Down}
  KeyWait, RButton
  SendInput {RButton Up}
}
Return

;######################
;#     CrouchJump     #
;######################

*XButton2:: ;Crouch when jumping [default: Button 4]
if CrouchJump = 1
{
  SendInput {Space down}
  SendInput {c down}
  SendInput {Space up}
  Sleep 500 ;Keeps crouching 0.5 seconds to improve the jump.
  SendInput {c up}
}
Return

;####################
;#     AutoFire     #
;####################

~$*LButton:: ;AutoFire
if AutoFire = 1
{
	Loop
{
	GetKeyState, LButton, LButton, P
	if LButton = U
		Break
	MouseClick, Left,,, 1
	Gosub, RandomSleep ;Call to RandomSleep.
  if Compensation = 1
  {
    mouseXY(0, compVal) ;If active, call to Compensation.
  }
}
}
Return
RandomSleep: ;Random timing between clicks, just in case.
  Random, random, 14, 25
  Sleep %random%-5
Return

;########################
;#     Compensation     #
;########################

mouseXY(x,y) ;Moves the mouse down to compensate recoil (value in compVal var).
{
  DllCall("mouse_event",uint,1,int,x,int,y,uint,0,int,0)
}

;####################
;#     Tooltips     #
;####################

ToolTip(label) ;Function to show a tooltip when activating, deactivating or changing values.
{
  ToolTip, %label%, 930, 650 ;Tooltips are shown under crosshair for FullHD monitors.
  SetTimer, RemoveToolTip, 1300 ;Removes tooltip after 1.3 seconds.
  return
  RemoveToolTip:
  SetTimer, RemoveToolTip, Off
  ToolTip
  Return
}

;#######################################
;#     Hotkeys for changing values     #
;#######################################

;Toggles
*NumPad1::(ADS = 0 ? (ADS := 1,ToolTip("ADS ON")) : (ADS := 0,ToolTip("ADS OFF")))
*NumPad2::(AutoFire = 0 ? (AutoFire := 1,ToolTip("AutoFire ON")) : (AutoFire := 0,ToolTip("AutoFire OFF")))
*NumPad3::(Compensation = 0 ? (Compensation := 1,ToolTip("Compensation ON")) : (Compensation := 0,ToolTip("Compensation OFF")))
*NumPad0::(CrouchJump = 0 ? (CrouchJump := 1,ToolTip("CrouchJump ON")) : (CrouchJump := 0,ToolTip("CrouchJump OFF")))

*NumpadAdd:: ;Adds compensation.
  compVal := compVal + 5
  ToolTip("Compensation " . compVal)
Return

*NumpadSub:: ;Substracts compensation.
if compVal > 0
{
  compVal := compVal - 5
  ToolTip("Compensation " . compVal)
}
Return
