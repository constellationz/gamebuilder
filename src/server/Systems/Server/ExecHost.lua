-- System for the Exec command

local ExecHost = {}

local Get = require(workspace.Get)
local G = Get "Common.Globals"
local Execute = Get.Remote "Execute"
local Players = Get.Service "Players"

-- Environment to use for ExecHost commands
local defaultEnv = {
	-- server state
	Get = Get,
	Server = nil,
	Players = Players,
	
	-- game state
	game = game,
	workspace = workspace,

	-- libs
	task = task,
	math = math,
	table = table,
	bit32 = bit32,
	pcall = pcall,
	pairs = pairs,
	ipairs = ipairs,
	string = string,

	-- output
	print = print,
	error = error,
	warn = warn,
}

-- Can this player execute arbitrary code?
function CanExecute(player: Instance)
	return G.IsOwner(player)
end

-- execute code
function Exec(executor: Instance, code: string)
	assert(executor ~= nil, "Argument 1 missing or nil: executor")
	assert(code ~= nil, "Argument 2 missing or nil: code")
	assert(CanExecute(executor), "Player does not have permission to run Exec")

	-- run code
	local env = table.clone(defaultEnv)
	local bytecode = loadstring(code)
	setfenv(bytecode, env)
	task.spawn(bytecode)

	return "> "..code
end

function ExecHost.Connect()
	-- Connect Exec
	Execute.OnInvoke = Exec
	
	-- Set server in environment state
	defaultEnv.Server = ExecHost.manager
end

return ExecHost