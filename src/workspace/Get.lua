-- Get is a customizable loader used to retrieve instances and modules

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Get = {
	-- The latest version can be found here:
	-- https://github.com/namatchi/gamebuilder/blob/main/src/workspace/Get.lua
	Version = "1.1.6",

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
-- Returns nil if no child is found
-- Returns instance if a singular child is found
-- Returns a dictionary of children if a wildcard is passed
function Search(parent, directories)
	-- the current directory to search
	local directory = directories[1]

	-- when a wildcard is passed, return all children
	if directory == "*" then
		-- return in the format {[Instance.Name] = Instance, ...}
		local dictionary = {}
		for _, child in pairs (parent:GetChildren()) do
			dictionary[child.Name] = child
		end
		return dictionary
	end

	-- if only one directory is left, try returning the child
	-- with the matching name
	local child = parent:FindFirstChild(directory)
	if #directories == 1 then
		return child
	end
	
	-- search the next directory if applicable
	if child ~= nil then
		table.remove(directories, 1)
		return Search(child, directories)
	end
	
	-- no child found, return nil
	return nil
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

-- Gets the name of some instance given a directory
function Get.InstanceName(location)
	local directories = string.split(location, Get.Directory)
	return directories[#directories]
end

-- Returns a function that searches for a module in directory
-- Optionally include a function that does post processing
function Get.MakeSearcher(parent, postProcess)
	return function(directory)
		-- capture variadic results with table
		local results = Get.Instance(parent, directory)

		-- if a post-retrieval function is provided, process results
		if postProcess ~= nil then
			-- repopulate results table
			if typeof(results) == "table" then
				for i, result in pairs (results) do
					results[i] = postProcess(result, i)
				end
			else
				-- change single result
				results = postProcess(results, directory)
			end
		end

		return results
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
