local fonts = {}

local assets = {
    audio = {},

    fonts = setmetatable({}, {
        __index = function(t, font_name)
            if type(font_name) == "number" then
                local font = love.graphics.newFont(font_name)
                rawset(t, font_name, font)

                return font
            end
            
            if fonts[font_name] then
                local useable_fonts = setmetatable({}, {
                    __index = function(t, size)
                        local font = love.graphics.newFont(fonts[font_name], size)
                        rawset(t, size, font)

                        return font
                    end
                })

                rawset(t, font_name, useable_fonts)

                return useable_fonts
            end
        end
    }),

    graphics = {},
    shaders = {}
}

local categories = {assets.audio, assets.graphics, assets.shaders, fonts}

local function make_directory(t)
    t.__assets = {}

    setmetatable(t, {
        __index = function(t, k)
            if rawget(t, "__assets") then
                local load_func = rawget(t, "__assets")[k]

                if load_func then
                    rawset(t, k, load_func())
                    return t[k]
                end
            end
        end,

        __call = function(t)
            if t.__assets then
                for k, load_func in pairs(t.__assets) do
                    t[k] = load_func()
                end

                t.__assets = nil
            end

            return t
        end
    })

    return t
end

for _, category in pairs(categories) do
    make_directory(category)
end

local function recursive_load(folder, func, table)
    for _, file_name in pairs(love.filesystem.getDirectoryItems(folder)) do
        local path = folder .. "/" .. file_name
        local info = love.filesystem.getInfo(path)

        if info.type == "file" then
            table.__assets[file_name:sub(1, -5)] = function() return func(path) end
        elseif info.type == "directory"  then
            table[file_name] = make_directory({})
            recursive_load(path, func, table[file_name])
        end
    end
end

local folder = (...):gsub("%.", "/") .. "/"

recursive_load(folder .."graphics", function(file_path)
    return love.graphics.newImage(file_path)
end, assets.graphics)

recursive_load(folder .. "audio/stream", function(file_path)
    return love.audio.newSource(file_path, "stream")
end, assets.audio)

recursive_load(folder .. "audio/static", function(file_path)
    return love.audio.newSource(file_path, "stream")
end, assets.audio)

recursive_load(folder .. "fonts", function(file_path)
    return file_path
end, fonts)

recursive_load(folder .. "shaders", function(file_path)
    return love.graphics.newShader(file_path)
end, assets.shaders)

return assets, recursive_load