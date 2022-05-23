-- Adds LocalPlayer tag to local players

local Get = require(workspace.Get)
local Players = Get.Service "Players"
local CollectionService = Get.Service "CollectionService"

local AddLocalPlayerTag = {}

local function AddTag()
	repeat 
		task.wait() 
	until Players.LocalPlayer ~= nil
	CollectionService:AddTag(Players.LocalPlayer, "LocalPlayer")
end

function AddLocalPlayerTag.Connect()
	task.spawn(AddTag)
end

return AddLocalPlayerTag