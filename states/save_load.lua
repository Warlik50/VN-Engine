local state = {}

function state:on_first_enter()
    self.ui = ui.new()
    self.ui:install(self)
    self.ui:uninstall_event("keypressed")



    self.background_panel = self.ui:add("panel")
    self.background_panel:set_background_color(colors.light_blue)
    self.background_panel:dock("fill")


    self.save_panels = {}
    
    self.current_page = 1

    local scale = 30
    local i = 0
    local offset = 20
    local shadow_offset = 8

    local center_x, center_y = love.graphics.getDimensions()
    center_x = center_x / 2
    center_y = center_y / 2
    local number_x = 3
    local number_y = 2

    for y = 0, number_y - 1 do
        for x = 0, number_x - 1 do
            i = i + 1
            local save_slot = i

            local save_panel = self.background_panel:add("panel")
            save_panel:set_size(16 * scale, 9 * scale) --16 x 9 aspect ratio
            save_panel:set_background_color(1, 1, 1)
            save_panel:set_outline_radius(20, 20)
            save_panel:set_outline_width(6)

            save_panel:set_pos(
                center_x - save_panel:get_width() * number_x / 2 + x * save_panel:get_width(),
                center_y - save_panel:get_height() * number_y / 2 + y * save_panel:get_height()
            )
            
            local bottom_panel = save_panel:add("panel")
            bottom_panel:set_draw_outline(false)
            bottom_panel:set_draw_background(false)
            bottom_panel:dock("bottom")

                local buttons = {
                    {"Clear", function()
                        if not save_load_manager:save_exists(save_slot) then
                            return
                        end

                        save_load_manager:delete(save_slot) 
                        self:load_current_page() 
                    end},

                    {"Load", function()
                        if not save_load_manager:save_exists(save_slot) then
                            return
                        end

                        states.set_current_state("game", true) 
                        save_load_manager:load(save_slot) 
                    end},

                    {"Save", function() 
                        if not states.get_state("game").can_continue then 
                            return 
                        end 

                        save_load_manager:save(save_slot) 
                        self:load_current_page() 
                    end}
                }

                for k, v in pairs(buttons) do
                    local button = bottom_panel:add("lockable_button")
                    button:set_text(v[1])
                    button:add_hook("on_clicked", v[2])
                    button:dock("right")
                end

            table.insert(self.save_panels, save_panel)

                save_panel.time_label = save_panel:add("label")
                save_panel.time_label:dock("bottom")

                save_panel.player_name_label = save_panel:add("label")
                save_panel.player_name_label:dock("bottom")

        end
    end
end

function state:on_enter()
    self:load_current_page()
end

function state:keypressed(key)
    self.ui:keypressed(key)

    if key == "escape" then
        states.set_current_state("menu")
    end
end

function state:load_current_page()
    for i, save_panel in pairs(self.save_panels) do
        local save_name = tostring(i * self.current_page)
        local save_data = save_load_manager:get_save_data(save_name)
        local name, time, image

        if save_data then
            name = save_data.variables.player.name
            time = save_data.time
            image = love.graphics.newImage(love.image.newImageData(love.data.newByteData(save_data.background_image_data)))
        end

        save_panel.time_label:set_text(time)
        save_panel.player_name_label:set_text(name or "Slot " .. i * self:get_current_page())
        save_panel:set_image(image)
    end
end

function state:get_current_page()
    return self.current_page
end

return state