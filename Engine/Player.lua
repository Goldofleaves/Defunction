---@class Player: Moveable

Player = Moveable:extend()
function Player:new(args)
    local OnGroundCond = function()
        return next(self.extra.OnGround) and not collisionContainsId(self.extra.OnGround, self.Id) and
            not collisionContainsProperty(self.extra.OnGround, "noCollision") and
            not collisionContainsProperty(self.extra.OnGround, "CollisionCheck") and
            (CollisionContainsextra(self.extra.OnGround, "Facing") and collisionContainsId(getAllCollisionextra(self.extra.OnGround, "Facing"), "Up") or true)
    end
    args = args or {}
    args.strength = 500
    args.properties = args.properties or {}
    args.properties.Player = true
    args.x = args.x or 140
    args.y = args.y or 140
    args.w = args.w or 20
    args.h = args.h or 40
    args.extra = {
        CoyoteTimer = 0,
        HaventJumped = true,
        HoldTimer = Macros.MaxHold,
        Facing = "Right",
        OnGround = {}
    }
    args.updateFunc = function(self, dt)
        if G.Controller.Mouse.Primary.Pressed and not self.extra.J and not G.Flags.BoomerangExists then
            self.extra.J = true
            love.mouse.setX((self.T.x + 10) * G.Settings.ScalingFactor)
            love.mouse.setY((self.T.y + 20) * G.Settings.ScalingFactor)
            Sprite({
                atlasKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                drawOrder = 4001,
                OffsetX = -30,
                OffsetY = -20,
                transparency = 0,
                updateFunc = function (s, ddt)
                    s.transparency = Util.Math.lerpDt(s.transparency, s.extra.Removen and 0 or 1, 0.0025)
                    if G.Controller.Mouse.Primary.Released then
                        s.extra.Removen = true
                    end
                    if s.extra.Removen and s.transparency <= 0.01 then
                        s:remove()
                        self.extra.J = nil
                    end
                end,
            }):SetParent(self)
            Sprite({
                atlasKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                drawOrder = 4002,
                OffsetX = -30,
                OffsetY = -20,
                transparency = 0,
                extra = {
                    Radius = -1/5,
                    Det = 1
                },
                updateFunc = function(s, ddt)
                    s.extra.Radius = Util.Math.lerpDt(s.extra.Radius, s.extra.Removen and 0 or 4.5, 0.0025)
                    s.transparency = Util.Math.lerpDt(s.transparency, s.extra.Removen and 0 or 1, 0.0025)
                    if G.Controller.Mouse.Primary.Released and not G.Flags.BoomerangExists then
                        G.Flags.BoomerangExists = true
                        s.extra.Removen = true
                        local XCoord, YCoord, XVel, YVel = 0, 0, 0, 0
                        local Spd, Offset = 300, 15
                        local rt2Spd, rt2Offset = Spd / (2 ^ (1 / 2)), Offset / (2 ^ (1 / 2))
                        if s.extra.Det == 1 then
                            XCoord = Offset
                            XVel = Spd
                        elseif s.extra.Det == 2 then
                            XCoord = rt2Offset
                            YCoord = -rt2Offset
                            XVel = rt2Spd
                            YVel = -rt2Spd
                        elseif s.extra.Det == 3 then
                            YCoord = -Offset
                            YVel = -Spd
                        elseif s.extra.Det == 4 then
                            XCoord = -rt2Offset
                            YCoord = -rt2Offset
                            XVel = -rt2Spd
                            YVel = -rt2Spd
                        elseif s.extra.Det == 5 then
                            XCoord = -Offset
                            XVel = -Spd
                        elseif s.extra.Det == 6 then
                            XCoord = -rt2Offset
                            YCoord = rt2Offset
                            XVel = -rt2Spd
                            YVel = rt2Spd
                        elseif s.extra.Det == 7 then
                            YCoord = Offset
                            YVel = Spd
                        else
                            XCoord = rt2Offset
                            YCoord = rt2Offset
                            XVel = rt2Spd
                            YVel = rt2Spd
                        end
                        BRang{
                            x = self.T.x + self.T.w / 2 + XCoord - 10,
                            y = self.T.y + self.T.h / 2 + YCoord - 10,
                            vx = XVel,
                            vy = YVel,
                            extra = {
                                OVX = XVel,
                                OVY = YVel,
                                clockInit = 0
                            }
                        }
                    end
                    if s.extra.Removen and s.transparency <= 0.005 then
                        s:remove()
                    end
                    local verticalQuadrant = G.MousePos.y >= (self.T.y + 20) and "down" or "up"
                    local horizontalQuadrant = G.MousePos.x >= (self.T.x + 10) and "right" or "left"
                    s.extra.s1 = s.extra.s1 or math.tan(math.pi / 8)
                    s.extra.s2 = s.extra.s2 or math.tan(3 * math.pi / 8)
                    s.extra.s3 = s.extra.s3 or math.tan(5 * math.pi / 8)
                    s.extra.s4 = s.extra.s4 or math.tan(7 * math.pi / 8)
                    local slope = -(G.MousePos.y - (self.T.y + 20)) / (G.MousePos.x - (self.T.x + 10))
                    s.extra.Det = 1-- the region of the mouse, going from 1 to 8 starting with the positive x direction going counter clockwise
                    if verticalQuadrant == "down" then
                        if horizontalQuadrant == "right" then
                            if slope > s.extra.s4 then
                                s.extra.Det = 1
                            elseif slope > s.extra.s3 then
                                s.extra.Det = 8
                            else
                                s.extra.Det = 7
                            end
                        else
                            if slope < s.extra.s1 then
                                s.extra.Det = 5
                            elseif slope < s.extra.s2 then
                                s.extra.Det = 6
                            else
                                s.extra.Det = 7
                            end
                        end
                    else
                        if horizontalQuadrant == "right" then
                            if slope < s.extra.s1 then
                                s.extra.Det = 1
                            elseif slope < s.extra.s2 then
                                s.extra.Det = 2
                            else
                                s.extra.Det = 3
                            end
                        else
                            if slope > s.extra.s4 then
                                s.extra.Det = 5
                            elseif slope > s.extra.s3 then
                                s.extra.Det = 4
                            else
                                s.extra.Det = 3
                            end
                        end
                    end
                    s.AtliInfo.x = (s.extra.Det - 1) % 4
                    s.AtliInfo.y = Util.Math.Div((s.extra.Det - 1), 4) + 1
                end,
                drawFunc = function(s)
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, s.extra.Radius)
                    love.graphics.setColor(Util.Other.Hex("#4a3052"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, math.max(0, s.extra.Radius - 0.5))
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.MousePos.x, G.MousePos.y, math.max(0, s.extra.Radius - 2.5))
                    love.graphics.setColor { r, g, b, a }
                end
            }):SetParent(self)
        end
        if not (G.Controller.Keyboard.left.Held or G.Controller.Keyboard.right.Held) or (G.Controller.Keyboard.right.Held and G.Controller.Keyboard.left.Held) then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, 0, 0.005)
        elseif G.Controller.Keyboard.left.Held then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, -90, 0.005)
            self.extra.Facing = "Left"
        elseif G.Controller.Keyboard.right.Held then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, 90, 0.005)
            self.extra.Facing = "Right"
        end
        self.TMod.x.Gravity = self.TMod.x.Gravity or 0
        self.V.x.Gravity = self.V.x.Gravity or 0
        self.TMod.y.Gravity = self.TMod.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity or 0
        self.V.y.Gravity = math.min(self.V.y.Gravity + Macros.Gravity / 0.02 * DELTATIME, Macros.TerminalVelocity)
        self.extra.OnGround = self.extra.DownCheck.extra.ticked
        self.extra.HitCeiling = self.extra.UpCheck.extra.ticked
        if OnGroundCond() then
            self.V.y.Gravity = math.min(0, self.V.y.Gravity)
            self.extra.HaventJumped = true
            self.extra.CoyoteTimer = Macros.CoyoteTime
            self.extra.HoldTimer = Macros.MaxHold
        else
            self.extra.CoyoteTimer = self.extra.CoyoteTimer - dt
        end
        if self.extra.CoyoteTimer < 0 then
            self.extra.HaventJumped = false
        end
        if G.Controller.Keyboard.up.Held then
            if self.extra.HaventJumped or self.extra.HoldTimer >= 0 then
                self.V.y.Gravity = -Macros.JumpVelocity
            end
            self.extra.HoldTimer = self.extra.HoldTimer - dt
        else
            self.extra.HoldTimer = -1
        end
        if self.V.y.Gravity <= 0 and next(self.extra.HitCeiling) and not collisionContainsId(self.extra.HitCeiling, self.Id) and not collisionContainsProperty(self.extra.HitCeiling, "noCollision") then
            self.V.y.Gravity = 20
            self.extra.HoldTimer = -1
        end
    end
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#00FF15"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    self.extra.CoyoteTimer = Macros.CoyoteTime
    self.extra.DownCheck = Moveable {
        properties = {
            CollisionCheck = true
        },
        w = 20,
        h = 1,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#2F00FF"))
                love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    self.extra.DownCheck.TMod.x.offset = 0
    self.extra.DownCheck.TMod.y.offset = 40
    self.extra.DownCheck:SetParent(self)

    self.extra.UpCheck = Moveable {
        properties = {
            CollisionCheck = true
        },
        w = 20,
        h = 1,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#2F00FF"))
                love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    self.extra.UpCheck.TMod.y.offset = -1
    self.extra.UpCheck:SetParent(self)









    Sprite({
        atlasKey = "ArnaOverworld",
        drawOrder = 4000,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworld",
        drawOrder = 3999,
        AtlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not OnGroundCond() then
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
        atlasKey = "ArnaOverworld",
        drawOrder = 3998,
        AtlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    -- Outlines Yay
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = 1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = 1,
        AtlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not OnGroundCond() then
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
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = 1,
        AtlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = -1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = -1,
        AtlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not OnGroundCond() then
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
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetX = -1,
        AtlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = 1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = 1,
        AtlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not OnGroundCond() then
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
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = 1,
        AtlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = -1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = -1,
        AtlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not OnGroundCond() then
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
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        OffsetY = -1,
        AtlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    self.Nid = "Player"
    return self
end
