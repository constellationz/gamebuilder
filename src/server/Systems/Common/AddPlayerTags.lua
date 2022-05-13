-- Adds Player and LocalPlayer tags to players

local AddPlayerTags = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

function AddPlayerTag(player)
	-- Use task.wait() to avoid CollectionService bug
	task.wait()
	CollectionService:AddTag(player, "Player")
end

function AddLocalPlayerTag()
	task.spawn(function()
		repeat 
			task.wait() 
		until Players.LocalPlayer ~= nil
		CollectionService:AddTag(Players.LocalPlayer, "LocalPlayer")
	end)
end

-- Add player tags to all players
function ListenForPlayers()
	Players.PlayerAdded:connect(AddPlayerTag)
end

function AddPlayerTags.Connect()
	-- Server adds player tags to all players
	if RunService:IsServer() then
		ListenForPlayers()
	end

	-- Client adds local player tag to players
	if RunService:IsClient() then
		AddLocalPlayerTag()
	end
end

return AddPlayerTags