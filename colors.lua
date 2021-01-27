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
    orange = {231, 139, 48},

    ui_yellow = {232, 218, 94},

    ui_white = {249, 240, 209},
    ui_dark_blue = {42, 61, 81},
    ui_blue = {44, 94, 122},
    ui_light_blue = {72, 125, 118},

    ui_white = {237, 224, 206},
    ui_grey1 = {98, 98, 99},
    ui_grey2 = {81, 81, 81},
    ui_grey3 = {51, 51, 51},
    ui_grey4 = {37, 37, 38},
    ui_black = {26, 27, 29},
}

for name, color in pairs(colors) do
    colors[name] = {love.math.colorFromBytes(unpack(color))}
end

return colors