-- Client entry point
local Get = require(workspace.Get)
local Manager = Get "Common.Manager"

-- Connect client systems
local manager = Manager.new()
manager:AddSystems{
	"Client.**<ModuleScript>"
	"Common.**<ModuleScript>",
}

-- Start the game
manager:ConnectClient()