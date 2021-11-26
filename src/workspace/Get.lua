-- Get is a customizable loader used to retrieve instances and modules
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Props = ReplicatedStorage:WaitForChild("Props")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Get = {
	Version = "1.1.5",
	
	-- Used to indicate members of a directory in Get searches
	Directory = ".",
}

-- Recursively explores children to find an instance
function Search(parent, locations)
	local child = parent:FindFirstChild(locations[1])
	if #locations == 1 then
		return child
	elseif child ~= nil then
		table.remove(locations, 1)
		return Search(child, locations)
	end
end

-- Look for an instance and return it.
-- Allows recursive searches with directory slashes.
function GetInstance(parent, location)
	local locations = string.split(location, Get.Directory)
	return Search(parent, locations)
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

-- Print a greeter that shows the Get version
function Get.Greet()
	print("Hello world!", "Get version:", Get.GetVersion)
end

-- Preload important folders
function Get.Preload(onPreload)
	ContentProvider:PreloadAsync({
		Modules,
		Remotes,
		Props,
	}, onPreload)
end

-- Get.Module looks into libraries and Modules
function Get.Module(name)
	-- looks for an Instance in Modules
	return GetInstance(Modules, name)
end

-- Loads from Get.Module
function Get.LoadedModule(name)
	local module = Get.Module(name)
	return LoadModule(module, name)
end

-- Add a Get call bound to GetInstance.
-- Optionally include a post processing function.
function ListenFor(call, parent, postProcess)
	Get[call] = function(name)
		-- get result with GetInstance
		local result = GetInstance(parent, name)

		-- if a post-retrieval function is provided, pass results
		if postProcess ~= nil then
			return postProcess(result, name)
		else
			return result
		end
	end
end

-- Look into folders different calls.
ListenFor("Prop", Props, AssertExistence) -- Get.Prop
ListenFor("Remote", Remotes, AssertExistence) -- Get.Remote

-- When Get(...) is called, it is passed here.
-- By default, evaluates to Get.LoadedModule
function RawGet(_, moduleName)
	return Get.LoadedModule(moduleName)
end
setmetatable(Get, {__call = RawGet})

return Get