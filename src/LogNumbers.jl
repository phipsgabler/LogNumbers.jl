import Base: show

module LogNumbers

mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}() where T<:AbstractFloat = new{T}()
    LogNumber{T}(x::T) where T<:AbstractFloat = new{T}(x)
end

Log{F<:AbstractFloat}(x::F) = LogNumber{F}(log(x))
Log{T<:Real}(x::T) = Log(float(x))
# Log(x::Irrational{:e}) = LogNumber(0.0)

fromlog{F<:AbstractFloat}(logx::F) = LogNumber{F}(logx)
fromlog{T<:Real}(logx::T) = fromlog(float(logx))

Base.show(io::IO, x::LogNumber) = print(io, "exp(", x.log, ")")

isneginf(x) = isinf(x) && x < zero(x)

# https://en.wikipedia.org/wiki/Log_probability
function Base.:+{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    isneginf(x) && return x
    LogNumber{F}(x.log + log1p(exp(y.log - x.log)))
end

# http://www.nowozin.net/sebastian/blog/streaming-log-sum-exp-computation.html
function logsumexp_stream(X)
    α = -Inf
    r = 0.0
    
    for x in X
        if x <= α
            r += exp(x - α)
        else
            r *= exp(α - x)
            r += 1.0
            α = x
        end
    end
    log(r) + α
end

# convert(::Type{Rational{T}}, x::Rational) where {T<:Integer} = Rational(convert(T,x.num),convert(T,x.den))
# convert(::Type{Rational{T}}, x::Integer) where {T<:Integer} = Rational(convert(T,x), convert(T,1))

# convert(rt::Type{Rational{T}}, x::AbstractFloat) where {T<:Integer} = convert(rt,x,eps(x))

# convert(::Type{T}, x::Rational) where {T<:AbstractFloat} = convert(T,x.num)/convert(T,x.den)
# convert(::Type{T}, x::Rational) where {T<:Integer} = div(convert(T,x.num),convert(T,x.den))

# promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
# promote_rule(::Type{Rational{T}}, ::Type{Rational{S}}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
# promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:AbstractFloat} = promote_type(T,S)

export Log

end
