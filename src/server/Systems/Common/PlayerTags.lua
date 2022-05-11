-- Adds Player and LocalPlayer tags to players

local PlayerTags = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

function AddPlayerTag(player)
	CollectionService:AddTag(player, "Player")
end

function AddLocalPlayerTag(player)
	task.spawn(function()
		repeat task.wait() until Players.LocalPlayer ~= nil
		CollectionService:AddTag(Players.LocalPlayer, "LocalPlayer")
	end)
end

-- Add player tags to all players
function AddPlayerTags()
	for _, player in pairs (Players:GetPlayers()) do
		AddPlayerTag(player)
	end

	Players.PlayerAdded:connect(AddPlayerTag)
end

function PlayerTags.Connect()
	-- Server adds player tags to all players
	if RunService:IsServer() then
		AddPlayerTags()
	end

	-- Client adds local player tag to players
	if RunService:IsClient() then
		AddLocalPlayerTag()
	end
end

return PlayerTags