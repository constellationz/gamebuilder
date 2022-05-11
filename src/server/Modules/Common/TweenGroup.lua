-- TweenGroup can be used to tween multiple objects

local TweenService = game:GetService("TweenService")

local TweenGroup = {}
TweenGroup.__index = TweenGroup

function TweenGroup.new(data)
	local self = setmetatable({}, TweenGroup)

	-- important data
	self._tweenInfo = nil
	self._functions = {}
	self._tweens = {}

	-- find tweenInfo	
	for i, datapoint in pairs (data) do
		if i == "TweenInfo" then
			self._tweenInfo = datapoint
			data[i] = nil
			break
		end
	end
	assert(self._tweenInfo ~= nil, "TweenInfo not defined in data table")

	-- find functions, if applicable
	for i, func in pairs (data) do
		if type(func) == "function" then
			self._functions[#self._functions + 1] = func
			data[i] = nil
		end
	end

	-- make other tweens
	for i, goal in pairs (data) do
		self._tweens[#self._tweens + 1] = TweenService:Create(i, self._tweenInfo, goal)
	end

	return self
end

function TweenGroup:Play()
	-- execute functions
	for _, func in pairs (self._functions) do
		func()
	end

	-- play tweens
	for _, tween in pairs (self._tweens) do
		tween:Play()
	end
end

function TweenGroup:Cancel()
	-- cancel tweens
	for _, tween in pairs (self._tweens) do
		tween:Cancel()
	end
end

return TweenGroup
