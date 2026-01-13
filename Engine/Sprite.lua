--- Sprite objects.

Atlases = {}
function RegisterAtlasSimple(key, fpos, px, py)
    Atlases[key] = {}
    local atli = Atlases[key]
    atli.imageData = love.image.newImageData(fpos)
    atli.image = love.graphics.newImage(atli.imageData)
    local spritewidth, spriteheight = atli.image:getWidth(), atli.image:getHeight()
    local Xsegments, Ysegments = spritewidth / px, spriteheight / py
    atli.key = key
    atli.filePos = fpos
    atli.splicedImages = {}
    atli.dimentions = { w = spritewidth, h = spriteheight }
    atli.singleDimention = { w = px, h = py }
    atli.size = { x = Xsegments, y = Ysegments }
    for i = 0, Xsegments - 1 do
        atli.splicedImages[i] = atli.splicedImages[i] or {}
        for j = 0, Ysegments - 1 do
            atli.splicedImages[i][j] = love.graphics.newQuad(math.floor(i * px), math.floor(j * py), math.floor(px),
                math.floor(py), math.floor(spritewidth), math.floor(spriteheight))
        end
    end
end
---@class Sprite: Object
Sprite = Object:extend()

function Sprite:new(args)
    args = args or {}
    self.nid = args.nid
    self.pos = {
        x = args.x or 0,
        y = args.y or 0
    }
    self.transparency = args.transparency or 1
    self.atliInfo = {
        key = args.atliKey,
        x = args.atliX or 0,
        y = args.atliY or 0
    }
    self.func = args.func or function(a, b) return end
    self.drawOrder = args.drawOrder or 1
    self.drawTiled = args.drawTiled == nil and false or args.drawTiled
    self.extra = args.extra or {}
    self.mask = {
        shouldApply = args.maskShouldApply == nil and false or args.maskShouldApply,
        imageFpos = args.maskImageFpos,
    }
    self.Properties = args.Properties or {}
    table.insert(G.I.SPRITES, self)
end

function Sprite:draw()
    local draw_func = function (kx, ky)
        local x = self.pos.x + kx
        local y = self.pos.y + ky
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor { r, g, b, a * self.transparency }
        if self.mask.shouldApply then
            self.extra = self.extra or {}
            self.extra.mask = self.extra.mask or love.graphics.newImage(self.mask.imageFpos)
            self.extra.mask_shader = self.extra.mask_shader or love.graphics.newShader [[
                   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
                         // a discarded pixel wont be applied as the stencil.
                         discard;
                      }
                      return vec4(1.0);
                   }
                ]]
            local function myStencilFunction()
                love.graphics.setShader(self.extra.mask_shader)
                love.graphics.draw(self.extra.mask, 0, 0)
                love.graphics.setShader()
            end
            love.graphics.stencil(myStencilFunction, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
        end
        if not self.drawTiled then
            love.graphics.draw(
                Atlases[self.atliInfo.key].image, Atlases[self.atliInfo.key].splicedImages[self.atliInfo.x][self.atliInfo.y],
                x, y,
                0, 1, 1
            )
        else
            local moduloX = x % Atlases[self.atliInfo.key].singleDimention.w
            local moduloY = y % Atlases[self.atliInfo.key].singleDimention.h
            local xSegments = math.ceil(Macros.BaseResolution.w / Atlases[self.atliInfo.key].singleDimention.w)
            local ySegments = math.ceil(Macros.BaseResolution.h / Atlases[self.atliInfo.key].singleDimention.h)
            for i = -1, xSegments + 1 do
                for j = -1, ySegments + 1 do
                    love.graphics.draw(
                        Atlases[self.atliInfo.key].image,
                        Atlases[self.atliInfo.key].splicedImages[self.atliInfo.x][self.atliInfo.y],
                        moduloX + i * Atlases[self.atliInfo.key].singleDimention.w,
                        moduloY + j * Atlases[self.atliInfo.key].singleDimention.h,
                        0, 1, 1
                    )
                end
            end
        end
        if self.mask.shouldApply then
            love.graphics.setStencilTest()
        end
        love.graphics.setColor { r, g, b, a }
    end
    if self.Properties.Outline then
        local r, g, b, a = love.graphics.getColor()
        local function myStencilFunction()
            draw_func(1, 0)
            draw_func(-1, 0)
            draw_func(0, 1)
            draw_func(0, -1)
        end
        love.graphics.stencil(myStencilFunction, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(self.Properties.OutlineColor)
        love.graphics.rectangle("fill", 0, 0, Macros.BaseResolution.w, Macros.BaseResolution.h)
        love.graphics.setColor { r, g, b, a }
        love.graphics.setStencilTest()
    end
    draw_func(0, 0)
end

function Sprite:update(dt)
    self.func(self, dt)
end
