export logvalue,
    LogZero, LogZero32, LogZero64,
    LogNaN, LogNaN32, LogNaN64,
    LogInf, LogInf32, LogInf64

mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}(x::T) where {T<:AbstractFloat} = new{T}(x)
end

LogNumber(x::F) where {F<:AbstractFloat} = LogNumber{F}(x)
LogNumber(x) = LogNumber(float(x))

logvalue(x::LogNumber) = x.log


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
