---@class BRang: Moveable

local function CreateAfterImage(x, y, f)
    Sprite({
        AtliKey = "Boomerang",
        DrawOrder = 50,
        AtliY = 2,
        AtliX = f,
        x = x, y = y,
        Transparency = 1/2,
        UpdateFunc = function(s, dt)
            s.Transparency = s.Transparency - dt
            if s.Transparency <= 0 then
                s:Remove()
            end
        end
    })
end

BRang = Moveable:extend()
function BRang:new(args)
    local CollidedFunc = function(a, dir)
        return next(a.Extra.Ticked or {}) and not CollisionContainsId(a.Extra.Ticked, self.Id) and
            not CollisionContainsProperty(a.Extra.Ticked, "NoCollision") and
            not CollisionContainsProperty(a.Extra.Ticked, "CollisionCheck") and
            (CollisionContainsExtra(a.Extra.Ticked, "Facing") and CollisionContainsId(GetAllCollisionExtra(a.Extra.Ticked, "Facing"), dir) or true)
    end
    args = args or {}
    args.DrawOrder = 35
    args.Properties = args.Properties or {}
    args.Properties.NoCollision = true
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 20
    args.h = args.h or 20
    args.Strength = 0
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF00B3"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    args.UpdateFunc = function(self, dt)
        self.Extra.VelD = self.Extra.VelD or 0
        self.Extra.TG = self.Extra.TG or 0
        self.Extra.VelD = self.Extra.VelD + 1 / 12
        self.Extra.ClockInit = self.Extra.ClockInit + dt
        self.Extra.LerpD = self.Extra.LerpD or 1
        if self.Extra.TG <= 0 then
            for k, v in pairs(self.Extra.Checks) do
                local opposite = {
                    Left = "Right",
                    Right = "Left",
                    Down = "Up",
                    Up = "Down"
                }
                local funcs = {
                    Left = function (a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.Extra.Checks.Left.Extra.Ticked,
                        "RicoChet")[1])
                        if a.V.x.base < 0 and bump and bump.T.x + bump.T.w > a.T.x and Util.Math.PercisionCheck(bump.T.x + bump.T.w, a.T.x, math.abs(a.V.x.base) * PREVIOUS_DELTATIME + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Sprite({
                                AtliKey = "Bump",
                                DrawOrder = 101,
                                AtliY = 2,
                                x = bump.T.x + bump.T.w,
                                y = a.T.y,
                                UpdateFunc = function(s, dt)
                                    s.Extra.Timer = s.Extra.Timer or 0
                                    s.Extra.Timer = s.Extra.Timer + dt
                                    if s.Extra.Timer > 4 * 0.1 then
                                        s:Remove()
                                    end
                                    local TickTime = 0.1
                                    local frame = Util.Math.Div(s.Extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Right = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.Extra.Checks.Right.Extra.Ticked,
                        "RicoChet")[1])
                        if a.V.x.base > 0 and bump and bump.T.x < a.T.x + a.T.w and Util.Math.PercisionCheck(bump.T.x, a.T.x + a.T.w, math.abs(a.V.x.base) * PREVIOUS_DELTATIME + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Sprite({
                                AtliKey = "Bump",
                                DrawOrder = 101,
                                AtliY = 0,
                                x = bump.T.x - 20,
                                y = a.T.y,
                                UpdateFunc = function(s, dt)
                                    s.Extra.Timer = s.Extra.Timer or 0
                                    s.Extra.Timer = s.Extra.Timer + dt
                                    if s.Extra.Timer > 4 * 0.1 then
                                        s:Remove()
                                    end
                                    local TickTime = 0.1
                                    local frame = Util.Math.Div(s.Extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Up = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.Extra.Checks.Up.Extra.Ticked,
                        "RicoChet")[1])
                        if a.V.y.base < 0 and bump and bump.T.y + bump.T.h > a.T.y and Util.Math.PercisionCheck(bump.T.y + bump.T.h, a.T.y, math.abs(a.V.y.base) * PREVIOUS_DELTATIME + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Sprite({
                                AtliKey = "Bump",
                                DrawOrder = 101,
                                AtliY = 1,
                                x = a.T.x,
                                y = bump.T.y + bump.T.h ,
                                UpdateFunc = function(s, dt)
                                    s.Extra.Timer = s.Extra.Timer or 0
                                    s.Extra.Timer = s.Extra.Timer + dt
                                    if s.Extra.Timer > 4 * 0.1 then
                                        s:Remove()
                                    end
                                    local TickTime = 0.1
                                    local frame = Util.Math.Div(s.Extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                    Down = function(a)
                        local bump = GetObjectById(GetAllCollisionPropertyIds(self.Extra.Checks.Down.Extra.Ticked, "RicoChet")[1])
                        if a.V.y.base > 0 and bump and bump.T.y < a.T.y + a.T.h and Util.Math.PercisionCheck(bump.T.y, a.T.y + a.T.h, math.abs(a.V.y.base) * PREVIOUS_DELTATIME + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Sprite({
                                AtliKey = "Bump",
                                DrawOrder = 101,
                                x = a.T.x,
                                y = bump.T.y - 20,
                                AtliY = 3,
                                UpdateFunc = function(s, dt)
                                    s.Extra.Timer = s.Extra.Timer or 0
                                    s.Extra.Timer = s.Extra.Timer + dt
                                    if s.Extra.Timer > 4 * 0.1 then
                                        s:Remove()
                                    end
                                    local TickTime = 0.1
                                    local frame = Util.Math.Div(s.Extra.Timer, TickTime) % 4
                                    s.AtliInfo.x = frame
                                end
                            })
                        end
                    end,
                }
                if CollidedFunc(v, opposite[k]) then
                    if CollisionContainsProperty(v.Extra.Ticked, "RicoChet") then
                        funcs[k](self)
                        self.Extra.TG = 0.05
                    elseif not CollisionContainsProperty(v.Extra.Ticked, "Player") then
                        self.Extra.Done = true
                        self.V.y.base = 0
                        self.V.x.base = 0
                    end
                end
            end
        end
        self.Extra.TG = self.Extra.TG - dt
        if self.Extra.ClockInit > 5 then
            self.Extra.Done = true
        end
        if self.Extra.Done then
            self.V.x.base = 0
            self.V.y.base = 0
            self.Extra.LerpD = Util.Math.LerpDt(self.Extra.LerpD, 0, 0.15)
            self.TMod.x.base = Util.Math.LerpDt(self.TMod.x.base, GetObjectByNid("Player").T.x, self.Extra.LerpD)
            self.TMod.y.base = Util.Math.LerpDt(self.TMod.y.base, GetObjectByNid("Player").T.y + 10, self.Extra.LerpD)
            if Util.Math.PercisionCheck(self.T.x, GetObjectByNid("Player").T.x, 2) and Util.Math.PercisionCheck(self.T.y, GetObjectByNid("Player").T.y + 10, 2) then
                self:Remove()
                G.Flags.BoomerangExists = nil
            end
        end
        local tick = 1/3
        local k, k_1 = self.Extra.ClockInit % tick, (self.Extra.ClockInit - dt) % tick
        if k <= k_1 then
            CreateAfterImage(self.TMod.x.base + self.V.x.base * dt, self.TMod.y.base + self.V.y.base * dt, self.Extra.A.AtliInfo.x)
        end
    end
    Moveable.new(self, args)
    self.Extra.A = Sprite({
        AtliKey = "Boomerang",
        DrawOrder = 100,
        AtliY = 0,
        UpdateFunc = function(s, dt)
            local TickTime = 0.15
            local frame = Util.Math.Div(G.Timer, TickTime) % 4
            s.AtliInfo.x = frame
            s.AtliInfo.y = self.Extra.Done and 1 or 0
        end
    })
    self.Extra.A:SetParent(self)
    self.Extra.Checks = {}
    local c = self.Extra.Checks
    c.Up = Moveable {
        Properties = {
            CollisionCheck = true,
        },
        Strength = -1000,
        w = 16,
        h = 1,
        DrawFunc = function(s)
            if G.Debug then
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
        Properties = {
            CollisionCheck = true,
        },
        w = 16,
        h = 1,
        Strength = -1000,
        DrawFunc = function(s)
            if G.Debug then
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
        Properties = {
            CollisionCheck = true,
        },
        w = 1,
        h = 16,
        Strength = -1000,
        DrawFunc = function(s)
            if G.Debug then
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
        Properties = {
            CollisionCheck = true,
        },
        w = 1,
        h = 16,
        Strength = -1000,
        DrawFunc = function(s)
            if G.Debug then
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
