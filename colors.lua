local colors = {
    white = {255, 255, 255},
    black = {0, 0, 0},
    burgundy = {128, 0, 32, 200},
    yellow = {255, 255, 0},
    blue = {2, 120, 126},
    pink = {234, 75, 128},
    gray = {113, 113, 113},
    light_blue = {162, 217, 247},
    pink2 = {218, 83, 112},
    orange = {231, 139, 48}
}

for name, color in pairs(colors) do
    colors[name] = {love.math.colorFromBytes(unpack(color))}
end

return colors