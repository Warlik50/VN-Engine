local panel = ui.get_element("panel")

local widget = class(panel)

function widget:init(scene_manager)
    self.scene_manager = scene_manager
    panel.init(self)
end

function widget:post_init()
    panel.post_init(self)
    self:dock("fill")
    self:hide()

    self.scroll = self:add("scroll_panel")
    self.scroll:dock("fill")

    event:add("post_load_save_data", function()
        --clear out the existing stuff
        --add in all new history stuff
    end)
end

function widget:add_thing()
    local panel = self.scroll:add("panel")
    panel:set_height(100)
    panel:dock("top")
end

return widget

