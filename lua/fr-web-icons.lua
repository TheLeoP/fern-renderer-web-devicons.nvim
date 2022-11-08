local M = {}

M.palette = function()
	local palette = {}
	local icons = vim.tbl_extend("force", {}, require("nvim-web-devicons").get_icons())

	-- delete default icon since it doesn't have a string as key
	icons[1] = nil
	for _, v in pairs(icons) do
		palette["DevIcon" .. v.name] = { v.icon }
	end

	palette["GlyphPaletteDirectory"] = { "", "", "", "", "", "" }

	return palette
end

return M
