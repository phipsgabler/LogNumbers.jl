__precompile__()

import Base

module LogNumbers

export LogNumber, Log, 
    floattype, logsumexp

include("types.jl")


# IO, literals
Base.show(io::IO, x::Union{LogFloat32,LogFloat64}) = print(io, "log", '\"', exp(logvalue(x)), '\"')
Base.show(io::IO, x::AbstractLogNumber{F}) where {F} = print(io, "Log(", F, ", ", exp(logvalue(x)), ")")

include("literal_macro.jl")


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

function Base.:+(x::AbstractLogNumber, y::AbstractLogNumber)
    y, x = minmax(x, y)
    iszero(x) && return x
    isinf(y) && return y
    LogNumber(logvalue(x) + log1p(exp(logvalue(y) - logvalue(x))))
end

function Base.:-(x::AbstractLogNumber, y::AbstractLogNumber)
    m = max(x, y)               # preserver order to automatically throw DomainError
    iszero(m) && return m
    LogNumber(logvalue(x) + log1p(-exp(logvalue(y) - logvalue(x))))
end

Base.:*(x::AbstractLogNumber, y::AbstractLogNumber) = LogNumber(logvalue(x) + logvalue(y))
Base.:/(x::AbstractLogNumber, y::AbstractLogNumber) = LogNumber(logvalue(x) - logvalue(y))
Base.log(x::AbstractLogNumber) = LogNumber(log(logvalue(x)))


# Summing values in log space
# See the following pages for explanation:
# http://www.nowozin.net/sebastian/blog/streaming-log-sum-exp-computation.html
# https://www.xarg.org/2016/06/the-log-sum-exp-trick-in-machine-learning/

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


# Random value generation
Base.rand(rng::AbstractRNG, ::Type{L}) where {L<:PrimitiveLogNumber} =
    reinterpret(L, rand(rng, floattype(L)))
Base.rand(rng::AbstractRNG, ::Type{WrappedLogNumber{F}}) where {F<:AbstractFloat} =
    WrappedLogNumber{F}(rand(rng, F))

end
