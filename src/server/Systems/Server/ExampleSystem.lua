-- ExampleSystem
-- A singleton system object
-- Remember, systems should have no state (as much as possible)!

local System = {}

local Get = require(workspace.Get)

function System.Connect()
	script:Remove()
end

return System