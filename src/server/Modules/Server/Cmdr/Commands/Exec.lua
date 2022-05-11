return {
	Name = "exec";
	Aliases = {"exec", "e"};
	Description = "Execute code on the server manager.";
	Group = "Owner";
	Args = {
		{
			Type = "string";
			Name = "code";
			Description = "The code to execute.";
		},
	};
}