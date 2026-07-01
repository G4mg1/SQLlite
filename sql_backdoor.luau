--[[
    SQL.backdoor - Create persistence, backdoor access to remotes, C2 channels
    Usage: SQL.backdoor:event(remoteEvent, interceptor)
           SQL.backdoor:function(remoteFunction, interceptor)
           SQL.backdoor:createRemote(name)
           SQL.backdoor:listen(remoteEvent, handler)
           SQL.backdoor:injectExecutor(targetScript)
           SQL.backdoor:firehack(targetRemote, ...)
           SQL.backdoor:cleanup()
]]

local SQL = getgenv().SQL
if not SQL then
	warn("[SQL.backdoor] Main SQL module not found. Load sql_main.luau first.")
	return
end

SQL.backdoor = SQL.backdoor or {}
SQL.backdoor._channels = SQL.backdoor._channels or {}

function SQL.backdoor:event(remoteEvent, interceptor)
	if not SQL._internals.isRemoteEvent(remoteEvent) then
		error("SQL.backdoor: target is not a RemoteEvent")
	end

	local meta = SQL._internals.rawGetMeta(remoteEvent)
	if not meta then return false end

	local oldNamecall = meta.__namecall
	meta.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if self == remoteEvent and method == "FireServer" then
			if interceptor then
				interceptor(...)
			end
			return oldNamecall(self, ...)
		end
		return oldNamecall(self, ...)
	end)

	return true
end

function SQL.backdoor:func(remoteFunction, interceptor)
		if not SQL._internals.isRemoteFunction(remoteFunction) then
			error("SQL.backdoor: target is not a RemoteFunction")
		end

		local meta = SQL._internals.rawGetMeta(remoteFunction)
		if not meta then return false end

		local oldNamecall = meta.__namecall
		meta.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if self == remoteFunction and method == "InvokeServer" then
				local args = {...}
				if interceptor then
					local modified = interceptor(unpack(args))
					if modified then
						return oldNamecall(self, unpack(modified))
					end
				end
				return oldNamecall(self, ...)
			end
			return oldNamecall(self, ...)
		end)

		return true
	end

	function SQL.backdoor:createRemote(name)
		name = name or "_SQL_Backdoor_" .. math.random(10000, 99999)

		local backdoor = Instance.new("RemoteEvent")
		backdoor.Name = name
		backdoor.Parent = game.ReplicatedStorage

		SQL.backdoor._channels[name] = backdoor
		return backdoor
	end

	function SQL.backdoor:listen(remoteEvent, handler)
		local meta = SQL._internals.rawGetMeta(remoteEvent)
		if not meta then return false end

		local oldNamecall = meta.__namecall
		meta.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if self == remoteEvent and method == "FireServer" then
				local args = {...}
				if handler then
					handler(unpack(args))
				end
				return nil
			end
			return oldNamecall(self, ...)
		end)

		return true
	end

	function SQL.backdoor:injectExecutor(targetScript)
		local env = getfenv(targetScript)
		setreadonly(env, false)

		env.__sql_exec = newcclosure(function(code)
			local success, result = loadstring(code)
			if success then
				return result()
			end
			return nil, result
		end)

		setreadonly(env, true)
		return true
	end

	function SQL.backdoor:firehack(targetRemote, ...)
		if SQL._internals.isRemoteEvent(targetRemote) then
			targetRemote:FireServer(...)
			return true
		elseif SQL._internals.isRemoteFunction(targetRemote) then
			return targetRemote:InvokeServer(...)
		end
		return false
	end

	function SQL.backdoor:cleanup()
		for name, remote in pairs(SQL.backdoor._channels) do
			pcall(function()
				remote:Destroy()
			end)
			SQL.backdoor._channels[name] = nil
		end
	end

	print("[SQL.backdoor] Loaded globally. Use SQL.backdoor:event(), SQL.backdoor:createRemote(), SQL.backdoor:firehack()")
