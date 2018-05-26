export AbstractLogNumber, PrimitiveLogNumber, WrappedLogNumber,
    LogFloat64, LogFloat32, LogFloat16,
    Log, LogNumber, logvalue,
    floattype, logtype,
    LogZero64, LogInf64, LogNaN64,
    LogZero32, LogInf32, LogNaN32,
    LogZero16, LogInf16, LogNaN16,
    LogZero, LogNaN, LogInf

abstract type AbstractLogNumber{F<:AbstractFloat} <: AbstractFloat end

abstract type PrimitiveLogNumber{F<:AbstractFloat} <: AbstractLogNumber{F} end

primitive type LogFloat64 <: PrimitiveLogNumber{Float64} 64 end
primitive type LogFloat32 <: PrimitiveLogNumber{Float32} 32 end
primitive type LogFloat16 <: PrimitiveLogNumber{Float16} 16 end

logvalue(x::PrimitiveLogNumber{F}) where F = reinterpret(F, x)

mutable struct WrappedLogNumber{F<:AbstractFloat} <: AbstractLogNumber{F}
    log::F
    WrappedLogNumber{T}(x::T) where {T<:AbstractFloat} = new{T}(x)
end

logvalue(x::WrappedLogNumber) = x.log


# Pseudo-constructors and conversions
const PrimitiveFloat = Union{Float16, Float32, Float64}

floattype(::Type{<:AbstractLogNumber{F}}) where F = F
floattype(x) = floattype(typeof(x))

logtype(::Type{Float64}) = LogFloat64
logtype(::Type{Float32}) = LogFloat32
logtype(::Type{Float16}) = LogFloat16
logtype(::Type{F}) where {F<:AbstractFloat} = WrappedLogNumber{F}
logtype(::Type{N}) where N = logtype(float(N))
logtype(x) = logtype(typeof(x))

# reinterpret and LogNumber perform conversion without transforming to log space
Base.reinterpret(::Type{WrappedLogNumber{F}}, x::F) where {F} = WrappedLogNumber{F}(x)

LogNumber(x::F) where {F<:AbstractFloat} = reinterpret(logtype(F), x)
LogNumber(x) = LogNumber(float(x))
LogNumber(::Type{F}, x) where {F<:AbstractFloat} = LogNumber(convert(F, x))

# convert and log transform with implicit log transformation
Base.convert(::Type{L}, x) where {L<:AbstractLogNumber} =
    reinterpret(L, log(convert(floattype(L), x)))

Log(x::F) where {F<:AbstractFloat} = convert(logtype(F), x)
Log(x) = Log(float(x))
Log(::Type{F}, x) where {F<:AbstractFloat} = Log(convert(F, x))

# converting back to normal space with exp
Base.convert(::Type{L}, x::AbstractLogNumber) where {L<:AbstractLogNumber} =
    LogNumber(convert(floattype(L), logvalue(x)))
Base.convert(::Type{T}, x::AbstractLogNumber) where {T} = convert(T, exp(logvalue(x)))

Base.promote_rule(::Type{S}, ::Type{T}) where {S<:AbstractLogNumber, T<:AbstractLogNumber} =
    logtype(promote_type(floattype(S), floattype(T)))
Base.promote_rule(::Type{L}, ::Type{R}) where {L<:AbstractLogNumber, R<:Real} =
    logtype(promote_type(floattype(L), R))


# Constants
const LogZero64 = LogNumber(-Inf64)
const LogInf64 = LogNumber(Inf64)
const LogNaN64 = LogNumber(NaN64)

const LogZero32 = LogNumber(-Inf32)
const LogNaN32 = LogNumber(NaN32)
const LogInf32 = LogNumber(Inf32)

const LogZero16 = LogNumber(-Inf16)
const LogNaN16 = LogNumber(NaN16)
const LogInf16 = LogNumber(Inf16)

const LogZero = LogZero64
const LogNaN = LogNaN64
const LogInf = LogInf64

infty(::Type{T}) where {T} = one(T) / zero(T)
infty(::T) where {T} = infty(T)

Base.zero(::Type{LogFloat64}) = LogZero64
Base.zero(::Type{LogFloat32}) = LogZero32
Base.zero(::Type{LogFloat16}) = LogZero16
Base.zero(::Type{WrappedLogNumber{F}}) where F = -infty(F)
Base.zero(x::AbstractLogNumber) = zero(typeof(x))

Base.one(::Type{LogFloat64}) = LogNumber(0e0)
Base.one(::Type{LogFloat32}) = LogNumber(0f0)
Base.one(::Type{LogFloat16}) = LogNumber(Float16(0f0))
Base.one(::Type{WrappedLogNumber{F}}) where F = zero(F)
Base.one(x::AbstractLogNumber) = one(typeof(x))
