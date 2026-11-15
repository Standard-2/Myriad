local fs = require("@lune/fs")
local checks = fs.readFile("src/tests/standards/checks/init.luau")

local flattened = {}
local seen = {}

local function flatten(name)
    if not name or seen[name] then return end
    table.insert(flattened, name)
    seen[name] = true
end

for name, path in string.gmatch(checks, '%["([^"]+)"%] = require%("@checks/([^"]+)"%)') do
    flatten(name)
    
    local file_path = "src/tests/standards/checks/" .. path
    if not string.find(file_path, "%.luau$") then
        file_path = file_path .. ".luau"
    end
    
    if fs.isFile(file_path) then
        local content = fs.readFile(file_path)
        local function collect(aliasesBlock)
            if not aliasesBlock then
                return
            end
            for alias in string.gmatch(aliasesBlock, '"([^"]+)"') do
                flatten(alias)
            end
            for alias in string.gmatch(aliasesBlock, "'([^']+)'") do
                flatten(alias)
            end
        end

        collect(string.match(content, 'require%("@standards/framework"%)%.aliases%s*%(%s*{(.-)}%s*%)'))
        collect(string.match(content, 'aliases%s*=%s*{(.-)}'))
    end
end

table.sort(flattened)
print(flattened)

return flattened
