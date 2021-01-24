local save_load_manager = class()

function save_load_manager:init(scene_manager)
    self.scene_manager = scene_manager
    self.last_save_name = nil --this should be stored in the global save
    self.globals = {}  --persistent variables that exist regardless of what save you load, loaded at the start of the game, and saved even if you dont want them to be.

    event:add("on_add_global_save_variable", function(k, v)
        self.globals[k] = v
        self:save_globals()
    end)
end

function save_load_manager:save(save_name)
    print("Saving - ", save_name, type(save_name))
    local canvas = love.graphics.newCanvas()
    local old_color = {love.graphics.getColor()}

    love.graphics.setCanvas({canvas, stencil = true})
        love.graphics.setColor(1, 1, 1)
            states.get_state("game"):draw()
        love.graphics.setColor(old_color)
    love.graphics.setCanvas()

    local drawables = {}

    for character_string, drawable in pairs(self.scene_manager.drawables) do
        drawables[character_string] = {
            image_string = drawable.image_string,
            align = drawable.align
        }
    end

    local save_data = {
        scene_data = {
            --also need to save: speaker_text_color, speaker_name_color
            scene = self.scene_manager.current_scene,
            scene_instruction = self.scene_manager.current_scene_instruction,
            choices = self.scene_manager.choices,
            speaker_name = self.scene_manager.speaker_name,
            speaker_text = self.scene_manager.speaker_text,
            background = self.scene_manager.background_string,
            dialogue_background = self.scene_manager.dialogue_background_string,
            music = self.scene_manager.music_string,
            target_music_volume = self.scene_manager.target_music_volume,
            drawables = drawables
        },

        
        variables = {},
        
        time = os.date("%c"),
        background_image_data = canvas:newImageData():encode("png"):getString(),
        hide_name_panel = not states.get_state("game").name_panel:get_visible(),
    }

    for k, v in pairs(self.scene_manager.scene_environment.__save_variables) do
        local type_k, type_v = type(k), type(v)

        --only save primitive data types, not functions or userdata, etc...
        if type_k == "string" and (type_v == "string" or type_v == "number" or type_v == "boolean" or type_v == "table") then
            print("save variable", k, v)
            save_data.variables[k] = v
        end

    end

    print("Saveing bitser data...")

    if not love.filesystem.getInfo("saves", "directory") then
        love.filesystem.createDirectory("saves")
    end

    love.filesystem.write("saves/" .. save_name .. ".txt", bitser.dumps(save_data))
end

function save_load_manager:get_save_data(save_name)
    local file_name = "saves/" .. save_name .. ".txt"

    if not self:save_exists(save_name) then
        return
    end

    return bitser.loads(love.filesystem.read(file_name))
end

function save_load_manager:save_exists(save_name)
    local file_name = "saves/" .. save_name .. ".txt"

    if not love.filesystem.getInfo(file_name) then
        return false
    end

    return true
end

function save_load_manager:load(save_name)
    print("loading - ", save_name, type(save_name))
    local save_data = self:get_save_data(save_name)

    if not save_data then
        assert("Tried to load non existent save_data!")
        return
    end

    local scene_data = save_data.scene_data  --ERRORed HERE
    
    self.scene_manager:restart()

    self.scene_manager:goto_scene(scene_data.scene)
    self.scene_manager.current_scene_instruction = scene_data.scene_instruction
    self.scene_manager.choices = scene_data.choices
    self.scene_manager.speaker_name = scene_data.speaker_name
    self.scene_manager.speaker_text = scene_data.speaker_text
    self.scene_manager.speaker_current_text = scene_data.speaker_text

    for character_string, drawable in pairs(save_data.scene_data.drawables) do
        self.scene_manager:add_drawable(character_string, drawable.image_string, drawable.align)
    end

    if scene_data.background then
        self.scene_manager:set_background(scene_data.background)
    end

    if scene_data.dialogue_background then
        self.scene_manager:set_dialogue_background(scene_data.dialogue_background)
    end

    if scene_data.music then
        local volume = scene_data.target_music_volume
        self.scene_manager:set_music(scene_data.music, volume, volume)
    end

    for k, v in pairs(save_data.variables) do
        self.scene_manager.scene_environment[k] = v
        print("LOADING VARIABLE", k, v)
    end

    event:run("post_load_save_data", save_data)
end

function save_load_manager:delete(save_name)
    love.filesystem.remove("saves/" .. save_name .. ".txt")
end

function save_load_manager:save_globals()
    --happens when closing the game
    love.filesystem.write("globals.txt", bitser.dumps(self.globals))
end

function save_load_manager:load_globals()
    if love.filesystem.getInfo("globals.txt", "file") then
        self.globals = bitser.loads(love.filesystem.read("globals.txt"))
    end
    --loads the data that persists, regardless of what save you load. permanent saved stuff like achievements or anything else.
end

return save_load_manager