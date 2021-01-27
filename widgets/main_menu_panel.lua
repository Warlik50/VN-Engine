local panel = ui.get_element("panel")

local widget = class(panel)

function widget:post_init()
    panel.post_init(self)

    self:set_auto_stretch(true)
    self:set_background_color(colors.light_blue)
    self:dock("fill")

    local panel = self:add("scroll_panel")
    panel:set_size(200, 200)

        for i = 1, 10 do
            local button = panel:add("button")
            button:dock("top")
        end

        local panel = self:add("panel")
        panel:set_draw_background(false)
        panel:set_draw_outline(false)
        panel:set_width(260)
        panel:set_dock_padding(0, 200, 0, 200)
        panel:set_pos(156, 208)
        panel:set_height(love.graphics.getHeight())
        


        
            local centered_panel = panel:add("centered_button_panel")
            centered_panel:set_draw_background(false)
            centered_panel:set_draw_outline(false)
            centered_panel:set_children_dock_margin(20, 40, 40, 20)
            centered_panel:dock("fill")

                --returns you to the game state if you've already been in it, else loads last created save file.
                self.continue_button = centered_panel:add_centered("lockable_button")
                self.continue_button:add_hook("on_clicked", function() states.set_current_state("game") print("DOPES THIS HAPPEN") end)
                self.continue_button:set_text("Continue")

                self.new_button = centered_panel:add_centered("lockable_button")
                self.new_button:add_hook("on_clicked", function() states.set_current_state("game", true) end)
                self.new_button:set_text("New Game")

                --lets you save over an existing save or create a new save
                self.save_button = centered_panel:add_centered("lockable_button")
                self.save_button:add_hook("on_clicked", function() states.set_current_state("save_load") end)
                self.save_button:set_text("Save/Load")

                --[[
                self.load_button = centered_panel:add_centered("lockable_button")
                self.load_button:add_hook("on_clicked", function() states.set_current_state("save_load", {load = true}) end)
                self.load_button:set_text("Load")
                ]]

                --[[
                self.gallery_button = centered_panel:add_centered("lockable_button")
                self.gallery_button:add_hook("on_clicked", function() states.set_current_state("gallery") end)
                self.gallery_button:set_text("Gallery")
                ]]


                self.quit_button = centered_panel:add_centered("lockable_button")
                self.quit_button:add_hook("on_clicked", function() love.event.quit() end)
                self.quit_button:set_text("Quit")


        local scr_w, scr_h = love.graphics.getDimensions()
        local offset = 18
end

function widget:on_enter()
    
    self.continue_button:lock()
    --self.save_button:lock()
    --self.load_button:lock()

    if states.get_state("game").can_continue then
        self.continue_button:unlock()
        --self.save_button:unlock()
    end
--[[
    if love.filesystem.getInfo("saves") then
        self.load_button:unlock()
    end
    ]]
end

function widget:wheelmoved(x, y)

end

return widget