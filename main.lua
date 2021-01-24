assets = require("assets")
animation = require("libraries.animation")
bitser = require("libraries.bitser")
class = require("libraries.class")
event = require("libraries.event")
ui = require("libraries.storm_ui")
util = require("libraries.util")
timer = require("libraries.timer")
states = require("libraries.state")
colors = require("colors")
scene_manager = require("scene_manager")
save_load_manager = require("save_load_manager")

require("widgets")

function love.load()
    local w, h = love.window.getDesktopDimensions()

    if not (w == 1920) or not (h == 1080) then
        love.window.setMode(1920, 1080)
    end

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