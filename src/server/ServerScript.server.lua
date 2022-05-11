-- Server entry point
local Get = require(workspace.Get)
local Manager = Get "Common.Manager"

-- Show that the server is running
Get.Greet()

-- Clone common systems to client
Get.ReplicateCommonModules()

-- Connect server systems
local manager = Manager.new()
manager:AddSystems{
	"Server.**<ModuleScript>",
	"Common.**<ModuleScript>",
}

-- Start the game
manager:ConnectServer()