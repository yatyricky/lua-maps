function string.formatPercentage(number, digits)
    digits = digits or 0
    number = number * 100
    local pow = 10 ^ digits
    number = math.round(number * pow) / pow
    return tostring(number) .. "%"
end
