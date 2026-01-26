---@class BRang: Moveable

local function createAfterImage(x, y, f)
    Sprite({
        atlasKey = "Boomerang",
        drawOrder = 50,
        atlasY = 2,
        atlasX = f,
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
        return next(a.extra.ticked or {}) and not collisionContainsId(a.extra.ticked, self.id) and
            not collisionContainsProperty(a.extra.ticked, "noCollision") and
            not collisionContainsProperty(a.extra.ticked, "collisionCheck") and
            (collisionContainsExtra(a.extra.ticked, "facing") and collisionContainsId(getAllCollisionextra(a.extra.ticked, "facing"), dir) or true)
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
            love.graphics.setColor(Util.Other.hex("#FF00B3"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    args.updateFunc = function(self, dt)
        if not getObjectByNid("player") then
            self:remove(true)
            if G.flags.boomerangExists then
                Sprite {
                    atlasKey = "BoomyDead",
                    x = self.T.x,
                    y = self.T.y,
                    updateFunc = function(s, dt)
                        s.extra.v = s.extra.v or {
                            x = math.random(1, -1) * 2,
                            y = -150,
                            g = 5,
                            counter = 0
                        }
                        s.extra.v.y = s.extra.v.y + s.extra.v.g / 0.015 * dt
                        s.T.x = s.T.x + s.extra.v.x * dt
                        s.T.y = s.T.y + s.extra.v.y * dt
                        s.extra.v.counter = s.extra.v.counter + dt
                        if s.extra.v.counter > 5 then
                            s:remove()
                        end
                    end,
                    drawOrder = 101,
                }
            end
            G.flags.boomerangExists = false
        end
        self.extra.velD = self.extra.velD or 0
        self.extra.TG = self.extra.TG or 0
        self.extra.velD = self.extra.velD + 1 / 12
        self.extra.clockInit = self.extra.clockInit + dt
        self.extra.lerpD = self.extra.lerpD or 1
        if self.extra.TG <= 0 then
            for k, v in pairs(self.extra.checks) do
                local opposite = {
                    left = "right",
                    right = "left",
                    down = "up",
                    up = "down"
                }
                local funcs = {
                    left = function (a)
                        local bump = getObjectById(getAllCollisionPropertyIds(self.extra.checks.left.extra.ticked,
                        "RicoChet")[1])
                        if a.V.x.base < 0 and bump and bump.T.x + bump.T.w > a.T.x and Util.Math.percisionCheck(bump.T.x + bump.T.w, a.T.x, math.abs(a.V.x.base) * DELTATIME * 1.5 + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Util.Audio.playSfx("Bump1", 0.65, math.random()*0.5 + 0.75)
                            Util.Event.screenShake(2, 1/4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                atlasY = 2,
                                x = bump.T.x + bump.T.w,
                                y = a.T.y,
                                updateFunc = function(s, dt)
                                    s.extra.timer = s.extra.timer or 0
                                    s.extra.timer = s.extra.timer + dt
                                    if s.extra.timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local tickTime = 0.075
                                    local frame = Util.Math.div(s.extra.timer, tickTime) % 4
                                    s.atlasInfo.x = frame
                                end
                            })
                        end
                    end,
                    right = function(a)
                        local bump = getObjectById(getAllCollisionPropertyIds(self.extra.checks.right.extra.ticked,
                        "RicoChet")[1])
                        if a.V.x.base > 0 and bump and bump.T.x < a.T.x + a.T.w and Util.Math.percisionCheck(bump.T.x, a.T.x + a.T.w, math.abs(a.V.x.base) * DELTATIME * 1.5 + 10) then
                            a.V.x.base = a.V.x.base * -1
                            Util.Audio.playSfx("Bump1", 0.65, math.random() * 0.5 + 0.75)
                            Util.Event.screenShake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                atlasY = 0,
                                x = bump.T.x - 20,
                                y = a.T.y,
                                updateFunc = function(s, dt)
                                    s.extra.timer = s.extra.timer or 0
                                    s.extra.timer = s.extra.timer + dt
                                    if s.extra.timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local tickTime = 0.075
                                    local frame = Util.Math.div(s.extra.timer, tickTime) % 4
                                    s.atlasInfo.x = frame
                                end
                            })
                        end
                    end,
                    up = function(a)
                        local bump = getObjectById(getAllCollisionPropertyIds(self.extra.checks.up.extra.ticked,
                        "RicoChet")[1])
                        if a.V.y.base < 0 and bump and bump.T.y + bump.T.h > a.T.y and Util.Math.percisionCheck(bump.T.y + bump.T.h, a.T.y, math.abs(a.V.y.base) * DELTATIME * 1.5 + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Util.Audio.playSfx("Bump1", 0.65, math.random() * 0.5 + 0.75)
                            Util.Event.screenShake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                atlasY = 1,
                                x = a.T.x,
                                y = bump.T.y + bump.T.h ,
                                updateFunc = function(s, dt)
                                    s.extra.timer = s.extra.timer or 0
                                    s.extra.timer = s.extra.timer + dt
                                    if s.extra.timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local tickTime = 0.075
                                    local frame = Util.Math.div(s.extra.timer, tickTime) % 4
                                    s.atlasInfo.x = frame
                                end
                            })
                        end
                    end,
                    down = function(a)
                        local bump = getObjectById(getAllCollisionPropertyIds(self.extra.checks.down.extra.ticked, "RicoChet")[1])
                        if a.V.y.base > 0 and bump and bump.T.y < a.T.y + a.T.h and Util.Math.percisionCheck(bump.T.y, a.T.y + a.T.h, math.abs(a.V.y.base) * DELTATIME * 1.5 + 10) then
                            a.V.y.base = a.V.y.base * -1
                            Util.Audio.playSfx("Bump1", 0.65, math.random() * 0.5 + 0.75)
                            Util.Event.screenShake(2, 1 / 4)
                            Sprite({
                                atlasKey = "Bump",
                                drawOrder = 101,
                                x = a.T.x,
                                y = bump.T.y - 20,
                                atlasY = 3,
                                updateFunc = function(s, dt)
                                    s.extra.timer = s.extra.timer or 0
                                    s.extra.timer = s.extra.timer + dt
                                    if s.extra.timer > 4 * 0.075 then
                                        s:remove()
                                    end
                                    local tickTime = 0.075
                                    local frame = Util.Math.div(s.extra.timer, tickTime) % 4
                                    s.atlasInfo.x = frame
                                end
                            })
                        end
                    end,
                }
                if collidedFunc(v, opposite[k]) then
                    if collisionContainsProperty(v.extra.ticked, "RicoChet") then
                        funcs[k](self)
                        self.extra.TG = 0.05
                    elseif not collisionContainsProperty(v.extra.ticked, "player") then
                        if not self.extra.done then
                            Util.Event.screenShake(3 / 4, 1 / 8)
                            Util.Audio.playSfx("BumpWeak1", 1, math.random()*0.5 + 0.75)
                        end
                        self.extra.done = true
                        self.V.y.base = 0
                        self.V.x.base = 0
                    end
                end
            end
        end
        self.extra.TG = self.extra.TG - dt
        if self.extra.clockInit > 5 then
            self.extra.done = true
        end
        if self.extra.done then
            self.V.x.base = 0
            self.V.y.base = 0
            self.extra.lerpD = Util.Math.lerpDt(self.extra.lerpD, 0, 0.15)
            self.TMod.x.base = Util.Math.lerpDt(self.TMod.x.base, getObjectByNid("player") and getObjectByNid("player").T.x or 0, self.extra.lerpD)
            self.TMod.y.base = Util.Math.lerpDt(self.TMod.y.base, (getObjectByNid("player") and getObjectByNid("player").T.y or 0) + 10, self.extra.lerpD)
            if Util.Math.percisionCheck(self.T.x, getObjectByNid("player") and getObjectByNid("player").T.x or 0, 2) and Util.Math.percisionCheck(self.T.y, (getObjectByNid("player") and getObjectByNid("player").T.y or 0) + 10, 2) then
                self:remove()
                G.flags.boomerangExists = nil
            end
        end
        local tick = 1/3
        local k, k_1 = self.extra.clockInit % tick, (self.extra.clockInit - dt) % tick
        if k <= k_1 then
            createAfterImage(self.TMod.x.base + self.V.x.base * dt, self.TMod.y.base + self.V.y.base * dt, self.extra.A.atlasInfo.x)
        end
    end
    Moveable.new(self, args)
    self.extra.A = Sprite({
        atlasKey = "Boomerang",
        drawOrder = 100,
        atlasY = 0,
        x = self.TMod.x.base,
        y = self.TMod.y.base,
        updateFunc = function(s, dt)
            local tickTime = 0.15
            local frame = Util.Math.div(G.timer, tickTime) % 4
            s.atlasInfo.x = frame
            s.atlasInfo.y = self.extra.done and 1 or 0
            if not G.flags.boomerangExists then
                s:remove()
            end
        end
    })
    self.extra.A:setParent(self)
    self.extra.checks = {}
    local c = self.extra.checks
    c.up = Moveable {
        properties = {
            collisionCheck = true,
        },
        strength = -1000,
        w = 16,
        h = 1,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.hex("#2F00FF"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.up.TMod.x.offset = 2
    c.up.TMod.y.offset = -1
    c.down = Moveable {
        properties = {
            collisionCheck = true,
        },
        w = 16,
        h = 1,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.hex("#F700FF"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.down.TMod.x.offset = 2
    c.down.TMod.y.offset = 20
    c.left = Moveable {
        properties = {
            collisionCheck = true,
        },
        w = 1,
        h = 16,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.hex("#FF0000"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.left.TMod.y.offset = 2
    c.left.TMod.x.offset = -1
    c.right = Moveable {
        properties = {
            collisionCheck = true,
        },
        w = 1,
        h = 16,
        strength = -1000,
        drawFunc = function(s)
            if G.debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.hex("#00FF22"))
                --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    c.right.TMod.y.offset = 2
    c.right.TMod.x.offset = 20
    for k, v in pairs(c) do
        v:setParent(self)
    end
    return self
end
