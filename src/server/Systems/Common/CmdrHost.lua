-- Host for Cmdr

local Get = require(workspace.Get)
local G = Get "Common.Globals"
local RunService = Get.Service "RunService"

local CmdrHost = {}

local function CmdrServer()
	local Cmdr = Get.Lib "Cmdr"
	local CmdrHooks = Get.Module "Server.Cmdr.Hooks"
	local CmdrTypes = Get.Module "Server.Cmdr.Types"
	local CmdrCommands = Get.Module "Server.Cmdr.Commands"
	
	-- Register commands and hooks
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterHooksIn(CmdrHooks)
	Cmdr:RegisterTypesIn(CmdrTypes)
	Cmdr:RegisterCommandsIn(CmdrCommands)
end

local function CmdrClient()
	local ReplicatedStorage = Get.Service "ReplicatedStorage"
	local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

	-- Studio has different activation behavior
	if G.IsStudio() then
		Cmdr:SetActivationKeys({ Enum.KeyCode.BackSlash })
	else
		Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
		Cmdr:SetMashToEnable(true)
	end
end

function CmdrHost.Connect()
	-- Bind server
	if RunService:IsServer() then
		CmdrServer()
	end

	-- Bind client
	if RunService:IsClient() then
		CmdrClient()
	end
end

return CmdrHost