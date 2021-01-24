

local button = ui.get_element("button")

local widget = class(button)

function widget:post_init()
    button.post_init(self)

    self.should_draw_shadow = true

    local height = self:get_height()



    self:set_background_color(colors.orange)
    self:set_outline_radius(height / 2, height / 2)  
    self:set_outline_color(1, 1, 1)
    self:set_outline_width(5)
    self:set_dropshadow(true)
    self:set_draw_hovered(false)
    self:set_draw_depressed(false)

    --[[
    self:set_draw_background(false)
    self:set_draw_outline(false)
    ]]


    self.size_x, self.size_y = self:get_size()
    self.margins = {0, 0, 0, 0}
    self.shadow_offset = 8

    local size_change = 4
    local half_size = size_change / 2




    self:add_hook("pre_draw_no_scissor", function(this)
        if not this.should_draw_shadow then
            return
        end

        local offset = this.shadow_offset

        love.graphics.translate(offset, offset)
            love.graphics.setColor(0, 0, 0, 0.5)
            this:draw_background()
        love.graphics.translate(-offset, -offset)
    end)
end

function widget:set_size(x, y)
    button.set_size(self, x, y)
    self.size_x, self.size_y = x, y
end

function widget:set_width(w)
    button.set_width(self, w)
    self.size_x = w
end

function widget:set_dock_margin(left, top, right, bottom)
    button.set_dock_margin(self, left, top, right, bottom)
    self.margins = type(left) == "table" and left or {left, top, right, bottom}
end

function widget:set_draw_shadow(bool)
    self.should_draw_shadow = bool
end

function widget:lock()
    if self.locked then
        return
    end

    self.locked = true

    self.locked_on_clicked = self.hooks.on_clicked
    self:remove_hooks("on_clicked")

    self:set_text_color(0.4, 0.4, 0.4)
    self:set_depressed_color(0, 0, 0, 0)
    self:set_hovered_color(0, 0, 0, 0)
end

function widget:unlock()
    if not self.locked then
        return
    end

    self.locked = false
    self.hooks.on_clicked = self.locked_on_clicked

    self:set_text_color(self.ui_manager.theme.label.text_color)
    self:set_depressed_color(self.ui_manager.theme.button.depressed_color)
    self:set_hovered_color(self.ui_manager.theme.button.hovered_color)
end

return widget