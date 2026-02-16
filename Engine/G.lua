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
        },
        keybinds = {
            keyboard = {
                up = { "w", "space", "up", { "lctrl", "lshift" } },
                down = { "s", "down" },
                left = { "a", "left" },
                right = { "d", "right" },
                select = { "z", "return" },
                pause = { "escape" }
            },
            mouse = {
                primary = {1},
                secondary = {2},
                middle = {3}
            }
        }
    }
    self.currentID = 0
    self.I = {
        SPRITES = {},
        MOVEABLES = {},
    }
    self.debug = true
    self.timer = 0
    self.subTimer = 0
    self.state = "TitleScreen"
    self.controller = {
        keyboard = {
            up = { pressed = false, held = false, released = false },
            down = { pressed = false, held = false, released = false },
            left = { pressed = false, held = false, released = false },
            right = { pressed = false, held = false, released = false },
            select = { pressed = false, held = false, released = false },
            pause = { pressed = false, held = false, released = false },
        },
        mouse = {
            primary = { pressed = false, held = false, released = false },       -- primary (left)
            secondary = { pressed = false, held = false, released = false },     -- secondary (right)
            middle = { pressed = false, held = false, released = false },        -- middle Click
        }
    }
    self.mousePos = {
        x = 0, y = 0
    }
    self.dispOffset = {
        x = {
            base = 0,
            room = 0
        },
        y = {
            base = 0,
            room = 0
        }
    }
    self.flags = {
        deaths = 0
    }
    self.roomInfo = {
        spawnPoint = {
            x = 140, y = 140
        }
    }
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
                for kk, vv in pairs(G.settings.keybinds.keyboard[k]) do
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
                for kk, vv in pairs(G.settings.keybinds.mouse[k]) do
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
    local function updateMoveable(k)
        handleCollisionsK(k)
        self.I.MOVEABLES[k]:update(dt)
        handleCollisionsK(k)
    end
    local function updateAllNonCheckMoveablesRecursively(filter)
        filter = filter or {}
        for k, v in pairs(self.I.MOVEABLES) do
            if not v.properties.collisionCheck and not filter[k] then
                filter[k] = true
                updateMoveable(k)
                updateAllNonCheckMoveablesRecursively(filter)
                break
            end
        end
        return
    end
    local function updateAllCheckMoveablesRecursively(filter)
        filter = filter or {}
        for k, v in pairs(self.I.MOVEABLES) do
            if v.properties.collisionCheck and not filter[k] then
                filter[k] = true
                if v.parent then handleCollisionsK(getPosById(v.parent)) end
                updateMoveable(k)
                updateAllCheckMoveablesRecursively(filter)
                break
            end
        end
        return
    end
    local function updateAllSpritesRecursively(filter)
        filter = filter or {}
        for k, v in pairs(self.I.SPRITES) do
            if not filter[k] then
                filter[k] = true
                v:update(dt)
                updateAllSpritesRecursively(filter)
                break
            end
        end
        return
    end
    if self.state ~= "Paused" then
        updateAllNonCheckMoveablesRecursively()
        updateAllCheckMoveablesRecursively()
        updateAllSpritesRecursively()
        for k, v in pairs(self.I.MOVEABLES) do
            if v.properties.collisionCheck then
                v.extra.ticked = {}
            end
        end
        self.subTimer = 0
        self.timer = self.timer + dt
        self.pauseVars = nil
    else
        self.subTimer = self.subTimer + dt
        self.pauseVars = self.pauseVars or {
            advTextObjs = (function()
                local retTable = {}
                for k, v in ipairs(G.localization.labels.pause) do
                    if k - 1 ~= 0 then
                        table.insert(retTable, AdvancedText(v))
                    else
                        table.insert(retTable, AdvancedText(G.localization.labels.pauseSelected[k]))
                    end
                end
                return retTable
            end)(),
            selectedOption = 0,
            r = 0
        }
        for k, v in ipairs(self.pauseVars.advTextObjs) do
            v:update(dt)
        end
        if self.controller.keyboard.up.pressed then
            self.pauseVars.selectedOption = (self.pauseVars.selectedOption - 1) % 3
            self.pauseVars.advTextObjs = {}
            for k, v in ipairs(G.localization.labels.pause) do
                if k - 1 ~= self.pauseVars.selectedOption then
                    table.insert(self.pauseVars.advTextObjs, AdvancedText(v))
                else
                    table.insert(self.pauseVars.advTextObjs, AdvancedText(G.localization.labels.pauseSelected[k]))
                end
            end
            Util.Audio.playSfx("MenuSwitchSubjects", 0.6, math.random() * 0.5 + 0.75)
            self.pauseVars.r = 1.5
        end
        if self.controller.keyboard.down.pressed then
            self.pauseVars.selectedOption = (self.pauseVars.selectedOption + 1) % 3
            self.pauseVars.advTextObjs = {}
            for k, v in ipairs(G.localization.labels.pause) do
                if k - 1 ~= self.pauseVars.selectedOption then
                    table.insert(self.pauseVars.advTextObjs, AdvancedText(v))
                else
                    table.insert(self.pauseVars.advTextObjs, AdvancedText(G.localization.labels.pauseSelected[k]))
                end
            end
            Util.Audio.playSfx("MenuSwitchSubjects", 0.6, math.random() * 0.5 + 0.75)
            self.pauseVars.r = 1.5
        end
        if self.controller.keyboard.select.pressed then
            local funcs = {
                [0] = function()
                    self.state = "Overworld"
                end,
                [1] = function()

                end,
                [2] = function ()
                    local function LoadFirstRoomTemp()
                        Wall()
                        RicoChet({ x = 380, w = 80, h = 20 })
                        Box()
                        OneWayPlatform({ x = 180, y = 60, facing = "up" })
                        OneWayPlatform({ x = 180, facing = "up" })
                        OneWayPlatform({ x = 220, y = 100, facing = "down" })
                        OneWayPlatform({ x = 240, h = 40, y = 140, facing = "right" })
                        --OneWayPlatform({ x = 420, h = 40, y = 160, facing = "left" })
                        Wall({ x = 220, y = 180, w = 160 })
                        RicoChet({ x = 500, y = 100 })
                        RicoChet({ x = 400, y = 60, h = 20, w = 80 })
                        Player()
                        DeathBlock()
                    end
                    Util.Other.removeAllObjects()
                    self.state = "TitleScreen"
                    Sprite({
                        atlasKey = "Border",
                        nid = "Border",
                        drawOrder = 9000
                    })
                    Sprite({
                        atlasKey = "BorderPattern",
                        nid = "BorderPattern",
                        drawOrder = 9001,
                        updateFunc = function(self, dt)
                            self.T.x = self.T.x + 25 * dt
                            self.T.y = self.T.y + 25 * dt
                            self.T.x = self.T.x % Macros.tileSize
                            self.T.y = self.T.y % Macros.tileSize
                        end,
                        drawTiled = true,
                        MaskShouldApply = true,
                        MaskImageFpos = "Assets/Images/BorderMask.png"
                    })
                    Sprite({
                        atlasKey = "TitleBase",
                        nid = "TitleScr",
                        drawOrder = 1,
                        extra = {
                            SelectedOption = 1,
                            Funcs = {
                                function(s, dt)
                                    love.event.push("quit")
                                end,
                                function(s, dt)
                                    return
                                end,
                                function(s, dt)
                                    s:remove()
                                    local tb = getObjectByNid("TitleButtons") or { remove = function() end }
                                    tb:remove()
                                    G.state = "Overworld"
                                    LoadFirstRoomTemp()
                                end
                            }
                        },
                        updateFunc = function(s, dt)
                            if G.controller.keyboard.up.pressed then
                                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption - 1)
                                local T = getObjectByNid("TitleButtons") or { extra = { Random = 1 } }
                                Util.Audio.playSfx("MenuSwitchSubjects", 0.3, math.random() * 0.5 + 0.75)
                                T.extra.Random = 1
                            end
                            if G.controller.keyboard.down.pressed then
                                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption + 1)
                                local T = getObjectByNid("TitleButtons") or { extra = { Random = 1 } }
                                Util.Audio.playSfx("MenuSwitchSubjects", 0.3, math.random() * 0.5 + 0.75)
                                T.extra.Random = 1
                            end
                            if G.controller.keyboard.select.pressed then
                                s.extra.Funcs[s.extra.SelectedOption](s, dt)
                            end
                            local tickTime = 0.5
                            local frame = Util.Math.div(G.timer, tickTime) % 3
                            s.atlasInfo.y = frame
                        end
                    })
                    Sprite({
                        atlasKey = "TitleSelection",
                        nid = "TitleButtons",
                        drawOrder = 2,
                        x = 359,
                        y = 228,
                        extra = {
                            Random = 0
                        },
                        updateFunc = function(s, dt)
                            local T = getObjectByNid("TitleScr") or { extra = { SelectedOption = 1 } }
                            s.T.x = 359 + (math.random() * 2 - 1) * s.extra.Random
                            s.T.y = 228 + (T.extra.SelectedOption - 1) * 11 + (math.random() * 2 - 1) * s.extra.Random
                            s.atlasInfo.y = T.extra.SelectedOption - 1
                            s.extra.Random = Util.Math.clamp(0, 1, s.extra.Random - 1 / 4)
                        end
                    })
                end
            }
            funcs[self.pauseVars.selectedOption]()
        end
        self.pauseVars.r = self.pauseVars.r - dt * 10
        self.pauseVars.r = math.max(self.pauseVars.r, 0)
    end

    -- Pause Screen
    if self.controller.keyboard.pause.pressed then
        if self.state == "Overworld" then
            self.state = "Paused"
        end
    end
end

function Game:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(Util.Other.hex("#4a3052"))
    love.graphics.rectangle("fill", 0, 0, Macros.baseResolution.w, Macros.baseResolution.h)
    love.graphics.setColor { r, g, b, a }
    if self.settings.showGrid then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(Util.Other.hex("#a32858"))
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
    if self.state == "Paused" then
        if self.pauseVars then
            local r, g, b, a = love.graphics.getColor()
            local s = self
            local color = Util.Other.hex("#181425")
            love.graphics.setColor(color[1], color[2], color[3], 1/2)
            love.graphics.rectangle("fill", 20, 20, Macros.baseResolution.w - 40, Macros.baseResolution.h - 40)
            local totalWidth = (1 + #s.pauseVars.advTextObjs) * s.pauseVars.advTextObjs[1].contents[1]:getHeight()
            for k, v in ipairs(s.pauseVars.advTextObjs) do
                v:lerpDraw(20 + self.pauseVars.r * 2 * (math.random() - 0.5) + (k-1 == s.pauseVars.selectedOption and 1 * math.sin(1.5 * (G.timer + G.subTimer)) or 0),
                    20 + Macros.roomSize.y / 2 - totalWidth / 2 + k * v.contents[1]:getHeight() +
                    self.pauseVars.r * 2 * (math.random() - 0.5) +
                    (k - 1 == s.pauseVars.selectedOption and 2 * math.sin(3 * (G.timer + G.subTimer)) or 0),
                    Macros.roomSize.x, 1 / 2)
            end
            love.graphics.setColor { r, g, b, a }
        end
    end
end

Game()
