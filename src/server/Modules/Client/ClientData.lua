-- Functions to interact with player data from the server

local ClientData = {}

local Get = require(workspace.Get)

-- Get a datapoint from the server
-- Returns the value from the server
function ClientData.Get(key)
	return Get.Remote "GetData":InvokeServer(key)
end

-- Set a client datapoint
-- Returns the value that was set
function ClientData.Set(key, value)
	Get.Remote "SetData":FireServer(key, value)
	return value
end

-- Bind a callback to a certain data keypoint
-- Returns the signal for the data update
function ClientData.BindToKey(key, callback)
	-- Try getting the value now
	task.spawn(function()
		callback(ClientData.Get(key))
	end)

	-- Bind to data distribution event
	local onSignalReceived = Get.Remote "DataUpdate".OnClientEvent:connect(function(incomingKey, value)
		if incomingKey == key then
			callback(value)
		end
	end)

	-- Return the signal that was connected
	return onSignalReceived
end

return ClientData
