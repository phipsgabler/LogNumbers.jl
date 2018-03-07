import Base

module LogNumbers

mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}(x::T) where T<:AbstractFloat = new{T}(x)
end

LogNumber(x::F) where {F<:AbstractFloat} = LogNumber{F}(x)
LogNumber(x::Real) = LogNumber(float(x))

Base.convert(::Type{LogNumber{F}}, x::LogNumber) where {F<:AbstractFloat} = LogNumber(convert(F, x.log))
Base.convert(lt::Type{LogNumber{F}}, x::Real) where {T<:AbstractFloat} = LogNumber(float(x))

Base.promote_rule(::Type{LogNumber{T}}, ::Type{LogNumber{S}}) where {T<:AbstractFloat,S<:AbstractFloat} = LogNumber{promote_type(T,S)}
Base.promote_rule(::Type{LogNumber{T}}, ::Type{S}) where {T<:AbstractFloat,S<:Real} = LogNumber{promote_type(T, S)}

Base.show(io::IO, x::LogNumber) = print(io, "exp(", x.log, ")")


Log(x::Real) = LogNumber(log(x))

isneginf(x) = isinf(x) && x < zero(x)

# https://en.wikipedia.org/wiki/Log_probability
function Base.:+{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    isneginf(x.log) && return x
    LogNumber{F}(x.log + log1p(exp(y.log - x.log)))
end

function Base.:-{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F})
    isneginf(x.log) && return x
    LogNumber{F}(x.log + log1p(-exp(y.log - x.log)))
end

Base.:*{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F}) = LogNumber{F}(x.log + y.log)
Base.:/{F<:AbstractFloat}(x::LogNumber{F}, y::LogNumber{F}) = LogNumber{F}(x.log - y.log)

# function Base.mapreduce(::typeof(+), op, v0, itr)
# end

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


export Log

end
