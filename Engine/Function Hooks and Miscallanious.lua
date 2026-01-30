local printref = print
function print(...)
    local function log(l)
        local printtext = {}
        local function j(a, spaces, f, ins)
            spaces = spaces or 0
            ins = ins or 0
            if type(a) == "table" then
                table.insert(printtext, string.rep(" ", spaces) .. (f and f .. ": " or "") .. "Table:")
                spaces = spaces + 1
                for k, v in pairs(a) do
                    if type(v) == "table" then
                        j(v, spaces + 1, k, ins + 1)
                    else
                        table.insert(printtext, string.rep(" ", spaces + 1) .. tostring(k) .. ": " .. tostring(v))
                    end
                end
            else
                table.insert(printtext, string.rep(" ", spaces) .. tostring(a))
            end
        end
        j(l)
        for k, v in pairs(printtext) do
            printref(v)
        end
    end
    for k, v in pairs({ ... }) do
        log(v)
    end
end

local utf8 = require "utf8"

local function error_printer(msg, layer)
    print((debug.traceback("ERROR: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
    local function hex(hex)
        if string.sub(hex, 1, 1) == "#" then
            hex = string.sub(hex, 2, string.len(hex))
        end
        if #hex <= 6 then hex = hex .. "FF" end
        local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
        local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
        return color
    end

    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end

    love.graphics.reset()

    love.graphics.setColor(1, 1, 1)

    local trace = debug.traceback()

    love.graphics.origin()

    local sanitizedmsg = {}
    for char in msg:gmatch(utf8.charpattern) do
        table.insert(sanitizedmsg, char)
    end
    local sanitizedmessage = table.concat(sanitizedmsg)

    local err = {}

    table.insert(err, "THE EARTH'S CORE HAS BLOWN UP")
    table.insert(err, "ERROR!\n")
    table.insert(err, sanitizedmessage)

    if #sanitizedmessage ~= #msg then
        table.insert(err, "Invalid UTF-8 string in error message.")
    end

    table.insert(err, "\n")

    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Stack Traceback:\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = p:gsub("\t", "")
    p = p:gsub("%[string \"(.-)\"%]", "%1")
    local function draw()
        if not love.graphics.isActive() then return end
        pos = pos or 40
        love.graphics.setDefaultFilter("nearest", "nearest", 1)
        J = J or love.graphics.newImage("Assets/Images/ErrorHandler.png")
        X = X or love.graphics.newFont("Assets/Fonts/monogram-extended.ttf", 16)
        love.graphics.clear(hex("#8465ec"))
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 40 - 22, 40 - 22, love.graphics.getWidth() - 20 - 16,
            love.graphics.getHeight() - 20 - 16)
        love.graphics.setColor(hex("#a32858"))
        love.graphics.rectangle("fill", 40 - 20, 40 - 20, love.graphics.getWidth() - 20 - 20,
            love.graphics.getHeight() - 20 - 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(J, 20, 20, 0, 2, 2)
        love.graphics.setColor(hex("#4a3052"))
        love.graphics.printf(p, X, 40, pos + 4,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 - 2, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 + 2, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 - 2, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 + 2, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40, pos - 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.setColor(hex("#8b9bb4"))
        love.graphics.printf(p, X, 40, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(p, X, 40, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.present()
    end

    local fullErrorText = p
    local function copyToClipboard()
        if not love.system then return end
        love.system.setClipboardText(fullErrorText)
        p = p .. "\nCopied to clipboard!"
    end

    if love.system then
        p = p .. "\n\nPress Ctrl+C or tap to copy this error"
        p = p .. "\nScroll the mouse to read full traceback"
    end

    return function()
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "escape" then
                return 1
            elseif e == "wheelmoved" then
                pos = pos + b * 4
                pos = math.min(pos, 40)
            elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
                copyToClipboard()
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = { "OK", "Cancel" }
                if love.system then
                    buttons[3] = "Copy to clipboard"
                end
                local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)
                if pressed == 1 then
                    return 1
                elseif pressed == 3 then
                    copyToClipboard()
                end
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end
