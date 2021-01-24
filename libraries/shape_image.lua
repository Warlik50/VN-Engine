local function newShapeImage(shape, width, height)
    local canvas = love.graphics.newCanvas(width, height or width)

    love.graphics.setCanvas(canvas)
        love.graphics.setColor(1, 1, 1)

        if shape == "circle" then
            love.graphics.circle("fill", canvas:getWidth() / 2, canvas:getHeight() / 2, canvas:getWidth() / 2)
        elseif shape == "rectangle" then
            love.graphics.rectangle("fill", 0, 0, width, height)
        end
    love.graphics.setCanvas()
    
    return love.graphics.newImage(canvas:newImageData())
end

return newShapeImage