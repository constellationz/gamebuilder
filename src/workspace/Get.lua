-- Get is a customizable loader used to retrieve instances and modules

local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Get = {
	-- The latest version can be found here:
	-- https://github.com/constellationz/gamebuilder
	Version = "1.1.8",

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

-- extract a classname from string
function MatchClassName(str: string)
	local str1 = str:match("<.*>")
	return if str1 ~= nil then str1:match("%w+") else nil
end

-- add something to dictionary with duplicate checks
function AddToDictionary(dictionary: table, instance: Instance)
	-- warn if multiple entries have the same name
	local name = instance.Name
	if dictionary[name] ~= nil then
		warn("Duplicate in dictionary:", name)
	end

	-- add to dictionary
	dictionary[name] = instance
end

-- try adding objects to dictionary given they are
-- of a certain class
function ConstructDictionary(instances: table, className)
	local dictionary = {}
	
	-- check every instance
	for _, instance in pairs (instances) do
		if className == nil or instance:isA(className) then
			AddToDictionary(dictionary, instance)
		end
	end
	
	return dictionary
end

-- Recursively explores children to find an instance
--[[
	-- Returns nil if no child is found
	-- Returns instance if a singular child is found
	-- Returns a dictionary of children if a wildcard is passed
	
	-- Examples: 
	Search(parent, "Common.Module")
	Search(parent, "Common.*<ModuleScript>")
	Search(parent, "Common.**<ModuleScript>")
]]
function Search(parent: Instance, directories: table)
	-- the current directory to search
	local directory = directories[1]
	
	-- when a globstar wildcard is passed, return
	-- all descendants matching classname
	if directory:sub(1, 2) == "**" then
		return ConstructDictionary(parent:GetDescendants(), 
				MatchClassName(directory))
	end

	-- when an asterisk wildcard is passed, return all children
	if directory:sub(1, 1) == "*" then
		return ConstructDictionary(parent:GetChildren(), 
				MatchClassName(directory))
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

-- Looks for a child and returns it
-- Allows recursive searches with directory markers
function Get.Child(parent: Instance, location: string)
	-- if either parameter is nil, silently return nil
	if parent == nil or location == nil then
		return
	end

	-- search for child
	return Search(parent, string.split(location, Get.Directory))
end

-- Returns a function that searches for a module in directory
-- Optionally include a function that does post processing
function Get.MakeSearcher(parent: Instance, postProcess)
	return function(location)
		-- capture variadic results with table
		local results = Get.Child(parent, location)

		-- if a post-retrieval function is provided, process results
		if postProcess ~= nil then
			-- repopulate results table
			if typeof(results) == "table" then
				for i, result in pairs (results) do
					results[i] = postProcess(result, i)
				end
			else
				-- change single result
				results = postProcess(results, location)
			end
		end

		return results
	end
end

-- Returns a function that explores an "index"
-- Indexes can only contain a certain type of instance
function Get.MakeIndex(parent: Instance, indexType: string)
	-- required to make an index searcher
	assert(parent ~= nil, "Cannot run Get.MakeIndex for nil parent")
	assert(indexType ~= nil, "Cannot run Get.MakeIndex for nil indexType")
	
	-- cache all children
	parent:GetChildren()

	-- search the index
	return function(index)
		-- get the instance
		local instance = if RunService:IsClient() then
			parent:WaitForChild(index) else parent:FindFirstChild(index)

		-- if this instance doesn't exist return nil
		if instance == nil then
			warn("Could not find index for", index, "in", parent)
			return nil
		end

		-- if this instance is of the wrong type, warn the user
		if instance ~= nil and instance:isA(indexType) == false then
			warn("Index", index, "is not a(n)", indexType, "in", parent)
		end

		-- return the instance
		return instance
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
