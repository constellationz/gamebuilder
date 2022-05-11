-- Execute arbitrary code on the server

local Get = require(workspace.Get)
local Execute = Get.Remote "Execute"

-- Note: The ExecHost system handles permissions
return function (context, code)
	local result = Execute:Invoke(context.Executor, code)
	return result
end