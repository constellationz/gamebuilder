-- Characters contains functions for handling characters

local Get = require(workspace.Get)
local Players = Get.Service "Players"
local RunService = Get.Service "RunService"

local Character = {}

-- execute callback on characters
function Character.OnAdded(callback)
	for _, player in pairs (Players:GetPlayers()) do
		-- execute the callback if the character exists
		if player.Character ~= nil then
			callback(player.Character)
		end
		
		-- when the character is added, call the callback
		player.CharacterAdded:connect(function(character)
			callback(character)
		end)
	end
end

-- is this part of a hat?
function Character.IsHat(part)
	return part.Parent ~= nil
		and part.Parent:isA'Accessory' 
		and part.Name ~= "Hitbox" 
		and true or false
end

-- get character from part
function Character.GetFromPart(part)
	-- if there's no part, there's no character
	if part == nil then
		return nil
	end
	
	-- try getting character from part
	local humanoidRootPart = Character.GetHumanoidRootPart(part.Parent)
	return humanoidRootPart ~= nil and humanoidRootPart.Parent
		or Character.IsHat(part) and part.Parent.Parent
		or nil
end

-- get humanoid from character
function Character.GetHumanoid(character)
	return character ~= nil and character:FindFirstChild("Humanoid") or nil
end

-- get humanoidrootpart from character
function Character.GetHumanoidRootPart(character)
	return character ~= nil 
		and character:FindFirstChild("HumanoidRootPart") or nil
end

-- get character forcefield
function Character.GetForceField(character)
	return character ~= nil 
		and character:FindFirstChild("ForceField") or nil
end

-- get player from character
function Character.GetPlayer(character)
	return character ~= nil 
		and Players:GetPlayerFromCharacter(character) or nil
end

return Character
