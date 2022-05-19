-- Compiles models from models.rbxlx to the instance tree.
local game = remodel.readPlaceFile("src/models.rbxlx")

-- get source folders
local exports = {
	["temp/models/gui/"] = game:GetService("StarterGui"),
	["temp/models/assets/"] = game:GetService("Workspace").Assets,
	["temp/models/storage/"] = game:GetService("ServerStorage"),
	["temp/models/lighting/"] = game:GetService("Lighting"),
	["temp/models/map/"] = game:GetService("Workspace").Map,
}

for directory, instance in pairs (exports) do
	-- create directory for these files
	remodel.createDirAll(directory)

	-- export all children into this directory
	local children = instance:GetChildren()
	for _, model in pairs (children) do
		remodel.writeModelFile(model, directory .. model.Name .. ".rbxmx")
	end
end