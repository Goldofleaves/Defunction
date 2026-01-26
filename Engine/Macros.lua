local function hex(hex)
    if string.sub(hex, 1, 1) == "#" then
        hex = string.sub(hex, 2, string.len(hex))
    end
    if #hex <= 6 then hex = hex .. "FF" end
    local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
    return color
end

Macros = {
    fileSuffix = ".def",
    tileSize = 20,
    baseResolution = {w = 640, h = 360},
    gravity = 4,
    jumpVelocity = 140,
    coyoteTime = 0.35,
    maxHold = 0.55,
    terminalVelocity = 250,
    fonts = {
        base = love.graphics.newFont("Assets/Fonts/monogram-extended.ttf", 16),
        italic = love.graphics.newFont("Assets/Fonts/monogram-extended-italic.ttf", 16),
    },
    roomSize = {
        x = 20 * 30,
        y = 20 * 16
    },
    colors = {
        black = hex("#4a3052"),
        lighterBlack = hex("#68386c"),
        white = { 1, 1, 1, 1 },
        transparent = { 0, 0, 0, 0 },
        red = hex("#ff0044"),
        yellow = hex("#feae34"),
        green = hex("#63c74d"),
        blue = hex("#2ce8f5"),
        purple = hex("#8465ec"),
        grey = hex("#8b9bb4"),
    }
}
