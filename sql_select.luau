--[[
    SQL.inject - Inject code into ModuleScripts, environments, or metatables
    Usage: SQL.inject:module(moduleScript, injectionCode)
           SQL.inject:environment(targetEnv, key, value)
           SQL.inject:globals()
           SQL.inject:metamethod(instance, methodName, callback)
           SQL.inject:scoped(scope, callback)
]]

local SQL = getgenv().SQL
if not SQL then
    warn("[SQL.inject] Main SQL module not found. Load sql_main.luau first.")
    return
end

SQL.inject = SQL.inject or {}
SQL.inject._moduleOverrides = SQL.inject._moduleOverrides or {}
SQL.inject._originalRequire = SQL.inject._originalRequire or nil

function SQL.inject:module(moduleScript, injectionCode)
    if not SQL._internals.isModuleScript(moduleScript) then
        error("SQL.inject: target is not a ModuleScript")
    end

    if not SQL.inject._originalRequire then
        local env = getfenv(2)
        SQL.inject._originalRequire = env.require
    end

    local originalReq = SQL.inject._originalRequire
    local env = getfenv(2)

    env.require = newcclosure(function(script)
        if script == moduleScript then
            local result = originalReq(script)
            if type(result) == "table" then
                if type(injectionCode) == "function" then
                    injectionCode(result)
                elseif type(injectionCode) == "table" then
                    for k, v in pairs(injectionCode) do
                        result[k] = v
                    end
                end
                SQL.inject._moduleOverrides[script] = result
                return result
            end
        end
        return originalReq(script)
    end)

    return true
end

function SQL.inject:environment(targetEnv, key, value)
    if type(targetEnv) == "table" then
        setreadonly(targetEnv, false)
        targetEnv[key] = value
        setreadonly(targetEnv, true)
        return true
    end
    return false
end

function SQL.inject:globals()
    local env = getfenv(0)
    setreadonly(env, false)
    return env
end

function SQL.inject:metamethod(instance, methodName, callback)
    local meta = SQL._internals.rawGetMeta(instance)
    if not meta then return false end

    setreadonly(meta, false)
    local old = meta[methodName]
    meta[methodName] = newcclosure(function(self, ...)
        if self == instance then
            return callback(old, self, ...)
        end
        if old then
            return old(self, ...)
        end
        return nil
    end)

    return true
end

function SQL.inject:scoped(scope, callback)
    if type(scope) ~= "table" then return false end

    local origMeta = getmetatable(scope)
    if origMeta then
        setreadonly(origMeta, false)
    end

    local meta = {
        __index = function(self, key)
            if callback(key) then
                return callback(key)
            end
            if origMeta and origMeta.__index then
                return origMeta.__index(self, key)
            end
            return nil
        end
    }

    setmetatable(scope, meta)
    return true
end

print("[SQL.inject] Loaded globally. Use SQL.inject:module(), SQL.inject:environment(), SQL.inject:metamethod()")
