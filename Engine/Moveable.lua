---@class Moveable: Object

Moveable = Object:extend()

function Moveable:new(args)
    self.strength = args.strength or 1
    self.id = G.currentID
    self.nid = args.nid
    G.currentID = G.currentID + 1
    args = args or {}
    self.objectType = 'MOVEABLE'
    self.T = {
        x = 0,
        y = 0,
        w = 0,
        h = 0,
    }
    self.TLast = {x = 0, y = 0}
    self.TMod = {
        x = { base = args.x or 0 },
        y = { base = args.y or 0 },
        w = { base = args.w or 0 },
        h = { base = args.h or 0 }
    }
    self.updateFunc = args.updateFunc or function(s, dt) return end
    self.drawFunc = args.drawFunc or function(s) return end
    self.V = {
        x = { base = args.vx or 0 },
        y = { base = args.vy or 0 },
    }
    self.parent = nil
    self.children = {}
    self.properties = args.properties or {}
    self.extra = args.extra or {}
    table.insert(G.I.MOVEABLES, self)
    self.tempStrength = self.strength
    self.drawOrder = args.drawOrder or 0
    return self
end

-- Functions ported from Badge of Severance

---Sets the parent of this object. Its return value will be a numeracal reference ID
---@param obj Moveable
---@return integer
function Moveable:setParent (obj)
    table.insert(obj.children,self.id)
    self.parent = obj.id
    return self.parent
end

---Add a children to this object.
---@param obj Moveable
function Moveable:addChildren (obj) obj:setParent(self) end

-- Aligns objects based on their offsets

function Moveable:getParentOffset()
    if not self.parent then return {x=0,y=0} end
    local parent = getObjectById(self.parent)
    if not parent then return {x = 0, y = 0} end
    return {x = parent.T.x, y = parent.T.y}
end

function Moveable:getTotalOffset(component)
    local ret = { x = 0, y = 0, w = 0, h = 0 }
    for k, v in pairs(self.TMod) do
        if not component then
            for kk, vv in pairs(v) do
                ret[k] = ret[k] + vv
            end
        else
            ret[k] = ret[k] + v[component]
        end
    end
    return ret
end

function Moveable:getTotalVelocity(component)
    local ret = { x = 0, y = 0 }
    for k, v in pairs(self.V) do
        if not component then
            for kk, vv in pairs(v) do
                ret[k] = ret[k] + vv
            end
        else
            if self.V[k][component] then
                ret[k] = ret[k] + v[component]
            end
        end
    end
    return ret
end

function Moveable:update(dt)
    self.TMod.x.parent = self:getParentOffset().x
    self.TMod.y.parent = self:getParentOffset().y
    self.TLast.x = self.T.x
    self.TLast.y = self.T.y
    self.updateFunc(self, dt)
    for k, v in pairs(self.TMod) do
        for kk, vv in pairs(v) do
            if k == "x" or k == "y" then
                v[kk] = vv + self:getTotalVelocity(kk)[k] * dt
            end
        end
    end
    for k, v in pairs(self.T) do
        if type(v) == "number" then
            self.T[k] = math.floor(self:getTotalOffset()[k])
        end
    end
    self.updateFunc(self, dt)
    self.tempStrength = self.strength
end

function Moveable:draw()
    self.drawFunc(self)
end

-- Taken from Sheepolution's collision stuff because im so fucking lazyyy

function Moveable:wasVerticallyAligned(e)
    return self.TLast.y < e.TLast.y + e.T.h and self.TLast.y + self.T.h > e.TLast.y
end

function Moveable:wasHorizontallyAligned(e)
    return self.TLast.x < e.TLast.x + e.T.w and self.TLast.x + self.T.w > e.TLast.x
end
function Moveable:checkCollision(e)
    return self.T.x + self.T.w > e.T.x
        and self.T.x < e.T.x + e.T.w
        and self.T.y + self.T.h > e.T.y
        and self.T.y < e.T.y + e.T.h
end
function Moveable:resolveCollision(e)
    if self.properties.noCollision or e.properties.noCollision then
        return false
    end
    if self.tempStrength > e.tempStrength then
        return e:resolveCollision(self)
    end
    -- self is strictly a less strong moveable than e
    if self:checkCollision(e) then
        self.tempStrength = e.tempStrength - 1
        if not self.properties.collisionCheck and not e.properties.collisionCheck then
            if self:wasVerticallyAligned(e) then
                if self.T.x + self.T.w / 2 < e.T.x + e.T.w / 2 then
                    local pushback = self.T.x + self.T.w - e.T.x
                    self.TMod.x.base = self.TMod.x.base - pushback
                    self.T.x = self.T.x - pushback
                else
                    local pushback = e.T.x + e.T.w - self.T.x
                    self.TMod.x.base = self.TMod.x.base + pushback
                    self.T.x = self.T.x + pushback
                end
            elseif self:wasHorizontallyAligned(e) then
                if self.T.y + self.T.h / 2 < e.T.y + e.T.h / 2 then
                    local pushback = self.T.y + self.T.h - e.T.y
                    self.TMod.y.base = self.TMod.y.base - pushback
                    self.T.y = self.T.y - pushback
                else
                    local pushback = e.T.y + e.T.h - self.T.y
                    self.TMod.y.base = self.TMod.y.base + pushback
                    self.T.y = self.T.y + pushback
                end
            end
            return true
        else
            if self.properties.collisionCheck then
                table.insert(self.extra.ticked, e.id)
            end
            if e.properties.collisionCheck then
                table.insert(e.extra.ticked, self.id)
            end
            return true
        end
    end
    return false
end
---@class Wall: Moveable

Wall = Moveable:extend()
function Wall:new(args)
    args = args or {}
    args.properties = args.properties or {}
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 80
    args.h = args.h or 20
    args.strength = 1000
    args.drawFunc = function (s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF0000"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor{r, g, b, a}
        end
    end
    return Moveable.new(self, args)
end

RicoChet = Moveable:extend()
function RicoChet:new(args)
    args = args or {}
    args.properties = args.properties or {}
    args.properties.RicoChet = true
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 20
    args.h = args.h or 80
    args.strength = 1000
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#9900FF"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    return Moveable.new(self, args)
end
require "Engine.Player"
require "Engine.Boomerang"

Box = Moveable:extend()
function Box:new(args)
    args = args or {}
    args.strength = 200
    args.properties = args.properties or {}
    args.x = args.x or 160
    args.y = args.y or 140
    args.w = args.w or 20
    args.h = args.h or 20
    args.extra = {
        onGround = true
    }
    args.updateFunc = function(self, dt)
        self.TMod.x.gravity = self.TMod.x.gravity or 0
        self.V.x.gravity = self.V.x.gravity or 0
        self.TMod.y.gravity = self.TMod.y.gravity or 0
        self.V.y.gravity = self.V.y.gravity or 0
        self.V.y.gravity = self.V.y.gravity + Macros.gravity
        self.extra.onGround = self.extra.downCheck.extra.ticked
        if next(self.extra.onGround) and not collisionContainsProperty(self.extra.onGround, "noCollision") then
            self.V.y.gravity = 0
        end
        self.strength = 200
        for k, v in pairs(G.I.MOVEABLES) do
            if v.properties.Player then
                if v.T.y + v.T.h <= self.T.y then
                    self.strength = 1000
                end
            end
        end
    end
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#83591B"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    self.extra.downCheck = Moveable {
        properties = {
            collisionCheck = true
        },
        w = args.w,
        h = 1
    }
    self.extra.downCheck.TMod.x.offset = 0
    self.extra.downCheck.TMod.y.offset = args.h
    self.extra.downCheck:setParent(self)
    return self
end
OneWayPlatform = Moveable:extend()
function OneWayPlatform:new(args)
    args.strength = 1000
    args = args or {}
    args.properties = args.properties or {}
    args.x = args.x or 160
    args.y = args.y or 120
    args.w = args.w or 20
    args.h = args.h or 20
    args.extra = {
        onGround = true,
        facing = args.facing or "up"
    }
    args.updateFunc = function(self, dt)
        self.properties.noCollision = true
        for k, v in pairs(G.I.MOVEABLES) do
            if v.properties.Player then
                if v.T.y + v.T.h <= self.T.y and self.extra.facing == "up" then
                    self.properties.noCollision = false
                end
                if v.T.y >= self.T.h + self.T.y and self.extra.facing == "down" then
                    self.properties.noCollision = false
                end
                if v.T.x + v.T.w <= self.T.x and self.extra.facing == "left" then
                    self.properties.noCollision = false
                end
                if v.T.x >= self.T.w + self.T.x and self.extra.facing == "right" then
                    self.properties.noCollision = false
                end
            end
        end
    end
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#ADA9C5")[1], Util.Other.Hex("#ADA9C5")[2], Util.Other.Hex("#ADA9C5")[3], 1/3)
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor(Util.Other.Hex("#0EDB0E"))
            if self.extra.facing == "up" then
                love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, 2)
            elseif self.extra.facing == "down" then
                love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + s.T.h - 2 + G:getTotalOffset().y, s.T.w, 2)
            elseif self.extra.facing == "left" then
                love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, 2, s.T.h)
            elseif self.extra.facing == "right" then
                love.graphics.rectangle("fill", s.T.x + s.T.w - 2 + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, 2,
                s.T.h)
            end
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    return self
end

-- UTILITY FUNCTIONS
function collisionContainsId(ticked, id)
    for k, v in ipairs(ticked) do
        if v == id then
            return true
        end
    end
    return false
end
function collisionContainsProperty(ticked, P)
    for k, v in ipairs(ticked) do
        local obj = getObjectById(v)
        if obj.properties[P] then
            return obj.properties[P]
        end
    end
    return false
end
function CollisionContainsextra(ticked, P)
    for k, v in ipairs(ticked) do
        local obj = getObjectById(v)
        if obj.extra[P] then
            return obj.extra[P]
        end
    end
    return false
end
function GetAllCollisionProperty(ticked, P)
    local PTab = {}
    for k, v in ipairs(ticked) do
        local obj = getObjectById(v)
        if obj.properties[P] then
            table.insert(PTab, obj.properties[P])
        end
    end
    return PTab
end

function getAllCollisionPropertyIds(ticked, P)
    local PTab = {}
    for k, v in ipairs(ticked) do
        local obj = getObjectById(v)
        if obj.properties[P] then
            table.insert(PTab, v)
        end
    end
    return PTab
end
function getAllCollisionextra(ticked, P)
    local PTab = {}
    for k, v in ipairs(ticked) do
        local obj = getObjectById(v)
        if obj.extra[P] then
            table.insert(PTab, obj.extra[P])
        end
    end
    return PTab
end
function Moveable:remove()
    for k, v in ipairs(G.I.MOVEABLES) do
        if v.id == self.id then
            local j = self.id
            table.remove(G.I.MOVEABLES, k)
            for k, v in ipairs(G.I.MOVEABLES) do
                if v.parent == j then
                    v.parent = nil
                end
            end
            G.oldState = G.state
            G.state = "DestroyedObj"
        end
    end
    self = nil
end
function getPosById(Id)
    for k, v in ipairs(G.I.MOVEABLES) do
        if v.id == Id then
            return k
        end
    end
end
