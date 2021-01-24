local state = {}

function state:on_first_enter()
    self.ui = ui.new()
    self.ui:install(self)

    self.back_button = self.ui:add("button")
    self.back_button:set_text("Back")

    self.fullscreen_label = self.ui:add("label")
    self.fullscreen_label:set_text("Fullscreen")
    self.fullscreen_label:set_pos(400, 380)
    
    self.fullscreen_checkbox = self.ui:add("checkbox")
    self.fullscreen_checkbox:add_hook("on_checked", function() love.window.setFullscreen(true) end)
    self.fullscreen_checkbox:add_hook("on_unchecked", function() love.window.setFullscreen(false) end)
    self.fullscreen_checkbox:set_pos(400, 400)
end

function state:on_enter(last_state)
    self.back_button:remove_hook("on_clicked", self.back_func)
    self.back_func = function() states.set_current_state(last_state) end
    self.back_button:add_hook("on_clicked", self.back_func)

    if love.window.getFullscreen() then
        self.fullscreen_checkbox:check_internal()
    else
        self.fullscreen_checkbox:uncheck_internal()
    end
end

return state