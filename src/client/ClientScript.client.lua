-- Client entry point
local Get = require(workspace.Get)
local Manager = Get "Common.Manager"

-- Connect client systems
local manager = SystemManager.new()
manager:AddSystems{
	"Client.**<ModuleScript>"
	"Common.**<ModuleScript>",
}

-- Start the game
manager:ConnectClient()