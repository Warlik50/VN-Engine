local state = {}

function state:on_first_enter()
    self.can_continue = true

    self.ui = ui.new()
    self.ui:install(self)
    self.ui:uninstall_event("draw")

    self.ui:set_theme({
        panel = {
            background_color = {1, 1, 1},
            outline_width = 6
        },

        label = {
            text_color = {0, 0, 0}
        }
    })

    self.scene_manager = scene_manager
    self.scene_manager.state = self

    --should move this code to background_panel.lua, too lazy tho
    self.background_background_panel = self.ui:add("panel")
    self.background_background_panel:set_draw_outline(false)
    self.background_background_panel:set_background_color(colors.light_blue)
    --self.background_background_panel:set_image(assets.graphics.pattern2)
    self.background_background_panel:dock("fill")

    local bottom_panel = self.background_background_panel:add("panel")
    bottom_panel:set_draw_background(false)
    bottom_panel:set_draw_outline(false)
    bottom_panel:set_dock_padding(60, 10, 60, 0)
    bottom_panel:dock("bottom")

    --[[
        local history_button = bottom_panel:add("lockable_button")
        history_button:lock()
        history_button:set_text("History")
        history_button:set_width(history_button.font:getWidth("History") + 100)
        history_button:set_dropshadow(false)
        history_button:set_draw_background(false)
        history_button:set_draw_outline(false)
        history_button:set_text_color(colors.black)
        history_button:dock("left")

        history_button:add_hook("on_clicked", function(this)
            --open up history panel
        end)
        ]]
        
        local quick_load_button = bottom_panel:add("lockable_button")
        quick_load_button:set_text("Q. Load")
        quick_load_button:set_width(quick_load_button.font:getWidth("Q. Load") + 100)
        quick_load_button:set_dropshadow(false)
        quick_load_button:set_draw_background(false)
        quick_load_button:set_draw_outline(false)
        quick_load_button:set_text_color(colors.black)
        quick_load_button:dock("right")

        quick_load_button:add_hook("on_clicked", function(this)
            save_load_manager:load("1")
        end)

        local quick_save_button = bottom_panel:add("lockable_button")
        quick_save_button:set_text("Q. Save")
        quick_save_button:set_width(quick_save_button.font:getWidth("Q. Save") + 100)
        quick_save_button:set_dropshadow(false)
        quick_save_button:set_draw_background(false)
        quick_save_button:set_draw_outline(false)
        quick_save_button:set_text_color(colors.black)
        quick_save_button:dock("right")

        quick_save_button:add_hook("on_clicked", function(this)
            save_load_manager:save("1")
        end)

    self.background_panel = self.ui:add("background_panel", self, self.scene_manager)
    self.name_panel = self.ui:add("name_entry_panel", scene_manager)
    self.history_panel = self.ui:add("history_panel", scene_manager)

    event:add("post_load_save_data", function(save_data) 
        if save_data.hide_name_panel then
            self.name_panel:hide()
        else
            self.name_panel:unhide()
        end
    end)
end

function state:on_enter(new_game)
    
    if new_game then
        self.name_panel:hide()
        self:restart()
    end
end

function state:restart()
    self.scene_manager:restart()
    self.background_panel:restart()
end

function state:update(dt)
    if love.keyboard.isDown("lctrl") then
        --probably dont want to be able to skip unless you've been this far yet...
        self.scene_manager:next_instruction()
    end
end

--local test_image = assets.graphics.stefan.stefan_no_hatless
local test_image_w, test_image_h
local offset_y = 0
local should_draw_test_image = true

if test_image then
    test_image_w, test_image_h = test_image:getDimensions()
    love.keyboard.setKeyRepeat(true)
end 

local scale = 1

function state:draw()
    self.ui:draw()

    if test_image then
        --print(love.mouse.getPosition())
        if should_draw_test_image then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(test_image, love.mouse.getX(), love.graphics.getHeight() - test_image_h * scale + offset_y, 0, scale, scale)
        end

        local left = love.graphics.getWidth() / 4
        local right = love.graphics.getWidth() * (3 / 4)
        local center_left = love.graphics.getWidth() / 3
        local center_right = love.graphics.getWidth() * (2 / 3)
        local height = love.graphics.getHeight()
        local center = love.graphics.getWidth() / 2
        love.graphics.line(left, 0, left, height)
        love.graphics.line(right, 0, right, height)
        love.graphics.line(center, 0, center, height)
        love.graphics.line(center_left, 0, center_left, height)
        love.graphics.line(center_right, 0, center_right, height)
    end
end

function state:wheelmoved(x, y)
    if test_image then
        if y == 1 then
            scale = scale + 0.01
        elseif y == -1 then
            scale = scale - 0.01
        end

        print(scale, test_image:getHeight() * scale)
    end
end
--[[
function state:mousepressed(x, y, button)
    if button == 1 then
        local hovered_panel = self.ui.hovered_child 

        if hovered_panel then
            if not hovered_panel.hooks.on_mousepressed and not hovered_panel.hooks.on_clicked then
                self.scene_manager:next_instruction()
            end
        else
            self.scene_manager:next_instruction()
        end
    end
end
]]
local keybinds = {
    ["f1"] = function(state)
        save_load_manager:save("quicksave")
    end,

    ["f2"] = function(state)
        save_load_manager:load("quicksave")
    end,

    ["escape"] = function(state)
        states.set_current_state("menu")
    end,

    ["space"] = function(state)
        state.scene_manager:next_instruction()
    end,

    ["return"] = function(state)
        state.scene_manager:next_instruction()
    end,

    ["1"] = function(state)
        should_draw_test_image = not should_draw_test_image
    end
}

function state:keypressed(key)
    local func = keybinds[key]

    if func then
        func(self)
    end

    --this code is only relevant for scaling images when adding them to the game.
    if test_image then
        if key == "space" then
            local w, h = test_image:getDimensions()
            local canvas = love.graphics.newCanvas(math.floor(w * scale), math.floor(h * scale) - offset_y)

            love.graphics.setCanvas(canvas)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(test_image, 0, 0, 0, scale, scale)
            love.graphics.setCanvas()

            canvas:newImageData():encode("png", "helloworld.png")
        end

        print(key)
        if key == "up" then
            offset_y = offset_y - 1
            print("UP")
        elseif key == "down" then
            offset_y = offset_y + 1
        end
    end
end

return state