using LogNumbers
using Base.Test

@testset "Conversions" begin
    x = 42.0
    
    r1 = convert(LogNumber{Float64}, Log(x))
    r2 = convert(LogNumber{Float32}, Log(x))
    r3 = convert(Float64, Log(x))
    r4 = convert(Float32, Log(x))
    @test r1.log ≈ log(x)
    @test floattype(r1) == Float64 == typeof(x)
    @test r2.log ≈ log(x)
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
    @test LogZero == LogNumber{Float64}(-Inf) == Log(0) == zero(LogNumber{Float64})
    @test iszero(LogZero)
    @test Log(1) == LogNumber{Float64}(0.0) == one(LogNumber{Float64})

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
    # pure
    @test Log(32) + Log(32) ≈ Log(64)
    @test Log(0) + Log(32) ≈ Log(32)
    @test Log(32) + Log(0) == Log(32)
    @test Log(0) + Log(0) == Log(0)
    
    @test Log(32) - Log(30) ≈ Log(2)
    @test Log(32) - Log(0) == Log(32)
    @test Log(32) - Log(32) == Log(0)

    @test Log(32) + Log(Inf) == Log(Inf)
    @test Log(Inf) + Log(32) == Log(Inf)
    @test Log(Inf) - Log(32) == Log(Inf)
    @test Log(Inf) + Log(Inf) == Log(Inf)

    # mixed
    @test Log(32) + 32 ≈ Log(64)
    @test 0 + Log(0) == Log(0)
    @test 32 - Log(0) == Log(32)
    @test Log(32) - 0 == Log(32)
    @test 32 - Log(30) ≈ Log(2)
    @test Log(32) - 32 ≈ Log(0)
    @test 32 - Log(32) ≈ Log(0)

    # indeterminates
    @test_throws DomainError Log(10) - Log(32)
    @test_throws DomainError Log(0) - Log(32)
    @test_throws DomainError Log(32) - Log(Inf)
    @test isequal(Log(Inf) - Log(Inf), Log(NaN))
end

@testset "Multiplication, division" begin
    @test Log(32) * Log(2) ≈ Log(64)
    @test Log(32) * Log(1) ≈ Log(32)
    @test Log(32) * Log(0) ≈ Log(0)

    @test Log(32) / Log(32) ≈ Log(1)
    @test Log(32) / Log(1) ≈ Log(32)
    @test Log(1) / Log(32) ≈ Log(1/32)
    @test Log(0) / Log(32) == Log(0)
    @test Log(32) / Log(0) == Log(Inf)

    # indetermiates
    @test isequal(Log(0) / Log(0), Log(NaN))
    @test isequal(Log(Inf) / Log(Inf), Log(NaN))
    @test isequal(Log(Inf) * Log(0), Log(NaN))
    @test isequal(Log(0) * Log(Inf), Log(NaN))
end
