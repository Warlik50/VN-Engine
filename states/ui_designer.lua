local theme = {
    panel = {
        background_color = colors.ui_black,
        outline_color = colors.ui_grey3,
    },

    button = {
        depressed_color = colors.ui_grey1,
        hovered_color = colors.ui_grey2
    },

    label = {
        font = assets.fonts[12],
        text_color = colors.ui_white,
    }
}

local design_width = 1920
local design_height = 1080
local scale = 1

local state = {}

function state:on_first_enter()
    self.ui = ui:new()
    self.ui:install(self)
    self.ui:set_theme(ui.base_theme)

    self.selected_panel = nil

    local right_panel = self.ui:add("panel")
    right_panel:set_width(300)
    right_panel:dock("right")

        local right_top_panel = right_panel:add("blank_panel")
        right_top_panel:set_draw_outline(false)
        right_top_panel:dock("top")

        right_top_panel:add_hook("on_update", function(this)
            this:set_height(this:get_parent():get_height() / 2)
        end)

            local hierarchy_label = right_top_panel:add("label")
            hierarchy_label:set_text("Hierarchy")
            hierarchy_label:set_align(5)
            hierarchy_label:set_text_color(colors.ui_light_blue)
            hierarchy_label:dock("top")

            local hierarchy_panel = right_top_panel:add("scroll_panel")
            hierarchy_panel:set_draw_outline(false)
            hierarchy_panel:dock("fill")

            function hierarchy_panel.refresh(this)
                this:remove_children()

                for k, v in pairs(self.design_panel.children) do
                    local button = this:add("button")
                    button:set_text(v.element_name)
                    button:set_align(4)
                    button:dock("top")

                    button:add_hook("on_clicked", function(this)
                        for k, v in pairs(hierarchy_panel:get_children()) do
                            v:set_background_color(v.ui_manager.theme.panel.background_color)
                        end

                        self.selected_panel = v
                        this:set_background_color(this:get_depressed_color())
                    end)

                    if self.selected_panel == v then
                        button:run_hooks("on_clicked")
                    end
                end
            end
            
            --hierarchy panel has buttons docked to the top, shows all children in the deisgn window
            --button pressing highlights buttons background color to show its selected, then makes it the selected panel
            --can now modify properties of selected panel


        local right_bottom_panel = right_panel:add("blank_panel")
        right_bottom_panel:set_draw_outline(false)
        right_bottom_panel:dock("fill")

            local properties_label = right_bottom_panel:add("label")
            properties_label:set_text("Properties")
            properties_label:set_align(5)
            properties_label:set_text_color(colors.ui_light_blue)
            properties_label:dock("top")

            local properties_panel = right_bottom_panel:add("scroll_panel")
            properties_panel:set_draw_outline(false)
            properties_panel:dock("fill")



    local viewport_panel = self.ui:add("blank_panel")
    viewport_panel:dock("fill")

        local design_panel = viewport_panel:add("panel")
        self.design_panel = design_panel
        design_panel:set_draw_outline(false)

        design_panel:add_hook("on_update", function(this, dt)
            this:center()
            this:set_width(viewport_panel:get_width())
            this:set_height(this:get_width() * (design_height / design_width))

            scale = (this:get_width() / design_width)
        end)

        function design_panel.add_element(this, ui_element)
            local element = this:add(ui_element)

            self.selected_panel = element
            hierarchy_panel:refresh()

            return element
        end

        design_panel:add_element("panel")
        design_panel:add_element("button")

end
--customize theme, add panels/buttons/labels/etc..., move panels and resize, load/export designs, 
return state

--first choose what state you are modifying, game, main menu, or creating a new ui (also the same as image maps)
--need a way to "go back" to the start

--after choosing a screen, you can load the default or existing one (for now we'll just load the default)
