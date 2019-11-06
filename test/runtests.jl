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

    @test all(a .=== b)
    @test all([a[i] === b[i] for i in 1:length(a)])
    @test all(all(a[i, :] .=== b[i, :]) for i in 1:20)
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