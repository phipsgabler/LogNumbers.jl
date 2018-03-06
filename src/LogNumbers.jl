import Base: show

module LogNumbers

mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}() where T<:AbstractFloat = new{T}()
    LogNumber{T}(x::T) where T<:AbstractFloat = new{T}(x)
end

Log{F<:AbstractFloat}(x::F) = LogNumber{F}(log(x))
Log{T<:Real}(x::T) = Log(float(x))

fromlog{F<:AbstractFloat}(logx::F) = LogNumber{F}(logx)
fromlog{T<:Real}(logx::T) = fromlog(float(logx))

Base.show(io::IO, x::LogNumber) = print(io, "exp(", x.log, ")")

function Base.:+{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    LogNumber{F}(x.log + log1p(exp(y.log - x.log)))
end

export Log

end
