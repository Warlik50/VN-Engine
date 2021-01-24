local util = {
    table = {},
    math = {},
    string = {}
}

function util.table.copy(t)
    local copy = {}

    for k, v in pairs(t) do
        copy[k] = v
    end

    return copy
end

function util.table.reverse(t)
    for i = 1, #t / 2 do
        local swap_index = #t - (i - 1)
        t[i], t[swap_index] = t[swap_index], t[i] 
    end
end

function util.math.lerp(a, b, t)
    return a * (1 - t) + b * t
end

function util.math.round(n)
    return math.floor(n + 0.5)
end

function util.math.smooth_lerp(a, b, t)
    t = t * t * (3 - 2 * t)
    return util.math.lerp(a, b, t)
end

function util.math.clamp(n, low, high) 
    return math.min(math.max(low, n), high) 
end

return util