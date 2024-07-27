---@author caleskog
---Adapted from this gits: https://gist.github.com/Lattay/84af7aa1fad7eab055d3636220638a3f
---Setup paths for luarocks
--- NOTE: This is needed for my custom completions for `premake`

local home = os.getenv('HOME')

if home == nil then
    return
end

local lua_version = _VERSION:match('%d+%.%d+')

local iv = function(v)
    return v:gsub('\\@', lua_version)
end

local path = table.concat({
    iv('/usr/share/lua/\\@/?.lua'),
    iv('/usr/share/lua/\\@/?/init.lua'),
    iv('/usr/lib/lua/\\@/?.lua'),
    iv('/usr/lib64/lua/\\@/?.lua'),
    iv('/usr/lib/lua/\\@/?/init.lua'),
    iv('/usr/lib64/lua/\\@/?/init.lua'),
    iv('./?.lua'),
    iv('./?/init.lua'),
    iv('~/.luarocks/share/lua/\\@/?.lua'),
    iv('~/.luarocks/share/lua/\\@/?/init.lua'),
}, ';')

local cpath = table.concat({
    iv('/usr/lib/lua/\\@/?.so'),
    iv('/usr/lib64/lua/\\@/?.so'),
    iv('/usr/lib/lua/\\@/loadall.so'),
    iv('/usr/lib64/lua/\\@/loadall.so'),
    iv('./?.so'),
    iv('~/.luarocks/lib lua/\\@/?.so'),
}, ';')

package.path = path:gsub('~', home)
package.cpath = cpath:gsub('~', home)

-- print(package.path)
