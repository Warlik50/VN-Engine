local theme = {
    panel = {
        background_color = {0.3, 0.3, 0.4}
    }
}

local states = {
    "menu",
    "game",
    --"save_load",
    --"settings",
    --"gallery",
    --"splash"
}

local panel_methods = {
    {name = "pos", args = 2},
    {name = "size", args = 2},
    {name = "background_color", args = 4}
}

--when u click on a panel, show all of its optios to modify it

local selected_panel = nil

local state = {}

function state:on_first_enter()
    self.ui = ui:new()
    self.ui:install(self)
    self.ui:set_theme(theme)

    selected_panel = self.ui:add("panel")

    local right_panels = {}

    local right_panel = self.ui:add("panel")
    right_panel:set_width(200)
    right_panel:dock("right")

    function right_panel:set_active_panel(index)
        for i, panel in pairs(right_panels) do
            if i == index then
                panel:unhide()
            else
                panel:hide()
            end
        end
    end

        local states_panel = right_panel:add("scroll_panel")
        states_panel:dock("fill")

            local label = states_panel:add("label")
            label:set_text("States")
            label:set_align(5)
            label:dock("top")
            
        --opened when u click on a panel that is already added to the current state's panel
        local options_panel = right_panel:add("scroll_panel")
        options_panel:dock("fill")

            local label = options_panel:add("label")
            label:set_text("Options")
            label:set_align(5)
            label:dock("top")

            for _, method_data in pairs(panel_methods) do
                local row = options_panel:add("panel")
                row:dock("top")

                    local method_label = row:add("label")
                    method_label:set_text(method_data.name)
                    method_label:size_to_contents()
                    method_label:set_align(4)
                    method_label:set_font(assets.fonts[12])
                    method_label:dock("left")

                    local value_entry = row:add("text_entry")
                    value_entry:dock("fill")

                    value_entry:add_hook("on_enter_pressed", function(this)
                        print("hi")
                    end)

            end
        
        table.insert(right_panels, states_panel)
        table.insert(right_panels, options_panel)

    right_panel:set_active_panel(2)
end

--let u choose the fonts from fonts in the assets folder
--let u choose images from images in assets/graphics folder

return state

--popup like the name panel where you can name nouns in the game like a "book"
--fix the blinking