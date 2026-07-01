--[[
    SQL - Roblox Pentesting Injection Framework
    GitHub: https://github.com/yourusername/SQL-Roblox
    Authorized security assessment tool only.
    Uses: getrawmetatable, hookfunction, getfenv, setreadonly, newcclosure
]]

getgenv().SQL = getgenv().SQL or {}
local SQL = getgenv().SQL

-- Internal utilities
SQL._internals = SQL._internals or {}

function SQL._internals.rawGetMeta(obj)
    local success, meta = pcall(getrawmetatable, obj)
    if success and meta then
        setreadonly(meta, false)
        return meta
    end
    return nil
end

function SQL._internals.isRemoteEvent(obj)
    return typeof(obj) == "Instance" and obj:IsA("RemoteEvent")
end

function SQL._internals.isRemoteFunction(obj)
    return typeof(obj) == "Instance" and obj:IsA("RemoteFunction")
end

function SQL._internals.isModuleScript(obj)
    return typeof(obj) == "Instance" and obj:IsA("ModuleScript")
end

function SQL._internals.hook(targetFunc, callback)
    if type(targetFunc) == "function" then
        return hookfunction(targetFunc, callback)
    end
    return nil
end

print("[SQL] Main module loaded globally via getgenv().SQL")
