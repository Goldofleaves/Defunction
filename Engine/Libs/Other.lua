Util.Other = {}

--- Creates a new table with the same elements to avoid jank caused by passing by reference
--- @param t table|any The original Table
--- @param filter table|nil If this is a table, then this function only copy entries inside filter as well.
--- @return table|any
Util.Other.CopyTable = function(t, filter)
	if type(t) ~= "table" then
		return t
	end
	local ret = {}
	for k,v in pairs(t) do
		if type(v) ~= "table" then
			if not filter then
			ret[k] = v
			else
				for _,vv in ipairs(filter) do
					if k == vv then
						ret[k] = v
					end
				end
			end
		else
			ret[k] = Util.Other.CopyTable(v, filter)
		end
	end
	return ret
end

--- Loads the localization entries to G.Localization.
Util.Other.LoadLocalization = function()
	G.Localization = assert(load(love.filesystem.read("Localization/english.lua")))()
	local language = G.Language or "english"
	local temp = assert(load(love.filesystem.read("Localization/"..language..".lua")))()
	for k,v in pairs(G.Localization) do
		G.Localization[k] = temp[k] or ('Error when loading localization with key'..k.."!")
	end
	-- love.window.setTitle(G.Localization.title)
end

--- Returns the color value for the passed in hex code.
--- @param hex string The hex code, `"#"` optionally included.
--- @return table Color
function Util.Other.Hex(hex)
	if string.sub(hex, 1, 1) == "#" then
		hex = string.sub(hex, 2, string.len(hex))
	end
	if #hex <= 6 then hex = hex.."FF" end
	local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
	local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
	return color
end

--- Return the stored value with the key list of hierarch in table.\
--- For example, F({a = {[4] = 7}}, {a, 4}) would return 7.
---@param tab table
---@param hierarch table
---@return any
function Util.Other.ExractValueFromHierarch(tab, hierarch)
	hierarch = Util.Other.CopyTable(hierarch)
	if next(hierarch) then
		local k = hierarch[#hierarch]
		table.remove(hierarch, #hierarch)
		if tab[k] then
			return Util.Other.ExractValueFromHierarch(tab[k], hierarch)
		end
		return
	end
	return tab
end