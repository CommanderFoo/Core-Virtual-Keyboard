--[[
	Virtual Keyboard allows players to enter text (i.e. naming a Pet).

	It doesn't support all the symbols on a keyboard, though I may expand on that in the future.

	All settings can be found on the root of the component.

	- The input field can be restricted to a max length if needed.
	- First letter of a new word will automatically toggle the shift for uppercase, this can be turned off.
	- Enable UI cursor. WIll enable the UI cursor if enabled.
	- Debug - If enabled, then you can test the opening and closing of the keyboard by pressing 1 or 2.

	--- EVENTS ---

	keyboard.open - Open the keyboard.
	keyboard.close - Close the keyboard.
	keyboard.change - When the input text changes.

	--- TWEEN ---

	A Tween library can be imported from Community Content that will enable the tweening functions when 
	showing and closing the keyboard.

	Search for "Tween" by CommanderFoo.

	When imported, drag the Tween script onto the Virtual_Keyboard_Client property "Tween".
]]