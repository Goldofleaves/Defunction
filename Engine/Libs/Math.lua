Util.Math = {}
local math_lib = Util.Math

--- The value of τ.
math.tau = math.pi * 2

math_lib.Div = function(num, div)
    return math.floor(num / div)
end

math_lib.RandomElement = function(tab)
    local f = {}
    for k, v in pairs(tab) do
        table.insert(f, k)
    end
    local k = f[math.random(1, #f)]
    return { v = tab[k], k = k }
end

math_lib.Chance = function(chance)
    return math.random() <= chance
end

math_lib.Clamp = function(min, max, value)
    if max < min then
        local a = min
        min = max
        max = a
    end
    return math.min(max, math.max(min, value))
end

--- Lerps a to b, so when v is 1 it returns b, when v is 0 it returns a, and when v is 0.5 it returns the midpoint.
math_lib.Lerp = function(a, b, v)
    return a + (v * (b - a))
end


-- Same as lerp but accounting with deltatime,
--- r is the fraction remaining after 1 second
math_lib.LerpDt = function(a, b, r)
    local v = 1 - (r ^ DELTATIME)
    return math_lib.Lerp(a, b, v)
end