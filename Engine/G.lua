---@class Game: Object

--boilerplate
Game = Object:extend()

function Game:new()
    self.Language = "english"
    self.Localization = {}
    self.ScalingFactor = 2
    G = self
end