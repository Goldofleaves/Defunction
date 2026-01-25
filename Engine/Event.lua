---@class Event: Object
--- `ease_func` - Runs every frame for the duration of the event\
--- `func` - Runs at the start of the event\
--- `end_func` - Runs at the end of the event\
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
    self.Ease = args.Ease == nil and true or args.Ease
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
function Util.Event.AddEvent(e)
    table.insert(G.Events, e)
end
function Util.Event.Screenshake(Amp, Dur)
    Util.Event.AddEvent(Event(
        {
            duration = Dur,
            easeFunc = function (t, e)
                G.dispOffset.x.Shake = (math.random() - 0.5) * 2 * (1-t) * Amp
                G.dispOffset.y.Shake = (math.random() - 0.5) * 2 * (1-t) * Amp
            end
        }
    ))
end