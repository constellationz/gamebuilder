-- Handles client data and data saving

local Data = {
	-- Messages
	Messages = {
		PlayerDataDidNotLoad = "Data loading is taking longer than usual, try rejoining...",
	}

	Profiles = {}
}

local Get = require(workspace.Get)
local G = Get "Game.Globals"
local Players = Get.Service "Players"
local ProfileService = Get.Lib "ProfileService"

function Data.Connect()
	-- Connect players to their store
	TagListener.new("Player", {
		connect = OpenPlayerData
		disconnect = ClosePlayerData
	}):ListenTo(Players)
end

function Data.GetPlayerData(player, key, value)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	assert(key ~= nil, "Argument 2 missing or nil: key")
	assert(value ~= nil, "Argument 3 missing or nil: value")

	-- make sure profile exists
	local profile = Data.Profiles[player]
	assert(profile ~= nil, "Profile missing or nil")

	return profile[key]
end

-- sets player data
-- returns the value that was set
function Data.SetPlayerData(player, key, value)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	assert(key ~= nil, "Argument 2 missing or nil: key")
	assert(value ~= nil, "Argument 3 missing or nil: value")

	-- make sure profile exists
	local profile = Data.Profiles[player]
	assert(profile ~= nil, "Profile missing or nil")

	-- set value
	profile[key] = value

	return value
end

-- increment the player data
-- return the value that was set
function Data.IncrementPlayerData(player, key, increment)
	-- try getting data
	local value = Data.GetPlayerData(player, key)
	if value == nil then
		return nil
	end

	-- set new value
	return Data.SetPlayerData(player, key, value + increment)
end

function OpenPlayerData(player)
	-- try opening player profile
	local profile = PlayerStore:LoadProfileAsync(Data.Profiles.Player..player.UserId)
	
	-- store might not open, kick player
	if profile == nil then
		player:Kick(Data.Messages.PlayerDataDidNotLoad)
		return
	end

	-- Setup data
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		player:SetAttribute("DataLoaded", false)
		player:Kick()
		Data.Profiles[player] = nil
	end)

	-- If the profile has successfully loaded...
	if player:IsDescendantOf(Players) then
		Data.Profiles[player] = profile
		player:SetAttribute("DataLoaded", true)
	else
		-- The player left before the profile loaded
		profile:Release()
	end
end

function ClosePlayerData(player)
	local profile = Data.Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end

return Data
