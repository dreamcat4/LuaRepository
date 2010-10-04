local persist = require "dist.persist"

local manifest = {}

local modules = io.open(".gitmodules", "r")

-- Collect URLs of repos for each module
local repo = {}
for line in modules:lines() do
    url = line:match("%surl%s=%s([^%s]+)")
    if name and url then
        repo[name] = url
    end
    name = line:match("%spath%s=%s([^%s]+)")
end
modules:close()

-- Collect tags for each module
local manifest = {}
for name, url in pairs(repo) do
    local remote = io.popen("git ls-remote --tags "..url)
    for line in remote:lines() do
        local hash, tag = line:match("([^%s]+)%srefs/tags/v([^%s%^]+)$")
        if hash and tag then
            local dist = { name = name, version = tag, path = "http://github.com/LuaDist/"..name.."/zipball/v"..tag.."?/"..name..".dist"}
            print(dist.name, dist.version, dist.path)
            table.insert(manifest, dist)
        end
    end
end

persist.saveManifest("dist.manifest", manifest)