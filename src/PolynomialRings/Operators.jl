module Operators

import Base: zero, one, +, -, *, ==, /, //, inv, diff, div, iszero, ^, gcd

import InPlace: @inplace, inplace!, inclusiveinplace!

import ..AbstractMonomials: AbstractMonomial
import ..Constants: Zero
import ..Expansions: expansion
import ..MonomialOrderings: MonomialOrder, @withmonomialorder
import ..NamingSchemes: Variable
import ..Polynomials: Polynomial, termtype, monomialorder, monomialtype, monomials, coefficients, map_coefficients, _monomialbyindex
import ..Polynomials: PolynomialBy, TermBy, MonomialBy, isstrictlysparse, TermOver
import ..Polynomials: leading_term
import ..Terms: Term, monomial, coefficient
import ..Util: @assertvalid
import PolynomialRings: basering, exptype, base_extend, base_restrict
import PolynomialRings: lcm_multipliers, expansion
import PolynomialRings: leading_monomial, leading_coefficient, checkconstant
import PolynomialRings: maybe_div

# -----------------------------------------------------------------------------
#
# zero, one, etc
#
# -----------------------------------------------------------------------------
zero(::P)       where P <: Polynomial = zero(P)
one(::P)        where P <: Polynomial = one(P)

# -----------------------------------------------------------------------------
#
# addition, subtraction
#
# -----------------------------------------------------------------------------
+(a::PolynomialBy{Order}, b::PolynomialBy{Order}) where Order = a .+ b
-(a::PolynomialBy{Order}, b::PolynomialBy{Order}) where Order = a .- b

*(a::Polynomial) = deepcopy(a)


# -----------------------------------------------------------------------------
#
# multiplication
#
# -----------------------------------------------------------------------------
function *(a::PolynomialBy{Order}, b::PolynomialBy{Order}) where Order
    P = promote_type(typeof(a), typeof(b))
    # FIXME(tkluck): promote_type currently only guarantees that
    #     namingscheme(P) == namingscheme(Order)
    # See NamedPromotions.jl
    @assert monomialorder(P) == Order()

    res = zero(P)
    for t_a in expansion(a), t_b in expansion(b)
        @inplace res += t_a * t_b
    end
    return @assertvalid res
end

# -----------------------------------------------------------------------------
#
# Operations when it is constant
#
# -----------------------------------------------------------------------------
inv(a::Polynomial) = inv(checkconstant(a))
/(a::Polynomial, b::Polynomial) = a / checkconstant(b)
/(a::Number, b::Polynomial) = a / checkconstant(b)
//(a::Polynomial, b::Polynomial) = a // checkconstant(b)
//(a::Number, b::Polynomial) = a // checkconstant(b)

# -----------------------------------------------------------------------------
#
# long division
#
# -----------------------------------------------------------------------------
abstract type RedType end
struct Lead <: RedType end
struct Full <: RedType end
struct Tail <: RedType end

terms_to_reduce(::Lead, f; order) = (leading_term(f, order=order),)
terms_to_reduce(::Full, f; order) = expansion(f, order, rev=true)
terms_to_reduce(::Tail, f; order) = expansion(f, order, rev=true, tail=true)

function one_step_div!(f::Polynomial, g::Polynomial; order::MonomialOrder, redtype::RedType)
    @withmonomialorder order
    g = oftype(f, g) # TODO: fix broacasting so the operations below work without this line.
    if iszero(f)
        return nothing
    end
    if iszero(g)
        throw(DivideError())
    end
    lt_g = lt(g)
    for t in terms_to_reduce(redtype, f, order=order)
        factor = maybe_div(t, lt_g)
        if factor !== nothing
            @. f -= factor * g
            return factor
        end
    end
    return nothing
end

function one_step_xdiv!(f::Polynomial, g::Polynomial; order::MonomialOrder, redtype::RedType)
    @withmonomialorder order
    g = oftype(f, g) # TODO: fix broacasting so the operations below work without this line.
    if iszero(f)
        return nothing
    end
    if iszero(g)
        throw(DivideError())
    end
    lm_g = lm(g)
    m2 = lc(g)
    for t in terms_to_reduce(redtype, f, order=order)
        factor = maybe_div(monomial(t), lm_g)
        if factor !== nothing
            m1 = coefficient(t)
            k1, k2 = lcm_multipliers(m1, m2)
            @. f = k1 * f - k2 * (factor * g)
            return k1, k2 * factor
        end
    end
    return nothing
end

# -----------------------------------------------------------------------------
#
# exponentiation
#
# -----------------------------------------------------------------------------
function multinomial(n,k...)
    @assert sum(k) == n

    i = 1
    for k_i in k
        i *= binomial(n,k_i)
        n -= k_i
    end
    i
end

function ^(f::Polynomial, n::Integer)
    if n == 0
        return one(f)
    end
    if n == 1 || iszero(f)
        return deepcopy(f)
    end

    P = typeof(f)
    M = monomialtype(f)
    C = basering(f)
    E = exptype(f)
    I = typeof(n)

    N = length(coefficients(f))

    # need BigInts to do the multinom computation, but we'll cast
    # back to I = typeof(n) when we use it as an exponent
    bign = BigInt(n)
    i = zeros(BigInt, N)
    i[N] = bign

    nterms = Int(multinomial(bign + N - 1, N - 1, bign))
    result = zero(P)
    sizehint!(result, nterms)

    while true
        c = try
            C(multinomial(bign, i...))
        catch e
            e isa InexactError || rethrow()
            throw(OverflowError("Coefficient overflow while doing exponentiation; suggested fix is replacing `f^n` by `base_extend(f, BigInt)^n`"))
        end
        m = one(M)
        for k in 1 : N
            m *= _monomialbyindex(f, k)      ^ E(i[k])
            @inplace c *= coefficients(f)[k] ^ I(i[k])
        end
        @inplace result += Term(m, c)

        carry = 1
        for j = N - 1 : -1 : 1
            i[j] += carry
            i[N] -= carry
            if i[N] < 0
                carry = 1
                i[N] += i[j]
                i[j] = 0
            else
                carry = 0
            end
        end
        if carry != 0
            break
        end
    end
    return @assertvalid result
end

# -----------------------------------------------------------------------------
#
# exponentiation
#
# -----------------------------------------------------------------------------
function diff(f::Polynomial, x)
    res = zero(f)
    for t in expansion(f)
        @inplace res += diff(t, x)
    end
    return res
end

# -----------------------------------------------------------------------------
#
# gcds and content
#
# -----------------------------------------------------------------------------
gcd(f::Polynomial, g::Integer) = gcd(g, reduce(gcd, coefficients(f), init=zero(basering(f))))
gcd(g::Integer, f::Polynomial) = gcd(g, reduce(gcd, coefficients(f), init=zero(basering(f))))

div(f::Polynomial, g::Integer) = map_coefficients(c -> c÷g, f)

content(f::Polynomial) = gcd(f, 0)

common_denominator(a) = denominator(a)
common_denominator(a::Complex) = common_denominator(real(a), imag(a))
common_denominator(a, b) = lcm(denominator(a), denominator(b))
common_denominator(a, b...) = lcm(denominator(a), denominator.(b)...)
common_denominator(f::Polynomial) = iszero(f) ? common_denominator(one(basering(f))) : mapreduce(common_denominator, lcm, coefficients(f))

function integral_fraction(f::Polynomial)
    N = common_denominator(f)
    return base_restrict(N * f), N
end


# -----------------------------------------------------------------------------
#
# Use Term/Monomial/Coefficient as a scalar
#
# -----------------------------------------------------------------------------
for Coeff in [Any, Polynomial, Number]
    @eval begin
        function *(a::C, b::P) where P <: Polynomial{M,C} where {M <: AbstractMonomial, C <: $Coeff}
            iszero(a) && return zero(P)
            map_coefficients(b_i -> a * b_i, b)
        end
        function *(a::P, b::C) where P <: Polynomial{M,C} where {M <: AbstractMonomial, C <: $Coeff}
            iszero(b) && return zero(P)
            map_coefficients(a_i -> a_i * b, a)
        end
    end
end

# -----------------------------------------------------------------------------
#
# Multiplying Terms in-place
#
# -----------------------------------------------------------------------------
function inplace!(::typeof(*), a::T, b::MonomialBy{Order}, c::T) where T <: TermBy{Order} where Order <: MonomialOrder
    if coefficient(a) === coefficient(c)
        # in-place means that we do not need to deepcopy the coefficient
        a = Term(b * monomial(c), coefficient(c))
    else
        a = b * c
    end
    a
end

function inplace!(::typeof(*), a::T, b::C, c::T) where T <: TermOver{C} where C
    if coefficient(a) === coefficient(c)
        coef = coefficient(a)
        @inplace coef *= b
        a = Term(monomial(c), coef)
    else
        a = b * c
    end
    a
end

end
