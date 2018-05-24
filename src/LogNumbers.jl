import Base

module LogNumbers

export LogNumber, Log, @log_str, floattype,
    LogZero, LogZero32, LogZero64,
    LogNaN, LogNaN32, LogNaN64,
    LogInf, LogInf32, LogInf64,
    logsumexp


mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}(x::T) where {T<:AbstractFloat} = new{T}(x)
end

LogNumber(x::F) where {F<:AbstractFloat} = LogNumber{F}(x)
LogNumber(x) = LogNumber(float(x))

Base.show(io::IO, x::LogNumber{<:Union{Float32,Float64}}) = print(io, "log", '\"', exp(x.log), '\"')
Base.show(io::IO, x::LogNumber{F}) where {F} = print(io, "Log(", F, ", ", exp(x.log), ")")


# Constructors and conversions
include("literal_macro.jl")

Log(x::F) where {F<:AbstractFloat} = LogNumber{F}(log(x))
Log(x) = Log(float(x))
Log(::Type{F}, x) where F = Log(convert(F, x))

floattype(::Type{LogNumber{F}}) where F = F
floattype(::LogNumber{F}) where F = F

logvalue(x::LogNumber) = x.log

Base.reinterpret(::Type{LogNumber{F}}, x::F) where {F} = LogNumber{F}(x)

Base.convert(::Type{LogNumber{F}}, x::LogNumber) where {F} = LogNumber{F}(convert(F, x.log))
Base.convert(::Type{LogNumber{F}}, x::Real) where {F} = LogNumber{F}(log(convert(F, x)))
Base.convert(::Type{T}, x::LogNumber) where {T} = convert(T, exp(x.log))

Base.promote_rule(::Type{LogNumber{T}}, ::Type{LogNumber{S}}) where {T, S} = LogNumber{promote_type(T, S)}
Base.promote_rule(::Type{LogNumber{T}}, ::Type{S}) where {T, S<:Real} = LogNumber{promote_type(T, S)}


# Constants
const LogZero64 = LogNumber{Float64}(-Inf64)
const LogInf64 = LogNumber{Float64}(Inf64)
const LogNaN64 = LogNumber{Float64}(NaN64)

const LogZero32 = LogNumber{Float32}(-Inf32)
const LogNaN32 = LogNumber{Float32}(NaN32)
const LogInf32 = LogNumber{Float32}(Inf32)

const LogZero = LogZero64
const LogNaN = LogNaN64
const LogInf = LogInf64

Base.zero(::Type{LogNumber{Float64}}) = LogZero64
Base.zero(::LogNumber{Float64}) = LogZero64
Base.zero(::Type{LogNumber{Float32}}) = LogZero32
Base.zero(::LogNumber{Float32}) = LogZero32

Base.one(::Type{LogNumber{Float64}}) = LogNumber{Float64}(0e0)
Base.one(::Type{LogNumber{Float32}}) = LogNumber{Float32}(0f0)

Base.isinf(x::LogNumber) = isinf(x.log) && x.log > 0
Base.isnan(x::LogNumber) = isnan(x.log)


# Comparison
Base.:(==)(x::LogNumber, y::LogNumber) = x.log == y.log
Base.isequal(x::LogNumber, y::LogNumber) = isequal(x.log, y.log)
Base.hash(x::LogNumber, h) = hash(x.log, hash(typeof(x), h))

Base.isapprox(x::LogNumber, y::LogNumber; args...) = isapprox(x.log, y.log; args...)
Base.eps(::Type{LogNumber{F}}) where F = Base.eps(F) # is this the right thing? 

Base.:<(x::LogNumber, y::LogNumber) = x.log < y.log
Base.:<=(x::LogNumber, y::LogNumber) = x.log <= y.log
Base.less(x::LogNumber, y::LogNumber) = less(x.log, y.log)


# Arithmetic
# See https://en.wikipedia.org/wiki/Log_probability for the formulae and precautions

function Base.:+{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    y, x = minmax(x, y)
    iszero(x) && return x
    isinf(y) && return y
    LogNumber{F}(x.log + log1p(exp(y.log - x.log)))
end

function Base.:-{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    m = max(x, y)               # preserver order to automatically throw DomainError
    iszero(m) && return m
    LogNumber{F}(x.log + log1p(-exp(y.log - x.log)))
end

Base.:*{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F}) = LogNumber{F}(x.log + y.log)
Base.:/{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F}) = LogNumber{F}(x.log - y.log)


# Summing values in log space
# See the following pages for explanation:
# http://www.nowozin.net/sebastian/blog/streaming-log-sum-exp-computation.html
# https://www.xarg.org/2016/06/the-log-sum-exp-trick-in-machine-learning/

infty(::Type{T}) where {T} = one(T) / zero(T)
infty(::T) where {T} = infty(T)


logsumexp(xs) = logsumexp(xs, eltype(xs))

function logsumexp(xs, ::Type{LogNumber{F}}) where {F}
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
