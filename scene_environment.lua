--scripting functions in the scene environment will use this mt
--so that they can chain function calls
--make your func return in on_call to pass that arg to the variable storing it
local environment_func_mt = {    
    __call = function(self, arg)
        table.insert(self, arg)

        local value = nil
        
        if self.on_call then
            value = self:on_call(arg)
        end

        return value or self
    end
}

local scene_environment = class()

local mt = {
    __newindex = function(t, k, v)
        rawset(t.__save_variables, k, v)
    end,

    __index = function(t, k)
        return rawget(t, k) or rawget(t.__save_variables, k) --or getmetatable(scene_environment).__index[k]
    end
}


function scene_environment:init(scene_manager)
    self._G = _G
    self.scene_manager = scene_manager --did this because I dont have a goto if op code..
    self.assets = assets
    self.love = love
    self.print = print
    self.pairs = pairs
    self.event = event
    self.setmetatable = setmetatable
    self.rawset = rawset
    self.rawget = rawget

    --um... firehawk I need help, the script is now expecting the first arg of every func to be the scene_environment so I can access its scene_manager variable
    for k, v in pairs(scene_environment) do
        if type(v) == "function" and not (k == "init") then
            self[k] = function(...) return v(self, ...) end
        end
    end

    self.__save_variables = {}

    setmetatable(self, mt)
end

function scene_environment:animation(spritesheet)
    local func_table = setmetatable({
        on_call = function(self, arg)
            if #self == 7 then
                for i = 2, 7 do
                    self[i] = tonumber(self[i])
                end

                return animation.new(unpack(self))
            end
        end
    }, environment_func_mt)

    return func_table(spritesheet)
end

function scene_environment:scene(scene_name)
    --scenes contain a set of instructions that happen in order, and wait, if necessary, before moving on
    self.scene_manager.__scene_object = {}
    self.scene_manager.scenes[scene_name] = self.scene_manager.__scene_object
end

function scene_environment:script(args)
    local func = table.remove(args, 1)

    self.scene_manager:add_instruction(function()
        func(unpack(args))
        self.scene_manager:next_instruction()
    end)
end

--todo implement this
--[[
local modify = {
    add = function(var1, var2)
        return var1 + var2
    end,

    sub = function(var1, var2)
        return var1 - var2
    end,

    mul = function(var1, var2)
        return var1 * var2
    end,

    div = function(var1, var2)
        return var1 / var2
    end
}

function scene_environment:modify_variable(arg)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local var1, modifier, var2 = unpack(func_table)

        self.scene_manager:next_instruction()
    end)

    return func_table(arg)
end
]]

local convert = {
    number = function(arg)
        return tonumber(arg)
    end,

    string = function(arg)
        return tostring(arg)
    end,

    boolean = function(arg)
        return (arg == "true" and true) or (arg == "false" and false)
    end
}

local compare = {
    less = function(var1, var2)
        return var1 < var2
    end,

    greater = function(var1, var2)
        return var2 > var2
    end,

    equals = function(var1, var2)
        return var1 == var2
    end,

    less_equals = function(var1, var2)
        return var1 <= var2
    end,

    greater_equals = function(var1, var2)
        return var1 >= var2
    end,

    not_equals = function(var1, var2)
        return var1 ~= var2
    end
}

local function replace_variables(string, environment)
    --gets a variable from the script string that starts and ends with "$", doesn't have any "$"s inbetween them, by getting all non-space characters between them.
    local pattern = "%$([^%$]%S+)%$"

    return string:gsub(pattern, function(variable)
        return setfenv(loadstring("return " .. variable), environment)()
    end)
end

local function replace_variable_same_type(string, environment)
    --gets a variable from the script string that starts and ends with "$", doesn't have any "$"s inbetween them, by getting all non-space characters between them.
    local pattern = "%$([^%$]%S+)%$"

    for variable in string:gmatch(pattern) do
        return setfenv(loadstring("return " .. variable), environment)()
    end

    return string
end

function scene_environment:choice(text)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        self.scene_manager.choices = self.scene_manager.choices or {}

        local text, scene = replace_variables(func_table[1], self), func_table[2]
        local condition = true

        for i = 3, #func_table, 3 do
            local var1, operator, var2 = func_table[i], func_table[i + 1], func_table[i + 2]

            if type(var1) == "string" then
                print("WHAT WAS THIS VARIABLE", var1, type(var1))
                var1 = replace_variable_same_type(var1, self)
                print("WHAT IS THIS VARIABLE", var1, type(var1))
            end

            if type(var2) == "string" then
                var2 = replace_variable_same_type(var2, self)
            end

            print("ARGS ARE ", var1, operator, var2)

            local type1, type2 = type(var1), type(var2)

            --[[
            if not (var1 and var2) then
                condition = false
                break
            end
            ]]

            if not (type1 == type2) then
                if convert[type1] then
                    var2 = convert[type1](var2)
                end
            end

            if not (compare[operator](var1, var2)) then
                condition = false
                break
            end
        end

        if condition then
            table.insert(self.scene_manager.choices, text)
            table.insert(self.scene_manager.choices, scene)
        end

        self.scene_manager:force_next_instruction()
    end)

    return func_table(text)
end

function scene_environment:unlock_gallery_image(image_name)
    self.scene_manager:add_instruction(function()   
        event:run("on_add_global_save_variable", image_name, true)
        self.scene_manager:next_instruction()
        --set some global variable or something
    end)
end

function scene_environment:sound(sound_string)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local sound = self.scene_manager:asset_from_string("audio", sound_string)

        sound:setVolume(tonumber(func_table[2]) or 1)
        sound:play()

        self.scene_manager:next_instruction() --without calling this, autoplay would make it awkwardly wait o.O
    end)

    return func_table(sound_name)
end

function scene_environment:voice(voice_string)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local voice = assets.audio scene_manager:asset_from_string("audio", voice_string)

        self.scene_manager:stop_voice()
        self.scene_manager:next_instruction()

        voice:setVolume(tonumber(func_table[2]) or 1)
        voice:play()

        self.scene_manager.current_voice = voice
    end)

    return func_table(voice_name)
end
--[[
function scene_environment:music(music_string)
    self.scene_manager:add_instruction(function()
        self.scene_manager:set_music(music_string)
    end)
end
]]
function scene_environment:stop_music()
    self.scene_manager:add_instruction(function()
        self.scene_manager:stop_music()
        self.scene_manager:next_instruction()
    end)
end
--[[
function scene_environment:pause_music()
    self.scene_manager:add_instruction(function()
        if self.scene_manager.current_music then
            self.scene_manager.current_music:pause()
        end
    end)
end

function scene_environment:unpause_music()
    self.scene_manager:add_instruction(function()
        if self.scene_manager.current_music then
            self.scene_manager.current_music:play()
        end
    end)
end
]]

function scene_environment:background(background_image)
    self.scene_manager:add_instruction(function()
        self.scene_manager:set_background(background_image)
    end)
end

function scene_environment:fade_in_background(background_string)
    --background_string = "whitescreen"
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local duration = tonumber(func_table[2])

        self.scene_manager:set_background(background_string)
        self.scene_manager.background_color[4] = 0

        local last_background_alpha

        if self.scene_manager.last_background_color then
            last_background_alpha = self.scene_manager.last_background_color[4]
        end

        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            local fraction = math.min(1, time_passed / duration)

            if self.scene_manager.last_background_image then
                self.scene_manager.last_background_color[4] = util.math.smooth_lerp(last_background_alpha, 0, fraction)
            end

            self.scene_manager.background_color[4] = util.math.smooth_lerp(0, 1, fraction)
        end)
    end)

    return func_table(background_string)
end

function scene_environment:fade_out_background(duration)
    self.scene_manager:add_instruction(function()
        duration = tonumber(duration)

        self.scene_manager:add_update_function(duration, function(time_passed)
            self.scene_manager.background_color[4] = util.math.smooth_lerp(1, 0, math.min(1, time_passed / duration))
        end)
    end)
end

--look at this beautiful fucking code, why didn't I just use hump timers...
function scene_environment:fade_in_music(music_string)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local duration, volume = tonumber(func_table[2]), tonumber(func_table[3]) or 1

        local current_music = self.scene_manager.current_music
        local current_volume = current_music and current_music:getVolume()

        self.scene_manager:next_instruction()
        
        if current_music then
            local time_passed = 0
            local fraction = 0

            timer.during(duration, function(dt) 
                time_passed = time_passed + dt
                fraction = math.min(1, time_passed / duration)
                current_music:setVolume(util.math.smooth_lerp(current_volume, 0, fraction))
            end, function() 
                self.scene_manager:stop_music()

                timer.after(0, function()
                    local music = self.scene_manager:set_music(music_string, 0, volume)
                    time_passed = 0

                    timer.during(duration, function(dt)
                        time_passed = time_passed + dt
                        fraction = math.min(1, time_passed / duration)
                        music:setVolume(util.math.smooth_lerp(0, volume, fraction))
                    end)
                end)
            end)
        else
            local music = self.scene_manager:set_music(music_string, 0, volume)
            time_passed = 0

            timer.during(duration, function(dt)
                time_passed = time_passed + dt
                fraction = math.min(1, time_passed / duration)
                music:setVolume(util.math.smooth_lerp(0, volume, fraction))
            end)
        end

        --[[
        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            fraction = math.min(1, time_passed / duration)

            if current_music then
                current_music:setVolume(util.math.smooth_lerp(current_volume, 0, math.min(1, fraction * 2)))

                if fraction == 1 then
                    current_music:stop()
                end
            end


            --had an error here with indexing music
            music:setVolume(util.math.smooth_lerp(0, volume, fraction))
        end)]]

        self.scene_manager.target_music_volume = volume
    end)

    return func_table(music_string)
end

function scene_environment:set_character_asset_lookup(character_string)
    return function(folder_string)
        self.scene_manager:add_instruction(function()
            self[character_string].asset_lookup = folder_string
        end)
    end
end

function scene_environment:fade_out_music(duration)
    self.scene_manager:add_instruction(function()
        local music = self.scene_manager.current_music

        if not music then
            return
        end

        local current_volume = music:getVolume()
        duration = tonumber(duration)

        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            print(util.math.smooth_lerp(current_volume, 0, math.min(1, time_passed / duration)))
            music:setVolume(util.math.smooth_lerp(current_volume, 0, math.min(1, time_passed / duration)))
        end)

        self.scene_manager.target_music_volume = volume
        self.scene_manager.music = nil
        self.scene_manager.music_string = nil
    end)
end



function scene_environment:fade_in_character(character)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        --self.scene_manager:fade_in_character(character, image_string, align, duration)
        local image_string = func_table[2]
        local align, duration = func_table[3], tonumber(func_table[4]) or 0

        local last_drawable = self.scene_manager.drawables[character]
        local last_drawable_alpha = last_drawable and last_drawable.color[4]
        local drawable = self.scene_manager:add_drawable(character, image_string, align)
        drawable.last_drawable = last_drawable
        drawable.color[4] = 0 
        
        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            local fraction = math.min(1, time_passed / duration)

            if last_drawable then
                last_drawable.color[4] = util.math.smooth_lerp(last_drawable_alpha, 0, fraction)
            end

            drawable.color[4] = util.math.smooth_lerp(0, 1, fraction)
        end)

    end)

    return func_table(character)
end

function scene_environment:fade_out_character(character)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local drawable = self.scene_manager.drawables[character]

        if not drawable then
            return
        end

        local duration = tonumber(func_table[2])
        local color = drawable.color
        local starting_alpha = color[4]

        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            color[4] = util.math.smooth_lerp(starting_alpha, 0, math.min(1, time_passed / duration))

            if time_passed >= duration then
                self.scene_manager:remove_drawable(character)
            end
        end)
    end)

    return func_table(character)
end

function scene_environment:move_character(args)
    --move them FROM somewhere, either where they are or choose left or right
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local character_string, end_align, duration = unpack(func_table)
        duration = tonumber(duration) or 1

        local drawable = assert(self.scene_manager.drawables[character_string], string.format("Character %s isn't on the screen to move!", character_string))
        local start_x = drawable.x
        local end_x = self.scene_manager:alignment(end_align, drawable.image)

        self.scene_manager:next_instruction()

        self.scene_manager:add_update_function(duration, function(time_passed)
            local fraction = math.min(1, time_passed / duration)
            drawable.x = util.math.smooth_lerp(start_x, end_x, fraction)
            drawable.align = end_align
        end)
    end)

    return func_table(args)
end

--[[
function scene_environment:animate_in_character(args)
    local character, image_string, start_x, start_y, end_x, end_y, duration = unpack(args)
    
    self.scene_manager:add_instruction(function()
        local drawable = self.scene_manager:add_drawable(character, image_string, start_x, start_y)

        self.scene_manager:add_update_function(duration, function(time_passed)
            local fraction = math.min(1, time_passed / duration)
            drawable.x = util.math.smooth_lerp(start_x, end_x, fraction)
            drawable.y = util.math.smooth_lerp(start_y, end_y, fraction)
        end)
    end)
end

function scene_environment:animate_out_character(args)
    local character, end_x, end_y, duration = unpack(args)

    self.scene_manager:add_instruction(function()
        local drawable = self.scene_manager.drawables[character]
        local start_x, start_y = drawable.x, drawable.y

        self.scene_manager:add_update_function(duration, function(time_passed)
            local fraction = math.min(1, time_passed / duration)
            drawable.x = util.math.smooth_lerp(start_x, end_x, fraction)
            drawable.y = util.math.smooth_lerp(start_y, end_y, fraction)

            if time_passed >= duration then
                self.scene_manager:remove_drawable(character)
            end
        end)
    end)
end
]]

function scene_environment:text(text)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        self.scene_manager:clear_speaker_info()

        self.scene_manager.speaker_text = replace_variables(text, self)

        self.scene_manager.speaker_current_text = ""
        self.scene_manager.speaker_text_color = DEFAULT_TEXT_COLOR
        self.scene_manager.speaker_name = nil
        self.scene_manager.speaker_name_color = nil
    end)

    return func_table(text)
end

function scene_environment:character(id, character_name, name_color)
    local character = {
        name = character_name,
        name_color = name_color,
        asset_lookup = id
    }

    self[id] = character

    setmetatable(character, {
        __call = function(this, text)
            text = string.format("\"%s\"", text)

            self.scene_manager:add_instruction(function()
                self.scene_manager:clear_speaker_info()
        
                self.scene_manager.speaker_text = replace_variables(text, self)
        
                self.scene_manager.speaker_current_text = ""
                self.scene_manager.speaker_text_color = {1, 1, 1}
                self.scene_manager.speaker_name = self[id].name
                self.scene_manager.speaker_name_color = self[id].name_color

                event:run("on_character_speak", character, text)
            end)
        end
    })

    return character
end

function scene_environment:goto(name)
    self.scene_manager:add_instruction(function()
        self.scene_manager:goto_scene(name)
        print("Current scene: ", name)
    end)
end

function scene_environment:goto_if(scene_name)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local scene_name, conditional, other_scene_name = unpack(func_table)

        if self[conditional] then
            self.scene_manager:goto_scene(scene_name)
        else
            self.scene_manager:goto_scene(other_scene_name)
        end
    end)

    return func_table(scene_name)
end

function scene_environment:request_set_variable(table)
    local func_table = setmetatable({}, environment_func_mt)

    self.scene_manager:add_instruction(function()
        local table, key = unpack(func_table)
        
        event:run("show_name_panel", table, key)
        self.scene_manager.can_skip = false
    end)

    return func_table(table)
end

function scene_environment:hide_navbar()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.button_panel:hide()
        --self.scene_manager.state.background_panel.right_column:hide()
        event:run("hide_navbar")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:show_navbar()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.button_panel:show()
        --self.scene_manager.state.background_panel.right_column:show()
        event:run("show_navbar")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:hide_inventory()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.button_panel:hide()
        --self.scene_manager.state.background_panel.right_column:hide()
        event:run("hide_inventory")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:show_inventory()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.button_panel:show()
        --self.scene_manager.state.background_panel.right_column:show()
        event:run("show_inventory")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:hide_dialogue_box()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.dialogue_box:hide()
        event:run("hide_dialogue_box")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:show_dialogue_box()
    self.scene_manager:add_instruction(function()
        --self.scene_manager.state.background_panel.dialogue_box:show()
        event:run("show_dialogue_box")
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:wait(duration)
    self.scene_manager:add_instruction(function()
        self.scene_manager:add_update_function(tonumber(duration), function(time_passed) end)
    end)
end

function scene_environment:set_dialogue_background(background_string)
    self.scene_manager:add_instruction(function()
        self.scene_manager:set_dialogue_background(background_string)
        self.scene_manager:next_instruction()
    end)
end

function scene_environment:set_character_variable(character_string)
    return function(key)
        return function(value)
            self.script({function() 
                self[character_string][key] = value
            end})
        end
    end
end

function scene_environment:set_variable(key)
    return function(value)
        self.script({function()
            self[key] = value
        end})
    end
end

return scene_environment