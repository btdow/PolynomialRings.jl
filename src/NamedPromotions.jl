module NamedPromotions

import Base: promote_rule, convert, Bottom
import SparseArrays: SparseVector, issparse

import ..AbstractMonomials: AbstractMonomial, exptype, num_variables, exponents
import ..Constants: One
import ..MonomialOrderings: MonomialOrder, NamedMonomialOrder, NumberedMonomialOrder
import ..Monomials.TupleMonomials: TupleMonomial
import ..Monomials.VectorMonomials: VectorMonomial
import ..NamingSchemes: Named, Numbered, NamingScheme, EmptyNamingScheme
import ..NamingSchemes: numberedvariablename, remove_variables, boundnames, canonicalscheme
import ..Polynomials:  NamedMonomial, NumberedMonomial, NamedTerm, NumberedTerm, TermOver, monomialorder
import ..Polynomials: Polynomial, PolynomialOver, NamedPolynomial, NumberedPolynomial, PolynomialBy, SparsePolynomialOver, DensePolynomialOver
import ..StandardMonomialOrderings: MonomialOrdering, rulesymbol
import ..Terms: Term, basering, monomial, coefficient
import ..Util: isdisjoint
import PolynomialRings: expansion, base_extend
import PolynomialRings: termtype, namingscheme, variablesymbols, exptype, monomialtype, allvariablesymbols, iscanonical, canonicaltype, nestednamingscheme, polynomialtype

# -----------------------------------------------------------------------------
#
# Base extension
#
# -----------------------------------------------------------------------------
base_extend(x, B::Type) = convert(base_extend(typeof(x), B), x)
base_extend(A::Type, B::Type) = error("cannot apply base_extend to $A")
base_extend(P::Type{<:Polynomial}, T::Type) = begin
    S = promote_rule(P, T)
    S == Bottom && error("No result for base_extend($P, $T)")
    return S
end

# short-circuit the non-conversions
convert(::Type{P}, p::P) where P <: SparsePolynomialOver{C,O} where {C,O<:NamedMonomialOrder} = p
convert(::Type{P}, p::P) where P <: SparsePolynomialOver{C,O} where {C,O<:NumberedMonomialOrder} = p
convert(::Type{P}, p::P) where P <: DensePolynomialOver{C,O} where {C,O<:NamedMonomialOrder} = p
convert(::Type{P}, p::P) where P <: DensePolynomialOver{C,O} where {C,O<:NumberedMonomialOrder} = p

# -----------------------------------------------------------------------------
#
# Promotions for different variable name sets
#
# -----------------------------------------------------------------------------

# fix method ambiguity
promote_rule(::Type{P}, ::Type{C}) where P<:PolynomialOver{C} where C <: Polynomial = polynomialtype(P)

function remove_variables(::Type{M}, vars) where M <: AbstractMonomial
    O = diff(monomialorder(M), vars)
    O == nothing && return One
    return monomialtype(O, exptype(M))
 end

function remove_variables(::Type{T}, vars) where T <: Term
    M = remove_variables(monomialtype(T), vars)
    C = remove_variables(basering(T), vars)
    M == One && return C
    return Term{M, C}
end
function remove_variables(::Type{P}, vars) where P <: Polynomial
    M = remove_variables(monomialtype(P), vars)
    C = remove_variables(basering(P), vars)
    M == One && return C
    return polynomialtype(M, C, issparse(P))
end
remove_variables(T::Type, vars) = T

nestednamingscheme(T::Type{<:Term}) = nestednamingscheme(basering(T)) * namingscheme(T)
nestednamingscheme(T::Type{<:Polynomial}) = nestednamingscheme(basering(T)) * namingscheme(T)
boundnames(T::Type{<:Term}) = boundnames(basering(T))
boundnames(T::Type{<:Polynomial}) = boundnames(basering(T))

_promote_rule(T1::Type{<:Polynomial}, T2::Type) = promote_rule(T1, T2)
_promote_rule(T1::Type,               T2::Type) = (res = promote_type(T1, T2); res === Any ? Bottom : res)

function promote_rule(::Type{T1}, ::Type{T2}) where T1 <: Polynomial where T2
    if !isdisjoint(namingscheme(T1), boundnames(T2))
        T1′ = remove_variables(T1, boundnames(T2))
        return _promote_rule(T1′, T2)
    elseif nestednamingscheme(T1) ⊆ nestednamingscheme(T2)
        return polynomialtype(_promote_rule(basering(T1), T2))
    elseif isdisjoint(namingscheme(T1), nestednamingscheme(T2))
        if (C = _promote_rule(basering(T1), T2)) !== Bottom
            return polynomialtype(monomialtype(T1), C, issparse(T1))
        end
    end
    return Bottom
end

function promote_rule(T1::Type{<:Term}, T2::Type)
    if !isdisjoint(namingscheme(T1), boundnames(T2))
        T1′ = remove_variables(T1, boundnames(T2))
        return _promote_rule(T1′, T2)
    elseif nestednamingscheme(T1) ⊆ nestednamingscheme(T2)
        return _promote_rule(basering(T1), T2)
    elseif isdisjoint(namingscheme(T1), nestednamingscheme(T2))
        if (C = _promote_rule(basering(T1), T2)) !== Bottom
            # TODO: replace by termtype(m, c) function
            return Term{monomialtype(T1), C}
        end
    end
    return Bottom
end


# -----------------------------------------------------------------------------
#
# Canonical types
#
# -----------------------------------------------------------------------------

joinsparse(x, y) = true
joinsparse(x::Type{<:Polynomial}, y) = issparse(x)
joinsparse(x, y::Type{<:Polynomial}) = issparse(y)
joinsparse(x::Type{<:Polynomial}, y::Type{<:Polynomial}) = issparse(x) && issparse(y)

≺(a::Numbered, b::Named) = !isempty(b)
≺(a::Numbered, b::Numbered) = numberedvariablename(a) < numberedvariablename(b)
≺(a::Named, b::Named) = isempty(a) && !isempty(b)
≺(a::Named, b::Numbered) = isempty(a)

promote_canonical_type(T1::Type, T2::Type) = promote_type(T1, T2)

promote_canonical_type(T1::Type, T2::Type{<:Polynomial}) = promote_canonical_type(T2, T1)

promote_canonical_type(T1::Type{<:Polynomial}, T2::Type{<:Polynomial}) = invoke(promote_canonical_type, Tuple{Type{<:Polynomial}, Type}, T1, T2)

function promote_canonical_type(T1::Type{<:Polynomial}, T2::Type)
    @assert iscanonical(T1) && iscanonical(T2)

    if !isdisjoint(namingscheme(T1), boundnames(T2))
        T1′ = remove_variables(T1, boundnames(T2))
        return promote_canonical_type(T1′, T2)
    elseif !isdisjoint(namingscheme(T2), boundnames(T1))
        T2′ = remove_variables(T2, boundnames(T1))
        return promote_canonical_type(T1, T2′)
    elseif namingscheme(T1) ≺ namingscheme(T2)
        M = monomialtype(T2)
        C = promote_canonical_type(T1, basering(T2))
        return polynomialtype(M, C, issparse(T2))
    elseif namingscheme(T2) ≺ namingscheme(T1)
        M = monomialtype(T1)
        C = promote_canonical_type(basering(T1), T2)
        return polynomialtype(M, C, issparse(T1))
    else
        M = promote_type(monomialtype(T1), monomialtype(T2))
        C = promote_type(basering(T1), basering(T2))
        return polynomialtype(M, C, joinsparse(T1, T2))
    end
end

function canonicaltype(P::Type{<:PolynomialOver{<:Polynomial}})
    C = canonicaltype(basering(P))
    M1 = monomialtype(C)
    M2 = canonicaltype(monomialtype(P))
    if namingscheme(M1) ≺ namingscheme(M2)
        P′ = polynomialtype(M2, C, issparse(P))
    elseif namingscheme(M2) ≺ namingscheme(M1)
        C1 = basering(C)
        P′ = polynomialtype(M1, polynomialtype(M2, C1), issparse(C))
    else
        M = promote_type(M1, M2)
        C1 = basering(C)
        P′ = polynomialtype(M, C1, joinsparse(P, C))
    end
    if P′ == P
        return P
    else
        # recursive sort
        return canonicaltype(P′)
    end
end
function canonicaltype(P::Type{<:Polynomial})
    C = canonicaltype(basering(P))
    M = canonicaltype(monomialtype(P))
    return polynomialtype(M, C, issparse(P))
end
@generated function canonicaltype(::Type{M}) where M <: NamedMonomial
    N = num_variables(M)
    I = exptype(M)
    names = tuple(sort(collect(variablesymbols(M)))...)
    res = TupleMonomial{N, I, MonomialOrdering{:degrevlex, Named{names}}}
    return :($res)
end

canonicaltype(M::Type{<:NumberedMonomial}) = M
canonicaltype(T::Type{<:Term}) = termtype(canonicaltype(polynomialtype(T)))
canonicaltype(T::Type) = T

iscanonical(::Type) = true
iscanonical(M::Type{<:AbstractMonomial}) = iscanonical(namingscheme(M)) && rulesymbol(monomialorder(M)) == :degrevlex

iscanonical(T::Type{<:Term})       = iscanonical(nestednamingscheme(T))
iscanonical(P::Type{<:Polynomial}) = iscanonical(nestednamingscheme(P))

@generated function _promote_result(::Type{T}, ::Type{S}, ::Type{LTR}, ::Type{RTL}) where {T, S, LTR, RTL}
    if LTR == Bottom && RTL != Bottom
        return RTL
    elseif RTL == Bottom && LTR != Bottom
        return LTR
    elseif LTR == RTL && LTR != Bottom
        return LTR
    else
        if namingscheme(T) == namingscheme(S)
            M = promote_type(monomialtype(T), monomialtype(S))
            C = promote_type(basering(T), basering(S))
            return polynomialtype(M, C, joinsparse(T, S))
        else
            return promote_canonical_type(canonicaltype(T), canonicaltype(S))
        end
    end
end

_promote_type(T, S) = _promote_result(T, S, promote_rule(T, S), promote_rule(S, T))

for T in [Term, Polynomial]
    @eval begin
        Base.promote_type(T::Type{<:$T}, S::Type)         = _promote_type(T, S)
        Base.promote_type(T::Type,       S::Type{<:$T})   = _promote_type(T, S)
        Base.promote_type(T::Type{<:$T}, S::Type{<:$T})   = _promote_type(T, S)

        Base.promote_type(T::Type{<:$T}, S::Type{Bottom}) = T
        Base.promote_type(T::Type{Bottom}, S::Type{<:$T}) = S
    end
end
for (T1, T2) in [(Term, Polynomial), (Polynomial, Term)]
    @eval begin
        Base.promote_type(T::Type{<:$T1}, S::Type{<:$T2}) = _promote_type(T, S)
    end
end

"""
    R = minring(f)

The smallest ring that faithfully contains `f`, i.e. the
intersection of all rings `R` that faithfully contain `f`.
"""
function minring end

minring(x::Integer) = typemin(Int) <= x <= typemax(Int) ? Int : BigInt
minring(x::Rational) = denominator(x) == 1 ? minring(numerator(x)) : typeof(x)
minring(x::Real) = round(x) ≈ x ? minring(Integer(x)) : typeof(x)
minring(x::Complex) = real(x) ≈ x ? minring(real(x)) : typeof(x)
minring(x) = typeof(x)

function minring(f::NamedPolynomial)
    iszero(f) && return Int

    base = reduce(promote_type, (minring(c) for (m, c) in expansion(f)))
    m = prod(m for (m, c) in expansion(f))

    if (nz = findall(!iszero, exponents(m, namingscheme(f)))) |> isempty
        return base
    else
        syms = variablesymbols(namingscheme(f))
        zscheme = namingscheme(syms[setdiff(eachindex(syms), nz)]...)
        M = remove_variables(monomialtype(f), zscheme)
        return polynomialtype(M, base, issparse(f))
    end
end

function minring(f::NumberedPolynomial)
    iszero(f) && return Int

    base = reduce(promote_type, (minring(c) for (m, c) in expansion(f)))
    m = prod(m for (m, c) in expansion(f))

    if isone(m)
        return base
    else
        return polynomialtype(monomialtype(f), base, issparse(f))
    end
end

"""
    R = minring(fs...)

The smallest ring that faithfully contains all `f ∈ fs`
"""
minring(fs...) = promote_type(minring.(fs)...)


"""
    g = ofminring(f)

Shorthand for `convert(minring(f), f)`
"""
ofminring(f) = convert(minring(f), f)

end # module
