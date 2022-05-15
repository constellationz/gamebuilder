-- Adds Player tag to players

local AddPlayerTags = {}

local Get = require(workspace.Get)
local Players = Get.Service "Players"
local CollectionService = Get.Service "CollectionService"

function AddPlayerTag(player)
	-- Use task.wait() to avoid CollectionService bug
	task.wait()
	CollectionService:AddTag(player, "Player")
end

function AddPlayerTags.Connect()
	Players.PlayerAdded:connect(AddPlayerTag)
end

return AddPlayerTags