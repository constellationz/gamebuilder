local exampleType = {
	Transform = function(text)
		return tonumber(text)
	end;

	Validate = function(value)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end;

	Parse = function(value)
		return value
	end
}

return function(registry)
	registry:RegisterType("exampleType", exampleType)
end
