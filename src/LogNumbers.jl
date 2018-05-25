__precompile__()

import Base

module LogNumbers

export LogNumber, Log, 
    floattype, logsumexp


include("types.jl")


# IO, literals
Base.show(io::IO, x::LogNumber{<:Union{Float32,Float64}}) = print(io, "log", '\"', exp(x.log), '\"')
Base.show(io::IO, x::LogNumber{F}) where {F} = print(io, "Log(", F, ", ", exp(x.log), ")")

include("literal_macro.jl")


# Constructors and conversions
Log(x::F) where {F<:AbstractFloat} = LogNumber{F}(log(x))
Log(x) = Log(float(x))
Log(::Type{F}, x) where F = Log(convert(F, x))

floattype(::Type{LogNumber{F}}) where F = F
floattype(::LogNumber{F}) where F = F

# Base.float(::Type{LogNumber{F}}) where {F} = LogNumber{F}
# Base.float(x::LogNumber) = x

Base.reinterpret(::Type{LogNumber{F}}, x::F) where {F} = LogNumber{F}(x)

Base.convert(::Type{LogNumber{F}}, x::LogNumber) where {F} = LogNumber{F}(convert(F, logvalue(x)))
Base.convert(::Type{LogNumber{F}}, x::Real) where {F} = LogNumber{F}(log(convert(F, x)))
Base.convert(::Type{T}, x::LogNumber) where {T} = convert(T, exp(logvalue(x)))

Base.promote_rule(::Type{LogNumber{T}}, ::Type{LogNumber{S}}) where {T, S} = LogNumber{promote_type(T, S)}
Base.promote_rule(::Type{LogNumber{T}}, ::Type{S}) where {T, S<:Real} = LogNumber{promote_type(T, S)}


# Comparison, floating point stuff
Base.:(==)(x::AbstractLogNumber, y::AbstractLogNumber) = logvalue(x) == logvalue(y)
Base.isequal(x::AbstractLogNumber, y::AbstractLogNumber) = isequal(logvalue(x), logvalue(y))
Base.hash(x::AbstractLogNumber, h) = hash(logvalue(x), hash(typeof(x), h))

Base.isapprox(x::AbstractLogNumber, y::AbstractLogNumber; args...) = isapprox(logvalue(x), logvalue(y); args...)
Base.eps(::Type{<:AbstractLogNumber{F}}) where F = Base.eps(F) # is this the right thing? 

Base.:<(x::AbstractLogNumber, y::AbstractLogNumber) = logvalue(x) < logvalue(y)
Base.:<=(x::AbstractLogNumber, y::AbstractLogNumber) = logvalue(x) <= logvalue(y)
Base.less(x::AbstractLogNumber, y::AbstractLogNumber) = less(logvalue(x), logvalue(y))

Base.isinf(x::AbstractLogNumber) = isinf(logvalue(x)) && logvalue(x) > 0
Base.isnan(x::AbstractLogNumber) = isnan(logvalue(x))

# Arithmetic etc.
# See https://en.wikipedia.org/wiki/Log_probability for the formulae and precautions

function Base.:+(x::AbstractLogNumber{F}, y::AbstractLogNumber{F}) where {F}
    y, x = minmax(x, y)
    iszero(x) && return x
    isinf(y) && return y
    LogNumber{F}(logvalue(x) + log1p(exp(logvalue(y) - logvalue(x))))
end

function Base.:-(x::AbstractLogNumber{F}, y::AbstractLogNumber{F}) where {F}
    m = max(x, y)               # preserver order to automatically throw DomainError
    iszero(m) && return m
    LogNumber{F}(logvalue(x) + log1p(-exp(logvalue(y) - logvalue(x))))
end

Base.:*(x::AbstractLogNumber{F}, y::AbstractLogNumber{F}) where {F} = LogNumber{F}(logvalue(x) + logvalue(y))
Base.:/(x::AbstractLogNumber{F}, y::AbstractLogNumber{F}) where {F} = LogNumber{F}(logvalue(x) - logvalue(y))
Base.log(x::AbstractLogNumber{F}) where {F} = LogNumber{F}(log(logvalue(x)))


# Summing values in log space
# See the following pages for explanation:
# http://www.nowozin.net/sebastian/blog/streaming-log-sum-exp-computation.html
# https://www.xarg.org/2016/06/the-log-sum-exp-trick-in-machine-learning/

infty(::Type{T}) where {T} = one(T) / zero(T)
infty(::T) where {T} = infty(T)

logsumexp(xs) = logsumexp(xs, eltype(xs))

function logsumexp(xs, ::Type{<:AbstractLogNumber{F}}) where {F}
    α, r = mapfoldr(logvalue, expsum_update, (-infty(F), zero(F)), xs)
    LogNumber(log(r) + α)
end

function logsumexp(xs, ::Type{F}) where {F}
    α, r = mapfoldr(identity, expsum_update, (-infty(F), zero(F)), xs)
    log(r) + α
end

function expsum_update(x, acc)
    α, r = acc
    
    if x <= α
        return (α, r + exp(x - α))
    else
        return (x, r * exp(α - x) + one(r))
    end
end

end
