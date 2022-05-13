-- G contains global constants that can be used across modules

local RunService = game:GetService("RunService")

local G = {}

-- Should a live game be simulated?
G.SimulateLive = false

-- Dictionary of UserIds
-- Can run Owner commands, Admin commands and Debug commands
G.Owners = {
	game.CreatorId,
}

-- Dictionary of UserIds
-- Can run DefaultAdmin commands
G.Admins = {

}

-- Is the game in debug mode?
function G.IsStudio()
	return RunService:IsStudio() and not G.SimulateLive
end

-- Is this player an owner?
function G.IsOwner(player: Instance)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	return G.IsStudio() or table.find(G.Owners, player.UserId) ~= nil
end

-- Is this player an admin?
function G.IsAdmin(player: Instance)
	assert(player ~= nil, "Argument 1 missing or nil: player")
	return G.IsStudio() or G.IsOwner(player) or table.find(G.Admins, player.UserId) ~= nil
end

return G