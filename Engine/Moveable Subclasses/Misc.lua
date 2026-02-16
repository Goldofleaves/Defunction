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
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.hex("#FF0000"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
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
            love.graphics.setColor(Util.Other.hex("#9900FF"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    return Moveable.new(self, args)
end

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
        self.V.y.gravity = math.min(self.V.y.gravity + Macros.gravity / 0.02 * DELTATIME, Macros.terminalVelocity)
        self.extra.onGround = self.extra.downCheck.extra.ticked ---@type table
        if next(type(self.extra.onGround) == "boolean" and {} or self.extra.onGround) and not collisionContainsProperty(self.extra.onGround, "noCollision") then
            self.V.y.gravity = 0
        end
        self.strength = 200
        for k, v in pairs(G.I.MOVEABLES) do
            if v.properties.player then
                if v.T.y + v.T.h <= self.T.y then
                    self.strength = 1000
                end
            end
        end
    end
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.hex("#83591B"))
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
            if v.properties.player then
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
            love.graphics.setColor(Util.Other.hex("#ADA9C5")[1], Util.Other.hex("#ADA9C5")[2],
                Util.Other.hex("#ADA9C5")[3], 1 / 3)
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor(Util.Other.hex("#0EDB0E"))
            if self.extra.facing == "up" then
                love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, 2)
            elseif self.extra.facing == "down" then
                love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + s.T.h - 2 + G:getTotalOffset().y,
                    s.T.w, 2)
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