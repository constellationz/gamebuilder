-- Hook dictating command permissions

local Get = require(workspace.Get)
local G = Get "Common.Globals"
local RunService = Get.Service "RunService"

-- Can this owner command be run?
function IsOwner(context)
	return G.IsOwner(context.Executor)
end

-- Can this admin command be run?
function IsAdmin(context)
	return G.IsAdmin(context.Executor)
end

-- Can this debug command be run?
function CanDebug(context)
	return IsOwner()
end

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		-- Owner commands
		if context.Group == "Owner" and not IsOwner(context) then
			return "Only the owner can run this command"
		end

		-- Admin commands
		if context.Group == "DefaultAdmin" and not IsAdmin(context) then
			return "You do not have permission to run this command"
		end

		-- Debug commands
		if context.Group == "DefaultDebug" and not CanDebug(context) then
			return "Debug commands cannot currently be run"
		end
	end)
end