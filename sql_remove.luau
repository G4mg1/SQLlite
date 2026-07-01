--[[
    SQL.remove - Block/suppress RemoteEvents, RemoteFunctions, or connections
    Usage: SQL.remove:event(remoteEvent)
           SQL.remove:function(remoteFunction)
           SQL.remove:connection(instance)
           SQL.remove:restore(target)
           SQL.remove:filter(remoteEvent, condition)
]]

local SQL = getgenv().SQL
if not SQL then
    warn("[SQL.remove] Main SQL module not found. Load sql_main.luau first.")
    return
end

SQL.remove = SQL.remove or {}
SQL.remove._hooked = SQL.remove._hooked or {}

function SQL.remove:event(remoteEvent)
    if not SQL._internals.isRemoteEvent(remoteEvent) then
        error("SQL.remove: target is not a RemoteEvent")
    end

    local meta = SQL._internals.rawGetMeta(remoteEvent)
    if not meta then return false end

    local oldNamecall = meta.__namecall
    meta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == remoteEvent and method == "FireServer" then
            return nil
        end
        return oldNamecall(self, ...)
    end)

    SQL.remove._hooked[remoteEvent] = oldNamecall
    return true
end

function SQL.remove:func(remoteFunction)
    if not SQL._internals.isRemoteFunction(remoteFunction) then
        error("SQL.remove: target is not a RemoteFunction")
    end

    local meta = SQL._internals.rawGetMeta(remoteFunction)
    if not meta then return false end

    local oldNamecall = meta.__namecall
    meta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == remoteFunction and method == "InvokeServer" then
            return nil
        end
        return oldNamecall(self, ...)
    end)

    SQL.remove._hooked[remoteFunction] = oldNamecall
    return true
end

function SQL.remove:connection(instance)
    local meta = SQL._internals.rawGetMeta(instance)
    if not meta then return false end

    local oldIndex = meta.__index
    meta.__index = newcclosure(function(self, key)
        if self == instance and key == "Connected" then
            return false
        end
        return oldIndex(self, key)
    end)

    return true
end

function SQL.remove:restore(target)
    if SQL.remove._hooked[target] then
        local meta = SQL._internals.rawGetMeta(target)
        if meta then
            setreadonly(meta, false)
            meta.__namecall = SQL.remove._hooked[target]
            SQL.remove._hooked[target] = nil
            return true
        end
    end
    return false
end

function SQL.remove:filter(remoteEvent, condition)
    local meta = SQL._internals.rawGetMeta(remoteEvent)
    if not meta then return false end

    local oldNamecall = meta.__namecall
    meta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == remoteEvent and method == "FireServer" then
            local args = {...}
            if condition(unpack(args)) then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)

    return true
end

print("[SQL.remove] Loaded globally. Use SQL.remove:event(), SQL.remove:function(), SQL.remove:filter()")
