import Base

module LogNumbers

mutable struct Log{F<:AbstractFloat} <: AbstractFloat
    log::F

    # Log{T}(x::T) where T<:AbstractFloat = new{T}(x)
end

Log(x::F) where {F<:AbstractFloat} = Log{F}(x)
Log(x::Real) = Log(float(x))

Base.convert(::Type{Log{F}}, x::Log) where {F<:AbstractFloat} = Log(convert(F, x.log))
Base.convert(lt::Type{Log{F}}, x::Real) where {F<:AbstractFloat} = Log(float(x))

Base.promote_rule(::Type{Log{T}}, ::Type{Log{S}}) where {T<:AbstractFloat, S<:AbstractFloat} = Log{promote_type(T, S)}
Base.promote_rule(::Type{Log{T}}, ::Type{S}) where {T<:AbstractFloat, S<:Real} = Log{promote_type(T, S)}

Base.show(io::IO, x::Log) = print(io, "exp(", x.log, ")")

isneginf(x) = isinf(x) && x < zero(x)

# https://en.wikipedia.org/wiki/Log_probability
function Base.:+{F<:AbstractFloat}(x::Log{F}, y::Log{F})
    isneginf(x.log) && return x
    Log{F}(x.log + log1p(exp(y.log - x.log)))
end

function Base.:-{F<:AbstractFloat}(x::Log{F}, y::Log{F})
    isneginf(x.log) && return x
    Log{F}(x.log + log1p(-exp(y.log - x.log)))
end

Base.:*{F<:AbstractFloat}(x::Log{F}, y::Log{F}) = Log{F}(x.log + y.log)
Base.:/{F<:AbstractFloat}(x::Log{F}, y::Log{F}) = Log{F}(x.log - y.log)

Base.:<(x::Log, y::Log) = x.log < y.log
Base.:<=(x::Log, y::Log) = x.log <= y.log
Base.less(x::Log, y::Log) = less(x.log, y.log)


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
