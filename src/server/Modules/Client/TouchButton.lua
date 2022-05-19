-- Object for a touch button UI

local Get = require(workspace.Get)
local UserInputService = Get.Service "UserInputService"

local assets = Get "Common.Assets"

local DEFAULT_SIZE = UDim2.new(0, 50, 0, 50)

function CreateButton(parent, image)
	-- create button
	local button = Instance.new("ImageButton")
	button.Size = DEFAULT_SIZE
	button.Image = assets.ui.touch_button_released
	button.BackgroundTransparency = 1
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Parent = parent

	-- create icon for the button
	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.new(0.7, 0, 0.7, 0)
	icon.Image = image or ""
	icon.Parent = button
	icon.Active = false

	return button
end

local TouchButton = {}
TouchButton.__index = TouchButton

function TouchButton.new(parent: Instance, image: string)
	local button = CreateButton(parent, image)
	local self = setmetatable({
		-- instances
		touchStarted = Instance.new("BindableEvent"),
		touchEnded = Instance.new("BindableEvent"),
		button = button,

		-- state
		isHeld = false,
		lastTouch = button.Position,
	}, TouchButton)

	local processInput = function(...) self:ProcessInput(...) end

	-- connections
	self.inputBegan = button.InputBegan:connect(processInput)
	self.inputEnded = UserInputService.InputEnded:connect(processInput)
	self.inputChanged = UserInputService.InputChanged:connect(processInput) 

	return self
end

-- process an Input signal
function TouchButton:ProcessInput(io)
	local isTouch = io.UserInputType == Enum.UserInputType.Touch

	-- get touch state
	local began = io.UserInputState == Enum.UserInputState.Begin
	local released = io.UserInputState == Enum.UserInputState.End
	local held = self.isHeld and (io.Position - io.Delta - self.lastTouch).magnitude < 10
	
	-- process state changes
	if isTouch and began then
		self.touchStarted:Fire()
		self.isHeld = true
		self.button.Image = assets.ui.touch_button_pressed
	elseif isTouch and held and released then
		self.touchEnded:Fire()
		self.isHeld = false
		self.button.Image = assets.ui.touch_button_released
	end

	-- update lastTouch position
	if isTouch and (began or held) then
		self.lastTouch = io.Position
	end
end

function TouchButton:Destroy()
	self.button:Destroy()
	self.touchStarted:Destroy()
	self.touchEnded:Destroy()
	self.inputBegan:Disconnect()
	self.inputChanged:Disconnect()
	self.inputEnded:Disconnect()
end

function TouchButton:Hide()
	self.button.Visible = false
end

function TouchButton:Show()
	self.button.Visible = true
end

function TouchButton:MoveTo(position)
	self.button.Position = position
end

function TouchButton:Resize(size)
	self.button.Size = size
end

function TouchButton:OnHeld(callback)
	return self.touchStarted.Event:connect(callback)
end

function TouchButton:OnRelease(callback)
	return self.touchEnded.Event:connect(callback)
end

return TouchButton