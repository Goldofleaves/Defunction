DeathBlock = Moveable:extend()
function DeathBlock:new(args)
    args = args or {}
    args.properties = args.properties or {}
    args.properties.collisionCheck = true
    args.properties.defeat = true
    args.x = args.x or 200
    args.y = args.y or 180
    args.w = args.w or 20
    args.h = args.h or 20
    args.strength = 0
    args.updateFunc = function (s, dt)
        if collisionContainsProperty(s.extra.ticked, "player") then
            local p = getObjectByNid("player") or { T = {x = 1, y = 1}, remove = function (a, b) end}
            local xx, yy = p.T.x, p.T.y
            p:remove(true)
            G.flags.deaths = G.flags.deaths + 1
            Sprite {
                atlasKey = "ArnaDead",
                x = xx,
                y = yy,
                updateFunc = function(s, dt)
                    s.extra.v = s.extra.v or {
                        x = math.random(1, -1) * 2,
                        y = -150,
                        g = 5,
                        counter = 0
                    }
                    s.extra.v.y = s.extra.v.y + s.extra.v.g/0.015 * dt
                    s.T.x = s.T.x + s.extra.v.x * dt
                    s.T.y = s.T.y + s.extra.v.y * dt
                    s.extra.v.counter = s.extra.v.counter + dt
                    if s.extra.v.counter > 5 then
                        s:remove()
                    end
                end,
                drawOrder = 4003,
            }
            Util.Event.delayFunc(1, function ()
                local a = Sprite {
                    drawFunc = function(s)
                        if s then
                        local r, g, b, a = love.graphics.getColor()
                        love.graphics.setColor(Macros.colors.lighterBlack)
                        love.graphics.rectangle("fill", Macros.tileSize, Macros.tileSize + s.extra.y, Macros.roomSize.x, s.extra.h)
                        love.graphics.setColor { r, g, b, a }
                        end
                    end,
                    updateFunc = function(s, dt)
                        s.extra.per = s.extra.cur/s.extra.dur
                        local per = s.extra.per
                        local per2, second = (4 * per) % 1, per > 0.75
                        s.extra.cur = s.extra.cur + dt
                        s.extra.y = Util.EaseSplines.createEase(Macros.roomSize.y, 0, nil, { preset = "eioc" })(per)
                        s.extra.h = Macros.roomSize.y - s.extra.y
                        if second then
                            s.extra.h = math.min(Util.EaseSplines.createEase(second and Macros.roomSize.y or 0,
                            second and 0 or Macros.roomSize.y, nil, { preset = second and "eoc" or "eioc" , param = 2})(per2),
                            Macros.roomSize.y - s.extra.y)
                        end
                    end,
                    drawOrder = 1e10 - 1,
                    extra = {
                        h = 0,
                        y = Macros.roomSize.y,
                        dur = 2.5,
                        cur = 0,
                        per = 0
                    }
                }
                Sprite {
                    drawFunc = function(s)
                        local function stencilF()
                            a.drawFunc(a)
                        end
                        love.graphics.stencil(stencilF, "replace", 1)
                        love.graphics.setStencilTest("greater", 0)
                        if s.extra.advTextObjs then
                            local totalWidth = (1 + #s.extra.advTextObjs) *
                            s.extra.advTextObjs[1].contents[1]:getHeight()
                            for k, v in ipairs(s.extra.advTextObjs) do
                                v:lerpDraw(20,
                                    20 + Macros.roomSize.y / 2 - totalWidth / 2 + k * v.contents[1]:getHeight(),
                                    Macros.roomSize.x, 1 / 2)
                            end
                        end
                        love.graphics.setStencilTest()
                    end,
                    updateFunc = function(s, dt)
                        if s.extra.advTextObjs then
                            for k, v in ipairs(s.extra.advTextObjs) do
                                v:update()
                            end
                        end
                        if a.extra.per > 0.7 and not s.temp then
                            Player(G.roomInfo.spawnPoint)
                            s.temp = true
                        end
                        if a.extra.per > 1 then
                            a:remove()
                            s:remove()
                        end
                    end,
                    drawOrder = 1e10,
                    extra = {
                        advTextObjs = (function()
                            local retTable = {}
                            for k, v in ipairs(G.localization.labels.death) do
                                table.insert(retTable, AdvancedText(v, { G.flags.deaths }))
                            end
                            return retTable
                        end)()
                    }
                }
            end)
        end
    end
    args.drawFunc = function(s)
        if G.debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.hex("#FF9900"))
            love.graphics.rectangle("fill", s.T.x + G:getTotalOffset().x, s.T.y + G:getTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    return Moveable.new(self, args)
end
