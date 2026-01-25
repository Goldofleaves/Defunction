Util.Math = {}

--- The value of τ.
math.tau = math.pi * 2

--- The value of e, better known as eulers number/the expodential constant.
math.e = math.exp(1)

--- Integer division. What more do I have to say?
--- @param num number
--- @param div number
--- @return integer Result
Util.Math.div = function(num, div)
    return math.floor(num / div)
    -- // is fucking broken, thanks love2d
end

--- Returns a random element and its corresponding key from tab.
--- @param tab table
--- @return {v:any,k:string|integer} Element
Util.Math.randomElement = function(tab)
    local f = {}
    for k, v in pairs(tab) do
        table.insert(f, k)
    end
    local k = f[math.random(1, #f)]
    return { v = tab[k], k = k }
end

--- Has a probably of the arguement to return true, else return false
--- @param chance number
--- @return boolean Result
Util.Math.chance = function(chance)
    return math.random() <= chance
end


--- Clamps a value between 2 numbers.
Util.Math.clamp = function(min, max, value)
    if max < min then
        local a = min
        min = max
        max = a
    end
    return math.min(max, math.max(min, value))
end

--- Linearly interpolates a to b, so when v is 1 it returns b, when v is 0 it returns a, and when v is 0.5 it returns the midpoint.
--- @param a number The starting value.
--- @param b number The ending value.
--- @param v number The `"speed"`, or fraction of the distance traversed in 1 frame.
Util.Math.lerp = function(a, b, v)
    return a + (v * (b - a))
end


--- Same as lerp but accounting with deltatime.\
--- More info: https://www.youtube.com/watch?v=LSNQuFEDOyQ
--- @param a number The starting value.
--- @param b number The ending value.
--- @param r number The `"speed"`, or fraction of the distance left to traverse in 1 second.
Util.Math.lerpDt = function(a, b, r)
    local v = 1 - (r ^ DELTATIME)
    return Util.Math.lerp(a, b, v)
end
math.sign = function (n)
    if n ~= 0 then
        return n/math.abs(n)
    end
    return 0
end
function Util.Math.percisionCheck(a, b, p)
    local delta = math.abs(a - b)
    return delta <= p
end