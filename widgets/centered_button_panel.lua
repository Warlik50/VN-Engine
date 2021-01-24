local panel = ui.get_element("panel")

local widget = ui.class(panel)

function widget:init()
    panel.init(self)
end

function widget:post_init()
    panel.post_init(self)

    self.inner_panel = self:add("panel")
    self.inner_panel:set_draw_background(false)
    self.inner_panel:set_draw_outline(false)
    self.inner_panel:dock("fill")

    self.inner_panel:add_hook("on_validate", function(this)
        local total_height = 0

        for k, child in pairs(self.inner_panel.children) do
            local margin = child:get_dock_margin()
            total_height = total_height + child:get_height() + margin[2] + margin[4]
        end

        this:set_height(total_height)
        this.y = self:get_height() / 2 - self.inner_panel:get_height() / 2
    end)
end

function widget:add_centered(...)
    local widget2 = self.inner_panel:add(...)
    widget2:dock("top")

    if self.children_dock_margin then
        widget2:set_dock_margin(self.children_dock_margin)
    end

    return widget2
end

function widget:set_children_dock_margin(left, top, right, bottom)
    self.children_dock_margin = type(left) == "table" and left or {left, top, right, bottom}

    for k, v in pairs(self.inner_panel.children) do
        v:set_dock_margin(self.children_dock_margin)
    end
end

return widget