local state = {}

function state:on_first_enter()
    self.ui = ui.new()
    self.ui:install(self)

    local background_panel = self.ui:add("panel")
    background_panel:set_image(assets.graphics.ui.book_open)
    background_panel:set_draw_outline(false)
    background_panel:set_draw_background(true)
    background_panel:set_background_color(colors.light_blue)
    background_panel:dock("fill")

        --dress it up as a bookmark
        local back_button = background_panel:add("panel")
        back_button:set_z_pos(1000)
        back_button:set_image(assets.graphics.ui.back_arrow)
        back_button:set_draw_background(false)
        back_button:set_draw_outline(false)
        back_button:set_size(200, 200)

        back_button:add_hook("on_clicked", function(this)
            states.set_current_state("menu")
        end)

        self.current_page = 1

        local gallery_panel = background_panel:add("panel")
        gallery_panel:dock("fill")
        gallery_panel:set_draw_background(false)
        gallery_panel:set_draw_outline(false)
        gallery_panel:set_dock_margin(100, 100, 100, 100)

        self.gallery_panel = gallery_panel

        --itterate over all the desired assets
        --check if they're locked, lock them if they are, unlock otherwise

        local fullscreen_panel = self.ui:add("panel")
        fullscreen_panel:set_draw_outline(false)
        fullscreen_panel:hide()
        fullscreen_panel:dock("fill")
        --fullscreen_panel:set_auto_stretch(true)

        fullscreen_panel:add_hook("on_clicked", function(this)
            this:hide()
        end)

        local images = {}
        local current_image = 0
        self.gallery_image_datas = images

        local function add_images_from(images_table)
            for name, image in pairs(images_table) do
                table.insert(images, {name = name, image = image})
            end
        end

        add_images_from(assets.graphics.fae())
        add_images_from(assets.graphics.holo())
        add_images_from(assets.graphics.sylvie())

        for y = -1, 1, 2 do
            for x = -1, 1, 2 do
                current_image = current_image + 1

                local image_panel = gallery_panel:add("panel")
                image_panel:set_size(400, 300)
                image_panel:set_draw_background(false)
                image_panel:set_draw_outline(false)
                image_panel.image_data = images[current_image]

                image_panel:add_hook("on_clicked", function(this)
                    if not this.image then
                        return
                    end
                    
                    fullscreen_panel:set_image(this:get_image())
                    fullscreen_panel:unhide()
                end)
                
                image_panel:add_hook("on_validate", function(this)
                    local max_width, max_height = gallery_panel:get_size()
                    local center_x, center_y = max_width / 2, max_height / 2
                    this:set_pos(center_x - this:get_width() / 2 + max_width / 3 * x, center_y - this:get_height() / 2 + max_height / 4 * y)
                end)
            end
        end

        function gallery_panel:next_page(page)
            for i = 1, 4 do
                local image_panel = gallery_panel.children[i]
                local image_data = images[i + (page - 1) * 4]
                if image_data then
                print(save_load_manager.globals[image_data.name], image_data.name)
                end
                if image_data and save_load_manager.globals[image_data.name] then
                    image_panel:set_image(image_data.image)
                else
                    image_panel:set_image(nil)
                end
            end
        end

        local arrow_margin = {0, 400, 0, 400}

        local left_panel = background_panel:add("panel")
        left_panel:set_width(200)
        left_panel:set_draw_outline(false)
        left_panel:set_draw_background(false)
        left_panel:dock("left")

            --so that left button has access to right butotn
            local right_button = nil

            --hide these buttons unless there is more left or more right to go to respectvely
            local left_button = left_panel:add("panel")
            left_button:set_dock_margin(0, 400, 0, 400)    
            left_button:set_image(assets.graphics.ui.left_arrow)
            left_button:set_draw_background(false)
            left_button:set_draw_outline(false)
            left_button:dock("fill")
            left_button:hide()

            left_button:add_hook("on_hovered", function(this)
                --squish it
                local w, h = this:get_size()
                this:set_size(w * 0.9, h * 0.9)
            end)

            left_button:add_hook("on_hover_end", function(this)
                --unsquish it
            end)

            left_button:add_hook("on_clicked", function(this)
                if self.current_page > 1 then
                    self.current_page = self.current_page - 1

                    if self.current_page == 1 then
                        this:hide()
                    end

                    gallery_panel:next_page(self.current_page)
                    right_button:unhide()
                end
            end)

        local right_panel = background_panel:add("panel")
        right_panel:set_width(200)
        right_panel:set_draw_background(false)
        right_panel:set_draw_outline(false)
        right_panel:dock("right")

            right_button = right_panel:add("panel")
            right_button:set_dock_margin(0, 400, 0, 400)    
            right_button:set_image(assets.graphics.ui.right_arrow)
            right_button:set_draw_outline(false)
            right_button:set_draw_background(false)
            right_button:dock("fill")

            right_button:add_hook("on_clicked", function(this)
                self.current_page = self.current_page + 1
                left_button:unhide()
                gallery_panel:next_page(self.current_page)

                --check if the next page is empty, if so, hide the right button
                if not images[((self.current_page) * 4) + 1] then
                    this:hide()
                end
            end)

    self.unlock_label = self.ui:add("label")
    self.unlock_label:set_align(2)
    self.unlock_label:dock("fill")
end

function state:on_enter()
    --update unlock bar
    local total_unlocked = 0
    local total_images = 0

    for k, image_data in pairs(self.gallery_image_datas) do
        total_images = total_images + 1

        if save_load_manager.globals[image_data.name] then
            total_unlocked = total_unlocked + 1
        end
    end

    self.unlock_label:set_text(string.format("%s/%s unlocked!", total_unlocked, total_images))
    self.unlock_label:set_height(400)

    self.gallery_panel:next_page(self.current_page)
end

return state