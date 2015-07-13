using NullableArrays
using DataArrays

srand(1)
A = rand(5_000_000)
B = rand(Bool, 5_000_000)
mu_A = mean(A)
X = NullableArray(A)
Y = NullableArray(A, B)
D = DataArray(A)
E = DataArray(A, B)

f(x) = 5 * x
f{T<:Number}(x::Nullable{T}) = Nullable(5 * x.value, x.isnull)

#-----------------------------------------------------------------------------#

function profile_reduce_methods()
    A = rand(5_000_000)
    B = rand(Bool, 5_000_000)
    X = NullableArray(A)
    Y = NullableArray(A, B)
    D = DataArray(A)
    E = DataArray(A, B)

    profile_mapreduce(A, X, Y, D, E)
    println()
    profile_reduce(A, X, Y, D, E)
    println()

    for method in (
        sum,
        prod,
        minimum,
        maximum,
    )
        (method)(A)
        (method)(X)
        (method)(D)
        println("Method: $method(A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(X))
        print("  for DataArray{Float64}:      ")
        @time((method)(D))

        (method)(f, A)
        (method)(f, X)
        (method)(f, D)
        println("Method: $method(f, A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(f, A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(f, X))
        print("  for DataArray{Float64}:      ")
        @time((method)(f, D))
    end
    println()

    for method in (
        sum,
        prod,
        minimum,
        maximum,
    )
        (method)(Y)
        println("Method: $method(A) (~half missing entries, skip=false)")
        print("  for NullableArray{Float64}:  ")
        @time((method)(Y))
        (method)(E)
        print("  for DataArray{Float64}:      ")
        @time((method)(E))

        (method)(f, Y)
        println("Method: $method(f, A) (~half missing entries, skip=false)")
        print("  for NullableArray{Float64}:  ")
        @time((method)(f, Y))
        if in(method, (sum, prod))
            (method)(f, E)
            print("  for DataArray{Float64}:      ")
            @time((method)(f, E))
        else
            println("  $method(f, A::DataArray) currently incurs error")
        end
    end
    println()

    for method in (
        sum,
        prod,
        minimum,
        maximum,
    )
        (method)(Y, skipnull=true)
        println("Method: $method(A) (~half missing entries, skip=true)")
        print("  for NullableArray{Float64}:  ")
        @time((method)(Y, skipnull=true))
        (method)(E, skipna=true)
        print("  for DataArray{Float64}:      ")
        @time((method)(E, skipna=true))

        (method)(f, Y, skipnull=true)
        println("Method: $method(f, A) (~half missing entries, skip=true)")
        print("  for NullableArray{Float64}:  ")
        @time((method)(f, Y, skipnull=true))
        (method)(f, E, skipna=true)
        print("  for DataArray{Float64}:      ")
        @time((method)(f, E, skipna=true))
    end
    println()

    for method in (
        sumabs,
        sumabs2
    )
        (method)(A)
        (method)(X)
        (method)(D)
        println("Method: $method(A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(X))
        print("  for DataArray{Float64}:      ")
        @time((method)(D))

        (method)(f, A)
        (method)(f, X)
        (method)(f, D)
        println("Method: $method(f, A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(f, A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(f, X))
        print("  for DataArray{Float64}:      ")
        @time((method)(f, D))
    end

    for method in (
        mean,
        var,
    )
        (method)(A)
        (method)(X)
        (method)(D)
        println("Method: $method(A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(X))
        print("  for DataArray{Float64}:      ")
        @time((method)(D))

        (method)(f, A)
        (method)(f, X)
        (method)(f, D)
        println("Method: $method(f, A) (0 missing entries)")
        print("  for Array{Float64}:          ")
        @time((method)(f, A))
        print("  for NullableArray{Float64}:  ")
        @time((method)(f, X))
        print("  for DataArray{Float64}:      ")
        @time((method)(f, D))
    end
end


function profile_mapreduce(A, X, Y, D, E)
    println("Method: mapreduce(f, op, A) (0 missing entries)")
    mapreduce(f, Base.(:+), A)
    print("  for Array{Float64}:          ")
    @time(mapreduce(f, Base.(:+), A))
    mapreduce(f, Base.(:+), X)
    print("  for NullableArray{Float64}:  ")
    @time(mapreduce(f, Base.(:+), X))
    mapreduce(f, Base.(:+), D)
    print("  for DataArray{Float64}:      ")
    @time(mapreduce(f, Base.(:+), D))

    println("Method: mapreduce(f, op, A) (~half missing entries, skip=false)")
    mapreduce(f, Base.(:+), Y)
    print("  for NullableArray{Float64}:  ")
    @time(mapreduce(f, Base.(:+), Y))
    mapreduce(f, Base.(:+), E)
    print("  for DataArray{Float64}:      ")
    @time(mapreduce(f, Base.(:+), E))

    println("Method: mapreduce(f, op, A) (~half missing entries, skip=true)")
    mapreduce(f, Base.(:+), Y, skipnull=true)
    print("  for NullableArray{Float64}:  ")
    @time(mapreduce(f, Base.(:+), Y, skipnull=true))
    mapreduce(f, Base.(:+), E, skipna=true)
    print("  for DataArray{Float64}:      ")
    @time(mapreduce(f, Base.(:+), E, skipna=true))
end

function profile_reduce(A, X, Y, D, E)
    println("Method: reduce(f, op, A) (0 missing entries)")
    reduce(Base.(:+), A)
    print("  for Array{Float64}:          ")
    @time(reduce(Base.(:+), A))
    reduce(Base.(:+), X)
    print("  for NullableArray{Float64}:  ")
    @time(reduce(Base.(:+), X))
    reduce(Base.(:+), D)
    print("  for DataArray{Float64}:      ")
    @time(reduce(Base.(:+), D))

    println("Method: reduce(f, op, A) (~half missing entries, skip=false)")
    reduce(Base.(:+), Y)
    print("  for NullableArray{Float64}:  ")
    @time(reduce(Base.(:+), Y))
    reduce(Base.(:+), E)
    print("  for DataArray{Float64}:      ")
    @time(reduce(Base.(:+), E))

    println("Method: reduce(f, op, A) (~half missing entries, skip=true)")
    reduce(Base.(:+), Y, skipnull=true)
    print("  for NullableArray{Float64}:  ")
    @time(reduce(Base.(:+), Y, skipnull=true))
    reduce(Base.(:+), E, skipna=true)
    print("  for DataArray{Float64}:      ")
    @time(reduce(Base.(:+), E, skipna=true))
end

function profile_sum1(A, X, D)
    sum(A)
    sum(X)
    sum(D)
    println("Method: sum(A)")
    print("  for Array{Float64}:          ")
    @time(sum(A))
    print("  for NullableArray{Float64}:  ")
    @time(sum(X))
    print("  for DataArray{Float64}:      ")
    @time(sum(D))
end

function profile_sum2(A, X, D)
    sum(f, A)
    sum(f, X)
    sum(f, D)
    println("Method: sum(f, A)")
    print("  for Array{Float64}:          ")
    @time(sum(f, A))
    print("  for NullableArray{Float64}:  ")
    @time(sum(f, X))
    print("  for DataArray{Float64}:      ")
    @time(sum(f, D))
end

function profile_prod1(A, X, D)
    prod(A)
    prod(X)
    prod(D)
    println("Method: prod(A)")
    print("  for Array{Float64}:          ")
    @time(prod(A))
    print("  for NullableArray{Float64}:  ")
    @time(prod(X))
    print("  for DataArray{Float64}:      ")
    @time(prod(D))
end

function profile_prod2(A, X, D)
    prod(f, A)
    prod(f, X)
    prod(f, D)
    println("Method: prod(f, A)")
    print("  for Array{Float64}:          ")
    @time(prod(f, A))
    print("  for NullableArray{Float64}:  ")
    @time(prod(f, X))
    print("  for DataArray{Float64}:      ")
    @time(prod(f, D))
end

function profile_minimum1(A, X, D)
    minimum(A)
    minimum(X)
    minimum(D)
    println("Method: minimum(A)")
    print("  for Array{Float64}:          ")
    @time(minimum(A))
    print("  for NullableArray{Float64}:  ")
    @time(minimum(X))
    print("  for DataArray{Float64}:      ")
    @time(minimum(D))
end

function profile_minimum2(A, X, D)
    minimum(f, A)
    minimum(f, X)
    minimum(f, D)
    println("Method: minimum(f, A)")
    print("  for Array{Float64}:          ")
    @time(minimum(f, A))
    print("  for NullableArray{Float64}:  ")
    @time(minimum(f, X))
    print("  for DataArray{Float64}:      ")
    @time(minimum(f, D))
end

function profile_maximum1(A, X, D)
    maximum(A)
    maximum(X)
    maximum(D)
    println("Method: maximum(A)")
    print("  for Array{Float64}:          ")
    @time(maximum(A))
    print("  for NullableArray{Float64}:  ")
    @time(maximum(X))
    print("  for DataArray{Float64}:      ")
    @time(maximum(D))
end

function profile_maximum2(A, X, D)
    maximum(f, A)
    maximum(f, X)
    maximum(f, D)
    println("Method: maximum(f, A)")
    print("  for Array{Float64}:          ")
    @time(maximum(f, A))
    print("  for NullableArray{Float64}:  ")
    @time(maximum(f, X))
    print("  for DataArray{Float64}:      ")
    @time(maximum(f, D))
end

function profile_sumabs(A, X, D)
    sumabs(A)
    sumabs(X)
    sumabs(D)
    println("Method: sumabs(A)")
    print("  for Array{Float64}:          ")
    @time(sumabs(A))
    print("  for NullableArray{Float64}:  ")
    @time(sumabs(X))
    print("  for DataArray{Float64}:      ")
    @time(sumabs(D))
end

function profile_sumabs2(A, X, D)
    sumabs2(A)
    sumabs2(X)
    sumabs2(D)
    println("Method: sumabs2(A)")
    print("  for Array{Float64}:          ")
    @time(sumabs2(A))
    print("  for NullableArray{Float64}:  ")
    @time(sumabs2(X))
    print("  for DataArray{Float64}:      ")
    @time(sumabs2(D))
end

function profile_mean1(A::AbstractArray, X::NullableArray)
    mean(A)
    mean(X)
    println("Method: mean(A)")
    print("  for Array{Float64}:          ")
    @time(mean(A))
    print("  for NullableArray{Float64}:  ")
    @time(mean(X))
end

function profile_varm1(A::AbstractArray, X::NullableArray)
    varm(A, mu_A)
    varm(X, mu_A)
    println("Method: varm(A, m)")
    print("  for Array{Float64}:          ")
    @time(varm(A, mu_A))
    print("  for NullableArray{Float64}:  ")
    @time(varm(X, mu_A))
end

function profile_varm2(X::NullableArray)
    # varm(A, mu_A)
    varm(X, Nullable(mu_A))
    println("Method: varm(A, m::Nullable)")
    print("  for Array{Float64}:           NA")
    # @time(varm(A))
    print("  for NullableArray{Float64}:  ")
    @time(varm(X, Nullable(mu_A)))
end

function profile_varzm(A::AbstractArray, X::NullableArray)
    varzm(A)
    varzm(X)
    println("Method: varzm(A)")
    print("  for Array{Float64}:          ")
    @time(varzm(A))
    print("  for NullableArray{Float64}:  ")
    @time(varzm(X))
end

function profile_var(A::AbstractArray, X::NullableArray)
    var(A)
    var(X)
    println("Method: var(A)")
    print("  for Array{Float64}:          ")
    @time(var(A))
    print("  for NullableArray{Float64}:  ")
    @time(var(X))
end

function profile_stdm(A::AbstractArray, X::NullableArray)
    stdm(A, mu_A)
    stdm(X, mu_A)
    println("Method: stdm(A, m)")
    print("  for Array{Float64}:          ")
    @time(stdm(A, mu_A))
    print("  for NullableArray{Float64}:  ")
    @time(stdm(X, mu_A))
end

function profile_std(A::AbstractArray, X::NullableArray)
    std(A, mu_A)
    std(X, mu_A)
    println("Method: std(A, m)")
    print("  for Array{Float64}:          ")
    @time(std(A, mu_A))
    print("  for NullableArray{Float64}:  ")
    @time(std(X, mu_A))
end

function profile_all()
    profile_mapreduce(A, X, D)
    profile_reduce(A, X, D)
    profile_sum1(A, X, D)
    profile_sum2(A, X, D)
    profile_prod1(A, X, D)
    profile_prod2(A, X, D)
    profile_minimum1(A, X, D)
    profile_minimum2(A, X, D)
    profile_maximum1(A, X, D)
    profile_maximum2(A, X, D)
    profile_sumabs(A, X, D)
    profile_sumabs2(A, X, D)
    # profile_mean1(A, X)
    # profile_varm1(A, X)
    # profile_varm2(X)
    # profile_varmz(A, X)
    # profile_var(A, X)
    # profile_stdm(A, X)
    # profile_std(A, X)
    return nothing
end

# # NullableArray vs. DataArray comparison
function profile_skip(skip::Bool)
    println("Comparison of skipnull/skipNA methods")
    println()
    println("f := IdFun(), op := AddFun()")
    println("mapreduce(f, op, X; skipnull/skipNA=$skip) (0 missing entries)")

    mapreduce(Base.IdFun(), Base.AddFun(), X, skipnull=skip)
    print("  for NullableArray{Float64}:  ")
    @time(mapreduce(Base.IdFun(), Base.AddFun(), X, skipnull=skip))

    mapreduce(Base.IdFun(), Base.AddFun(), D, skipna=skip)
    print("  for DataArray{Float64}:      ")
    @time(mapreduce(Base.IdFun(), Base.AddFun(), D, skipna=skip))

    println()
    println("reduce(op, X; skipnull/skipNA=$skip) (0 missing entries)")
    reduce(Base.AddFun(), X, skipnull=skip)
    print("  for NullableArray{Float64}:  ")
    @time(reduce(Base.AddFun(), X, skipnull=skip))

    reduce(Base.AddFun(), D, skipna=skip)
    print("  for DataArray{Float64}:      ")
    @time(reduce(Base.AddFun(), D, skipna=skip))

    println()
    println("mapreduce(f, op, X; skipnull/skipNA=$skip) (~half missing entries)")
    mapreduce(Base.IdFun(), Base.AddFun(), Y, skipnull=skip)
    print("  for NullableArray{Float64}:  ")
    @time(mapreduce(Base.IdFun(), Base.AddFun(), Y, skipnull=skip))

    mapreduce(Base.IdFun(), Base.AddFun(), E, skipna=skip)
    print("  for DataArray{Float64}:      ")
    @time(mapreduce(Base.IdFun(), Base.AddFun(), E, skipna=skip))

    println()
    println("reduce(op, X; skipnull/skipNA=$skip) (~half missing entries)")
    reduce(Base.AddFun(), Y, skipnull=skip)
    print("  for NullableArray{Float64}:  ")
    @time(reduce(Base.AddFun(), Y, skipnull=skip))

    reduce(Base.AddFun(), E, skipna=true)
    print("  for DataArray{Float64}:      ")
    @time(reduce(Base.AddFun(), E, skipna=true))
    nothing
end

function profile_skip_impl()
    println("Comparison of internal skip methods:")
    println("mapreduce_impl_skipnull(f, op, X) (0 missing entries)")
    NullableArrays.mapreduce_impl_skipnull(Base.IdFun(), Base.AddFun(), X)
    print("  for NullableArray{Float64}:  ")
    @time(NullableArrays.mapreduce_impl_skipnull(Base.IdFun(), Base.AddFun(), X))

    DataArrays.mapreduce_impl_skipna(Base.IdFun(), Base.AddFun(), D)
    print("  for DataArray{Float64}:      ")
    @time(DataArrays.mapreduce_impl_skipna(Base.IdFun(), Base.AddFun(), D))

    println()
    println("mapreduce_impl_skipnull(f, op, X) (~half missing entries)")
    NullableArrays.mapreduce_impl_skipnull(Base.IdFun(), Base.AddFun(), Y)
    print("  for NullableArray{Float64}:  ")
    @time(NullableArrays.mapreduce_impl_skipnull(Base.IdFun(), Base.AddFun(), Y))

    DataArrays.mapreduce_impl_skipna(Base.IdFun(), Base.AddFun(), E)
    print("  for DataArray{Float64}:      ")
    @time(DataArrays.mapreduce_impl_skipna(Base.IdFun(), Base.AddFun(), E))
    nothing
end
