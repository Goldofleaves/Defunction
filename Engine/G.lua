---@class Game: Object

--boilerplate
Game = Object:extend()

function Game:new()
    self.language = "english"
    self.localization = {}
    self.settings = {
        scalingFactor = 2,
        fullscreen = false,
        showGrid = true,
        sound = {
            master = 100,
            music = 100,
            sfx = 100
        }
    }
    self.currentID = 0
    self.I = {
        SPRITES = {},
        MOVEABLES = {},
    }
    self.debug = true
    self.timer = 0
    self.state = "Overworld"
    self.controller = {
        keyboard = {
            up = { keybind = {"w", "space", "up", {"lctrl", "lshift"}}, pressed = false, held = false, released = false },
            down = { keybind = {"s", "down"}, pressed = false, held = false, released = false },
            left = { keybind = {"a", "left"}, pressed = false, held = false, released = false },
            right = { keybind = { "d", "right" }, pressed = false, held = false, released = false },
            select = { keybind = { "z", "return" }, pressed = false, held = false, released = false },
        },
        mouse = {
            primary = { keybind = {1}, pressed = false, held = false, released = false }, -- primary (left)
            secondary = { keybind = {2}, pressed = false, held = false, released = false },     -- secondary (right)
            middle = { keybind = {3}, pressed = false, held = false, released = false },     -- middle Click
        }
    }
    self.mousePos = {
        x = 0, y = 0
    }
    self.dispOffset = {
        x = {
            base = 0
        },
        y = {
            base = 0
        }
    }
    self.flags = {}
    self.events = {}
    self.audio = {
        sfx = {},
        music = {},
        musicHandler = {}
    }
    G = self
end
function Game:getTotalOffset()
    local ret = {x = 0, y = 0}
    for k, v in pairs(self.dispOffset) do
        for kk, vv in pairs(v) do
            ret[k] = ret[k] + vv
        end
    end
    return ret
end
function Game:update(dt)

    -- Mouse
    self.mousePos = {
        x = love.mouse.getX() / G.settings.scalingFactor,
        y = love.mouse.getY() / G.settings.scalingFactor
    }

    -- Handling Events
    for k, v in ipairs(self.events) do
        local event = v
        event.curTime = event.curTime or 0
        if event.easeFunc then
            event.easeFunc(event.curTime / event.duration, event)
        end
        event.completed = event.completed == nil and false or event.completed
        if not event.completed and event.func then
            event.func(event)
            event.completed = true
        end
        event.curTime = event.curTime + dt
        if event.curTime > event.duration then
            if event.endFunc then event.endFunc(event) end
            self.events[k] = nil
        end
    end
    self.events = Util.Other.removeNils(self.events)

    -- Controller
    for k, v in pairs(self.controller.keyboard) do
        if (function ()
                for kk, vv in pairs(v.keybind) do
                    if type(vv) ~= "table" then
                        if love.keyboard.isDown(vv) then
                            return true
                        end
                    else
                        local bool = true
                        for kkk, vvv in pairs(vv) do
                            if not love.keyboard.isDown(vvv) then
                                bool = false
                            end
                        end
                        if bool then
                            return true
                        end
                    end
                end
                return false
            end)() then
            v.held = true
            if not v.pressTemp then
                v.pressed = true
                v.pressTemp = true
            else
                v.pressed = false
            end
        else
            if v.held then
                v.released = true
            else
                v.released = false
            end
            v.held = false
            v.pressed = false
            v.pressTemp = nil
        end
    end

    for k, v in pairs(self.controller.mouse) do
        if (function()
                for kk, vv in pairs(v.keybind) do
                    if type(vv) ~= "table" then
                        if love.mouse.isDown(vv) then
                            return true
                        end
                    else
                        local bool = true
                        for kkk, vvv in pairs(vv) do
                            if not love.mouse.isDown(vvv) then
                                bool = false
                            end
                        end
                        if bool then
                            return true
                        end
                    end
                end
                return false
            end)() then
            v.held = true
            if not v.pressTemp then
                v.pressed = true
                v.pressTemp = true
            else
                v.pressed = false
            end
        else
            if v.held then
                v.released = true
            else
                v.released = false
            end
            v.held = false
            v.pressed = false
            v.pressTemp = nil
        end
    end

    -- Sounds
    -- Sfx
    for i, v in ipairs(self.audio.sfx) do
        if not v.source:isPlaying() and not v.no_delete then
            v.source:release()
            self.audio.sfx[i] = nil
        end
    end
    self.audio.sfx = Util.Other.removeNils(self.audio.sfx)

    -- Music
    local targetBgm = self.audio.music[#self.audio.music]
    local previousBgm = self.audio.musicHandler.previousBgm
    for i, v in ipairs(self.audio.music) do
        if i < #self.audio.music and v.source:isPlaying() then
            v.source:pause()
        end
    end
    if targetBgm then
        if previousBgm and previousBgm ~= targetBgm and previousBgm == targetBgm.group then
            targetBgm.source:seek(previousBgm.source:tell('seconds'), 'seconds')
        end
        local source = targetBgm.source
        if not source:isPlaying() then source:play() end
        source:setVolume(targetBgm.volume * G.settings.sound.music / 100 * G.settings.sound.master / 100)
    end
    self.audio.musicHandler.previousBgm = targetBgm

    -- Collision handling + Updating Instances
    local function handleCollisionsK(K)
        local loop = true
        local limit = 0

        while loop do
            loop = false
            limit = limit + 1
            if limit > 20 then
                break
            end
            for i = 1, #self.I.MOVEABLES do
                if i ~= K then
                    local collision = self.I.MOVEABLES[i]:resolveCollision(self.I.MOVEABLES[K])
                    if collision then
                        loop = true
                    end
                end
            end
        end
    end
    --HandleCollisionsGeneral()
    for k, v in pairs(self.I.MOVEABLES) do
        if not v.properties.collisionCheck then
            handleCollisionsK(k)
            v:update(dt)
            handleCollisionsK(k)
            if self.state == "DestroyedObj" then
                self.state = self.oldState
                self.oldState = nil
            end
        end
    end
    for k, v in pairs(self.I.MOVEABLES) do
        if v.properties.collisionCheck then
            v:update(dt)
            if v.parent then handleCollisionsK(getPosById(v.parent)) end
            handleCollisionsK(k)
            if self.state == "DestroyedObj" then
                self.state = self.oldState
                self.oldState = nil
                break
            end
        end
    end
    for k, v in pairs(self.I.SPRITES) do
        v:update(dt)
        if self.state == "DestroyedObj" then
            self.state = self.oldState
            self.oldState = nil
            break
        end
    end
    for k, v in pairs(self.I.MOVEABLES) do
        if v.properties.collisionCheck then
            v.extra.ticked = {}
        end
    end
    self.timer = self.timer + dt
end

function Game:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(Util.Other.Hex("#4a3052"))
    love.graphics.rectangle("fill", 0, 0, Macros.baseResolution.w, Macros.baseResolution.h)
    love.graphics.setColor { r, g, b, a }
    if self.settings.showGrid then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(Util.Other.Hex("#a32858"))
        local amtx, amty = (Macros.baseResolution.w - Macros.tileSize * 2) / Macros.tileSize,
            (Macros.baseResolution.h - Macros.tileSize * 2) / Macros.tileSize
        for i = 1, amtx - 1 do
            love.graphics.rectangle("fill", (1 + i) * Macros.tileSize, Macros.tileSize, 1,
                Macros.baseResolution.h - Macros.tileSize * 2)
        end
        for i = 1, amty - 1 do
            love.graphics.rectangle("fill", Macros.tileSize, (1 + i) * Macros.tileSize,
                Macros.baseResolution.w - Macros.tileSize * 2, 1)
        end
        love.graphics.setColor { r, g, b, a }
    end
    local jTable = {}
    for _, v in pairs(self.I.MOVEABLES) do
        table.insert(jTable, v)
    end
    table.sort(jTable, function(a, b)
        return (a.drawOrder < b.drawOrder)
    end)
    for _, v in ipairs(jTable) do
        v:draw()
    end
    local iTable = {}
    for _, v in pairs(self.I.SPRITES) do
        table.insert(iTable, v)
    end
    table.sort(iTable, function(a, b)
        return (a.drawOrder < b.drawOrder)
    end)
    for _, v in ipairs(iTable) do
        v:draw()
    end
end

Game()
