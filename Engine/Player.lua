---@class Player: Moveable

Player = Moveable:extend()
function Player:new(args)
    local OnGroundCond = function()
        return next(self.extra.onGround) and not collisionContainsId(self.extra.onGround, self.id) and
            not collisionContainsProperty(self.extra.onGround, "noCollision") and
            not collisionContainsProperty(self.extra.onGround, "collisionCheck") and
            (CollisionContainsextra(self.extra.onGround, "facing") and collisionContainsId(getAllCollisionextra(self.extra.onGround, "facing"), "up") or true)
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
        HoldTimer = Macros.maxHold,
        facing = "right",
        onGround = {}
    }
    args.updateFunc = function(self, dt)
        if G.controller.mouse.primary.pressed and not self.extra.J and not G.flags.boomerangExists then
            self.extra.J = true
            love.mouse.setX((self.T.x + 10) * G.settings.scalingFactor)
            love.mouse.setY((self.T.y + 20) * G.settings.scalingFactor)
            Sprite({
                atlasKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                drawOrder = 4001,
                offsetX = -30,
                offsetY = -20,
                transparency = 0,
                updateFunc = function (s, ddt)
                    s.transparency = Util.Math.lerpDt(s.transparency, s.extra.Removen and 0 or 1, 0.0025)
                    if G.controller.mouse.primary.released then
                        s.extra.Removen = true
                    end
                    if s.extra.Removen and s.transparency <= 0.01 then
                        s:remove()
                        self.extra.J = nil
                    end
                end,
            }):setParent(self)
            Sprite({
                atlasKey = "BoomerangRing",
                x = self.T.x,
                y = self.T.y,
                drawOrder = 4002,
                offsetX = -30,
                offsetY = -20,
                transparency = 0,
                extra = {
                    Radius = -1/5,
                    Det = 1
                },
                updateFunc = function(s, ddt)
                    s.extra.Radius = Util.Math.lerpDt(s.extra.Radius, s.extra.Removen and 0 or 4.5, 0.0025)
                    s.transparency = Util.Math.lerpDt(s.transparency, s.extra.Removen and 0 or 1, 0.0025)
                    if G.controller.mouse.primary.released and not G.flags.boomerangExists then
                        G.flags.boomerangExists = true
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
                    local verticalQuadrant = G.mousePos.y >= (self.T.y + 20) and "down" or "up"
                    local horizontalQuadrant = G.mousePos.x >= (self.T.x + 10) and "right" or "left"
                    s.extra.s1 = s.extra.s1 or math.tan(math.pi / 8)
                    s.extra.s2 = s.extra.s2 or math.tan(3 * math.pi / 8)
                    s.extra.s3 = s.extra.s3 or math.tan(5 * math.pi / 8)
                    s.extra.s4 = s.extra.s4 or math.tan(7 * math.pi / 8)
                    local slope = -(G.mousePos.y - (self.T.y + 20)) / (G.mousePos.x - (self.T.x + 10))
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
                    s.atlasInfo.x = (s.extra.Det - 1) % 4
                    s.atlasInfo.y = Util.Math.div((s.extra.Det - 1), 4) + 1
                end,
                drawFunc = function(s)
                    local r, g, b, a = love.graphics.getColor()
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.mousePos.x, G.mousePos.y, math.max(0, s.extra.Radius))
                    love.graphics.setColor(Util.Other.Hex("#4a3052"))
                    love.graphics.circle("fill", G.mousePos.x, G.mousePos.y, math.max(0, s.extra.Radius - 0.5))
                    love.graphics.setColor(Util.Other.Hex("#FFFFFF"))
                    love.graphics.circle("fill", G.mousePos.x, G.mousePos.y, math.max(0, s.extra.Radius - 2.5))
                    love.graphics.setColor { r, g, b, a }
                end
            }):setParent(self)
        end
        if not (G.controller.keyboard.left.held or G.controller.keyboard.right.held) or (G.controller.keyboard.right.held and G.controller.keyboard.left.held) then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, 0, 0.005)
        elseif G.controller.keyboard.left.held then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, -90, 0.005)
            self.extra.facing = "left"
        elseif G.controller.keyboard.right.held then
            self.V.x.base = Util.Math.lerpDt(self.V.x.base, 90, 0.005)
            self.extra.facing = "right"
        end
        self.TMod.x.gravity = self.TMod.x.gravity or 0
        self.V.x.gravity = self.V.x.gravity or 0
        self.TMod.y.gravity = self.TMod.y.gravity or 0
        self.V.y.gravity = self.V.y.gravity or 0
        self.V.y.gravity = math.min(self.V.y.gravity + Macros.gravity / 0.02 * DELTATIME, Macros.terminalVelocity)
        self.extra.onGround = self.extra.downCheck.extra.ticked
        self.extra.HitCeiling = self.extra.upCheck.extra.ticked
        if OnGroundCond() then
            self.V.y.gravity = math.min(0, self.V.y.gravity)
            self.extra.HaventJumped = true
            self.extra.CoyoteTimer = Macros.coyoteTime
            self.extra.HoldTimer = Macros.maxHold
        else
            self.extra.CoyoteTimer = self.extra.CoyoteTimer - dt
        end
        if self.extra.CoyoteTimer < 0 then
            self.extra.HaventJumped = false
        end
        if G.controller.keyboard.up.held then
            if self.extra.HaventJumped or self.extra.HoldTimer >= 0 then
                self.V.y.gravity = -Macros.jumpVelocity
            end
            self.extra.HoldTimer = self.extra.HoldTimer - dt
        else
            self.extra.HoldTimer = -1
        end
        if self.V.y.gravity <= 0 and next(self.extra.HitCeiling) and not collisionContainsId(self.extra.HitCeiling, self.id) and not collisionContainsProperty(self.extra.HitCeiling, "noCollision") then
            self.V.y.gravity = 20
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
    self.extra.CoyoteTimer = Macros.coyoteTime
    self.extra.downCheck = Moveable {
        properties = {
            collisionCheck = true
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
    self.extra.downCheck.TMod.x.offset = 0
    self.extra.downCheck.TMod.y.offset = 40
    self.extra.downCheck:setParent(self)

    self.extra.upCheck = Moveable {
        properties = {
            collisionCheck = true
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
    self.extra.upCheck.TMod.y.offset = -1
    self.extra.upCheck:setParent(self)









    Sprite({
        atlasKey = "ArnaOverworld",
        drawOrder = 4000,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworld",
        drawOrder = 3999,
        atlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            if not OnGroundCond() then
                s.atlasInfo.x = 1
                s.atlasInfo.y = 1
            else
                if (G.controller.keyboard.left.held or G.controller.keyboard.right.held) and not (G.controller.keyboard.left.held and G.controller.keyboard.right.held) then
                    local frame = Util.Math.div(G.timer, tickTime) % 6
                    s.atlasInfo.x = frame
                    s.atlasInfo.y = 2
                else
                    s.atlasInfo.x = 0
                    s.atlasInfo.y = 1
                end
            end
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworld",
        drawOrder = 3998,
        atlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    -- Outlines Yay
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = 1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = 1,
        atlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            if not OnGroundCond() then
                s.atlasInfo.x = 1
                s.atlasInfo.y = 1
            else
                if (G.controller.keyboard.left.held or G.controller.keyboard.right.held) and not (G.controller.keyboard.left.held and G.controller.keyboard.right.held) then
                    local frame = Util.Math.div(G.timer, tickTime) % 6
                    s.atlasInfo.x = frame
                    s.atlasInfo.y = 2
                else
                    s.atlasInfo.x = 0
                    s.atlasInfo.y = 1
                end
            end
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = 1,
        atlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = -1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = -1,
        atlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            if not OnGroundCond() then
                s.atlasInfo.x = 1
                s.atlasInfo.y = 1
            else
                if (G.controller.keyboard.left.held or G.controller.keyboard.right.held) and not (G.controller.keyboard.left.held and G.controller.keyboard.right.held) then
                    local frame = Util.Math.div(G.timer, tickTime) % 6
                    s.atlasInfo.x = frame
                    s.atlasInfo.y = 2
                else
                    s.atlasInfo.x = 0
                    s.atlasInfo.y = 1
                end
            end
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetX = -1,
        atlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = 1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = 1,
        atlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            if not OnGroundCond() then
                s.atlasInfo.x = 1
                s.atlasInfo.y = 1
            else
                if (G.controller.keyboard.left.held or G.controller.keyboard.right.held) and not (G.controller.keyboard.left.held and G.controller.keyboard.right.held) then
                    local frame = Util.Math.div(G.timer, tickTime) % 6
                    s.atlasInfo.x = frame
                    s.atlasInfo.y = 2
                else
                    s.atlasInfo.x = 0
                    s.atlasInfo.y = 1
                end
            end
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = 1,
        atlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = -1,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = -1,
        atlasY = 2,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            if not OnGroundCond() then
                s.atlasInfo.x = 1
                s.atlasInfo.y = 1
            else
                if (G.controller.keyboard.left.held or G.controller.keyboard.right.held) and not (G.controller.keyboard.left.held and G.controller.keyboard.right.held) then
                    local frame = Util.Math.div(G.timer, tickTime) % 6
                    s.atlasInfo.x = frame
                    s.atlasInfo.y = 2
                else
                    s.atlasInfo.x = 0
                    s.atlasInfo.y = 1
                end
            end
        end
    }):setParent(self)
    Sprite({
        atlasKey = "ArnaOverworldMask",
        drawOrder = 3997,
        offsetY = -1,
        atlasY = 3,
        updateFunc = function(s, dt)
            s.Xflipped = self.extra.facing == "left" and true or false
            local tickTime = 0.2
            local frame = Util.Math.div(G.timer, tickTime) % 7
            s.atlasInfo.x = frame
        end
    }):setParent(self)
    self.nid = "Player"
    return self
end
