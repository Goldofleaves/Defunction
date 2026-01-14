---@class Moveable: Object

Moveable = Object:extend()

function Moveable:new(args)
    self.Id = G.CurrentID
    self.Nid = args.nid
    G.CurrentID = G.CurrentID + 1
    args = args or {}
    self.ObjectType = 'MOVEABLE'
    self.T = {
        x = 0,
        y = 0,
        w = 0,
        h = 0
    }
    self.TMod = {
        x = { base = args.x or 0 },
        y = { base = args.y or 0 },
        w = { base = args.w or 0 },
        h = { base = args.h or 0 }
    }
    self.UpdateFunc = args.UpdateFunc or function(s, dt) return end
    self.DrawFunc = args.DrawFunc or function(s) return end
    self.V = {
        x = { base = args.vx or 0 },
        y = { base = args.vy or 0 },
    }
    self.Parent = nil
    self.Children = {}
    self.Properties = args.Properties or {}
    table.insert(G.I.MOVEABLES, self)
    return self
end

-- Functions ported from Badge of Severance

---Sets the parent of this object. Its return value will be a numeracal reference ID
---@param Obj Moveable
---@return integer
function Moveable:SetParent (Obj)
    table.insert(Obj.Children,self.Id)
    self.Parent = Obj.Id
    return self.parent
end

---Add a children to this object.
---@param Obj Moveable
function Moveable:AddChildren (Obj) Obj:SetParent(self) end

-- Aligns objects based on their offsets

function Moveable:GetParentOffset()
    if not self.Parent then return {x=0,y=0} end
    local Parent = GetObjectById(self.Parent)
    if not Parent then return {x = 0, y = 0} end
    return {x = Parent.T.x, y = Parent.T.Y}
end

function Moveable:GetTotalOffset(Component)
    local RetTable = { x = 0, y = 0, w = 0, h = 0 }
    for k, v in pairs(self.TMod) do
        if not Component then
            for kk, vv in pairs(v) do
                RetTable[k] = RetTable[k] + vv
            end
        else
            RetTable[k] = RetTable[k] + v[Component]
        end
    end
    return RetTable
end

function Moveable:GetTotalVelocity(Component)
    local RetTable = { x = 0, y = 0 }
    for k, v in pairs(self.V) do
        if self.V[k][Component] then
            if not Component then
                for kk, vv in pairs(v) do
                    RetTable[k] = RetTable[k] + vv
                end
            else
                RetTable[k] = RetTable[k] + v[Component]
            end
        end
    end
    return RetTable
end

function Moveable:update(dt)
    self.TMod.x.parent = self:GetParentOffset().x
    self.TMod.y.parent = self:GetParentOffset().y
    for k, v in pairs(self.TMod) do
        for kk, vv in pairs(v) do
            if k == "x" or k == "y" then
                v[kk] = vv + self:GetTotalVelocity(kk)[k] * dt
            end
        end
    end
    for k, v in pairs(self.T) do
        self.T[k] = self:GetTotalOffset()[k]
    end
    self.UpdateFunc(self, dt)
end

function Moveable:draw()
    self.DrawFunc(self)
end

---@class Wall: Moveable

Wall = Moveable:extend()
function Wall:new(args)
    args = args or {}
    args.x = args.x or 100
    args.y = args.y or 100
    args.w = args.w or 20
    args.h = args.h or 20
    args.DrawFunc = function (s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF0000"))
            love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor{r, g, b, a}
        end
    end
    return Moveable.new(self, args)
end