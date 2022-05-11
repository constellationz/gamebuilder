-- Client entry point

local Get = require(workspace.Get)
local Manager = Get "Common.Manager"

-- Show that the server is running
Get.Greet()

-- Connect client systems
local manager = Manager.new()
manager:AddSystems{
	"Client.**<ModuleScript>",
	"Common.**<ModuleScript>",
}

-- Start the game
manager:ConnectClient()