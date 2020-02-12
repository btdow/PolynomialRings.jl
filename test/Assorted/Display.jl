using Test
using PolynomialRings

@testset "Display" begin

    using PolynomialRings
    using PolynomialRings: basering, termtype
    using PolynomialRings.Polynomials: NamedPolynomial

    R = @ring! ℚ[x,y]
    S = @ring! ℚ[q[]][x,y]
    T = @ring! ℤ[a,b,c]
    U = @ring! Int64[ε]
    V = @ring! ℤ[r[]]

    @testset "Types" begin
        @test repr(R) == "ℚ[x,y]"
        @test repr(S) == "ℚ[q[]][x,y]"
        @test repr(T) == "ℤ[a,b,c]"
        @test repr(U) == "Int64[ε]"

        @test repr(termtype(R)) == "(Term over Rational{BigInt} in x,y)"

        # test that these do not throw an error
        @test repr(methods(^)) isa String
        @test repr(NamedPolynomial) isa String
    end

    @testset "Polynomials" begin
        @test repr(a) == "a"
        @test repr(r[1]) == "r[1]"
        @test repr(a+b) == "a + b"
        @test repr(-a) == "-a"
        @test repr(b-a) == "-a + b"
        @test repr(2a) == "2*a"
        @test repr(-2a) == "-2*a"
        @test repr(r[1]*a) == "r[1]*a"
        @test repr(r[1]*a + a) == "(r[1] + 1)*a"
        @test repr(2r[1]*a + a) == "(2*r[1] + 1)*a"
        @test repr(0*x) == "0"

        @ring! R[e[]]
        e1,e2,e3 = e[]
        @test repr(e1) == "e[1]"
        @test repr(e2) == "e[2]"
        @test repr(e3) == "e[3]"
        @test repr(2*e3) == "2//1*e[3]"

    end

end
