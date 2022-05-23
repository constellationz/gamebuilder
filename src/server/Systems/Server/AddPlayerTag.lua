-- Adds Player tag to players

local Get = require(workspace.Get)
local Players = Get.Service "Players"
local CollectionService = Get.Service "CollectionService"

local AddPlayerTags = {}

local function AddPlayerTag(player)
	-- Use task.wait() to avoid CollectionService bug
	task.wait()
	CollectionService:AddTag(player, "Player")
end

function AddPlayerTags.Connect()
	Players.PlayerAdded:connect(AddPlayerTag)
end

return AddPlayerTags