---@class BRang: Moveable

local function CreateAfterImage(x, y, f)
    Sprite({
        atlasKey = "Boomerang",
        drawOrder = 50,
        AtlasY = 2,
        AtlasX = f,
        x = x, y = y,
        transparency = 1/2,
        updateFunc = function(s, dt)
            s.transparency = s.transparency - dt
            if s.transparency <= 0 then
                s:remove()
            end
        end
    })
end

BRang = Moveable:extend()
function BRang:new(args)
    local collidedFunc = function(a, dir)
        return next(a.extra.ticked or {}) and not collisionContainsId(a.extra.ticked, self.Id) and
            not collisionContainsProperty(a.extra.ticked, "noCollision") and
            not collisionContainsProperty(a.extra.ticked, "CollisionCheck") and
            (CollisionContainsextra(a.extra.ticked, "Facing") and collisionContainsId(getAllCollisionextra(a.extra.ticked, "Facing"), dir) or true)
    end
    args = args or {}
    args.drawOrder = 35
    args.properties = args.properties or {}
    args.properties.noCollision = true
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 20
    args.h = args.h or 20
    args.strength = 0
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF00B3"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    args.updateFunc = function(self, dt)
        self.extra.velD = self.extra.velD or 0
        self.extra.TG = self.extra.TG or 0
        self.extra.velD = self.extra.velD + 1 / 12
        self.extra.clockInit = self.extra.clockInit + dt
        self.extra.lerpD = self.extra.lerpD or 1
        if self.extra.TG <= 0 then
            for k, v in pairs(self.extra.checks) do
                local opposite = {
                    Left = "Right",
                    Right = "Left",
                    Down = "Up",
                    Up = "Down"
                }
                local funcs = {
                    Left = function (a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.extra.checks.Left.extra.ticked,
                        "RicoChet")[1])
                        if a.V.x.base < 0 and bump and bump.T.x + bump.T.w > a.T.x and Util.Math.PercisionCheck(bump.T.x + bump.T.w, a.T.x, math.abs(a.V.x.base) * DELTATIME * 1.5 + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Util.Event.Screenshake(2, 1/4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                AtlasY = 2,
                                x = bump.T.x + bump.T.w,
                                y = a.T.y,
                                updateFunc = function(s, dt)
                                    s.extra.Timer = s.extra.Timer or 0
                                    s.extra.Timer = s.extra.Timer + dt
                                    if s.extra.Timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local TickTime = 0.075
                                    local frame = Util.Math.Div(s.extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Right = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.extra.checks.Right.extra.ticked,
                        "RicoChet")[1])
                        if a.V.x.base > 0 and bump and bump.T.x < a.T.x + a.T.w and Util.Math.PercisionCheck(bump.T.x, a.T.x + a.T.w, math.abs(a.V.x.base) * DELTATIME * 1.5 + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Util.Event.Screenshake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                AtlasY = 0,
                                x = bump.T.x - 20,
                                y = a.T.y,
                                updateFunc = function(s, dt)
                                    s.extra.Timer = s.extra.Timer or 0
                                    s.extra.Timer = s.extra.Timer + dt
                                    if s.extra.Timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local TickTime = 0.075
                                    local frame = Util.Math.Div(s.extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Up = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.extra.checks.Up.extra.ticked,
                        "RicoChet")[1])
                        if a.V.y.base < 0 and bump and bump.T.y + bump.T.h > a.T.y and Util.Math.PercisionCheck(bump.T.y + bump.T.h, a.T.y, math.abs(a.V.y.base) * DELTATIME * 1.5 + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Util.Event.Screenshake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                AtlasY = 1,
                                x = a.T.x,
                                y = bump.T.y + bump.T.h ,
                                updateFunc = function(s, dt)
                                    s.extra.Timer = s.extra.Timer or 0
                                    s.extra.Timer = s.extra.Timer + dt
                                    if s.extra.Timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local TickTime = 0.075
                                    local frame = Util.Math.Div(s.extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Down = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.extra.checks.Down.extra.ticked, "RicoChet")[1])
                        if a.V.y.base > 0 and bump and bump.T.y < a.T.y + a.T.h and Util.Math.PercisionCheck(bump.T.y, a.T.y + a.T.h, math.abs(a.V.y.base) * DELTATIME * 1.5 + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Util.Event.Screenshake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                x = a.T.x,
                                y = bump.T.y - 20,
                                AtlasY = 3,
                                updateFunc = function(s, dt)
                                    s.extra.Timer = s.extra.Timer or 0
                                    s.extra.Timer = s.extra.Timer + dt
                                    if s.extra.Timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local TickTime = 0.075
                                    local frame = Util.Math.Div(s.extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                }
                if collidedFunc(v, opposite[k]) then
                    if collisionContainsProperty(v.extra.ticked, "RicoChet") then
                        funcs[k](self)
                        self.extra.TG = 0.05
                    elseif not collisionContainsProperty(v.extra.ticked, "Player") then
                        if not self.extra.Done then Util.Event.Screenshake(3/4, 1 / 8) end
                        self.extra.Done = true
                        self.V.y.base = 0
                        self.V.x.base = 0
                    end
                end
            end
        end
        self.extra.TG = self.extra.TG - dt
        if self.extra.clockInit > 5 then
            self.extra.Done = true
        end
        if self.extra.Done then
            self.V.x.base = 0
            self.V.y.base = 0
            self.extra.lerpD = Util.Math.lerpDt(self.extra.lerpD, 0, 0.15)
            self.TMod.x.base = Util.Math.lerpDt(self.TMod.x.base, GetObjectByNid("Player").T.x, self.extra.lerpD)
            self.TMod.y.base = Util.Math.lerpDt(self.TMod.y.base, GetObjectByNid("Player").T.y + 10, self.extra.lerpD)
            if Util.Math.PercisionCheck(self.T.x, GetObjectByNid("Player").T.x, 2) and Util.Math.PercisionCheck(self.T.y, GetObjectByNid("Player").T.y + 10, 2) then
                self:remove()
                G.Flags.BoomerangExists = nil
            end
        end
        local tick = 1/3
        local k, k_1 = self.extra.clockInit % tick, (self.extra.clockInit - dt) % tick
        if k <= k_1 then
            CreateAfterImage(self.TMod.x.base + self.V.x.base * dt, self.TMod.y.base + self.V.y.base * dt, self.extra.A.AtliInfo.x)
        end
    end
    Moveable.new(self, args)
    self.extra.A = Sprite({
        atlasKey = "Boomerang",
        drawOrder = 100,
        AtlasY = 0,
        updateFunc = function(s, dt)
            local TickTime = 0.15
            local frame = Util.Math.Div(G.Timer, TickTime) % 4
            s.AtliInfo.x = frame
            s.AtliInfo.y = self.extra.Done and 1 or 0
            if not G.Flags.BoomerangExists then
                s:remove()
            end
        end
    })
    self.extra.A:SetParent(self)
    self.extra.checks = {}
    local c = self.extra.checks
    c.Up = Moveable {
        properties = {
            CollisionCheck = true,
        },
        strength = -1000,
        w = 16,
        h = 1,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#2F00FF"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.Up.TMod.x.offset = 2
    c.Up.TMod.y.offset = -1
    c.Down = Moveable {
        properties = {
            CollisionCheck = true,
        },
        w = 16,
        h = 1,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#F700FF"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.Down.TMod.x.offset = 2
    c.Down.TMod.y.offset = 20
    c.Left = Moveable {
        properties = {
            CollisionCheck = true,
        },
        w = 1,
        h = 16,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#FF0000"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.Left.TMod.y.offset = 2
    c.Left.TMod.x.offset = -1
    c.Right = Moveable {
        properties = {
            CollisionCheck = true,
        },
        w = 1,
        h = 16,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#00FF22"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.Right.TMod.y.offset = 2
    c.Right.TMod.x.offset = 20
    for k, v in pairs(c) do
        v:SetParent(self)
    end
    return self
end
