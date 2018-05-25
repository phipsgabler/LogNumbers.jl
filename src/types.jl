export logvalue,
    LogZero64, LogInf64, LogNaN64,
    LogZero32, LogInf32, LogNaN32,
    LogZero16, LogInf16, LogNaN16,
    LogZero, LogNaN, LogInf

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

const LogZero16 = LogNumber{Float16}(-Inf16)
const LogNaN16 = LogNumber{Float16}(NaN16)
const LogInf16 = LogNumber{Float16}(Inf16)

const LogZero = LogZero64
const LogNaN = LogNaN64
const LogInf = LogInf64

Base.zero(::Type{LogNumber{Float64}}) = LogZero64
Base.zero(::LogNumber{Float64}) = LogZero64
Base.zero(::Type{LogNumber{Float32}}) = LogZero32
Base.zero(::LogNumber{Float32}) = LogZero32
Base.zero(::Type{LogNumber{Float16}}) = LogZero16
Base.zero(::LogNumber{Float16}) = LogZero16

Base.one(::Type{LogNumber{Float64}}) = LogNumber{Float64}(0e0)
Base.one(::LogNumber{Float64}) = LogNumber{Float64}(0e0)
Base.one(::Type{LogNumber{Float32}}) = LogNumber{Float32}(0f0)
Base.one(::LogNumber{Float32}) = LogNumber{Float32}(0f0)
Base.one(::Type{LogNumber{Float16}}) = LogNumber{Float16}(Float16(0f0))
Base.one(::LogNumber{Float16}) = LogNumber{Float16}(Float16(0f0))

