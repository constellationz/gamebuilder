-- Sample class that built with Get
-- local Get = require(workspace.Get)
-- local Maid = Get "Maid"

local SampleClass = {}
SampleClass.ClassName = "SampleClass"
SampleClass.__index = SampleClass

function SampleClass.new()
	local self = setmetatable({}, SampleClass)
	
	-- self._maid = Maid.new()
	
	return self
end

return SampleClass