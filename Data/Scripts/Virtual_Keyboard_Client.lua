local TWEEN_PROP = script:GetCustomProperty("Tween")
local Tween = nil

if(TWEEN_PROP ~= nil) then
	Tween = require(TWEEN_PROP)
end

local ROOT = script.parent.parent

local TOGGLE_SHIFT_AFTER_SPACE = ROOT:GetCustomProperty("toggle_shift_after_space")
local MAX_LENGTH = ROOT:GetCustomProperty("max_length")
local ENABLE_CURSOR = ROOT:GetCustomProperty("enable_cursor")
local DEBUG = ROOT:GetCustomProperty("debug")

local INPUT_TEXT = script:GetCustomProperty("InputText"):WaitForObject()
local KEYS = script:GetCustomProperty("Keys"):WaitForObject()
local DELETE = script:GetCustomProperty("Delete"):WaitForObject()
local SHIFT = script:GetCustomProperty("Shift"):WaitForObject()
local KEYBOARD = script:GetCustomProperty("Keyboard"):WaitForObject()
local CLOSE_BUTTON = script:GetCustomProperty("CloseButton"):WaitForObject()
local COUNTER = script:GetCustomProperty("Counter"):WaitForObject()

local keys = KEYS:GetChildren()
local shift_toggle = true
local shift_line = SHIFT:FindChildByName("Line")
local tween_opacity = nil
local is_open = false

if(ENABLE_CURSOR) then
	UI.SetCursorVisible(true)
	UI.SetCanCursorInteractWithUI(true)
end

if(MAX_LENGTH > 0) then
	COUNTER.visibility = Visibility.FORCE_ON
	COUNTER.text = "0 / " .. tostring(MAX_LENGTH)
end

local function update_counter()
	if(MAX_LENGTH > 0) then
		COUNTER.text = string.len(INPUT_TEXT.text) .. " / " .. tostring(MAX_LENGTH)
	end
end

local function toggle_letter_case(force_toggle_shift)
	if(force_toggle_shift ~= nil) then
		shift_toggle = force_toggle_shift
	end

	for i, k in ipairs(keys) do
		local letter_obj = k:FindChildByName("Letter")
		local letter = string.lower(tostring(letter_obj.text))

		if(letter ~= "space" and letter ~= "shift" and letter ~= "delete") then
			letter_obj.text = (shift_toggle and string.upper(letter)) or string.lower(letter)
		end
	end

	if(shift_toggle) then
		shift_line.visibility = Visibility.FORCE_ON		
	else
		shift_line.visibility = Visibility.FORCE_OFF
	end
end

local function on_key_clicked(button)
	local current_str = INPUT_TEXT.text
	local input_letter = button:GetCustomProperty("letter")

	if(input_letter == "shift") then
		shift_toggle = not shift_toggle
		toggle_letter_case()
	elseif(input_letter == "delete") then
		INPUT_TEXT.text = string.sub(current_str, 1, #current_str - 1)
	elseif(MAX_LENGTH == 0 or string.len(INPUT_TEXT.text) < MAX_LENGTH) then
		input_letter = (shift_toggle and string.upper(input_letter)) or input_letter
		INPUT_TEXT.text = INPUT_TEXT.text .. tostring(input_letter)

		Events.Broadcast("keyboard.change", INPUT_TEXT.text, MAX_LENGTH)

		if(TOGGLE_SHIFT_AFTER_SPACE) then
			toggle_letter_case((input_letter == " " and true) or false)
		else
			toggle_letter_case(false)
		end
	end

	update_counter()
end

local function open_keyboard()
	if(is_open) then
		return
	end

	is_open = true

	if(Tween ~= nil) then
		tween_opacity = Tween:new(.3, { o = 0 }, { o = 1})
		tween_opacity:on_change(function(c)
			KEYBOARD.opacity = c.o
		end)

		tween_opacity:on_complete(function() tween_opacity = nil end)

		tween_opacity:on_start(function()
			KEYBOARD.visibility = Visibility.FORCE_ON
		end)
	else
		KEYBOARD.opacity = 1
		KEYBOARD.visibility = Visibility.FORCE_ON
	end
end

local function close_keyboard()
	if(not is_open) then
		return
	end

	is_open = false

	if(Tween ~= nil) then
		tween_opacity = Tween:new(.3, { o = 1 }, { o = 0})
		tween_opacity:on_change(function(c)
			KEYBOARD.opacity = c.o
		end)

		tween_opacity:on_complete(function()
			tween_opacity = nil
			KEYBOARD.visibility = Visibility.FORCE_OFF
			INPUT_TEXT.text = ""
			toggle_letter_case(true)
		end)
	else
		KEYBOARD.opacity = 0
		KEYBOARD.visibility = Visibility.FORCE_OFF
		INPUT_TEXT.text = ""
		toggle_letter_case(true)
	end
end

for i, k in ipairs(keys) do
	k.clickedEvent:Connect(on_key_clicked)
end

function Tick(dt)
	if(tween_opacity ~= nil) then
		tween_opacity:tween(dt)
	end
end

CLOSE_BUTTON.clickedEvent:Connect(close_keyboard)

if(DEBUG) then
	Game.GetLocalPlayer().bindingPressedEvent:Connect(function(p, binding)
		if(binding == "ability_extra_1") then
			open_keyboard()
		elseif(binding == "ability_extra_2") then
			close_keyboard()
		end
	end)
end

Events.Connect("keyboard.open", open_keyboard)
Events.Connect("keyboard.close", close_keyboard)