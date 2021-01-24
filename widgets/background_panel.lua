local waiting_anim = nil

local panel = ui.get_element("panel")

local widget = class(panel)

function widget:init(state, scene_manager)
    panel.init(self)

    self.state = state
    self.scene_manager = scene_manager
end

function widget:post_init()
    panel.post_init(self)

    self:dock("fill")
    self:set_outline_radius(20, 20)
    self:set_dock_margin(50, 50, 50, 50)
    self:set_outline_width(6)
    --self:set_outline_color(colors.pink)
    
    self.shadow_offset = 8


    self:add_hook("pre_draw", function(this)
        love.graphics.stencil(function() this:draw_background() end, "replace", 1)
        love.graphics.setStencilTest("equal", 1)
    end)

    self:add_hook("post_draw", function()
        self.scene_manager:draw()
    end)

    self:add_hook("post_draw_children", function(this)
        love.graphics.setStencilTest()
    end)

    self:add_hook("pre_draw_no_scissor", function(this)
        local offset = this.shadow_offset

        love.graphics.translate(offset, offset)
            love.graphics.setColor(0, 0, 0, 0.5)
            this:draw_background()
        love.graphics.translate(-offset, -offset)
    end)



    local dialogue_height = 300
    dialogue_height = love.graphics.getHeight() / 4
    local dialogue_margin = {20, 0, 20, 0}
    dialogue_margin = {100, 0, 100, 0} -- test dialogue margin for when theres no left or right column
    dialogue_margin = {20, 0, 20, 0}
    dialogue_margin = {0, 0, 0, 0}
    local dialogue_padding = {20, 20, 20, 20}

    self.dialogue_box = self:add("panel")
    self.dialogue_box:set_height(dialogue_height)
    self.dialogue_box:set_dock_margin(dialogue_margin)
    self.dialogue_box:set_dock_padding(dialogue_padding)
    self.dialogue_box:set_background_color(colors.white)
    self.dialogue_box:set_background_alpha(0.8)
    self.dialogue_box.duration = 0.5
    self.dialogue_box.time = 0
    self.dialogue_box:set_image_color(1, 1, 1, 0.8)
    self.dialogue_box:dock("bottom")

    --[[
    self.dialogue_box:add_hook("on_update", function(this, dt)
        this.time = this.time + dt

        local x, y = this:get_pos()

        local w, h = this:get_size()
        local scr_h = love.graphics.getHeight()

        if this.showing then
            this:set_pos(x, util.math.smooth_lerp(scr_h, scr_h - h - dialogue_margin[4], math.min(1, this.time / this.duration)), 0)
        elseif this.hiding then
            this:set_pos(x, util.math.smooth_lerp(scr_h - h - dialogue_margin[4], scr_h, math.min(1, this.time / this.duration)), 0)
        end
    end)
    ]]

    function self.dialogue_box.hide(this)

    end

    function self.dialogue_box.show(this)

    end



        self.dialogue_text = self.dialogue_box:add("label")

        --self.dialogue_text:set_dropshadow(true)
        self.dialogue_text:set_dropshadow_color(1, 1, 1)
        self.dialogue_text:add_hook("on_update", function(this, dt) this:set_text(self.scene_manager.speaker_current_text) end)
        self.dialogue_text:dock("fill")
--[[
        self.dialogue_text:add_hook("post_draw", function(this)
            if self.scene_manager.speaker_current_text == self.scene_manager.speaker_text and not (self.scene_manager.speaker_text == nil) and
            #self.scene_manager.update_functions == 0 and not self.scene_manager.choices then
                local screen_x, screen_y = this:get_screen_pos()
                local w, h = this:get_size()
                local x, y = screen_x + w - waiting_anim.quad_w - dialogue_padding[3], screen_y + h - waiting_anim.quad_h - dialogue_padding[4]

                waiting_anim:update(love.timer.getDelta()) 

                love.graphics.setColor(colors.black)
                waiting_anim:draw(x, y)
            end
        end)
]]
    local name_x_offset = 20
    name_x_offset = name_x_offset + 20
    local name_font = assets.fonts[48]
    name_font = assets.fonts[56]
    name_font = assets.fonts[64]

    self.name_label = self:add("label")
    self.name_label:set_font(name_font)
    self.name_label:set_dock_margin(dialogue_margin[1] + name_x_offset, 0, 0, 0)
    self.name_label:add_hook("on_update", function(this, dt) this:set_text(self.scene_manager.speaker_name) end)
    self.name_label:set_align(7)
    self.name_label:set_text_outline(true)
    self.name_label:set_text_outline_color(colors.white)
    self.name_label:set_text_color(colors.black)
    self.name_label:set_text_outline_distance(3)
    self.name_label:size_to_contents()
    self.name_label:dock("bottom")

    local clickable_panel = self:add("panel")
    clickable_panel:set_background_color(colors.black)
    clickable_panel:set_draw_outline(false)
    clickable_panel:set_draw_background(false)

    clickable_panel:add_hook("on_validate", function(this)
        this:set_size(self:get_size())
    end)

    clickable_panel:add_hook("on_mousepressed", function(this, x, y, button)
        if button == 1 then
            self.scene_manager:next_instruction()
        elseif button == 2 then
            --states.set_current_state("menu")
        end
    end)

    self.choice_panel = self:add("choice_panel", self.scene_manager)
    self.choice_panel:dock("fill")

    event:add("on_character_speak", function(character, text) self.name_label:set_text_outline_color(character.name_color) end)
end

function widget:clear_choices()
    self.choice_panel:clear_choices()
end

function widget:restart()
    self:clear_choices()
end

return widget