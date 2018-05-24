# Base.show(io::IO, x::LogNumber{<:Union{Float32,Float64}}) = print(io, "log\"", exp(x.log), "\"")
# FLOAT32_LIT = r"[+-]?[0-9]+([.][0-9]*)?[f][0-9]+"
# FLOAT64_LIT = r"[+-]?[0-9]+((([.][0-9]*)?[e][0-9]+)|([.][0-9]*))"

macro log_str(s)
    F, x = string_to_number(s, 0)
    return :(LogNumber{$F}($(log(x))))
end

# from https://github.com/JuliaLang/JuliaParser.jl/blob/f15bb47ff00536c72bb1cdb414baad22dede44c7/src/lexer.jl
function string_to_number(str::AbstractString, loc)
    len = length(str)
    len > 0 || throw(ArgumentError("empty string"))
    neg = str[1] === '-'
    
    # NaN and Infinity
    (str == "NaN" || str == "+NaN" || str == "-NaN") && return Float64, NaN
    (str == "Inf" || str == "+Inf" || str == "-Inf") && return Float64, Inf
    
    # floating point literals
    didx, fidx = 0, 0
    isfloat32, isfloat64 = false, false
    for i=1:len
        c = str[i]
        if c === '.'
            @assert isfloat64 == false
            didx, isfloat64 = i, true
        elseif c === 'f'
            @assert i > didx && i != len
            fidx, isfloat32 = i, true
        elseif c === 'e' || c === 'E' || c === 'p' || c === 'P'
            isfloat64 = true
        end
    end
    
    if isfloat32
        base = parse(Float64,str[1:fidx-1])
        expn = parse(Int,str[fidx+1:end])
        return Float32, convert(Float32, base * 10.0 ^ expn)
    else
        # its better to ask for forgiveness...
        return Float64, parse(Float64, str)
    end
end
