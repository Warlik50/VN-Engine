local centered_button_panel = ui.get_element("centered_button_panel")  --this might not work because we don't know the order these files will get loaded in
local button = ui.get_element("button")

local widget = class(centered_button_panel)

function widget:init(scene_manager)
    centered_button_panel.init(self)

    self.scene_manager = scene_manager
    self.total_choices = 0
    self.longest_choice_width = 0
end

function widget:post_init()
    centered_button_panel.post_init(self)

    self:set_draw_background(false)
    self:set_draw_outline(false)
    self:set_children_dock_margin(0, 40, 0, 40)

    --might be better firing off an event from scene manager...
    self.inner_panel:add_hook("on_update", function(this, dt)
        local choices = self.scene_manager.choices

        if choices and self.total_choices == 0 then
            for i = 1, #choices, 2 do
                local choice = self:add_choice(choices[i], choices[i + 1])
            end
        end

        if not choices or #choices == 0 then
            self:clear_choices()
        end
    end)
end

function widget:clear_choices()
    self:hide()

    self.inner_panel:remove_children()
    self.total_choices = 0
    self.longest_choice_width = 0
end

function widget:add_choice(text, scene_name)
    self:unhide()

    self.total_choices = self.total_choices + 1
    local choice_index = self.total_choices

    local choice = self:add_centered("lockable_button")
    choice:set_font(assets.fonts[50])
    choice:set_text(text)
    choice:set_height(80)
    choice:set_outline_radius(choice:get_height() / 2, choice:get_height() / 2)
    choice:set_outline_color(0, 0, 0)
    choice:set_background_color(colors.white)
    choice:set_text_color(colors.black)
    choice:set_dropshadow(false)
    choice:set_outline_color(colors.black)
    
    choice.hovered_font = assets.fonts[49]
    choice.depressed_font = assets.fonts[46]
    choice.dialogue_font = assets.fonts[48]

    choice:add_hook("on_clicked", function(this)
        self.scene_manager:select_choice(choice_index)
        self:clear_choices()
    end)

    local total_width = choice.font:getWidth(text)

    if total_width > self.longest_choice_width then
        self.longest_choice_width = total_width
    end

    for k, child in pairs(self.inner_panel.children) do
        local margin = child:get_dock_margin()
        local margin_w = (self.inner_panel:get_width() - self.longest_choice_width) / 2 - 20
        child:set_dock_margin(margin_w, margin[2], margin_w, margin[4])
    end

    return choice
end

return widget