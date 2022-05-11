-- Creates a TagListener that acts on instances with a certain tag
-- When an instance with a certain tag is created, it is added to 
-- the TagListener

-- Example usage:
--[[
	bombSystem = TagListener.new("Bomb", {
		connect = function(self)
			local instance = self.instance
		end,
		step = function(self, deltaTime)
			local instance = self.instance
		end,
		disconnect = function(self)
			local instance = self.instance
		end,
	}
	
	-- add to SystemManager which acts on workspace
	local manager = SystemManager.new(workspace)
	manager:AddSystem(bombSystem)
]]

local Get = require(workspace.Get)
local Maid = Get "Common.Maid"
local CollectionService = Get.Service "CollectionService"

local TagListener = {}
TagListener.__index = TagListener

-- listen for a tag
-- pass in data {connect = function, step = function, disconnect = function}
function TagListener.new(tag: string, data: table)
	-- assert that args exist
	assert(tag ~= nil, "argument 1 missing or nil: tag")
	assert(data ~= nil, "argument 2 missing or nil: data")

	-- assert correct types
	if data.step ~= nil then
		assert(type(data.step) == "function", 
			"data.step is not a function")
	end
	if data.connect ~= nil then
		assert(type(data.connect) == "function", 
			"data.connect is not a function")
	end
	if data.disconnect ~= nil then
		assert(type(data.disconnect) == "function", 
			"data.disconnect is not a function")
	end

	-- create TagListener state
	local self = setmetatable({
		-- list of all instances in this TagListener
		-- {[instance] = {instance = instance, ...}, ...}
		instances = {},

		-- use functions from input args
		tag = tag,
		step = data.step,
		connect = data.connect,
		disconnect = data.disconnect,

		-- create a maid to clean up later
		maid = Maid.new()
	}, TagListener)

	return self
end

-- disconnect the system
function TagListener:Disconnect()
	self.maid:Clean()
end

-- connects the TagListener to client workspace
function TagListener:ListenTo(parent)
	-- parent must exist to connect
	if parent == nil then
		warn("TagListener cannot listen to nil parent")
		return
	end

	-- add instances
	self:AddInstancesIn(parent)
	self:BindToCollectionService()
end

-- disconnect all instances
function TagListener:RemoveAllInstances()
	for _, instance in pairs (self.instances) do
		self:RemoveInstance(instance)
	end
end

-- binds to collection service
function TagListener:BindToCollectionService()
	self.maid.instanceAdded = CollectionService
	:GetInstanceAddedSignal(self.tag)
	:connect(function(instance)

		self:AddInstance(instance)
	end)
	self.maid.instanceRemoving = CollectionService
	:GetInstanceAddedSignal(self.tag)
	:connect(function(instance)

		self:RemoveInstance(instance)
	end)
end

function TagListener:AddWorkspace(workspace)
	for _, v in pairs (workspace:GetDescendants()) do
		self:AddInstance(v)
	end
end

-- add all instances in a certain model
function TagListener:AddInstancesIn(workspace)
	-- if workspace doesn't exist, warn user
	if workspace == nil then
		warn("argument 1 missing or nil: workspace")
		return
	end

	-- if many instances are provided, add all of them as workspaces
	if type(workspace) == "table" then
		for _, v in pairs (workspace) do
			self:AddWorkspace(v)
		end
	elseif workspace:isA'Instance' then
		-- if one instance is provided, add it as a workspace
		self:AddWorkspace(workspace)
	end
end

-- add an instance to the TagListener state
function TagListener:AddInstance(instance)
	-- if the instance is invalid, quietly return
	if instance == nil 
		or CollectionService:HasTag(instance, self.tag) == false then

		return
	end

	-- create data for this instance
	local data = {
		instance = instance,
		maid = Maid.new()
	}

	-- connect and add to instances table
	if self.connect ~= nil then
		self.connect(data)
	end

	-- only keep state if a disconnect exists
	if self.disconnect ~= nil or self.stepped ~= nil then
		self.instances[instance] = data
	end
end

-- remove an instance from the TagListener state
function TagListener:RemoveInstance(instance)
	-- try getting the data
	local data = self.instances[instance]

	-- if the data doesn't exist, return quietly
	if data == nil then
		return
	end

	-- otherwise, disconnect
	if self.disconnect ~= nil then
		self.disconnect(data)
		data.maid:Clean()
	end
	self.instances[instance] = nil
end

-- tick TagListener
function TagListener:Tick(deltaTime)
	-- silently return if step is not defined
	if self.step == nil then
		return
	end

	-- step everything in the TagListener
	for _, data in pairs (self.instances) do
		self.step(data, deltaTime)
	end
end

return TagListener
