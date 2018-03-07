import Base

module LogNumbers

mutable struct LogNumber{F<:AbstractFloat} <: AbstractFloat
    log::F

    LogNumber{T}(x::T) where T<:AbstractFloat = new{T}(x)
end

LogNumber(x::F) where {F<:AbstractFloat} = LogNumber{F}(x)
LogNumber(x::Real) = LogNumber(float(x))

Base.convert(::Type{LogNumber{F}}, x::LogNumber) where {F<:AbstractFloat} = LogNumber(convert(F, x.log))
Base.convert(lt::Type{LogNumber{F}}, x::Real) where {F<:AbstractFloat} = LogNumber(float(x))

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

Base.:<(x::LogNumber, y::LogNumber) = x.log < y.log
Base.:<=(x::LogNumber, y::LogNumber) = x.log <= y.log
Base.less(x::LogNumber, y::LogNumber) = less(x.log, y.log)


# http://www.nowozin.net/sebastian/blog/streaming-log-sum-exp-computation.html
# https://www.xarg.org/2016/06/the-log-sum-exp-trick-in-machine-learning/
function logsumexp_stream(X)
    α = -Inf
    r = 0.0
    
    for x in X
        if x.log <= α
            r += exp(x.log - α)
        else
            r *= exp(α - x.log)
            r += 1.0
            α = x.log
        end
    end
    @show r, α
    Log(r) + α
end

function logsumexp_stream2(X)
    α = maximum(X).log
    s = sum(exp(x.log - α) for x in X)
    @show s, α
    Log(s) + α
end


export Log

end
