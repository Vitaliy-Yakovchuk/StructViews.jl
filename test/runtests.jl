using StructViews

using Test

struct Point
    x
    y::Int
end

function create_point_array()
    points = Array{Point}(undef, 20, 30)

    for i in 1:length(points)
        points[i] = Point(i, i+100)
    end

    points
end

function create_point_array_and_view()
    points = create_point_array()
    view = StructView(points)

    return points, view
end


function testarrayssame(a, b)
    @test a == b
    @test size(a) == size(b)
    @test length(a) == length(b)
    @test eltype(a) === eltype(b)

    if(isempty(a))
        return
    end

    @test all(a .=== b)
    @test all([a[i] === b[i] for i in 1:length(a)])
    @test all(all(a[i, :] .=== b[i, :]) for i in 1:20)
    @test all(all(eltype.(a[i, :]) .=== eltype.(b[i, :])) for i in 1:20)
end


@testset "basic_wrapper" begin
    points, view = create_point_array_and_view()
    @test points[2, 2] === view[2, 2]

    testarrayssame(points, view)
    @test parent(view) === points
    @test :x in propertynames(view)
    @test :y in propertynames(view)
    @test :parent in propertynames(view)
end

@testset "basic_field" begin
    points, view = create_point_array_and_view()

    X = (point->point.x).(points)
    Y = (point->point.y).(points)

    # X may contain by Any type
    X = convert(Array{Any}, X)
    
    testarrayssame(X, view.x)
    testarrayssame(Y, view.y)

    @test parent(view.x) === points
    @test parent(view.y) === points
end

@testset "field_view" begin
    points = create_point_array()

    X = (point->point.x).(points)
    Y = (point->point.y).(points)
    xview = FieldView{Int, :x}(points)
    yview = FieldView{:y}(points)
    testarrayssame(X, xview)
    testarrayssame(Y, yview)
    @test X[2, 2] === xview[2, 2]
    @test parent(xview) === points
    @test parent(yview) === points
end

struct Point1
    x::Complex{Int}
    y::Int
end

function create_point1_array()
    points = Array{Point1}(undef, 20, 30)

    for i in 1:length(points)
        points[i] = Point1(i+2im, i+100)
    end

    points
end

@testset "recursive_view" begin
    points = create_point1_array()

    X = (point->point.x).(points)
    Y = (point->point.y).(points)

    view = StructView(points)
    
    xview = view.x
    yview = view.y

    @test eltype(xview) === eltype(X)
    @test eltype(yview) === eltype(Y)

    testarrayssame(X, xview)
    testarrayssame(Y, yview)
    @test X[2, 2] === xview[2, 2]
    
    Xim = (point->point.x.im).(points)
    Xre = (point->point.x.re).(points)

    @test !(:re in propertynames(yview))

    @test :im in propertynames(xview)
    @test :re in propertynames(xview)

    ximview = xview.im
    xreview = xview.re
    @test eltype(ximview) === eltype(Xim)
    @test eltype(xreview) === eltype(Xre)

    testarrayssame(Xim, ximview)
    testarrayssame(Xre, xreview)
    
    @test Xim[2, 2] === ximview[2, 2]
end


struct H{T}
    t::T
    f::Int
end

struct Point2
    x::Complex{Int}
    y::Int
    p::Point2
    h::H{Point2}
end

function create_point2_array()
    Array{Point2}(undef, 0, 0)
end

@testset "recursive_view_with_cycle" begin
    points = create_point2_array()

    X = (point->point.x).(points)
    Y = (point->point.y).(points)
    
    view = StructView(points)

    @test !(:p in propertynames(view))
    @test !(:t in propertynames(view.h))
    @test (:f in propertynames(view.h))
    
    xview = view.x
    yview = view.y

    @test eltype(xview) === eltype(X)
    @test eltype(yview) === eltype(Y)
    
    testarrayssame(X, xview)
    testarrayssame(Y, yview)
    
    Xim = (point->point.x.im).(points)
    Xre = (point->point.x.re).(points)

    @test !(:re in propertynames(yview))

    @test :im in propertynames(xview)
    @test :re in propertynames(xview)

    ximview = xview.im
    xreview = xview.re
    @test eltype(ximview) === eltype(Xim)
    @test eltype(xreview) === eltype(Xre)

    testarrayssame(Xim, ximview)
    testarrayssame(Xre, xreview)
end

mutable struct MitableComplex
    im
    re
end

mutable struct Point3
    x
    y::MitableComplex
end

function create_point3_array()
    points = Array{Point3}(undef, 20, 30)

    for i in 1:length(points)
        points[i] = Point3(i, MitableComplex(i+1, i+100))
    end

    points
end

@testset "update_mutable" begin
    points = create_point3_array()
    view = StructView(points)
    
    X = convert(Array{Any}, (point->point.x).(points))
    
    testarrayssame(X, view.x)

    view.x .+= 1
    X .+= 1

    testarrayssame(X, view.x)

    view.x[1] = 123

    @test points[1].x === 123

    c = MitableComplex(1, 1)
    view.y[10] = c

    @test points[10].y === c

    view.y.im[11] = -10

    @test points[11].y.im === -10
end

@testset "indexstyle" begin
    a = [1, 2, 3]
    @test IndexStyle(a) === IndexStyle(StructView(a))
    points = create_point_array()
    view = StructView(points)
    @test IndexStyle(points) === IndexStyle(view)
    @test IndexStyle(points) === IndexStyle(view.x)
end
