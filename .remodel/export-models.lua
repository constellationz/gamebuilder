-- Exports models to the file tree

-- export many things
-- format: exports = { [<path>] = instance, ... }
local function export(exports)
	for directory, instance in pairs (exports) do
		remodel.createDirAll(directory)
		local children = instance:GetChildren()
		for _, model in pairs (children) do
			remodel.writeModelFile(model, directory .. model.Name .. ".rbxmx")
		end
	end
	return exports
end

-- Export from models.rbxlx
local game = remodel.readPlaceFile("src/models.rbxlx")
export({
	["temp/models/gui/"] = game:GetService("StarterGui"),
	["temp/models/assets/"] = game:GetService("Workspace").Assets,
	["temp/models/storage/"] = game:GetService("ServerStorage"),
	["temp/models/lighting/"] = game:GetService("Lighting"),
	["temp/models/map/"] = game:GetService("Workspace").Map,
})
