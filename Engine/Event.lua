---@class Event: Object
--- `easeFunc` - Runs every frame for the duration of the event\
--- `func` - Runs at the start of the event\
--- `endFunc` - Runs at the end of the event\
--- `duration` - In seconds, the duration of the event\
--- `skippable` - Whether this function can be skipped or not.\
--- `nid` - The unique-identifier to events.\
--- `extra` - Other data not included above, used primarely for very specific use-cases.
Event = Object:extend()
function Event:new(args)
    args = args or {}
    self.id = G.currentID
    G.currentID = G.currentID + 1
    self.nid = args.nid or "_"
    self.ease = args.ease == nil and true or args.ease
    self.curTime = 0
    self.easeFunc = args.easeFunc or function() end
    self.func = args.func or function () end
    self.endFunc = args.endFunc or function () end
    self.completed = false
    self.duration = args.duration or 1
    self.extra = args.extra
    return self
end
Util.Event = {}
function Util.Event.addEvent(e)
    table.insert(G.events, e)
end
function Util.Event.screenShake(Amp, Dur)
    for k, v in ipairs(G.events) do
        if v.nid == "shake" then
            if v.endFunc then v.endFunc(v) end
            G.events[k] = nil
        end
    end
    G.events = Util.Other.removeNils(G.events)
    Util.Event.addEvent(Event(
        {
            duration = Dur,
            nid = "shake",
            easeFunc = function (t, e)
                G.dispOffset.x.Shake = (math.random() - 0.5) * 2 * (1 - t) * Amp
                G.dispOffset.y.Shake = (math.random() - 0.5) * 2 * (1 - t) * Amp
            end,
            endFunc = function()
                G.dispOffset.x.Shake = 0
                G.dispOffset.y.Shake = 0
            end
        }
    ))
end

function Util.Event.delayFunc(t, f)
    Util.Event.addEvent(Event(
        {
            duration = t,
            endFunc = f
        }
    ))
end
