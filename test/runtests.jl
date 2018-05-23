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
