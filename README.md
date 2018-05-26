# LogNumbers

[![Build Status](https://travis-ci.org/phipsgabler/LogNumbers.jl.svg?branch=master)](https://travis-ci.org/phipsgabler/LogNumbers.jl)

Unsatisfied with always having to remember which probabilities are in log space, and having to
transform calculations on them?

```julia
using Rmath

"""Independent MCMC sampling form a binomial distribution"""
function imh_binom(;x0 = 0, n = 10^5, β = 0.9, m = 100)
    X = Vector{Float64}(n)
    x = x0
    log_p(x) = dbinom(x, m, β, true)
    log_px = log_p(x)
    accepted = 0

    for k in 1:n
        y = rand(1:m)
        log_py = log_p(y)

        if rand() < exp(log_py - log_px)
            x = y
            log_px = log_py
            accepted += 1
        end

        X[k] = x
    end

    return X, accepted / n
end
```

Enter `LogNumbers`:

```julia
"""Independent MCMC sampling form a binomial distribution"""
function imh_binom2(;x0 = 0, n = 10^5, β = 0.9, m = 100)
    X = Vector{Float64}(n)
    x = x0
    p(x) = LogNumber(dbinom(x, m, β, true))
    px = p(x)
    accepted = 0

    for k in 1:n
        y = rand(1:m)
        py = p(y)
        
        if rand() < (py / px)
            x = y
            px = py
            accepted += 1
        end

        X[k] = x
    end

    return X, accepted / n
end
```

## Disclaimer

This is an experimental project I started out of interest (after doing a lot of MCMC stuff).  _Don't
assume that I know anything about numerics or floating point numbers_.  I do hope that what I wrote
makes sense, but I'd be happy to be corrected!

## Interface

The main type is `AbstractLogNumber{F}`, where `F <: AbstractFloat`.  This stores a floating point
number in log space, but can otherwise be handled just like a normal positive real number.  The
cases for `Float16`, `Float32`, and `Float64` are specialized as `primitive` types.

There are a number of ways to construct a `LogNumber`:

- `LogNumber(0.1)`, and construct a `LogFloat64` containing the value 0.1, as in log-space.
  `reinterpret` is also specialized for this.
- `Log(0.1)`, `Log(Float64, 0.1)`, and `log"0.1"` construct a `LogFloat64` containing log(0.1) ≈
  -2.3025; i.e., they transform to log space.  The string macro `@log_str` understands Julia decimal
  `Float32` and `Float64` literals, and is used for printing, if possible.  `convert` can be used as
  well to transform from normal to log space.
- There are constants for `LogZero`, `LogNaN`, and `LogInf`, and their explicit 32 and 64 bit
  variants `LogZero32` etc.  Also `one` and `zero` are overloaded accordingly.

`convert` and `promote` are overloaded to perform automatically transform to log space, so that
e.g., `log"0.1" + 0.2` results in `log"0.30000000000000004"`.
  
To access the values in `LogNumber`, you can use `float` or `convert` to get back thevalue in the
normal domain, or `floatvalue` or the field `log` to access the value in log space, if that should
be necessary.  `floattype` returns the underlying float type, and `logtype` the type a conversion to
log space will result in.

After that, the usual arithmetic operations on probabilities, like arithmetic and comparison, should
work just as for normal floats in non-log space.

Finally, there is a function `logsumexp` which effiently and more numerically stably calculates the
value of `log(sum(exp.(xs)))` for xs in log space -- a frequent operation, which corresponds to
summing probabilities in normal space.  The implementation works on general iterables both of normal
numbers and `LogNumbers`.

## Todo

- Sane conversion: not `float` anymore?  Why the infinite loop in `sin` etc.?
- More mathematical functions.
- Broadcasting to operate directly on log space values.
- What is the right epsilon?  Also `typemin`, `typemax`, etc.
- Overload `parse` appropriately.
- Add docstrings to everything!
- Tests for WrappedLogNumber{BigFloat}
