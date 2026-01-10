Util.Other = {}
local other_lib = Util.Other

other_lib.copy_table = function(t,filter)
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
			ret[k] = other_lib.copy_table(v,filter)
		end
	end
	return ret
end

other_lib.load_localization = function()
	G.Localization = assert(load(love.filesystem.read("Localization/english.lua")))()
	local language = G.Language or "english"
	local temp = assert(load(love.filesystem.read("Localization/"..language..".lua")))()
	for k,v in pairs(G.Localization) do
		G.Localization[k] = temp[k] or ('Error when loading localization with key'..k.."!")
	end
	-- love.window.setTitle(G.Localization.title)
end

function other_lib.HEX(hex)
	if string.sub(hex, 1, 1) == "#" then
		hex = string.sub(hex, 2, string.len(hex))
	end
	if #hex <= 6 then hex = hex.."FF" end
	local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
	local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
	return color
end

function other_lib.exract_value_from_hierarch(tab, hierarch)
	hierarch = other_lib.copy_table(hierarch)
	if next(hierarch) then
		local k = hierarch[#hierarch]
		table.remove(hierarch, #hierarch)
		if tab[k] then
			return other_lib.exract_value_from_hierarch(tab[k], hierarch)
		end
		return
	end
	return tab
end