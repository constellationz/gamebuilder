-- TagReference contains documentation for CollectionService
-- tags in your place.

-- TagReference can automatically generate documentation in markdown
-- and generate a TagList model for the Tag Editor plugin

local TagListener = {}

-- This module may be required from either the terminal or in-game
TagListener.Tags = script ~= nil and script:GetChildren() or {}

function TagListener.GenerateMarkdown(tagName: string)
	local markdown = ""
	-- Generate markdown
	return markdown
end

function TagListener.GenerateTagList()
	local folder = nil
	for tagName, tagData in pairs (TagListener.Tags) do
		-- Add tag to folder
	end
	return folder
end

return TagListener
