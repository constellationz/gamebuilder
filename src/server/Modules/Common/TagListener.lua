-- Creates a TagListener that acts on instances with a certain tag
-- When an instance with a certain tag is created, it is added to 
-- the TagListener

-- Example usage:
--[[
	bombSystem = TagListener.new("Bomb", {
		connect = function(instance)

		end,
		step = function(instance, deltaTime)

		end,
		disconnect = function(instance)

		end,
	})
]]

local Get = require(workspace.Get)
local Maid = Get "Common.Maid"
local RunService = Get.Service "RunService"
local CollectionService = Get.Service "CollectionService"

local TagListener = {}
TagListener.__index = TagListener

function TagListener.new(tag: string, data: table)
	assert(tag ~= nil, "argument 1 missing or nil: tag")
	assert(data ~= nil, "argument 2 missing or nil: data")

	if data.step ~= nil then
		assert(type(data.step) == "function", "data.step is not a function")
	end
	if data.connect ~= nil then
		assert(type(data.connect) == "function", "data.connect is not a function")
	end
	if data.disconnect ~= nil then
		assert(type(data.disconnect) == "function", "data.disconnect is not a function")
	end

	-- create TagListener state
	local self = setmetatable({
		-- list of all instances in this TagListener
		instances = {},

		-- use functions from input args
		tag = tag,
		step = data.step,
		connect = data.connect,
		disconnect = data.disconnect,

		-- create a maid to clean up later
		maid = Maid.new()
	}, TagListener)

	-- connect Stepped (if applicable)
	if self.step ~= nil and RunService:IsServer() then
		self.maid.Stepped = RunService.Stepped:connect(function(_, deltaTime)
			self:Step(deltaTime)
		end)
	elseif self.step ~= nil and RunService:IsClient() then
		self.maid.RenderStepped = RunService.RenderStepped:connect(function(deltaTime)
			self:Step(deltaTime)
		end)
	end

	return self
end

-- disconnects taglistener connections
function TagListener:Disconnect()
	self.maid:Clean()
end

-- binds to collection service
function TagListener:BindToCollectionService()
	self.maid.instanceAdded = CollectionService
		:GetInstanceAddedSignal(self.tag)
		:connect(function(instance)

		self:AddInstance(instance)
	end)
	self.maid.instanceRemoving = CollectionService
		:GetInstanceRemovedSignal(self.tag)
		:connect(function(instance)

		self:RemoveInstance(instance)
	end)
end

-- Get all tagged objects in a workspace and then bind to collection service
function TagListener:ListenTo(workspace)
	-- Add tagged instances in workspace
	for _, d in pairs (workspace:GetDescendants()) do
		if CollectionService:HasTag(d, self.tag) then
			self:AddInstance(d)
		end
	end

	-- Bind to CollectionService
	self:BindToCollectionService()
end

-- tick TagListener
function TagListener:Step(deltaTime)
	for _, instance in pairs (self.instances) do
		self.step(instance, deltaTime)
	end
end

-- add an instance to the TagListener state
function TagListener:AddInstance(instance)
	-- if the instance is invalid, quietly return
	if instance == nil or CollectionService:HasTag(instance, self.tag) == false then
		return
	end

	-- connect and add to instances table
	if self.connect ~= nil then
		self.connect(instance)
	end

	-- only keep state if a disconnect exists
	if self.disconnect ~= nil or self.stepped ~= nil then
		self.instances[instance] = instance
	end
end

-- remove an instance from the TagListener state
function TagListener:RemoveInstance(instance)
	-- try getting the data
	local hasInstance = self.instances[instance] ~= nil

	-- if the data doesn't exist, return quietly
	if hasInstance == false then
		return
	end

	-- otherwise, disconnect
	if self.disconnect ~= nil then
		self.disconnect(instance)
	end
	
	-- remove instance
	self.instances[instance] = nil
end

return TagListener
