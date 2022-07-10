--[[
	Putting this on CC as I am not really using it right now, so might be of use to someone.
	
	Virtual Keyboard allows players to enter text (i.e. naming a Pet).

	It doesn't support all the symbols on a keyboard, though I may expand on that in the future.

	All settings can be found on the root of the component.

	If debug is enabled, then you can open the keyboard with 1 for testing. It's advised to use an action
	binding instead.

	Close on save and show save button is if you need the player to confirm their change so that you can
	use that text value to update something (i.e. a pet name).


	--- EVENTS ---

	keyboard.open - Open the keyboard.
	keyboard.close - Close the keyboard.
	keyboard.change - When the input text changes.
	keyboard.clear - Clears the input text.
	keyboard.text - Set the input text.
	keyboard.save - Connect to this when the player clicks the save button (if enabled).
	And more...

	Code is simple, have a look at the events broadcasted to see the parameters.
]]
