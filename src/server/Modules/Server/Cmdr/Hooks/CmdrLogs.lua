-- Hook to log commands after they were run

local Get = require(workspace.Get)
local G = Get "Common.Globals"

function Log(context)
	-- Only log in live game
	if not G.IsStudio() then
		print(string.format("%s ran %s and got %s", 
			context.Executor.Name, 
			context.RawText,
			context.Response
		))
	end
end

return function(registry)
	registry:RegisterHook("AfterRun", Log)
end