var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PolynomialRings.jl-Documentation-1",
    "page": "Home",
    "title": "PolynomialRings.jl Documentation",
    "category": "section",
    "text": "Welcome to the documentation for this module! For getting started, have a look at Getting Started With PolynomialRings.jl."
},

{
    "location": "index.html#Table-of-contents-1",
    "page": "Home",
    "title": "Table of contents",
    "category": "section",
    "text": ""
},

{
    "location": "getting-started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting-started.html#Getting-Started-With-PolynomialRings.jl-1",
    "page": "Getting Started",
    "title": "Getting Started With PolynomialRings.jl",
    "category": "section",
    "text": ""
},

{
    "location": "getting-started.html#Installation-1",
    "page": "Getting Started",
    "title": "Installation",
    "category": "section",
    "text": "Refer to the Julia website for details on installing Julia. As soon as you have, start it and runjulia> Pkg.clone(\"https://github.com/tkluck/PolynomialRings.jl.git\")to install PolynomialRings.jl and its dependencies. To test whether it worked, typeusing PolynomialRings\n@ring! Int[x,y]\n(x + y) * (x - y)If you see the same, you are all set!"
},

{
    "location": "getting-started.html#Overview-1",
    "page": "Getting Started",
    "title": "Overview",
    "category": "section",
    "text": ""
},

{
    "location": "getting-started.html#Defining-polynomial-rings-1",
    "page": "Getting Started",
    "title": "Defining polynomial rings",
    "category": "section",
    "text": "The easiest way to define your polynomial rings is using the @ring! macro:R = @ring! Int[x,y]This will create a type R for your polynomials, and it will assign the polynomial x to the variable x and similarly for y.For a mathematically more pleasing look, tryR = @ring! ℤ[x,y]For entering ℤ, type \\BbbZ<tab> in the Julia command line. (Juno and julia-vim support this as well.) We support ℤ (arbitrary precision integers), ℚ (fractions of arbitrary precision integers), ℝ (arbitrary precision floating point) and ℂ (a + im*b with both coefficients in ℝ).If your variables have numbers instead of distinct names, you can use [] to represent that:R = @ring! ℤ[c[]]This will make available the object c, which you can use as follows:c1,c2,c3 = c[1], c[2], c[3]; c1,c2,c3  # or\nc1,c2,c3 = c[1:3]; c1,c2,c3            # or\nc1,c2,c3 = c[]; c1,c2,c3               # or\n# note that the following keeps state:\nc1 = c(); c2 = c(); c3 = c(); c1,c2,c3\nc4 = c(); c5 = c(); c6 = c(); c4,c5,c6Note that you cannot combine named and numbered variables in one ring definition. However, you can let one kind of ring be the base ring for another:R = @ring! ℤ[c[]][x,y]A quick way to define a polynomial without first defining the ring is# will implicitly create the ring Int[x,y]\n@polynomial x^2 - y^2"
},

{
    "location": "getting-started.html#Arithmetic-1",
    "page": "Getting Started",
    "title": "Arithmetic",
    "category": "section",
    "text": "The usual ring operations +,-,*,^ work as you'd expect:@ring! ℤ[x,y]\n(x + y) * (x - y) == x^2 - y^2We also support reduction operations between polynomials; for that, you can use the standard julia functions div, rem and divrem. For doing a single reduction step, use divrem(f, g). If you want to do a full reduction until no further reductions are possible, use divrem(f, [g]). Using the latter semantics, you can also reduce until no reductions are possible with a set of polynomials, e.g. divrem(f, [g1,g2]).For example, in the one-variable case, this is just the Euclidean algorithm:rem(x^2 - 1, [x - 1])Don't forget to pass the second parameter as an array if you want to do as many reduction operations as possible! For example,rem(x^2 - 1, x - 1)only did the first reduction step x^2 - 1 - x*(x-1)."
},

{
    "location": "getting-started.html#Variables-in-your-ring-vs.-variables-in-your-script-1",
    "page": "Getting Started",
    "title": "Variables in your ring vs. variables in your script",
    "category": "section",
    "text": "It is common to use names such as f,g,h for polynomials and names such as xyz for the variables in your ring. For example, you might defineR = @ring! ℤ[x,y,z]\nf = x^2 - x*yIn this situation, f is a variable in your script, of type R.You might also defineg(x,y) = x^2 - x*ybut this means something different.  In this case, x and y are arguments to the function, and in its body, they take whatever value you pass to g. For example:g(x,y)\ng(y,x)\ng(y,y)Maybe by now you wonder about x and y: are they Julia variables or just names? The answer is easiest to understand if we look at the @ring macro. Note that this one does not have the ! in the end:using PolynomialRings\nS = @ring ℤ[x,y]\nxAs you can see, we did define a type S that contains polynomials with names x and y for the variables. However, in our script, the variable x doesn't exist. The way to get the variable with name x is to start with the symbol :x, and convert it to S. Here's how:S(:x)The result is an object of type S, much like how f was an object of type R. It represents a polynomial with just one term: 1x.Wouldn't it be practical if we would do x = S(:x) and y = S(:y) now? That way, we can use the Julia variable x to refer to the polynomial x. Indeed, that's exactly what @ring! (with !) does!In the next chapters, we will often pass variables as arguments. For example, we pass the variable in which we are doing an expansion, or the variable with respect to which we are taking a derivative. In those cases, we pass the variable as a symbol (e.g. :x) to the function. For example, this works:diff(x^3, :x)But this doesn't:diff(x^3, x)In some cases, we offer a convenience macro. For example, the @deg macro:deg(x^3*y^4, :x)\ndeg(x^3*y^4, :y)\n@deg x^3*y^4 y"
},

{
    "location": "getting-started.html#Expansions,-coefficients,-collecting-monomials-1",
    "page": "Getting Started",
    "title": "Expansions, coefficients, collecting monomials",
    "category": "section",
    "text": "The rings ℤ[a,b][c], ℤ[a,b,c] and ℤ[b][a,c] are canonically isomorphic, and we make it easy to switch perspective between them. For example, the different polynomials compare equal (using ==) and can be easily converted into each other. Type promotions also happen as you'd expect.R = @ring ℤ[a,b][c]\nT = @ring! ℤ[a,b,c]\nU = @ring ℤ[b][a,c]\nR(a*b + b*c + a*c)\nT(a*b + b*c + a*c)\nU(a*b + b*c + a*c)Keep in mind that they don't have equal hash() values, so don't rely on this for Set{Any} and Dict{Any}. Set{R} and Dict{R} should work, since type conversion will happen before hashing.For seeing the constituent parts of a polynomial, use the @expand macro. You need to specify in which variables you are expanding. After all, (a+1)bc = abc + bc, so the result from expanding in ab and c is different from an expansion in just b and c.@ring! ℤ[a,b,c]\n@expand (a*b*c + b*c) a b c\n@expand (a*b*c + b*c) b cFor just obtaining a single coefficient, use @coefficient.@coefficient (a*b*c + b*c) a^0*b^1*c^1\n@coefficient (a*b*c + b*c) b^1*c^1There is also corresponding functions expansion() and coefficient(). For those, you need to pass the variables as symbols. For example:coefficient(a*b*c + b*c, (0, 1, 1), :a, :b, :c)\ncoefficient(a*b*c + b*c, (1, 1), :b, :c)"
},

{
    "location": "getting-started.html#Monomial-orders-1",
    "page": "Getting Started",
    "title": "Monomial orders",
    "category": "section",
    "text": "Functions such as leading_term and divrem have an implicit understanding of what the monomial order is. By default, if you create a ring, it will be ordered by degree, then reversely lexicographically. This is often called 'degrevlex'.If you want to use a different order, you can specify that by creating the ring using the polynomial_ring function:R,(x,y) = polynomial_ring(:x, :y, monomialorder=:lex)\nPolynomialRings.monomialorder(R)Built-in are :lex, :deglex and :degrevlex. It is very easy to define your own order, though, and thanks to Julia's design, this doesn't incur any performance penalty. Read the documentation for PolynomialRings.MonomialOrderings.MonomialOrder for details."
},

{
    "location": "getting-started.html#Gröbner-basis-computations-1",
    "page": "Getting Started",
    "title": "Gröbner basis computations",
    "category": "section",
    "text": "For computing a Gröbner basis for a set of polynomials, use the gröbner_basis function. (For easier typing, groebner_basis is an alias.)You typically use this to figure out whether a polynomial is contained in the ideal generated by a set of other polynomials. For example, it is not obvious that y^2 is a member of the ideal (x^5 x^2 + y xy + y^2). Indeed, if one applies rem, you will not find the expression of y^2 in terms of these polynomials:@ring! ℤ[x,y]\nI = [x^5, x^2 + y, x*y + y^2]\nrem(y^2, I)  # nonzero, even though y^2 ∈ (I)However, if you compute a Gröbner basis first, you will:G = gröbner_basis(I)\nrem(y^2, G) # now, it reduces to zero.If you want to obtain the expression of y^2 in these elements, you can first use div to obtain the (row) vector of factors expressing y^2 in G:div(y^2, G)The gröbner_transformation function gives a matrix tr expressing G in terms of I:G, tr = gröbner_transformation(I); tr\ndiv(y^2, G) * tr * I   # gives back y^2In other words, by looking atdiv(y^2, G) * trwe see that y^2 = 1(x^5) + (y + xy - x^3)(x^2 + y) + -x(xy + y^2) which proves that y^2 in (I)."
},

{
    "location": "getting-started.html#Using-helper-variables-1",
    "page": "Getting Started",
    "title": "Using helper variables",
    "category": "section",
    "text": "(Be sure you understand Variables in your ring vs. variables in your script before reading this section.)We now get to an important implementation detail. Imagine that you want to write a function that computes a derivative in the following way:function myderivative(f::R, varsymbol) where R <: Polynomial\n    varvalue = R(varsymbol)\n    @ring! Int[ε]\n    substitution = Dict(varsymbol => varvalue + ε)\n    return @coefficient f(;substitution...) ε^1\nend\nmyderivative(x^3 + x^2, :x)(In fact, diff is already built-in and has a more efficient implementation, but this example is for educational purposes.)This works, but what about the following?@ring! ℚ[ε]\nmyderivative(ε^3 + ε^2, :ε)This gives a wrong answer because of the naming clash inside myderivative. You may be tempted to work around this as follows:function myderivative2(f::R, varsymbol) where R <: Polynomial\n    varvalue = R(varsymbol)\n    ε = gensym()\n    _,(ε_val,) = polynomial_ring(ε)\n    substitution = Dict(varsymbol => varvalue + ε_val)\n    return coefficient(f(;substitution...), (1,), ε)\nend\nmyderivative2(ε^3 + ε^2, :ε)which gives the correct answer. Unfortunately, this is very inefficient:@time myderivative2(ε^3 + ε^2, :ε);\n@time myderivative2(ε^3 + ε^2, :ε);The reason is that variable names are part of the type definition, and Julia specializes functions based on the type of its arguments. In this case, that means that for evaluating the @coefficient call, and for the substitution call, all the code needs to be compiled every time you call myderivative.For this reason, we provide a function formal_coefficient(R) which yields a variable that's guaranteed not to clash with the ring that you pass as an argument:function myderivative3(f::R, varsymbol) where R <: Polynomial\n    varvalue = R(varsymbol)\n    ε_sym, ε_val = formal_coefficient(typeof(f))\n    substitution = Dict(varsymbol => varvalue + ε_val)\n    return coefficient(f(;substitution...), (1,), ε_sym)\nend\n@time myderivative3(ε^3 + ε^2, :ε);   # first time is still slow (compiling)\n@time myderivative3(ε^3 + ε^2, :ε);   # but much faster the second time\n@time myderivative3(ε^3 + ε^2, :ε);   # and the third"
},

{
    "location": "getting-started.html#Free-modules-(arrays-of-polynomials)-1",
    "page": "Getting Started",
    "title": "Free modules (arrays of polynomials)",
    "category": "section",
    "text": "For practical purposes, a free module (of finite rank) over a ring R is just an array of polynomials in R. Many algorithms that work for polynomial rings also work for modules. For example, the function gröbner_basis works just as well if we pass a vector of vectors of polynomials instead of a vector of polynomials:G = [[x^5-y,x^4],[x^3+y,y^3]];\nGG = gröbner_basis(G)One can then use the functions rem and div to express a given vector as an R-linear combination of the others.For these purposes, the leading term of a vector is defined to be the tuple (it) where i is the first nonzero index, and t is the leading term of that nonzero element."
},

{
    "location": "getting-started.html#Base-rings-and-base-restriction-/-extension-1",
    "page": "Getting Started",
    "title": "Base rings and base restriction / extension",
    "category": "section",
    "text": "Some operations need a field for a base ring. For example:R = @ring! ℤ[x]\nrem(2x^2, 3x + 1)gives an error because we have to substract x^2 + frac23x, which is not representable in R. We offer a convenience function base_extend to extend to ℚ:rem(base_extend(2x^2), 3x + 1)Note that it is sufficient to base-extend one of the arguments; the other is taken care of by Julia's type promotion system in the same way as1 - 1//2yields a rational result.If you want, you can also extend to bigger base rings than the quotient field by passing that as an extra parameter. For example:f = base_extend(x^2 + 1, Complex{Rational{Int}})\ndiv(f, [x - im])"
},

{
    "location": "getting-started.html#Implementation-of-named-and-numbered-variables-1",
    "page": "Getting Started",
    "title": "Implementation of named and numbered variables",
    "category": "section",
    "text": "The difference between @ring Int[x1,x2,x3] and @ring Int[x[]] is not just the display name of the variables. In terms of implementation, the first version uses a Tuple to represent the exponents, whereas the second version uses a SparseVector. This means that for moderate number of variables, the former is often more efficient than the latter as tuples can often remain on the stack, saving allocation and garbage collection overhead. This stops being true when your exponents are very sparse, when the overhead of dealing with all the zeros in the tuple is worse than the overhead of garbage collection.If you want to transform a set of polynomials from the latter representation to the former, use to_dense_monomials. This is sometimes beneficial right before doing a computationally expensive operation, e.g. a Gröbner basis computation."
},

{
    "location": "getting-started.html#Frequently-Asked-Questions-1",
    "page": "Getting Started",
    "title": "Frequently Asked Questions",
    "category": "section",
    "text": "Be the first to ask a question! Feel free to open an issue for it."
},

{
    "location": "reference.html#",
    "page": "Reference Index",
    "title": "Reference Index",
    "category": "page",
    "text": ""
},

{
    "location": "reference.html#Reference-Index-1",
    "page": "Reference Index",
    "title": "Reference Index",
    "category": "section",
    "text": ""
},

{
    "location": "functions.html#",
    "page": "Types and Functions",
    "title": "Types and Functions",
    "category": "page",
    "text": ""
},

{
    "location": "functions.html#Types-and-Functions-1",
    "page": "Types and Functions",
    "title": "Types and Functions",
    "category": "section",
    "text": ""
},

{
    "location": "functions.html#PolynomialRings.EntryPoints.@ring!",
    "page": "Types and Functions",
    "title": "PolynomialRings.EntryPoints.@ring!",
    "category": "Macro",
    "text": "@ring! ℚ[x,y]\n\nDefine and return the specified polynomial ring, and bind the variable names to its generators.\n\nCurrently, the supported rings are: ℚ (Rational{BigInt}), ℤ (BigInt), ℝ (BigFloat) and ℂ (Complex{BigFloat}).\n\nNote: @ring! returns the ring and injects the variables. The macro @ring only returns the ring.\n\nIf you need different coefficient rings, or need to specify a non-default monomial order or exponent integer type, use polynomial_ring instead.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> @ring! ℚ[x,y];\n\njulia> x^3 + y\ny + x^3\n\nSee also\n\npolynomial_ring @polynomialring\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.EntryPoints.@ring",
    "page": "Types and Functions",
    "title": "PolynomialRings.EntryPoints.@ring",
    "category": "Macro",
    "text": "@ring ℚ[x,y]\n\nDefine and return the specified polynomial ring.\n\nCurrently, the supported rings are: ℚ (Rational{BigInt}), ℤ (BigInt), ℝ (BigFloat) and ℂ (Complex{BigFloat}).\n\nNote: @ring! returns the ring and injects the variables into the surrounding scope. The macro @ring only returns the ring.\n\nIf you need different coefficient rings, or need to specify a non-default monomial order or exponent integer type, use polynomial_ring instead.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> @ring ℚ[x,y]\nℚ[x,y]\n\nSee also\n\npolynomial_ring @ring!\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.EntryPoints.@polyvar",
    "page": "Types and Functions",
    "title": "PolynomialRings.EntryPoints.@polyvar",
    "category": "Macro",
    "text": "@polyvar var [var...]\n\nDefine a polynomial ring in the given variables, and inject them into the surrounding scope.\n\nThis is equivalent to @ring! Int[var...].\n\nIf you need different coefficient rings, or need to specify a non-default monomial order or exponent integer type, use @ring! or polynomial_ring instead.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> @polyvar x y;\n\njulia> x + 3y\n3*y + x\n\njulia> @polyvar ε[];\n\njulia> 1 + ε()*x + ε()*y\n1 + ε[2]*y + ε[1]*x\n\nSee also\n\npolynomial_ring @ring!\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.EntryPoints.@polynomial",
    "page": "Types and Functions",
    "title": "PolynomialRings.EntryPoints.@polynomial",
    "category": "Macro",
    "text": "@polynomial x^3 + 3x^2 + 3x + 1\n\nCreate a multi-variate polynomial from an expression by creating the ring generated by all symbols appearing in the expression.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> @polynomial x^3 + x^2*y + x*y^2 + y^3\ny^3 + x*y^2 + x^2*y + x^3\n\njulia> @polynomial x^3 + x^2*y + x*y^2 + y^3\ny^3 + x*y^2 + x^2*y + x^3\n\nnote: Note\nIn general, you cannot use variables from outside the macro expression; all symbols are interpreted as variables. For example:d = 4\n@polynomial d*xwill give a polynomial in two variables, d and x.As a special exception, exponents are not interpreted, so@polynomial(x^d) == @polynomial(x)^dUnfortunately/confusingly, together, this gives@polynomial(d*x^(d-1))will have d-1 interpreting d as an outer variable, and d*x is a monomial.This behaviour may (should?) change.\n\nSee also\n\n@ring, polynomial_ring, convert(R, symbol)\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Polynomials.polynomial_ring",
    "page": "Types and Functions",
    "title": "PolynomialRings.Polynomials.polynomial_ring",
    "category": "Function",
    "text": "polynomial_ring(symbols::Symbol...; basering=Rational{BigInt}, exptype=UInt16, monomialorder=:degrevlex)\n\nCreate a type for the polynomial ring over basering in variables with names specified by symbols, and return the type and a tuple of these variables.\n\nThe exptype parameter defines the integer type for the exponents.\n\nThe monomialorder defines an order for the monomials for e.g. Gröbner basis computations; it also defines the internal sort order. Built-in values are :degrevlex and :deglex. This function will accept any symbol, though, and you can define your own monomial order by implementing\n\nBase.Order.lt(::MonomialOrder{:myorder}, a::M, b::M) where M <: AbstractMonomial\n\nSee PolynomialRings.MonomialOrderings for examples.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R,(x,y,z) = polynomial_ring(:x, :y, :z);\n\njulia> x*y + z\nz + x*y\n\n\n\n"
},

{
    "location": "functions.html#Entry-points-1",
    "page": "Types and Functions",
    "title": "Entry points",
    "category": "section",
    "text": "@ring!\n@ring\n@polyvar\n@polynomial\npolynomial_ring"
},

{
    "location": "functions.html#Arithmetic-1",
    "page": "Types and Functions",
    "title": "Arithmetic",
    "category": "section",
    "text": "gcd\nlcm\nmaybe_div\nrem\ndiv\ndivrem"
},

{
    "location": "functions.html#PolynomialRings.MonomialOrderings.MonomialOrder",
    "page": "Types and Functions",
    "title": "PolynomialRings.MonomialOrderings.MonomialOrder",
    "category": "Type",
    "text": "struct MonomialOrder{Name} <: Ordering end\n\nFor implementing your own monomial order, do the following:\n\nChoose a symbol to represent it, say :myorder;\nimport Base.Order: lt;\nlt(::MonomialOrder{:myorder}, a::M, b::M) where M <: AbstractMonomial = ...\n\nA few useful functions are enumeratenz, index_union, and rev_index_union. See PolynomialRings.Monomials and PolynomialRings.MonomialOrderings for details.\n\nYou can then create a ring that uses it by calling\n\nR,vars = polynomial_ring(vars...; monomialorder=:myorder)\n\nThere is no performance cost for using your own monomial order compared to a built-in one.\n\n\n\n"
},

{
    "location": "functions.html#Monomial-orderings-1",
    "page": "Types and Functions",
    "title": "Monomial orderings",
    "category": "section",
    "text": "PolynomialRings.MonomialOrderings.MonomialOrder"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@expansion",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@expansion",
    "category": "Macro",
    "text": "@expansion(f, var, [var...])\n\nReturn a collection of (exponent tuple, coefficient) tuples decomposing f into its consituent parts.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> collect(@expansion(x^3 + y^2, y))\n[((0,), x^3), ((2,), 1)]\n\njulia> collect(@expansion(x^3 + y^2, x, y))\n[((3,0), 1), ((0,2), 1)]\n\nSee also\n\n@expand, expansion(...), @coefficient and coefficient\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.expansion",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.expansion",
    "category": "Function",
    "text": "expansion(f, symbol, [symbol...])\n\nReturn a collection of (exponent_tuple, coefficient) tuples decomposing f into its consituent parts.\n\nIn the REPL, you likely want to use the friendlier version @expansion instead.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> collect(expansion(x^3 + y^2, :y))\n[((0,), 1 x^3), ((2,), 1)]\n\njulia> collect(expansion(x^3 + y^2, :x, :y))\n[((3,0), 1), ((0,2), 1)]\n\nSee also\n\n@expansion(...), @coefficient and coefficient\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@expand",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@expand",
    "category": "Macro",
    "text": "@expand(f, var, [var...])\n\nReturn a collection of (monomial, coefficient) tuples decomposing f into its consituent parts.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> collect(@expand(x^3 + y^2, y))\n[(1, x^3), (y^2, 1)]\n\njulia> collect(@expand(x^3 + y^2, x, y))\n[(x^3, 1), (y^2, 1)]\n\nSee also\n\nexpansion(...), @coefficient and coefficient\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@coefficient",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@coefficient",
    "category": "Macro",
    "text": "@coefficient(f, monomial)\n\nReturn a the coefficient of f at monomial.\n\nnote: Note\nmonomial needs to be a literal monomial; it cannot be a variable containing a monomial.  This macro has a rather naive parser that gets exponents and variable names from monomial.This is considered a feature (not a bug) because it is only as a literal monomial that we can distinguish e.g. x^4 from x^4*y^0.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> @coefficient(x^3*y + x, x)\n1\n\njulia> @coefficient(x^3*y + x, x^3)\ny\n\njulia> @coefficient(x^3*y + x, x^3*y^0)\n0\n\njulia> @coefficient(x^3*y + x, x^3*y^1)\n1\n\nSee also\n\ncoefficient, expansion and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Terms.coefficient",
    "page": "Types and Functions",
    "title": "PolynomialRings.Terms.coefficient",
    "category": "Function",
    "text": "coefficient(f, exponent_tuple, symbol, [symbol...])\n\nReturn a the coefficient of f at monomial. In the REPL, you likely want to use the friendlier version @coefficient.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> coefficient(x^3*y + x, (1,), :x)\n1\n\njulia> coefficient(x^3*y + x, (3,), :x)\ny\n\njulia> coefficient(x^3*y + x, (3,0), :x, :y)\n0\n\njulia> coefficient(x^3*y + x, (3,1), :x, :y)\n1\n\nSee also\n\n@coefficient, expansion and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@deg",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@deg",
    "category": "Macro",
    "text": "@deg(f, vars...)\n\nReturn the total degree of f when expanded as a polynomial in the given variables.\n\nnote: Note\nvars need to be literal variable names; it cannot be a variable containing it.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> @deg x^2 + x*y - 1 x\n2\n\njulia> @deg x^2 + x*y - 1 y\n1\n\nSee also\n\ndeg, @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.deg",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.deg",
    "category": "Function",
    "text": "deg(f, vars...)\n\nReturn the total degree of f when regarded as a polynomial in vars.\n\njulia> using PolynomialRings\n\njulia> R = @ring ℤ[x,y];\n\njulia> deg(x^2, :x)\n2\n\njulia> deg(x^2, :x, :y)\n2\n\njulia> deg(x^2, :y)\n0\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@linear_coefficients",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@linear_coefficients",
    "category": "Macro",
    "text": "@linear_coefficient(f, vars...)\nlinear_coefficients(f, vars...)\n\nReturn the linear coefficients of f as a function of vars.\n\nnote: Note\nvars need to be symbols; e.g. they cannot be the polynomial x.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> @linear_coefficients(x^3*y + x + y + 1, x)\n[1]\n\njulia> @linear_coefficients(x^3*y + x + y + 1, x, y)\n[1,x^3+1]\n\nSee also\n\n@constant_coefficient, @coefficient, and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.linear_coefficients",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.linear_coefficients",
    "category": "Function",
    "text": "linear_coefficients(f, vars...)\n\nReturn the linear coefficients of f as a function of vars.\n\nnote: Note\nvars need to be symbols; e.g. they cannot be the polynomial x.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> linear_coefficients(x^3*y + x + y + 1, :x)\n[1]\n\njulia> linear_coefficients(x^3*y + x + y + 1, :x, :y)\n[1,x^3+1]\n\nSee also\n\n@constant_coefficient, @coefficient, and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.@constant_coefficient",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.@constant_coefficient",
    "category": "Macro",
    "text": "@constant_coefficient(f, vars...)\n\nReturn the constant coefficient of f as a function of vars.\n\nnote: Note\nvars need to be literal variable names; it cannot be a variable containing it.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> @constant_coefficient(x^3*y + x + y + 1, x)\n1 + 1 y\n\njulia> @constant_coefficient(x^3*y + x + y + 1, x, y)\n1\n\nSee also\n\nconstant_coefficient, @coefficient, and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Expansions.constant_coefficient",
    "page": "Types and Functions",
    "title": "PolynomialRings.Expansions.constant_coefficient",
    "category": "Function",
    "text": "constant_coefficient(f, vars...)\n\nReturn the constant coefficient of f as a function of vars.\n\nnote: Note\nvars need to be symbols; e.g. they cannot be the polynomial x.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> constant_coefficient(x^3*y + x + y + 1, :x)\n1 + y\n\njulia> constant_coefficient(x^3*y + x + y + 1, :x, :y)\n1\n\nSee also\n\n@constant_coefficient, @coefficient, and @expansion\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Arrays.@flat_coefficients",
    "page": "Types and Functions",
    "title": "PolynomialRings.Arrays.@flat_coefficients",
    "category": "Macro",
    "text": "@flat_coefficients(a, var, [var...])\n\nReturn the polynomial coefficients of the matrix coefficients of a, when those matrix coefficients are regarded as polynomials in the given variables.\n\nExamples\n\njulia> R = @ring! ℤ[x,y];\njulia> collect(flat_coefficients([x^3 + y^2; y^5], :y))\n[1 x^3, 1, 1]\njulia> collect(flat_coefficients([x^3 + y^2, y^5], :x, :y))\n[1, 1, 1]\n\nSee also\n\nflat_coefficients, @expansion, expansion, @coefficient and coefficient\n\n\n\n"
},

{
    "location": "functions.html#Expansions,-coefficients,-collecting-monomials-1",
    "page": "Types and Functions",
    "title": "Expansions, coefficients, collecting monomials",
    "category": "section",
    "text": "@expansion\nexpansion\n@expand\n@coefficient\ncoefficient\n@deg\ndeg\n@linear_coefficients\nlinear_coefficients\n@constant_coefficient\nconstant_coefficient\n@flat_coefficients"
},

{
    "location": "functions.html#PolynomialRings.gröbner_basis",
    "page": "Types and Functions",
    "title": "PolynomialRings.gröbner_basis",
    "category": "Function",
    "text": "basis = gröbner_basis(polynomials)\n\nReturn a Gröbner basis for the ideal generated by polynomials.\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.gröbner_transformation",
    "page": "Types and Functions",
    "title": "PolynomialRings.gröbner_transformation",
    "category": "Function",
    "text": "basis, transformation = gröbner_transformation(polynomials)\n\nReturn a Gröbner basis for the ideal generated by polynomials, together with a transformation that proves that each element in basis is in that ideal (i.e. basis == transformation * polynomials).\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.syzygies",
    "page": "Types and Functions",
    "title": "PolynomialRings.syzygies",
    "category": "Function",
    "text": "syz = syzygies(G)\n\nReturn all relations between the elements of G.\n\nExamples\n\njulia> using PolynomialRings\n\njulia> R = @ring! ℤ[x,y];\n\njulia> I = [x^5, x^2 + y, x*y + y^2];\n\njulia> G, tr = gröbner_transformation(I);\n\njulia> K = syzygies(G) * tr; # the kernel of the map R^3 -> I induced by these generators\n\njulia> iszero(K * I)\ntrue\n\n\n\n"
},

{
    "location": "functions.html#Gröbner-basis-computations-1",
    "page": "Types and Functions",
    "title": "Gröbner basis computations",
    "category": "section",
    "text": "gröbner_basis\ngröbner_transformation\nsyzygies"
},

{
    "location": "functions.html#PolynomialRings.Monomials.AbstractMonomial",
    "page": "Types and Functions",
    "title": "PolynomialRings.Monomials.AbstractMonomial",
    "category": "Type",
    "text": "AbstractMonomial{Nm}\n\nThe abstract base type for multi-variate monomials.\n\nSpecifying a monomial is equivalent to specifying the exponents for all variables. The concrete type decides whether this happens as a tuple or as a (sparse or dense) array.\n\nThe variables may or may not have names at this abstraction level; they can always be identified by a number (e.g. the index in the array/tuple) but the type may choose to support having a symbolic name for each as well. In the former case, namestype(::Type{M}) returns Numbered; otherwise, it returns Named{Names}. This is also the value of Nm.\n\nEach concrete implementation should implement:     m[i]     nzindices(m)     _construct(M, i -> exponent, nonzero_indices, [total_degree])     exptype(M)     namestype(M)\n\nIn addition, one may choose to add specific optimizations by overloading other functions, as well.\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Monomials.TupleMonomial",
    "page": "Types and Functions",
    "title": "PolynomialRings.Monomials.TupleMonomial",
    "category": "Type",
    "text": "TupleMonomial{N, I, Nm} <: AbstractMonomial where I <: Integer where Nm\n\nAn implementation of AbstractMonomial that stores exponents as a tuple of integers. This is a dense representation.\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Monomials.VectorMonomial",
    "page": "Types and Functions",
    "title": "PolynomialRings.Monomials.VectorMonomial",
    "category": "Type",
    "text": "VectorMonomial{V,I,Nm} <: AbstractMonomial where V <: AbstractVector{I} where I <: Integer where Nm\n\nAn implementation of AbstractMonomial that stores exponents as a vector of integers. This can be a sparse or dense representation, depending on the type specialization.\n\nThis representation is intended for the case when the number of variables is unbounded. In particular, the indexing operation m[i] returns 0 when i is out-of-bounds, instead of throwing an exception.\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Terms.Term",
    "page": "Types and Functions",
    "title": "PolynomialRings.Terms.Term",
    "category": "Type",
    "text": "Term{M, C} where M <: AbstractMonomial where C\n\nThis type represents a single term of a multivariate polynomial: that is, it represents the combination of a coefficient and a monomial.\n\n\n\n"
},

{
    "location": "functions.html#PolynomialRings.Polynomials.Polynomial",
    "page": "Types and Functions",
    "title": "PolynomialRings.Polynomials.Polynomial",
    "category": "Type",
    "text": "Polynomial{A, Order} where A <: AbstractVector{T} where T <: Term where Order <: Val\n\nThis type represents a polynomial as a vector of terms. All methods guarantee and assume that the vector is sorted by increasing monomial order, according to Order (see PolynomialRings.MonomialOrderings).\n\n\n\n"
},

{
    "location": "functions.html#Internal-types-1",
    "page": "Types and Functions",
    "title": "Internal types",
    "category": "section",
    "text": "PolynomialRings.Monomials.AbstractMonomial\nPolynomialRings.Monomials.TupleMonomial\nPolynomialRings.Monomials.VectorMonomial\nPolynomialRings.Terms.Term\nPolynomialRings.Polynomials.Polynomial"
},

]}
