local anim = function(image, x_frames, y_frames, remove_frames, time_per_frame)
    local img_w, img_h = image:getDimensions()

    local anim = {
        quads = {},
        time_passed = 0,
        duration = (x_frames * y_frames - remove_frames) * time_per_frame,
        quad_w = img_w / x_frames,
        quad_h = img_h / y_frames
    }

    for y = 0, y_frames - 1 do
        for x = 0, x_frames - 1 do
            table.insert(anim.quads, love.graphics.newQuad(x * anim.quad_w, y * anim.quad_h, anim.quad_w, anim.quad_h, img_w, img_h))
        end
    end

    for i = 1, remove_frames do
        table.remove(anim.quads)
    end

    function anim:update(dt)
        self.time_passed = (self.time_passed + dt) % self.duration
        self.current_index = math.floor(#self.quads * (self.time_passed / self.duration)) + 1
    end

    function anim:draw(x, y, r, scale_x, scale_y, offset_x, offset_y)
        love.graphics.draw(image, self.quads[self.current_index], x, y, r, scale_x, scale_y, offset_x, offset_y)
    end

    function anim:set_time_per_frame(time_per_frame)
        local fraction = self.time_passed / self.duration
        self.duration = (x_frames * y_frames - remove_frames) * time_per_frame
        self.time_passed = self.duration * fraction
    end

    return anim
end

return anim