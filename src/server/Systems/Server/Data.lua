-- Handles client data and data saving

local Data = {
	Messages = {
		PlayerDataDidNotLoad = "Data could not be loaded, try rejoining"
	},

	-- Stores loaded with Data.OpenStores
	Stores = {},
	
	-- Player profiles loaded with OpenPlayerProfile
	PlayerProfiles = {},
}

local Get = require(workspace.Get)
local G = Get "Common.Globals"
local Players = Get.Service "Players"
local TagListener = Get "Common.TagListener"
local ProfileService = Get.Lib "ProfileService"

function Data.Connect()
	-- Open data profiles
	Data.OpenStores({
		Player = Get "Server.Stores.PlayerStore",
		World = Get "Server.Stores.WorldStore",
	})

	-- Connect players to their store
	TagListener.new("Player", {
		connect = OpenPlayerProfile,
		disconnect = ClosePlayerProfile,
	}):ListenTo(Players)
end

-- Try to open and lock a profile
-- return profile, didOpen
function Data.OpenProfile(storeName: string, profileKey: string)
	-- Get profile store
	local store = Data.Stores[storeName]
	if store == nil then
		warn("Could not find profile store for", storeName)
		warn("Did you forget to open the profile?")
		return nil, false
	end

	-- Try loading the profile
	local profile = store:LoadProfileAsync(profileKey)
	if profile == nil then
		warn("Could not load profile in", storeName, "with", profileKey)
		return nil, false
	end

	-- At this point the profile has been opened and locked.
	return profile, true
end

-- Open various profile stores
function Data.OpenStores(stores)
	for storeName, storeData in pairs (stores) do
		local key = storeData.Key
		local defaults = storeData.Defaults

		-- Make sure this is a valid profile
		assert(key ~= nil, "storeData.Key missing or nil")
		assert(defaults ~= nil, "storeData.Defaults missing or nil")

		-- Add this profile to the stores state
		Data.Stores[storeName] = ProfileService.GetProfileStore(key, defaults)
	end
end

function Data.GetPlayerData(player, key)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	assert(key ~= nil, "Argument 2 missing or nil: key")

	-- make sure profile exists
	local profile = Data.PlayerProfiles[player]
	if profile == nil then
		warn("Player profile missing or nil for", player)
		return nil
	end

	return profile[key]
end

-- sets player data
-- returns the value that was set
function Data.SetPlayerData(player, key, value)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	assert(key ~= nil, "Argument 2 missing or nil: key")
	assert(value ~= nil, "Argument 3 missing or nil: value")

	-- make sure profile exists
	local profile = Data.PlayerProfiles[player]
	if profile == nil then
		warn("Player profile missing or nil for", player)
		return nil
	end

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

function OpenPlayerProfile(player)
	local profile, didOpen = Data.OpenProfile("Player", "Player_"..player.UserId)

	-- Kick player if their profile doesn't load
	if didOpen == false then
		player:Kick(Data.Messages.PlayerDataDidNotLoad)
		return
	end

	-- Bind the profile to this user
	profile:Reconcile()
	profile:AddUserId(player.UserId)
	profile:ListenToRelease(function()
		player:SetAttribute("DataLoaded", false)
		player:Kick()
		Data.PlayerProfiles[player] = nil
	end)

	-- Make sure the player is still in the game
	if player:IsDescendantOf(Players) then
		Data.PlayerProfiles[player] = profile
		player:SetAttribute("DataLoaded", true)
	else
		-- The player left before the profile loaded
		profile:Release()
	end
end

function ClosePlayerProfile(player)
	local profile = Data.PlayerProfiles[player]
	if profile ~= nil then
		profile:Release()
	end
end

return Data
