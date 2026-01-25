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
    self.Id = G.CurrentID
    G.CurrentID = G.CurrentID + 1
    self.Nid = args.Nid or "_"
    self.Ease = args.Ease == nil and true or args.Ease
    self.CurTime = 0
    self.EaseFunc = args.EaseFunc or function() end
    self.Func = args.Func or function () end
    self.EndFunc = args.EndFunc or function () end
    self.Completed = false
    self.Duration = args.Duration or 1
    self.Extra = args.Extra
    return self
end
Util.Event = {}
function Util.Event.AddEvent(e)
    table.insert(G.Events, e)
end
function Util.Event.Screenshake(Amp, Dur)
    Util.Event.AddEvent(Event(
        {
            Duration = Dur,
            EaseFunc = function (t, e)
                G.DispOffset.x.Shake = (math.random() - 0.5) * 2 * (1-t) * Amp
                G.DispOffset.y.Shake = (math.random() - 0.5) * 2 * (1-t) * Amp
            end
        }
    ))
end