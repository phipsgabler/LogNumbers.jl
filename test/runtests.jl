using LogNumbers
using Base.Test

@testset "Conversions" begin
    x = 42.0
    
    r1 = convert(LogFloat64, x)
    r2 = convert(LogFloat32, x)
    r3 = convert(Float64, Log(x))
    r4 = convert(Float32, Log(x))
    @test logvalue(r1) ≈ log(x)
    @test floattype(r1) == Float64 == typeof(x)
    @test logvalue(r2) ≈ log(x)
    @test floattype(r2) == Float32
    @test r3 ≈ x
    @test typeof(r3) == Float64 == typeof(x)
    @test r4 ≈ x
    @test typeof(r4) == Float32

    # promote(Log(32f1), Log(32e1))
    # promote(Log(32f1), 32e1)
    # promote(32f1, Log(32e1))
end

@testset "Constants, literals, equality" begin
    @test LogZero == LogNumber(Float64, -Inf) == Log(0) == zero(LogFloat64)
    @test iszero(LogZero)
    @test Log(1) == LogNumber(Float64, 0.0) == one(LogFloat64)

    @test Log(Inf) == LogInf
    @test isinf(LogInf)

    @test isequal(Log(NaN), LogNaN)
    @test Log(NaN) != LogNaN
    @test isnan(LogNaN)

    @test log"32" == Log(32)
    @test log"32e1" == Log(32e1)
    @test log"32f1" == Log(32f1)
end

@testset "Addition, subtraction" begin
    for F ∈ [Float64, Float32, Float16]
        # pure
        @test Log(F, 32) + Log(F, 32) ≈ Log(F, 64)
        @test Log(F, 0) + Log(F, 32) ≈ Log(F, 32)
        @test Log(F, 32) + Log(F, 0) == Log(F, 32)
        @test Log(F, 0) + Log(F, 0) == Log(F, 0)
        
        @test Log(F, 32) - Log(F, 30) ≈ Log(F, 2)
        @test Log(F, 32) - Log(F, 0) == Log(F, 32)
        @test Log(F, 32) - Log(F, 32) == Log(F, 0)

        @test Log(F, 32) + Log(F, Inf) == Log(F, Inf)
        @test Log(F, Inf) + Log(F, 32) == Log(F, Inf)
        @test Log(F, Inf) - Log(F, 32) == Log(F, Inf)
        @test Log(F, Inf) + Log(F, Inf) == Log(F, Inf)

        # mixed
        @test Log(F, 32) + 32 ≈ Log(F, 64)
        @test 0 + Log(F, 0) == Log(F, 0)
        @test 32 - Log(F, 0) == Log(F, 32)
        @test Log(F, 32) - 0 == Log(F, 32)
        @test 32 - Log(F, 30) ≈ Log(F, 2)
        @test Log(F, 32) - 32 ≈ Log(F, 0)
        @test 32 - Log(F, 32) ≈ Log(F, 0)

        # indeterminates
        @test_throws DomainError Log(F, 10) - Log(F, 32)
        @test_throws DomainError Log(F, 0) - Log(F, 32)
        @test_throws DomainError Log(F, 32) - Log(F, Inf)
        @test isequal(Log(F, Inf) - Log(F, Inf), Log(F, NaN))
    end
end

@testset "Multiplication, division" begin
    for F ∈ [Float64, Float32, Float16]
        @test Log(F, 32) * Log(F, 2) ≈ Log(F, 64)
        @test Log(F, 32) * Log(F, 1) ≈ Log(F, 32)
        @test Log(F, 32) * Log(F, 0) ≈ Log(F, 0)

        @test Log(F, 32) / Log(F, 32) ≈ Log(F, 1)
        @test Log(F, 32) / Log(F, 1) ≈ Log(F, 32)
        @test Log(F, 1) / Log(F, 32) ≈ Log(F, 1/32)
        @test Log(F, 0) / Log(F, 32) == Log(F, 0)
        @test Log(F, 32) / Log(F, 0) == Log(F, Inf)

        # indetermiates
        @test isequal(Log(F, 0) / Log(F, 0), Log(F, NaN))
        @test isequal(Log(F, Inf) / Log(F, Inf), Log(F, NaN))
        @test isequal(Log(F, Inf) * Log(F, 0), Log(F, NaN))
        @test isequal(Log(F, 0) * Log(F, Inf), Log(F, NaN))
    end
end

@testset "Logsumexp" begin
    function logsumexp_naive(xs)
        α = maximum(xs)
        r = sum(exp(x - α) for x in xs)
        log(r) + α
    end

    l1, l2, l3, l4, l5 = [0], [1], [42], 1:1000, 1 ./ (1:1000)
    @test isequal(logvalue(logsumexp(Log.([0]))), logsumexp_naive(log.([0])))
    for l in [l2, l3, l4, l5]
        @test logvalue(logsumexp(Log.(l))) ≈ logsumexp(log.(l)) ≈ logsumexp_naive(log.(l))
    end
end
