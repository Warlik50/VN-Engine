local panel = ui.get_element("panel")

local widget = class(panel)

function widget:init(scene_manager)
    panel.init(self)
    self.scene_manager = scene_manager
end

function widget:post_init()
    panel.post_init(self)

    self:hide()
    self:dock("fill")
    self:set_draw_background(false)
    self:set_draw_outline(false)

    local panel_width = 400
    local panel_height = 200

    local center_panel = self:add("panel")
    center_panel:set_size(panel_width, panel_height)
    center_panel:center()

        self.name_text_entry = center_panel:add("text_entry")
        --name_text_entry:add_hook("on_enter_pressed", function() self:confirm_name(name_text_entry:get_text()) end)
        self.name_text_entry:set_text(nil)
        self.name_text_entry:dock("top")

        self.name_text_entry:add_hook("on_enter_pressed", function() self:confirm_name(self.name_text_entry:get_text()) end)

        
        local confirm_button = center_panel:add("button")
        confirm_button:set_text("Confirm")
        confirm_button:add_hook("on_clicked", function() self:confirm_name(self.name_text_entry:get_text()) end)
        confirm_button:dock("top")
        

    self:size_to_contents()
    event:add("show_name_panel", self)
end

function widget:show_name_panel(table, key)
    self.name_text_entry:set_text(nil)
    self.ui_manager:set_focus(self.name_text_entry)

    self.table = table
    self.key = key

    self:unhide()
end

--dont let the players name freakin' break the game!!
function widget:confirm_name(name)
    if self.name_text_entry:get_text() == "" then
        return
    end

    if not self.key then
        self.key = self.table
        self.table = self.scene_manager.scene_environment
    end
    
    self.table[self.key] = name

    self:hide()
    self.scene_manager.can_skip = true
    self.scene_manager:next_instruction()
end

return widget