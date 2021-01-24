--give it access to some ui to draw on, add panels etc...
--give it access to timer in game state for timing functions to clean those up
local scene_environment = require("scene_environment")

local scene_manager = class()

function scene_manager:init()
    self.scene_environment = scene_environment.new(self)
    self.scenes = {}
    self.current_scene = "start"
    self.current_scene_instruction = 0
    self.choices = nil

    self.__scene_object = nil

    self.autoplay = false  --get this value based on save data
    self.autoplay_duration = 4  --how long after the words finished before it will try to call next on its own
    self.autoplay_time_passed = 0

    self.speaker_name = nil
    self.speaker_text = nil
    self.speaker_current_text = nil  --the text the player sees, gets updated every frame or whatever until it shows the full speaker_text.
    self.speaker_letter_time_passed = 0
    self.speaker_letter_duration = 1 / 180  --TODO make this use the default text speed
    self.speaker_letter_duration = 1/ 90

    self.speaker_text_color = {1, 1, 1}
    self.speaker_name_color = {1, 1, 1}
    
    self.background_image = nil
    self.background_color = {1, 1, 1, 1}
    self.last_background_image = nil
    self.last_background_color = {1, 1, 1, 1}
    
    self.drawables = {}
    self.update_functions = {}
    self.buttons = {}
    
    self.target_music_volume = nil
    self.current_music = nil
    self.current_voice = nil

    self.can_skip = true
end

function scene_manager:restart()
    self.scene_environment = scene_environment.new(self)
    self:load_scenes()

    self.can_skip = true
    self.current_scene = "start"
    self.current_scene_instruction = 0
    self.autoplay_time_passed = 0

    self:clear_speaker_info()        
    self:clear_background()
    self:clear_choices()

    self:remove_drawables()
    self:clear_update_functions()

    self:stop_music()
    self:stop_voice()
end

function scene_manager:asset_from_string(first_folder, string)
    print(first_folder, string)
    local asset = assets[first_folder]
    local pattern = "[%w_]+"

    for key in string:gmatch(pattern) do
        asset = asset[key]
    end

    return asset
end

function scene_manager:load_scenes()
    local file_paths = {}

    for _, file_path in pairs(love.filesystem.getDirectoryItems("scenes")) do
        table.insert(file_paths, "scenes/" .. file_path)
    end

    --start.lua needs to load first
    table.sort(file_paths, function(a, b)
        return a == "scenes/start.lua"
    end)

    for k, file_path in pairs(file_paths) do
        --loads the script chunk, letting it make use of the functions in the script environment, then runs it.
        setfenv(love.filesystem.load(file_path), self.scene_environment)()
    end
end

function scene_manager:goto_scene(name) 
    assert(self.scenes[name], name .. " isn't a valid scene name.")
    print(name)

    self:clear_choices()
    self:clear_speaker_info()

    self.current_scene = name
    self.current_scene_instruction = 0
    --self:next_instruction()
end

function scene_manager:goto_scene_instruction(name, instruction)
    print("GOTO SCENE INSTRUCTION", name, instruction)
    assert(self.scenes[name], name .. " isn't a valid scene name.")

    self:clear_speaker_info()

    self.current_scene = name
    self.current_scene_instruction = tonumber(instruction)

    --self:next_instruction()
    --for loading
    --how am I gonna make sure the music, background
    --characters on screen and whatever else are there?
end

function scene_manager:force_next_instruction()
    self.current_scene_instruction = self.current_scene_instruction + 1

    local next = self.scenes[self.current_scene][self.current_scene_instruction]

    if next then
        self.speaker_letter_time_passed = 0
        next()
    end
end

function scene_manager:next_instruction()
    self.autoplay_time_passed = 0

    --finish any lerping functions, then remove them
    for _, update_table in pairs(self.update_functions) do
        --ghetto way of finishing the lerp function... TODO make it not so ghetto?
        update_table.func(update_table.duration)
    end

    self:clear_update_functions()

    if self.speaker_current_text == self.speaker_text and not self.choices and self.can_skip then
        --i think that we're not getting to see the choices because its too far ahead of chocies because force next instruction 
        self:force_next_instruction()
    else
        --if you try to skip to the next instruction, but text isn't complete, complete it.
        self.speaker_current_text = self.speaker_text
    end
end

function scene_manager:add_instruction(instruction)
    table.insert(self.__scene_object, instruction)
end

function scene_manager:add_update_function(duration, func)
    table.insert(self.update_functions, {
        time_passed = 0,
        duration = duration,
        func = func
    })
end

local alignment = {
    center = function(image)
        return love.graphics.getWidth() / 2 - image:getWidth() / 2
    end,

    left = function(image)
        return love.graphics.getWidth() / 4 - image:getWidth() / 2
    end,

    right = function(image)
        return love.graphics.getWidth() * 3 / 4 - image:getWidth() / 2
    end,

    center_left = function(image)
        return love.graphics.getWidth() / 3 - image:getWidth() / 2
    end,

    center_right = function(image)
        return love.graphics.getWidth() * (2 / 3) - image:getWidth() / 2
    end
}

function scene_manager:alignment(align, image)
    return alignment[align](image)
end

function scene_manager:add_drawable(character, image_string, align)
    local is_animation
    --if the image is an animation then...
    local image = self:asset_from_string("graphics", self.scene_environment[character].asset_lookup .. "." .. image_string)
    
    local drawable = {
        x = assert(alignment[align], "Alignment not valid: " .. align)(image),
        y = love.graphics.getHeight() - image:getHeight(),
        image_string = image_string,
        image = image,
        offset_x = 0,
        offset_y = 0,
        color = {1, 1, 1, 1},
        align = align,
        last_drawable = nil
    }

    self.drawables[character] = drawable

    return drawable
end

function scene_manager:remove_drawable(character)
    self.drawables[character] = nil
end

function scene_manager:remove_drawables()
    self.drawables = {}
end

function scene_manager:clear_background()
    self.background_image = nil
    self.background_color = {1, 1, 1, 1}
    self.last_background_image = nil
    self.last_background_color = {1, 1, 1, 1}
end

function scene_manager:clear_update_functions()
    self.update_functions = {}
end

function scene_manager:clear_speaker_info()
    self.speaker_name = nil
    self.speaker_text = nil
    self.speaker_current_text = nil
    self.speaker_letter_time_passed = 0
end

function scene_manager:clear_choices()
    self.choices = nil
end

function scene_manager:select_choice(choice)
    if self.choices then
        choice = tonumber(choice)
        
        if choice then
            --choices table might look like this {"This is a choice", "scene_name", "This is another choice", "different_scene_name"}
            local scene_name = self.choices[choice * 2]

            if scene_name then
                self:goto_scene(scene_name)
                self:clear_choices()
            end
        end
    end
end

function scene_manager:set_dialogue_background(background_string)
    event:run("set_dialogue_background", self:asset_from_string("graphics", background_string))
    self.dialogue_background_string = background_string
end

function scene_manager:set_background(background_string)
    self.last_background_image = self.background_image
    self.last_background_color = {unpack(self.background_color)}

    self.background_image = self:asset_from_string("graphics", "backgrounds." .. background_string)
    self.background_image_width, self.background_image_height = self.background_image:getDimensions()
    self.background_string = background_string
end

function scene_manager:set_music(music_string, volume, target_volume, should_stop_music)
    if should_stop_music then
        self:stop_music()
    end
        
    local music = self:asset_from_string("audio", music_string)

    assert(volume, "No Volume in Set Music")
    assert(target_volume, "No Target Volume in Set Music")

    if music then
        music:setLooping(true)

        if volume then
            music:setVolume(volume)
        end

        music:play()

        self.target_music_volume = target_volume
        self.current_music = music
        self.music_string = music_string
        
        return music
    end
end

function scene_manager:stop_music()
    if self.current_music then
        self.current_music:stop()
        self.current_music = nil
        self.target_music_volume = nil
        self.music_string = nil
    end
end

function scene_manager:stop_voice()
    if self.current_voice then
        self.current_voice:stop()
        self.current_voice = nil
    end
end

function scene_manager:update(dt)
    local full_text = self.speaker_text
    local current_text = self.speaker_current_text

    if full_text and not (full_text == current_text) then
        self.speaker_letter_time_passed = self.speaker_letter_time_passed + dt

        --[[
        local current_letter = full_text:sub(#current_text, #current_text)

        --TODO, make it here that if the current letter is any length number of consecutive punctuation marks, but doesnt cntain the last punctuation mark, 
        --use the speaker_sentence_duration or whatever variable from the config instead of speaker_letter_duration

        if self.speaker_letter_time_passed >= self.speaker_letter_duration then
            self.speaker_letter_time_passed = self.speaker_letter_time_passed % self.speaker_letter_duration
            self.speaker_current_text = full_text:sub(1, #current_text + 1)
        end]]

        local letter_position = util.math.round(self.speaker_letter_time_passed / (self.speaker_letter_duration * #full_text) * #full_text)
        self.speaker_current_text = full_text:sub(1, math.min(#full_text, letter_position))
    end

    for k, update_table in pairs(self.update_functions) do
        local duration = update_table.duration
        local func = update_table.func

        update_table.time_passed = update_table.time_passed + dt

        func(update_table.time_passed)

        if update_table.time_passed >= duration then
            table.remove(self.update_functions, k)
        end
    end

    --if text is complete and no lerpers and no choices, we're ready to move on
    if #self.update_functions == 0 and not self.choices then
        if self.speaker_text then
            if self.speaker_text == self.speaker_current_text and self.autoplay then
                self.autoplay_time_passed = self.autoplay_time_passed + dt
            
                if self.autoplay_time_passed >= self.autoplay_duration then
                    if not (self.current_voice and self.current_voice:isPlaying()) then
                        self:next_instruction()
                    end
                end
            end
        else
            self:next_instruction()
        end
    end
end

function scene_manager:draw(scr_w, scr_h)
    scr_w = scr_w or love.graphics.getWidth()
    scr_h = scr_h or love.graphics.getHeight()

    love.graphics.setFont(assets.fonts[18])

    local last_background = self.last_background_image

    if last_background then
        local w, h = last_background:getDimensions()
        local width_shorter = w < h
        local new_scale = width_shorter and (scr_h / h) or (scr_w / w)

        love.graphics.setColor(self.last_background_color)
        love.graphics.draw(last_background, scr_w / 2, scr_h / 2, 0, new_scale, new_scale, w / 2, h / 2)
    end

    local background = self.background_image

    if background then
        local w, h = background:getDimensions()
        local width_shorter = w < h
        local new_scale = width_shorter and (scr_h / h) or (scr_w / w)

        love.graphics.setColor(self.background_color)
        love.graphics.draw(background, scr_w / 2, scr_h / 2, 0, new_scale, new_scale, w / 2, h / 2)
    end
    
    local dt = love.timer.getDelta()

    for character, drawable in pairs(self.drawables) do
        love.graphics.setColor(drawable.color)

        if drawable.is_animation then
            drawable.image:update(dt)
            drawable.image:draw(drawable.x, drawable.y)
        else
            love.graphics.draw(drawable.image, drawable.x, drawable.y)
        end

        local last_drawable = drawable.last_drawable

        if last_drawable then
            love.graphics.setColor(last_drawable.color)

            if last_drawable.is_animation then
                last_drawable.image:update(dt)
                last_drawable.image:draw(drawable.x, drawable.y)
            else
                love.graphics.draw(last_drawable.image, last_drawable.x, last_drawable.y)
            end
        end
    end
    --[[
    if scene_manager.choices then
        for i = 1, #scene_manager.choices, 2 do
            local choice_text = scene_manager.choices[i]
            local scene_name = scene_manager.choices[i + 1]

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(choice_text)
        end
    end
    ]]
end

return scene_manager