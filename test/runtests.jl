using LogNumbers
using Test

@testset "Conversions" begin
    for x ∈ [Float64(42), Float32(42), Float16(42)]
        for F ∈ [Float64, Float32, Float16]
            L = logtype(F)
            
            l = convert(L, x)
            f = convert(F, Log(x))
            
            @test f ≈ x
            @test logvalue(l) ≈ log(x)
            @test floattype(l) == F
            @test l isa L
            @test f isa F
        end
    end
    
    # promote(Log(32f1), Log(32e1))
    # promote(Log(32f1), 32e1)
    # promote(32f1, Log(32e1))
end

@testset "Literals" begin
    @test log"32" == Log(32)
    @test log"32" isa logtype(32)

    @test log"32e1" == Log(32e1)
    @test log"32e1" isa logtype(32e1)

    @test log"32f1" == Log(32f1)
    @test log"32f1" isa logtype(32f1)
end

@testset "Constants" begin
    LogZero16 = zero(LogFloat16)

    # zero and inf constants
    for (logzero, loginf, F) ∈ zip([LogZero64, LogZero32, LogZero16],
                                   [LogInf64, LogInf32, LogInf16],
                                   [Float64, Float32, Float16])
        L = logtype(F)
        @test logzero == zero(L)
        @test loginf == infty(L)
    end

    # nan constants
    for (nan, lognan) ∈ zip([NaN64, NaN32, NaN16], [LogNaN64, LogNaN32, LogNaN16])
        @test isequal(Log(nan), lognan)
        @test Log(nan) != lognan
        @test isnan(lognan)
    end

    # constructors
    for F ∈ [Float64, Float32, Float16]
        L = logtype(F)

        @test Log(F, 0) == LogNumber(F, -infty(F)) == zero(L)
        @test iszero(zero(L))
        @test Log(F, 1) == LogNumber(F, 0) == one(L)
        @test Log(infty(F)) == infty(L)
        @test isinf(infty(L))
    end
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
