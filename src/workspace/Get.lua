-- Get is a customizable loader used to retrieve instances and modules

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Get = {
	-- The latest version can be found here:
	-- https://github.com/namatchi/gamebuilder/blob/main/src/workspace/Get.lua
	Version = "1.1.5",

	-- Used to indicate members of a directory in Get searches
	Directory = ".",
}

-- Print a greeter that shows the Get version
function Get.Greet()
	print("Hello world!", "Get version:", Get.Version)
end

-- Preload important folders
function Get.Preload(onPreload)
	ContentProvider:PreloadAsync({
		Modules,
	}, onPreload)
end

-- Recursively explores children to find an instance
function Search(parent, directories)
	local child = parent:FindFirstChild(directories[1])
	if #directories == 1 then
		return child
	elseif child ~= nil then
		table.remove(directories, 1)
		return Search(child, directories)
	end
end

-- Proxy function for game:GetService
function Get.Service(...)
	return game:GetService(...)
end

-- Get the LocalPlayer
function Get.LocalPlayer()
	return Get.Service("Players").LocalPlayer
end

-- Look for an instance and return it.
-- Allows recursive searches with directory markers.
function Get.Instance(parent, location)
	local directories = string.split(location, Get.Directory)
	return Search(parent, directories)
end

-- Returns a function that searches for a module in directory
-- Optionally include a function that does post processing
function Get.MakeSearcher(parent, postProcess)
	return function(name)
		-- get result with GetInstance
		local result = Get.Instance(parent, name)

		-- if a post-retrieval function is provided, pass results
		if postProcess ~= nil then
			return postProcess(result, name)
		else
			return result
		end
	end
end

-- Makes sure a result exists.
function AssertExistence(result, name)
	if result == nil then
		error(string.format("Could not find %s", name), 0)
	else
		return result
	end
end

-- Tries to load a module.
function LoadModule(module, name)
	AssertExistence(module, name)
	assert(module:isA("ModuleScript"), string.format(
		"Tried to load %s which is a %s", name, module.ClassName))

	return require(module)
end

-- Get.Module tries loading a module in the Modules directory
Get.Module = Get.MakeSearcher(Modules, LoadModule)

-- When Get(...) is called, it is passed here.
-- By default, evaluates to Get.LoadedModule
function RawGet(_, moduleName)
	return Get.Module(moduleName)
end
setmetatable(Get, {__call = RawGet})

return Get
