assets              = require("assets")
animation           = require("libraries.animation")
bitser              = require("libraries.bitser")
class               = require("libraries.class")
event               = require("libraries.event")
ui                  = require("libraries.storm_ui")
util                = require("libraries.util")
timer               = require("libraries.timer")
states              = require("libraries.state")
colors              = require("colors")
scene_manager       = require("scene_manager")
save_load_manager   = require("save_load_manager")

require("widgets")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    scene_manager = scene_manager.new()

    save_load_manager = save_load_manager.new(scene_manager)
    save_load_manager:load_globals()

    scene_manager:load_scenes() --explicitly wanting to load scenes after save_load_manager exists for globals

    states.load_states("states")
    states.set_current_state("menu")
end

function love.update(dt)
    timer.update(dt)
    scene_manager:update(dt)
    states.current_state:update(dt)
end

function love.quit()
    save_load_manager:save_globals()
end

--when scaling resolution up or down:
--squeeze or stretch left and right
--preserve text size
--zoom in height so that it takes the full height of the window, and you squeeze or stretch the left and right

--it depends on "what the problem is" but you can alsos cale to the width, and clip off the hieght
--important things: character art, text, try to preserve 
--make sure to scale character art up or down based on screen resolution

--for testing change screen resolution to different sizes to see how it affects the game code