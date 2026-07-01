# SQL - Roblox Pentesting Injection Framework

An SQL-like injection framework for authorized Roblox penetration testing.
Uses `getrawmetatable`, `hookfunction`, `getfenv`, `setreadonly`, and `newcclosure`.

## ⚠️ Legal Warning
This tool is **ONLY** for authorized security assessments. You must own the game
or have explicit written permission from the owner before use. Unauthorized use
violates Roblox ToS and may be illegal.

## Features

| Module | Function | Description |
|--------|----------|-------------|
| `SQL.select` | `:all()` | Enumerate all RemoteEvents/Functions/Modules |
| `SQL.select` | `:events()` | Find all RemoteEvents |
| `SQL.select` | `:functions()` | Find all RemoteFunctions |
| `SQL.select` | `:modules()` | Find all ModuleScripts |
| `SQL.select` | `:search()` | Search remotes by name/pattern |
| `SQL.select` | `:metatable()` | Inspect object metatables |
| `SQL.select` | `:properties()` | Get remote properties |
| `SQL.add` | `:event()` | Intercept RemoteEvent fires |
| `SQL.add` | `:listener()` | Hook OnClientEvent listeners |
| `SQL.add` | `:function()` | Intercept RemoteFunction invokes |
| `SQL.remove` | `:event()` | Block RemoteEvent fires |
| `SQL.remove` | `:function()` | Block RemoteFunction invokes |
| `SQL.remove` | `:connection()` | Spoof connection state |
| `SQL.remove` | `:restore()` | Restore original hooks |
| `SQL.remove` | `:filter()` | Conditional blocking |
| `SQL.inject` | `:module()` | Inject into ModuleScripts |
| `SQL.inject` | `:environment()` | Inject into environments |
| `SQL.inject` | `:globals()` | Access global env |
| `SQL.inject` | `:metamethod()` | Hook metamethods |
| `SQL.inject` | `:scoped()` | Create scoped interceptors |
| `SQL.backdoor` | `:event()` | Backdoor a RemoteEvent |
| `SQL.backdoor` | `:function()` | Backdoor a RemoteFunction |
| `SQL.backdoor` | `:createRemote()` | Create C2 channel |
| `SQL.backdoor` | `:listen()` | Listen on backdoor |
| `SQL.backdoor` | `:injectExecutor()` | Inject code executor |
| `SQL.backdoor` | `:firehack()` | Fire remotes directly |
| `SQL.backdoor` | `:cleanup()` | Remove all backdoors |

## Load Order

to load them you need to load all scripts in order to make it fully work !
