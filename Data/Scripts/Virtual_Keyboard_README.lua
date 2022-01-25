--[[
	Virtual Keyboard allows players to enter text (i.e. naming a Pet).

	It doesn't support all the symbols on a keyboard, though I may expand on that in the future.

	All settings can be found on the root of the component.

	--- EVENTS ---

	keyboard.open - Open the keyboard.
	keyboard.close - Close the keyboard.
	keyboard.change - When the input text changes.
	keyboard.clear - Clears the input text.
	keyboard.text - Set the input text.
	keyboard.save - Connect to this when the player clicks the save button (if enabled).
	And more...

	Code is simple, have a look at the events broadcasted to see the parameters.
	
	--- TWEEN ---

	A Tween library can be imported from Community Content that will enable the tweening functions when 
	showing and closing the keyboard.

	Search for "Tween" by CommanderFoo.

	When imported, drag the Tween script onto the Virtual_Keyboard_Client property "Tween".
]]