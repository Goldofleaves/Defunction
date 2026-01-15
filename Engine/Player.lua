---@class Player: Moveable

Player = Moveable:extend()
function Player:new(args)
    args = args or {}
    args.Strength = 500
    args.Properties = args.Properties or {}
    args.Properties.Player = true
    args.x = args.x or 140
    args.y = args.y or 140
    args.w = args.w or 20
    args.h = args.h or 40
    args.Extra = {
        CoyoteTimer = 0,
        HaventJumped = true,
        HoldTimer = Macros.MaxHold,
        Facing = "Right",
        OnGround = true
    }
    args.UpdateFunc = function(self, dt)
        if not (love.keyboard.isDown("left") or love.keyboard.isDown("right")) or (love.keyboard.isDown("right") and love.keyboard.isDown("left")) then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, 0, 0.005)
        elseif love.keyboard.isDown("left") then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, -90, 0.005)
            self.Extra.Facing = "Left"
        elseif love.keyboard.isDown("right") then
            self.V.x.base = Util.Math.LerpDt(self.V.x.base, 90, 0.005)
            self.Extra.Facing = "Right"
        end
        self.TMod.x.Gravity = self.TMod.x.Gravity or 0
        self.V.x.Gravity = self.V.x.Gravity or 0
        self.TMod.y.Gravity = self.TMod.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity + Macros.Gravity
        self.Extra.OnGround = self.Extra.DownCheck.Extra.Ticked
        if self.Extra.OnGround and self.Extra.OnGround ~= self.Id then
            self.V.y.Gravity = 0
            self.Extra.HaventJumped = true
            self.Extra.CoyoteTimer = Macros.CoyoteTime
            self.Extra.HoldTimer = Macros.MaxHold
        else
            self.Extra.CoyoteTimer = self.Extra.CoyoteTimer - dt
        end
        if self.Extra.CoyoteTimer < 0 then
            self.Extra.HaventJumped = false
        end
        if love.keyboard.isDown("up") then
            if self.Extra.HaventJumped or self.Extra.HoldTimer >= 0 then
                self.V.y.Gravity = -Macros.JumpVelocity
            end
            self.Extra.HoldTimer = self.Extra.HoldTimer - dt
        else
            if self.Extra.HaventJumped then
                self.Extra.HoldTimer = -1
            end
        end
        if self.Extra.OnGround == self.Id then
            self.V.y.Gravity = 20
            self.Extra.HoldTimer = -1
        end
    end
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#00FF15"))
            --love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    self.Extra.CoyoteTimer = Macros.CoyoteTime
    self.Extra.DownCheck = Moveable {
        Properties = {
            CollisionCheck = true
        },
        w = 16,
        h = 1,
        DrawFunc = function(s)
            if G.Debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#2F00FF"))
                love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end,
    }
    self.Extra.DownCheck.TMod.x.offset = 2
    self.Extra.DownCheck.TMod.y.offset = 40
    self.Extra.DownCheck:SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 4000,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 3999,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and not (love.keyboard.isDown("left") and love.keyboard.isDown("right")) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworld",
        DrawOrder = 3998,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    -- Outlines Yay
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and not (love.keyboard.isDown("left") and love.keyboard.isDown("right")) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = 1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and not (love.keyboard.isDown("left") and love.keyboard.isDown("right")) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetX = -1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and not (love.keyboard.isDown("left") and love.keyboard.isDown("right")) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = 1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        AtliY = 2,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            if not (self.Extra.OnGround and self.Extra.OnGround ~= self.Id) then
                s.AtliInfo.x = 1
                s.AtliInfo.y = 1
            else
                if (love.keyboard.isDown("left") or love.keyboard.isDown("right")) and not (love.keyboard.isDown("left") and love.keyboard.isDown("right")) then
                    local frame = Util.Math.Div(G.Timer, TickTime) % 6
                    s.AtliInfo.x = frame
                    s.AtliInfo.y = 2
                else
                    s.AtliInfo.x = 0
                    s.AtliInfo.y = 1
                end
            end
        end
    }):SetParent(self)
    Sprite({
        AtliKey = "ArnaOverworldMask",
        DrawOrder = 3997,
        OffsetY = -1,
        AtliY = 3,
        UpdateFunc = function(s, dt)
            s.Xflipped = self.Extra.Facing == "Left" and true or false
            local TickTime = 0.2
            local frame = Util.Math.Div(G.Timer, TickTime) % 7
            s.AtliInfo.x = frame
        end
    }):SetParent(self)
    return self
end
