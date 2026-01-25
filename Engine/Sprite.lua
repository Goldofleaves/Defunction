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
    self.Id = G.CurrentID
    self.Nid = args.Nid
    G.CurrentID = G.CurrentID + 1
    self.T = {
        x = args.x or 0,
        y = args.y or 0,
    }
    self.Xflipped = false
    self.transparency = args.transparency or 1
    self.AtliInfo = {
        key = args.atlasKey,
        x = args.AtlasX or 0,
        y = args.AtlasY or 0
    }
    self.updateFunc = args.updateFunc or function(s, dt) return end
    self.drawOrder = args.drawOrder or 1
    self.DrawTiled = args.DrawTiled == nil and false or args.DrawTiled
    self.extra = args.extra or {}
    self.drawFunc = args.drawFunc or function (s) return end
    self.Mask = {
        ShouldApply = args.MaskShouldApply == nil and false or args.MaskShouldApply,
        ImageFpos = args.MaskImageFpos,
    }
    self.properties = args.properties or {}
    table.insert(G.I.SPRITES, self)
    self.Offset = {
        x = args.OffsetX or 0,
        y = args.OffsetY or 0
    }
    return self
end

function Sprite:draw()
    local dir = self.Xflipped and -1 or 1
    local XFlpiiedOffset = self.Xflipped and Atlases[self.AtliInfo.key].singleDimention.w or 0
    local draw_func = function (kx, ky)
        local x = self.T.x + kx
        local y = self.T.y + ky
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor { r, g, b, a * self.transparency }
        if self.Mask.ShouldApply then
            self.extra = self.extra or {}
            self.extra.mask = self.extra.mask or love.graphics.newImage(self.Mask.ImageFpos)
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
        if not self.DrawTiled then
            love.graphics.draw(
                Atlases[self.AtliInfo.key].image, Atlases[self.AtliInfo.key].splicedImages[self.AtliInfo.x][self.AtliInfo.y],
                x + XFlpiiedOffset, y,
                0, dir, 1
            )
        else
            local moduloX = x % Atlases[self.AtliInfo.key].singleDimention.w
            local moduloY = y % Atlases[self.AtliInfo.key].singleDimention.h
            local xSegments = math.ceil(Macros.BaseResolution.w / Atlases[self.AtliInfo.key].singleDimention.w)
            local ySegments = math.ceil(Macros.BaseResolution.h / Atlases[self.AtliInfo.key].singleDimention.h)
            for i = -1, xSegments + 1 do
                for j = -1, ySegments + 1 do
                    love.graphics.draw(
                        Atlases[self.AtliInfo.key].image,
                        Atlases[self.AtliInfo.key].splicedImages[self.AtliInfo.x][self.AtliInfo.y],
                        moduloX + i * Atlases[self.AtliInfo.key].singleDimention.w + XFlpiiedOffset,
                        moduloY + j * Atlases[self.AtliInfo.key].singleDimention.h,
                        0, dir, 1
                    )
                end
            end
        end
        self.drawFunc(self)
        if self.Mask.ShouldApply then
            love.graphics.setStencilTest()
        end
        love.graphics.setColor { r, g, b, a }
    end
    if self.properties.Outline then
        local r, g, b, a = love.graphics.getColor()
        local function myStencilFunction()
            draw_func(self.Offset.x + 1 + G:GetTotalOffset().x, self.Offset.y + G:GetTotalOffset().y)
            draw_func(self.Offset.x - 1 + G:GetTotalOffset().x, self.Offset.y + G:GetTotalOffset().y)
            draw_func(self.Offset.x + G:GetTotalOffset().x, self.Offset.y + 1 + G:GetTotalOffset().y)
            draw_func(self.Offset.x + G:GetTotalOffset().x, self.Offset.y - 1 + G:GetTotalOffset().y)
        end
        love.graphics.stencil(myStencilFunction, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(self.properties.OutlineColor)
        love.graphics.rectangle("fill", 0, 0, Macros.BaseResolution.w, Macros.BaseResolution.h)
        love.graphics.setColor { r, g, b, a }
        love.graphics.setStencilTest()
    end
    draw_func(self.Offset.x + G:GetTotalOffset().x, self.Offset.y + G:GetTotalOffset().y)
end
function Sprite:SetParent(Obj)
    table.insert(Obj.Children, self.Id)
    self.Parent = Obj.Id
    return self.Parent
end
function Sprite:GetParentOffset()
    if not self.Parent then return { x = 0, y = 0 } end
    local Parent = GetObjectById(self.Parent)
    if not Parent then return { x = 0, y = 0 } end
    return { x = Parent.T.x, y = Parent.T.y }
    end

function Sprite:update(dt)
    if self.Parent then
        self.T.x = self:GetParentOffset().x
        self.T.y = self:GetParentOffset().y
    end
    self.updateFunc(self, dt)
end

function Sprite:remove()
    for k, v in ipairs(G.I.SPRITES) do
        if v.Id == self.Id then
            table.remove(G.I.SPRITES, k)
            G.OldState = G.State
            G.State = "DestroyedObj"
        end
    end
    self = nil
end
