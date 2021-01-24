local state = {}

function state:on_first_enter()
    self.ui = ui.new()
    self.ui:install(self)

    self.main_menu_panel = self.ui:add("main_menu_panel")

    --self.music:setVolume(0.05)
    --self.music:setLooping(true)
    --self.music:play()
end

function state:on_enter()

end

function state:on_state_changed()

end

function state:on_enter()
    self.main_menu_panel:on_enter()
end

function state:wheelmoved(x, y)
    self.main_menu_panel:wheelmoved(x, y)
end

return state