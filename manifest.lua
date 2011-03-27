#!/bin/env lua

--- A GitHub specific manifest generator for the LuaDist deployment utility
local per = require "dist.persist"
local man = require "dist.manifest"
local fet = require "dist.fetch"

-- Collect URLs of repos for each module
local modules = io.open(".gitmodules", "r")
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
    local remote = io.popen("git ls-remote --tags "..url.. " | tail -r")
    for line in remote:lines() do
        local hash, tag = line:match("([^%s]+)%srefs/tags/([^%s%^]+)$")
        if hash and tag then
            -- Collect dist.info for each tag
            local url = "https://github.com/LuaDist/"..name.."/raw/"..tag.."/dist.info"
            local info = man.info(per.loadText(fet.get(url)) or {})
            if info then
                print(info.name, info.version)
                -- Small hack to generate correct filename
                -- I apologize to GitHub for (ab)using their automated zip feature.
                info.path = "http://nodeload.github.com/LuaDist/"..name.."/zipball/"..tag.."?/"..info.name.."-"..info.version..".dist"
                table.insert(manifest, info)
            end
        end
    end
    remote:close()
end

per.saveManifest("dist.manifest", manifest)
