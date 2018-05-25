export AbstractLogNumber, PrimitiveLogNumber, WrappedLogNumber,
    LogFloat64, LogFloat32, LogFloat16,
    Log, LogNumber, logvalue,
    floattype, logtype,
    LogZero64, LogInf64, LogNaN64,
    LogZero32, LogInf32, LogNaN32,
    LogZero16, LogInf16, LogNaN16,
    LogZero, LogNaN, LogInf

abstract type AbstractLogNumber{F<:AbstractFloat} <: AbstractFloat end

abstract type PrimitiveLogNumber{F} <: AbstractLogNumber{F} end

primitive type LogFloat64 <: PrimitiveLogNumber{Float64} 64 end
primitive type LogFloat32 <: PrimitiveLogNumber{Float32} 32 end
primitive type LogFloat16 <: PrimitiveLogNumber{Float16} 16 end

logvalue(x::PrimitiveLogNumber{F}) where F = reinterpret(F, x)

mutable struct WrappedLogNumber{F} <: AbstractLogNumber{F}
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
logtype(x) = logtype(typeof(x))

# reinterpret and LogNumber perform conversion without transforming to log space
Base.reinterpret(::Type{WrappedLogNumber{F}}, x::F) where {F} = WrappedLogNumber{F}(x)

LogNumber(x::F) where {F<:AbstractFloat} = reinterpret(logtype(F), x)
LogNumber(x) = LogNumber(float(x))
LogNumber(::Type{F}, x) where F = LogNumber(convert(F, x))

# convert and log transform with implicit log transformation
Base.convert(::Type{L}, x::F) where {F, L<:AbstractLogNumber{F}} = reinterpret(L, log(x))
Base.convert(::Type{L}, x::Real) where {F, L<:AbstractLogNumber{F}} =
    convert(L, convert(F, x))

Log(x::F) where {F<:AbstractFloat} = convert(logtype(F), log(x))
Log(x) = Log(float(x))
Log(::Type{F}, x) where F = Log(convert(F, x))

# converting back to normal space with exp
Base.convert(::Type{T}, x::AbstractLogNumber) where {T} = convert(T, exp(logvalue(x)))

# Base.float(::Type{LogNumber{F}}) where {F} = LogNumber{F}
# Base.float(x::LogNumber) = x


# Base.promote_rule(::Type{LogNumber{T}}, ::Type{AbstractLogNumber{S}}) where {T, S} =
#     LogNumber{promote_type(T, S)}
# Base.promote_rule(::Type{LogNumber{T}}, ::Type{S}) where {T, S<:Real} = LogNumber{promote_type(T, S)}


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

Base.zero(::Type{LogFloat64}) = LogZero64
Base.zero(::Type{LogFloat32}) = LogZero32
Base.zero(::Type{LogFloat16}) = LogZero16
Base.zero(::Type{WrappedLogNumber{F}}) where F = zero(F)
Base.zero(x::AbstractLogNumber) = zero(typeof(x))

Base.one(::Type{LogFloat64}) = LogNumber(0e0)
Base.one(::Type{LogFloat32}) = LogNumber(0f0)
Base.one(::Type{LogFloat16}) = LogNumber(Float16(0f0))
Base.one(::Type{WrappedLogNumber{F}}) where F = one(F)
Base.one(x::AbstractLogNumber) = one(typeof(x))
