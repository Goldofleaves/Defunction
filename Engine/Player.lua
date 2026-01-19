---@class Player: Moveable

Player = Moveable:extend()
function Player:new(args)
    args = args or {}
    args.Strength = 500
    args.Properties = args.Properties or {}
    args.Properties.Player = true
    args.x = args.x or 140
    args.y = args.y or 140
    args.w = args.w or 20
    args.h = args.h or 40
    args.Extra = {
        CoyoteTimer = 0,
        HaventJumped = true,
        HoldTimer = Macros.MaxHold,
        Facing = "Right",
        OnGround = true
    }
    args.UpdateFunc = function(self, dt)
        if G.Controller.Mouse.Primary.Pressed and not self.Extra.J then
            self.Extra.J = true
            love.mouse.setX((self.T.x + 10) * G.Settings.ScalingFactor)
            love.mouse.setY((self.T.y + 20) * G.Settings.ScalingFactor)
            Sprite({
                AtliKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                DrawOrder = 4001,
                OffsetX = -30,
                OffsetY = -20,
                Transparency = 0,
                Extra = {
                    a = 0
                },
                UpdateFunc = function (s, ddt)
                    s.Extra.a = Util.Math.LerpDt(s.Extra.a, s.Extra.Removen and 0 or 4.5, 0.0025)
                    s.Transparency = Util.Math.LerpDt(s.Transparency, s.Extra.Removen and 0 or 1, 0.0025)
                    if G.Controller.Mouse.Primary.Released then
                        s.Extra.Removen = true
                    end
                    if s.Extra.Removen and s.Transparency <= 0.01 then
                        s:remove()
                        self.Extra.J = nil
                    end
                end,
            }):SetParent(self)
            Sprite({
                AtliKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                DrawOrder = 4002,
                OffsetX = -30,
                OffsetY = -20,
                Transparency = 0,
                Extra = {
                    a = 0,
                    Det = 1
                },
                UpdateFunc = function(s, ddt)
                    s.Extra.a = Util.Math.LerpDt(s.Extra.a, s.Extra.Removen and 0 or 4.5, 0.0025)
                    s.Transparency = Util.Math.LerpDt(s.Transparency, s.Extra.Removen and 0 or 1, 0.0025)
                    if G.Controller.Mouse.Primary.Released then
                        s.Extra.Removen = true
                    end
                    if s.Extra.Removen and s.Transparency <= 0.005 then
                        s:remove()
                    end
                    local verticalQuadrant = G.MousePos.y >= (self.T.y + 20) and "down" or "up"
                    local horizontalQuadrant = G.MousePos.x >= (self.T.x + 10) and "right" or "left"
                    s.Extra.s1 = s.Extra.s1 or math.tan(math.pi / 8)
                    s.Extra.s2 = s.Extra.s2 or math.tan(3 * math.pi / 8)
                    s.Extra.s3 = s.Extra.s3 or math.tan(5 * math.pi / 8)
                    s.Extra.s4 = s.Extra.s4 or math.tan(7 * math.pi / 8)
                    local slope = -(G.MousePos.y - (self.T.y + 20)) / (G.MousePos.x - (self.T.x + 10))
                    s.Extra.Det = 1-- the region of the mouse, going from 1 to 8 starting with the positive x direction going counter clockwise
                    if verticalQuadrant == "down" then
                        if horizontalQuadrant == "right" then
                            if slope > s.Extra.s4 then
                                s.Extra.Det = 1
                            elseif slope > s.Extra.s3 then
                                s.Extra.Det = 8
                            else
                                s.Extra.Det = 7
                            end
                        else
                            if slope < s.Extra.s1 then
                                s.Extra.Det = 5
                            elseif slope < s.Extra.s2 then
                                s.Extra.Det = 6
                            else
                                s.Extra.Det = 7
                            end
                        end
                    else
                        if horizontalQuadrant == "right" then
                            if slope < s.Extra.s1 then
                                s.Extra.Det = 1
                            elseif slope < s.Extra.s2 then
                                s.Extra.Det = 2
                            else
                                s.Extra.Det = 3
                            end
                        else
                            if slope > s.Extra.s4 then
                                s.Extra.Det = 5
                            elseif slope > s.Extra.s3 then
                                s.Extra.Det = 4
                            else
                                s.Extra.Det = 3
                            end
                        end
                    end
                    s.AtliInfo.x = (s.Extra.Det - 1) % 4
                    s.AtliInfo.y = Util.Math.Div((s.Extra.Det - 1), 4) + 1
                end,
                DrawFunc = function(s)
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, s.Extra.a)
                    love.graphics.setColor(Util.Other.Hex("#4a3052"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, math.max(0, s.Extra.a - 0.5))
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, math.max(0, s.Extra.a - 2.5))
                    love.graphics.setColor { r, g, b, a }
                end
            }):SetParent(self)
        end
        if not (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) or (G.Controller.Keyboard.right.Held and G.Controller.Keyboard.left.Held) then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, 0, 0.005)
        elseif G.Controller.Keyboard.left.Held then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, -90, 0.005)
            self.Extra.Facing = "Left"
        elseif G.Controller.Keyboard.right.Held then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, 90, 0.005)
            self.Extra.Facing = "Right"
        end
        self.TMod.x.Gravity = self.TMod.x.Gravity or 0
        self.V.x.Gravity = self.V.x.Gravity or 0
        self.TMod.y.Gravity = self.TMod.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity or 0
        self.V.y.Gravity = math.min(self.V.y.Gravity + Macros.Gravity, Macros.TerminalVelocity)
        self.Extra.OnGround = self.Extra.DownCheck.Extra.Ticked
        if self.Extra.OnGround and self.Extra.OnGround ~= self.Id then
            self.V.y.Gravity = 0
            self.Extra.HaventJumped = true
            self.Extra.CoyoteTimer = Macros.CoyoteTime
            self.Extra.HoldTimer = Macros.MaxHold
        else
            self.Extra.CoyoteTimer = self.Extra.CoyoteTimer - dt
        end
        if self.Extra.CoyoteTimer < 0 then
            self.Extra.HaventJumped = false
        end
        if G.Controller.Keyboard.up.Held then
            if self.Extra.HaventJumped or self.Extra.HoldTimer >= 0 then
                self.V.y.Gravity = -Macros.JumpVelocity
            end
            self.Extra.HoldTimer = self.Extra.HoldTimer - dt
        else
            if self.Extra.HaventJumped then
                self.Extra.HoldTimer = -1
            end
        end
        if self.Extra.OnGround == self.Id then
            self.V.y.Gravity = 20
            self.Extra.HoldTimer = -1
        end
    end
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#00FF15"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    self.Extra.CoyoteTimer = Macros.CoyoteTime
    self.Extra.DownCheck = Moveable {
        Properties = {
            CollisionCheck = true
        },
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
    self.Extra.DownCheck.TMod.x.offset = 2
    self.Extra.DownCheck.TMod.y.offset = 40
    self.Extra.DownCheck:SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 4000,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 3999,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) and not (G.Controller.Keyboard.left.Held and G.Controller.Keyboard.right.Held) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 3998,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    -- Outlines Yay
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) and not (G.Controller.Keyboard.left.Held and G.Controller.Keyboard.right.Held) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) and not (G.Controller.Keyboard.left.Held and G.Controller.Keyboard.right.Held) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) and not (G.Controller.Keyboard.left.Held and G.Controller.Keyboard.right.Held) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) and not (G.Controller.Keyboard.left.Held and G.Controller.Keyboard.right.Held) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    return self
end
