-- Adds LocalPlayer tag to local players

local AddLocalPlayerTag = {}

local Get = require(workspace.Get)
local Players = Get.Service "Players"
local CollectionService = Get.Service "CollectionService"

function AddTag()
	repeat 
		task.wait() 
	until Players.LocalPlayer ~= nil
	CollectionService:AddTag(Players.LocalPlayer, "LocalPlayer")
end

function AddLocalPlayerTag.Connect()
	task.spawn(AddTag)
end

return AddLocalPlayerTag