--[[
    SQL.add - Inject new listeners/hooks into RemoteEvents & RemoteFunctions
    Usage: SQL.add:event(remoteEvent, callback)
           SQL.add:listener(remoteEvent, callback)
           SQL.add:function(remoteFunction, callback)
]]

local SQL = getgenv().SQL
if not SQL then
	warn("[SQL.add] Main SQL module not found. Load sql_main.luau first.")
	return
end

SQL.add = SQL.add or {}

function SQL.add:event(remoteEvent, callback)
	if not SQL._internals.isRemoteEvent(remoteEvent) then
		error("SQL.add: target is not a RemoteEvent")
	end

	local meta = SQL._internals.rawGetMeta(remoteEvent)
	if not meta then
		error("SQL.add: could not get metatable. Ensure you have a compatible exploit.")
	end

	local oldNamecall = meta.__namecall
	meta.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if self == remoteEvent and method == "FireServer" then
			local args = {...}
			local shouldFire, newArgs = callback(unpack(args))
			if shouldFire ~= false then
				return oldNamecall(self, unpack(newArgs or args))
			end
			return nil
		end
		return oldNamecall(self, ...)
	end)

	return true
end

function SQL.add:listener(remoteEvent, callback)
	local oldConnect
	oldConnect = hookfunction(remoteEvent.OnClientEvent.Connect, function(self, func)
		return oldConnect(self, function(...)
			callback(...)
			return func(...)
		end)
	end)
	return true
end

function SQL.add:func(remoteFunction, callback)
		if not SQL._internals.isRemoteFunction(remoteFunction) then
			error("SQL.add: target is not a RemoteFunction")
		end

		local meta = SQL._internals.rawGetMeta(remoteFunction)
		local oldNamecall = meta.__namecall

		meta.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if self == remoteFunction and method == "InvokeServer" then
				local args = {...}
				callback(unpack(args))
			end
			return oldNamecall(self, ...)
		end)

		return true
	end

	print("[SQL.add] Loaded globally. Use SQL.add:event(), SQL.add:listener(), SQL.add:function()")
