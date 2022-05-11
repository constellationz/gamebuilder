-- Maid handles easy cleanup within modules

local Maid = {}
Maid.__index = Maid

-- list of destructors
local destructors = {
	["function"] = function(callback)
		callback()
	end;
	["RBXScriptConnection"] = function(connection)
		connection:Disconnect()
	end;
	["Instance"] = function(instance)
		instance:Destroy()
	end;
	["table"] = function(tbl)
		-- clean maids if applicable
		if tbl._isMaid then
			tbl:Clean()
		end
	end
}

-- when indexing, return either Maid primitive or something in _tasks
function Maid.__index(tbl, index)
	return Maid[index] or tbl._tasks[index]
end

function Maid.__newindex(tbl, index, value)
	-- if an index is overwritten, disconnect the old task
	local existingTask = tbl._tasks[index]
	if existingTask ~= nil then
		Maid.ExecuteTask(existingTask)
	end

	tbl._tasks[index] = value
end

-- adds unsorted task
function Maid:Add(task)
	self._unsortedTasks[#self._unsortedTasks + 1] = task
end

function Maid.new()
	-- create maid state
	local self = setmetatable({
		_isMaid = true,
		_tasks = {},
		_unsortedTasks = {},
	}, Maid)

	return self
end

-- execute destructors for all tasks
function Maid:Clean()
	-- execute named tasks
	for i, v in pairs (self._tasks) do
		Maid.ExecuteTask(v)
	end

	-- execute unsorted tasks
	for i, v in ipairs (self._unsortedTasks) do
		Maid.ExecuteTask(v)
	end
end

-- alternate syntax for Remove
Maid.Disconnect = Maid.Clean
Maid.Remove = Maid.Clean

-- execute a task
function Maid.ExecuteTask(v)
	local destructor = destructors[typeof(v)]
	if destructor ~= nil then
		destructor(v)
	else
		-- undefined destructors spit warnings
		warn("destructor doesn't exist for", typeof(v))
	end
end

return Maid
