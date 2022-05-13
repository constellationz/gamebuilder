-- Adds Character tag to the character

local CollectionService = game:GetService("CollectionService")

-- Use task.wait() to avoid CollectionService bug
task.wait()
CollectionService:AddTag(script.Parent, "Character")
