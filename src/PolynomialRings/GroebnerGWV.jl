module GröbnerGWV

using Nulls
using DataStructures: SortedDict, DefaultDict
using Iterators: chain

import PolynomialRings
import PolynomialRings: gröbner_basis
import PolynomialRings.Backends.Gröbner: GWV

import PolynomialRings: leading_term, leading_monomial, lcm_multipliers, lcm_degree, fraction_field, basering, base_extend
import PolynomialRings: maybe_div, termtype, monomialtype, leading_row, leading_coefficient
import PolynomialRings.MonomialOrderings: MonomialOrder
import PolynomialRings.Monomials: total_degree, any_divisor
import PolynomialRings.Polynomials: Polynomial, monomialorder, monomialtype
import PolynomialRings.Terms: monomial, coefficient
import PolynomialRings.Modules: AbstractModuleElement, modulebasering
import PolynomialRings.Operators: Lead, Full

function regular_topreduce_rem(o, m, G)
    u1,v1 = m
    i = 1
    supertopreducible = false
    while i <= length(G)
        u2, v2 = G[i]
        if iszero(v2)
            if !isnull(maybe_div(u1, u2))
                supertopreducible = true
            end
        elseif !iszero(v1)
            t = maybe_div(leading_monomial(o,v1), leading_monomial(o,v2))
            if !isnull(t)
                c = leading_coefficient(o,v1) // leading_coefficient(o,v2)
                if Base.Order.lt(o, t * u2, u1)
                    # new_u1 = u1 - c*(t*u2)
                    v1 = v1 - c*(t*v2)
                    supertopreducible = false
                    i = 1
                    continue
                elseif t * u2 == u1 && c == one(c)
                    supertopreducible = true
                end
            end
        end
        i += 1
    end

    return (m[1],v1), supertopreducible ? :supertopreducible : :notsupertopreducible
end

"""
    gröbner_basis = gwv(monomialorder, polynomials)

An implementation of the GWV algorithm as popularized by
> Shuhong Gao, Frank Volny, and Mingsheng Wang. "A new algorithm for computing
> Groebner bases." IACR Cryptology ePrint Archive 2010 (2010): 641.
"""
function gwv(o::MonomialOrder, polynomials::AbstractVector{P}) where P <: Polynomial
    R = base_extend(P)
    Rm = RowVector{R, SparseVector{R,Int}}
    Signature = monomialtype(polynomials)
    M = Tuple{Signature, R}

    signature(m) = m[1]
    # --------------------------------------------------------------------------
    # Declare the variables where we'll accumulate the result
    # --------------------------------------------------------------------------
    G = Tuple{Signature, R}[]
    H = DefaultDict{Int, Set{monomialtype(R)}}(Set{monomialtype(R)})
    JP = SortedDict{Signature, M}(o)

    n = length(polynomials)
    for (i,p) in enumerate(polynomials)
        T = leading_monomial( sparsevec(Dict(i=>one(R)), n)' )
        m = (T, p)
        JP[signature(m)] = m
    end

    loops = 0
    considered = 0
    divisors_considered = 0
    divisor_considerations = 0
    progress_logged = false
    # step 3
    while !isempty(JP)
        loops += 1
        if loops % 100 == 0
            l = length(G)
            k = length(JP)
            h = sum(length, values(H))
            info("GWV: After $loops loops: $l elements in basis; $considered J-pairs considered; |JP|=$k, |H|=$h; $divisor_considerations considerations of divisors ($(divisors_considered/divisor_considerations) divisors on average).")
            progress_logged = true
        end

        # step 1.
        sig, m = first(JP)
        delete!(JP, sig)
        (T, v1) = m

        # step 2: criterion from thm 2.3(c)
        # there is a pair (u_2, v_2) ∈ G so that lm(u_2) divides
        # lm(T) and t lm(v_2) ≺ lm(v_1) where t = lm(T)/lm(u_2)
        if any(G) do m2
            u2,v2 = m2
            t = maybe_div(T, u2)
            if !isnull(t)
                if Base.Order.lt(o, t * leading_monomial(o,v2), leading_monomial(o,v1))
                    return true
                end
            end
            return false
        end
            continue
        end

        (_,v), status = regular_topreduce_rem(o, m, G)

        if iszero(v)
            newh = T
            push!(H[newh.i], newh.m)
            filter!(JP) do sig, jp
                T2, v2 = jp
                divisible = !isnull(maybe_div(T2, newh))
                !divisible
            end
        else
            if status == :supertopreducible
                # pass
            elseif status == :notsupertopreducible
                # i) Add the leading terms of the principle syzygies, vT j − v j T for
                # 1 ≤ j ≤ |U |, to H,
                for (Tj, vj) in G
                    # syzygy = v*Tj - vj*T
                    lhs = leading_monomial(o,v)*Tj
                    rhs = leading_monomial(o,vj)*T
                    if lhs != rhs
                        newh = max(o, lhs, rhs)
                        push!(H[newh.i], newh.m)
                    end
                end
                # ii) Form new J-pairs of (T, v) and (T j , v j ), 1 ≤ j ≤ |U |,
                # iii) Insert into JP all such J-pairs whose signatures are not re-
                # ducible by H (storing only one J-pair for each distinct signature
                # T , the one with v-part minimal), and
                for (Tj, vj) in G
                    t1, t2 = lcm_multipliers(leading_monomial(o,v), leading_monomial(o,vj))
                    c = leading_coefficient(o,v) // leading_coefficient(o,vj)
                    lhs = t1*T
                    rhs = t2*Tj
                    if !(c == one(c) && lhs == rhs)
                        if Base.Order.lt(o, lhs, rhs)
                            Jsig = rhs
                            Jpair = (t2*Tj, t2*vj)
                        else
                            Jsig = lhs
                            Jpair = (t1*T, t1*v)
                        end
                        divisor_considerations += 1
                        if !any_divisor(Jsig.m) do d
                            divisors_considered += 1
                            d in H[Jsig.i]
                        end
                            if Jsig in keys(JP)
                                oldu,oldv = JP[Jsig]
                                newv = Jpair[2]
                                if Base.Order.lt(o, newv, oldv)
                                    JP[Jsig] = Jpair
                                end
                            else
                                JP[Jsig] = Jpair
                            end
                        end
                    end
                end
                # iv) Append T to U and v to V .
                push!(G, (T,v))
            else
                @assert false "Didn't expect $status"
            end
        end

        considered += 1
    end

    # --------------------------------------------------------------------------
    # Interreduce the result
    # --------------------------------------------------------------------------
    result = getindex.(G, 2)
    k = length(result)
    progress_logged && info("Done; interreducing the $k result polynomials")
    for i in 1:k
        result[i] = rem(o, result[i], result[[1:i-1; i+1:k]])
    end
    filter!(!iszero, result)
    progress_logged && info("Done. Returning a Gröbner basis of length $(length(result))")
    # --------------------------------------------------------------------------
    # Return the result
    # --------------------------------------------------------------------------
    return result
end

gröbner_basis(::GWV, o::MonomialOrder, G::AbstractArray{<:Polynomial}; kwds...) = gwv(o, G, kwds...)

end