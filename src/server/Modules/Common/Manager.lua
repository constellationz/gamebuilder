-- Manager is an entry-point object that manages game systems.

-- Usage:
--[[
	-- create manager
	local manager = Manager.new()
	
	-- add systems
	manager:AddSystems{
		"Common.Bombs",
		"Common.Timers"
	}
	
	-- under the hood, this syntax is being used:
	-- manager:AddSystem("Bombs", Get.System "Common.Bombs")
	-- manager:AddSystem("Timers", Get.System "Common.Timers")
	
	-- connect all systems
	-- each system is connected in the order they were added
	-- depending on whether the client or server is connecting, use
	-- each respective syntax
	if RunService:IsClient()
		manager:ConnectClient()
	else
		manager:ConnectServer()
	end
]]

-- Example system:
-- manager:AddSystem("MySystem", Get "Common.MySystem")
--[[
	-- create system
	mySystem = {
		-- global state
	}
	
	-- style tip: place Get calls after system declaration
	local Get = require(workspace.Get)
	local TagListener = Get "Common.TagListener"
	
	-- before mySystem.Connect is defined, mySystem.manager is set
	-- to the system manager
	function mySystem.Connect()
		TagListener.new(...)
	end
]]

local Get = require(workspace.Get)
local RunService = Get.Service "RunService"

local Manager = {}
Manager.__index = Manager

-- make a new Manager
function Manager.new()
	local self = setmetatable({
		-- array of all systems {[1] = system, ...}
		systems = {},
	}, Manager)

	return self
end

-- add system to state
-- return the system
function Manager:AddSystem(systemName: string, system: table)
	-- assert valid systemName and system
	assert(systemName ~= nil, "Argument 1 missing or nil: systemName")
	assert(system ~= nil, "Argument 2 missing or nil: system")
	assert(system.Connect ~= nil, "System.Connect missing or nil in "..systemName)

	-- no duplicate systems allowed
	assert(self[systemName] == nil, 
		"Manager["..systemName.."] is already defined!")

	-- set the system's manager
	system.manager = self

	-- add system to the module state
	self[systemName] = system
	self.systems[#self.systems + 1] = system

	return system
end

-- add multiple systems
function Manager:AddSystems(systems)
	assert(systems ~= nil, "Argument 1 missing or nil: systems")

	-- add each system
	for i, directory in pairs (systems) do
		local results = Get.System(directory)

		-- if a wildcard was passed, load each system
		if typeof(results) == "table" then
			-- if there are many results, sort alphabetically
			-- this defines the loading order so wildcard modules
			-- always load in the same order
			table.sort(results, function(a, b)
				return a.Name < b.Name
			end)

			-- add systems as normally
			for _, result in pairs (results) do
				self:AddSystem(result.Name, require(result))
			end
		elseif typeof(results) == "Instance" then
			-- otherwise, load individual systems
			self:AddSystem(results.Name, require(results))
		end
	end
end

-- connect each system
function Manager:ConnectSystems()
	for _, system in pairs (self.systems) do
		task.spawn(system.Connect)
	end
end

-- connect the server
function Manager:ConnectServer()
	-- systems are connected immediately
	self:ConnectSystems()
end

-- connect the client
function Manager:ConnectClient()
	-- systems are connected after the game is loaded
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	self:ConnectSystems()
end

return Manager
