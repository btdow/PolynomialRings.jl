module Util

import Base: delete!, similar
import Base: filter, filter!
import Base: iterate
import Base: length, isempty
import Base: length, iterate
import Base: pairs
import SparseArrays: SparseVector, SparseMatrixCSC, AbstractSparseArray, spzeros

import DataStructures: PriorityQueue, SortedSet, OrderedSet, OrderedDict
import DataStructures: percolate_down!, percolate_up!, enqueue!, dequeue!, peek
import OrderedCollections: ht_keyindex, rehash!
import ProgressMeter
import ProgressMeter: Progress, next!, finish!
import Transducers: Transducer, R_, inner, wrap, xform
import Transducers: start, next, complete
import Transducers: wrapping, unwrap

# -----------------------------------------------------------------------------
#
# Bounded heap
#
# -----------------------------------------------------------------------------
mutable struct BoundedHeap{T, O<:Base.Order.Ordering}
    values::Vector{T}
    cur_length::Int
    max_length::Int
    order::O
    BoundedHeap{T, O}(max_length::Int, order::O) where {T, O} = new(resize!(T[], max_length+1), 0, max_length, order)
end

BoundedHeap(T::Type, max_length::Int, order::Base.Order.Ordering) = BoundedHeap{T, typeof(order)}(max_length, order)


function enqueue!(x::BoundedHeap{T, O}, v::T) where {T,O}
    x.values[x.cur_length+1] = v
    if(x.cur_length < x.max_length)
        x.cur_length +=1
    end
    percolate_up!(x.values, x.cur_length, x.order)
end

function dequeue!(x::BoundedHeap{T, O})::T where {T,O}
    if x.cur_length < 1
        throw(BoundsError())
    end
    v = x.values[1]
    x.values[1] = x.values[x.cur_length]
    x.cur_length -= 1
    percolate_down!(x.values, 1, x.order, x.cur_length)
    return v
end

function peek(x::BoundedHeap{T,O})::T where {T,O}
    if x.cur_length < 1
        throw(BoundsError())
    end
    return x.values[1]
end

length(x::BoundedHeap) = x.cur_length
isempty(x::BoundedHeap) = iszero(x.cur_length)


lazymap(f::Function, c) = map(f,c)
lazymap(f::Function, c::C) where C<:Channel = Channel() do ch
    for x in c
        push!(ch, f(x))
    end
end

# -----------------------------------------------------------------------------
#
# make filter! work for priority queues
#
# -----------------------------------------------------------------------------
delete!(pq::PriorityQueue{K}, k::K) where K = dequeue!(pq, k)
similar(pq::PriorityQueue{K, V, O}) where {K, V, O} = PriorityQueue{K, V}(O.instance)

# -----------------------------------------------------------------------------
#
# make filter! work for SortedSets
#
# -----------------------------------------------------------------------------
function filter!(f::Function, s::SortedSet)
    for x in s
        if !f(x)
            delete!(s, x)
        end
    end
    return s
end
filter(f::Function, s::SortedSet) = filter!(f, copy(s))

# -----------------------------------------------------------------------------
#
# speed up iteration over pairs(::PriorityQueue)
#
# -----------------------------------------------------------------------------
pairs(x::PriorityQueue) = x.xs

# -----------------------------------------------------------------------------
#
# iterate over subsets of OrderedSet
#
# -----------------------------------------------------------------------------
function interval(x::OrderedDict, lower; lo)
    δ = lo == :exclusive ? 1 : lo == :inclusive ? 0 : error("lo needs to be :inclusive or :exclusive; not $lo")
    # XXX rehash is only needed for deletions, which we don't do
    #rehash!(x)
    index = ht_keyindex(x, lower, true)
    return (index<0) ? throw(KeyError(lower)) : @views zip(x.keys[index + δ : end], x.vals[index + δ : end])
end

function last_(x::OrderedDict)
    # XXX rehash is only needed for deletions, which we don't do
    #rehash!(x)
    return x.keys[end]
end

interval(x::OrderedSet, lower; lo) = interval(x.dict, lower; lo=lo).is[1]
last_(x::OrderedSet) = last_(x.dict)

include("LinAlgUtil.jl")

# -----------------------------------------------------------------------------
#
# Utility for showing progress on Gröbner basis computations
#
# -----------------------------------------------------------------------------
_length(x) = length(x)
_length(x::AbstractDict{K, <: AbstractDict}) where K = sum(length, values(x))
_length(x::AbstractDict{K, <: AbstractVector}) where K = sum(length, values(x))
macro showprogress(desc, exprs...)
    infos = exprs[1:end-1]
    expr = last(exprs)

    min_update_time = :( $Base.isinteractive() ? 1 : Inf )

    ourpattern = expr.head == :while && expr.args[1].head == :call &&
        expr.args[1].args[1] == :! && expr.args[1].args[2].head == :call &&
        expr.args[1].args[2].args[1] == :isempty
    if !ourpattern
        return esc(:(
            $ProgressMeter.@showprogress $min_update_time $desc $expr
        ))
    end
    P = expr.args[1].args[2].args[2]
    condition = expr.args[1]
    body = expr.args[2]

    function infoval(L)
        sym = QuoteNode(Symbol("|$L|"))
        :( ($sym, _length($(esc(L)))) )
    end
    infovals = map(infoval, infos)

    quote
        progress = Progress(length($(esc(P))), $min_update_time, $desc)
        loops = 0
        while $(esc(condition))
            $(esc(body))

            loops += 1
            progress.n = length($(esc(P))) + loops
            next!(progress, showvalues = [$(infovals...)])
        end
        finish!(progress)
    end
end

# -----------------------------------------------------------------------------
#
# Readable alternative for Iterators.flatten
#
# -----------------------------------------------------------------------------
chain(iters...) = Iterators.flatten(iters)

# -----------------------------------------------------------------------------
#
# Helper for iteration over nonzeros in arrays
#
# -----------------------------------------------------------------------------
nzpairs(iter) = (i => x for (i, x) in pairs(iter) if !iszero(x))

nzpairs(iter::SparseVector) = (
    iter.nzind[j] => iter.nzval[j]
    for j in eachindex(iter.nzind) if !iszero(iter.nzval[j])
)

nzpairs(iter::SparseMatrixCSC) = (i => iter[i] for i in findall(!iszero, iter))

eachstoredindex(::NTuple{N}...) where N = Base.OneTo(N)
eachstoredindex(xs...) = Base.OneTo(min(map(lastindex, xs)...))
eachstoredindex(a::SparseVector, b::SparseVector) = begin
    length(a) == length(b) || error("eachstoredindex: need same-length arguments")
    EachStoredIndex(a, b)
end

struct EachStoredIndex{A <: SparseVector, B <: SparseVector}
    a :: A
    b :: B
end

iterate(x::EachStoredIndex, state=(1, 1)) = begin
    a, b = x.a, x.b
    ixa, ixb = state
    if ixa > lastindex(a.nzind) && ixb > lastindex(b.nzind)
        return nothing
    elseif ixb > lastindex(b.nzind)
        a.nzind[ixa] > length(a) && return nothing # we sometimes create views of length
                                                   # findlast(!iszero, ...), which may be
                                                   # shorter than the number of stored elements
        return a.nzind[ixa], (ixa + 1, ixb)
    elseif ixa > lastindex(a.nzind)
        b.nzind[ixb] > length(b) && return nothing # same
        return b.nzind[ixb], (ixa, ixb + 1)
    elseif a.nzind[ixa] < b.nzind[ixb]
        a.nzind[ixa] > length(a) && return nothing # same
        return a.nzind[ixa], (ixa + 1, ixb)
    elseif a.nzind[ixa] > b.nzind[ixb]
        b.nzind[ixb] > length(b) && return nothing # same
        return b.nzind[ixb], (ixa, ixb + 1)
    else
        a.nzind[ixa] > length(a) && return nothing # same
        return a.nzind[ixa], (ixa + 1, ixb + 1)
    end
end

struct RevEachStoredIndex{A <: SparseVector, B <: SparseVector}
    a :: A
    b :: B
end

iterate(x::RevEachStoredIndex, state=(lastindex(x.a.nzind), lastindex(x.b.nzind))) = begin
    a, b = x.a, x.b
    ixa, ixb = state
    if ixa < 1 && ixb < 1
        return nothing
    elseif ixb < 1
        return a.nzind[ixa], (ixa - 1, ixb)
    elseif ixa < 1
        return b.nzind[ixb], (ixa, ixb - 1)
    elseif a.nzind[ixa] > b.nzind[ixb]
        return a.nzind[ixa], (ixa - 1, ixb)
    elseif a.nzind[ixa] < b.nzind[ixb]
        return b.nzind[ixb], (ixa, ixb - 1)
    else
        return a.nzind[ixa], (ixa - 1, ixb - 1)
    end
end

Iterators.reverse(x::EachStoredIndex) = RevEachStoredIndex(x.a, x.b)
Iterators.reverse(x::RevEachStoredIndex) = EachStoredIndex(x.a, x.b)

similarzeros(a::AbstractArray, elementtype=eltype(a)) = zeros(elementtype, size(a)...)
similarzeros(a::AbstractSparseArray, elementtype=eltype(a)) = spzeros(elementtype, size(a)...)

# -----------------------------------------------------------------------------
#
# A transducer that merges two iterables like a zipper
#
# -----------------------------------------------------------------------------
struct MergingTransducer{Iter, Order, LeftOp, RightOp, MergeOp, Key, Value, Constructor} <: Transducer
    iter        :: Iter
    order       :: Order
    leftop      :: LeftOp
    rightop     :: RightOp
    mergeop     :: MergeOp
    key         :: Key
    value       :: Value
    constructor :: Constructor
end

function start(rf::R_{<:MergingTransducer}, result)
    outeriter = iterate(xform(rf).iter)
    return wrap(rf, outeriter, start(inner(rf), result))
end

function next(rf::R_{<:MergingTransducer}, result, input)
    ≺(a, b) = Base.Order.lt(xform(rf).order, a, b)
    #T = outtype(xform(rf), typeof(input))

    leftop = xform(rf).leftop
    rightop = xform(rf).rightop
    mergeop = xform(rf).mergeop
    key = xform(rf).key
    value = xform(rf).value
    constructor = xform(rf).constructor

    outeriter, res = unwrap(rf, result)
    while !isnothing(outeriter)
        outerinput, state = outeriter
        if key(input) ≺ key(outerinput)
            t = constructor(key(input), rightop(value(input)))
            res = next(inner(rf), res, t)
            return wrap(rf, outeriter, res)
        elseif key(input) == key(outerinput)
            t = constructor(key(input), mergeop(value(outerinput), value(input)))
            res = next(inner(rf), res, t)
            outeriter = iterate(xform(rf).iter, state)
            return wrap(rf, outeriter, res)
        else
            t = constructor(key(outerinput), leftop(value(outerinput)))
            res = next(inner(rf), res, t)
            outeriter = iterate(xform(rf).iter, state)
        end
    end
    res = next(inner(rf), res, constructor(key(input), rightop(value(input))))
    return wrap(rf, outeriter, res)
end

function complete(rf::R_{<:MergingTransducer}, result)
    leftop = xform(rf).leftop
    key = xform(rf).key
    value = xform(rf).value
    constructor = xform(rf).constructor

    outeriter, res = unwrap(rf, result)
    while !isnothing(outeriter)
        outerinput, state = outeriter
        res = next(inner(rf), res, constructor(key(outerinput), leftop(value(outerinput))))
        outeriter = iterate(xform(rf).iter, state)
    end
    complete(inner(rf), res)
end

Base.deepcopy(x::BigInt) = return Base.GMP.MPZ.set(x)
function Base.deepcopy(x::Rational)
    T = typeof(x)
    n = deepcopy(numerator(x))
    d = numerator(x) === denominator(x) ? n : deepcopy(denominator(x))
    y = ccall(:jl_new_structt, Any, (Any, Any), T, (n, d))
    return y::T
end

_debugassertions() = false

function _debug_isvalid end

macro assertvalid(p)
    if _debugassertions()
        quote
            res = $(esc(p))
            @assert _debug_isvalid(res)
            res
        end
    else
        esc(p)
    end
end

# -----------------------------------------------------------------------------
#
# unalias: convert or deepcopy
#
# -----------------------------------------------------------------------------
unalias(::Type{T}, a::T) where T = deepcopy(a)
unalias(::Type{T}, a::S) where {T,S} = convert(T, a)

# -----------------------------------------------------------------------------
#
# isdisjoint function: import from Base if it exists
#
# -----------------------------------------------------------------------------
if VERSION >= v"1.5-"
    import Base: isdisjoint
else
    function isdisjoint end
end

function showsingleton(io, T::Type)
    if isconcretetype(T)
        print(io, "typeof(")
        show(io, T.instance)
        print(io, ")")
    else
        invoke(show, Tuple{IO, Type}, io, T)
    end
end


end
