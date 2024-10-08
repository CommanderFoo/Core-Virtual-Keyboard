-- CommanderFoo

local ROOT = script.parent.parent

local TWEEN_PROP = ROOT:GetCustomProperty("Tween")
local Tween = nil

if(TWEEN_PROP ~= nil) then
	Tween = require(TWEEN_PROP)
end

local TOGGLE_SHIFT_AFTER_SPACE = ROOT:GetCustomProperty("toggle_shift_after_space")
local MAX_LENGTH = ROOT:GetCustomProperty("max_length")
local ENABLE_CURSOR = ROOT:GetCustomProperty("enable_cursor")
local SHOW_SAVE_BUTTON = ROOT:GetCustomProperty("show_save_button")
local CLOSE_ON_SAVE = ROOT:GetCustomProperty("close_on_save")
local ENABLE_BLOCKER = ROOT:GetCustomProperty("enable_blocker")
local BLOCKER_COLOR = ROOT:GetCustomProperty("blocker_color")
local DEBUG = ROOT:GetCustomProperty("debug")

local INPUT_TEXT = script:GetCustomProperty("InputText"):WaitForObject()
local KEYS = script:GetCustomProperty("Keys"):WaitForObject()
local DELETE = script:GetCustomProperty("Delete"):WaitForObject()
local SHIFT = script:GetCustomProperty("Shift"):WaitForObject()
local KEYBOARD = script:GetCustomProperty("Keyboard"):WaitForObject()
local CLOSE_BUTTON = script:GetCustomProperty("CloseButton"):WaitForObject()
local COUNTER = script:GetCustomProperty("Counter"):WaitForObject()
local SAVE_BUTTON = script:GetCustomProperty("SaveButton"):WaitForObject()
local INPUT_BACKGROUND = script:GetCustomProperty("InputBackground"):WaitForObject()
local BLOCKER = script:GetCustomProperty("Blocker"):WaitForObject()

local TOP_PANEL = script:GetCustomProperty("TopPanel"):WaitForObject()
local BOTTOM_PANEL = script:GetCustomProperty("BottomPanel"):WaitForObject()
local RIGHT_PANEL = script:GetCustomProperty("RightPanel"):WaitForObject()
local LEFT_PANEL = script:GetCustomProperty("LeftPanel"):WaitForObject()

local panels = {

	["TOP"] = {

		panel = TOP_PANEL,
		header_text = TOP_PANEL:GetCustomProperty("HeaderText"):GetObject(),
		scroll_panel = TOP_PANEL:GetCustomProperty("ScrollPanel"):GetObject()

	},

	["BOTTOM"] = {

		panel = BOTTOM_PANEL,
		header_text = BOTTOM_PANEL:GetCustomProperty("HeaderText"):GetObject(),
		scroll_panel = BOTTOM_PANEL:GetCustomProperty("ScrollPanel"):GetObject()

	},

	["RIGHT"] = {

		panel = RIGHT_PANEL,
		header_text = RIGHT_PANEL:GetCustomProperty("HeaderText"):GetObject(),
		scroll_panel = RIGHT_PANEL:GetCustomProperty("ScrollPanel"):GetObject()

	},

	["LEFT"] = {

		panel = LEFT_PANEL,
		header_text = LEFT_PANEL:GetCustomProperty("HeaderText"):GetObject(),
		scroll_panel = LEFT_PANEL:GetCustomProperty("ScrollPanel"):GetObject()

	}

}

local keys = KEYS:GetChildren()
local shift_toggle = true
local shift_line = SHIFT:FindChildByName("Line")
local tween_opacity = nil
local is_open = false

if(MAX_LENGTH > 0) then
	COUNTER.visibility = Visibility.FORCE_ON
	COUNTER.text = "0 / " .. tostring(MAX_LENGTH)
end

BLOCKER:SetButtonColor(BLOCKER_COLOR)

local function enable_save_button()
	SAVE_BUTTON.isInteractable = true
end

local function disable_save_button()
	SAVE_BUTTON.isInteractable = false
end

local function setup_save_button()
	if(SHOW_SAVE_BUTTON) then
		SAVE_BUTTON.visibility = Visibility.FORCE_ON
		INPUT_BACKGROUND.width = INPUT_BACKGROUND.width - 24

		if(MAX_LENGTH == 0) then
			enable_save_button()
		end
	end
end

local function update_counter()
	if(MAX_LENGTH > 0) then
		COUNTER.text = string.len(INPUT_TEXT.text) .. " / " .. tostring(MAX_LENGTH)

		if(string.len(INPUT_TEXT.text) > 0) then
			enable_save_button()
		else
			disable_save_button()
		end
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

local function truncate(text)
	return string.sub(text, 1, MAX_LENGTH)
end

local function set_text(text)
	if(text == nil) then
		return
	end

	INPUT_TEXT.text = truncate(tostring(text))
	update_counter()
end

local function clear_text()
	INPUT_TEXT.text = ""
end

local function block()
	if(ENABLE_BLOCKER) then
		BLOCKER.visibility = Visibility.FORCE_ON
	end
end

local function unblock()
	if(ENABLE_BLOCKER) then
		BLOCKER.visibility = Visibility.FORCE_OFF
	end
end

local function open_keyboard(text)
	if(is_open) then
		return
	end

	set_text(text)

	is_open = true
	block()

	if(ENABLE_CURSOR) then
		UI.SetCursorVisible(true)
		UI.SetCanCursorInteractWithUI(true)
	end

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

local function reset()
	KEYBOARD.opacity = 0
	KEYBOARD.visibility = Visibility.FORCE_OFF
	INPUT_TEXT.text = ""
	toggle_letter_case(true)
	update_counter()
end

local function close_keyboard()
	if(not is_open) then
		return
	end

	is_open = false
	Events.Broadcast("keyboard.closed")
	unblock()

	if(ENABLE_CURSOR) then
		UI.SetCursorVisible(false)
		UI.SetCanCursorInteractWithUI(false)
	end

	if(Tween ~= nil) then
		tween_opacity = Tween:new(.3, { o = 1 }, { o = 0})
		tween_opacity:on_change(function(c)
			KEYBOARD.opacity = c.o
		end)

		tween_opacity:on_complete(reset)
	else
		reset()
	end
end

local function save()
	Events.Broadcast("keyboard.save", INPUT_TEXT.text)

	if(CLOSE_ON_SAVE) then
		close_keyboard()
	end
end

local function open_panel(panel, opts)
	if(panels[panel] ~= nil) then
		local the_panel = panels[panel]

		the_panel.panel.visibility = Visibility.FORCE_ON

		if(not opts) then
			return
		end

		the_panel.header_text.text = opts.header_text or ""
		the_panel.panel.width = opts.width or the_panel.panel.width
		the_panel.panel.height = opts.height or the_panel.panel.height

		if(opts.header_color ~= nil) then
			the_panel.header_text:SetColor(opts.header_color)
		end
	end
end

local function close_panel(panel)
	if(panels[panel] ~= nil) then
		panels[panel].panel.visibility = Visibility.FORCE_OFF
	end
end

local function clear_panel(panel)
	if(panels[panel] ~= nil) then
		for i, c in ipairs(panels[panel].scroll_panel:GetChildren()) do
			c:Destroy()
		end
	end
end

local function add_items(panel, items)
	if(panels[panel] ~= nil) then
		for i, item in ipairs(items) do
			item.parent = panels[panel].scroll_panel
		end
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

if(DEBUG) then
	Game.GetLocalPlayer().bindingPressedEvent:Connect(function(p, binding)
		if(binding == "ability_extra_1") then -- 1
			open_keyboard()
		elseif(binding == "ability_extra_2") then -- 2
			close_keyboard()
		end
	end)
end

setup_save_button()

CLOSE_BUTTON.clickedEvent:Connect(close_keyboard)
SAVE_BUTTON.clickedEvent:Connect(save)

Events.Connect("keyboard.open", open_keyboard)
Events.Connect("keyboard.close", close_keyboard)
Events.Connect("keyboard.text", set_text)
Events.Connect("keyboard.clear", clear_text)
Events.Connect("keyboard.unblock", unblock)
Events.Connect("keyboard.block", block)

Events.Connect("keyboard.open_panel", open_panel)
Events.Connect("keyboard.close_panel", close_panel)
Events.Connect("keyboard.clear_panel", clear_panel)
Events.Connect("keyboard.add_items", add_items)