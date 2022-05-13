return {
	Key = "PlayerData",
	
	-- Default values to use
	Defaults = {
		Value = 500,
		MySetting = false,
	},
	
	-- Values that the client can set (Only applies to this store)
	ClientKeys = {
		MySetting = "boolean",
	},
}