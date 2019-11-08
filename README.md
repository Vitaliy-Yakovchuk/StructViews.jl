# StructViews.jl

[![Build Status](https://travis-ci.org/Vitaliy-Yakovchuk/StructViews.jl.svg?branch=master)](https://travis-ci.org/Vitaliy-Yakovchuk/StructViews.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/454jumcoasn6259m?svg=true)](https://ci.appveyor.com/project/Vitaliy-Yakovchuk/structviews-jl)
[![Coverage Status](https://coveralls.io/repos/github/Vitaliy-Yakovchuk/StructViews.jl/badge.svg?branch=master)](https://coveralls.io/github/Vitaliy-Yakovchuk/StructViews.jl?branch=master)
[![codecov](https://codecov.io/gh/Vitaliy-Yakovchuk/StructViews.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Vitaliy-Yakovchuk/StructViews.jl)


This package introduces the types `StructView` and `FieldView` which are `AbstractArray`. `StructView` lets to view fields of the struct in the array as the array of fields.

## Example usage to view point coordinates

```julia
julia> using StructViews

julia> struct Point
       x
       y
end

julia> points = [Point(i, i + 100) for i in 1:5]
5-element Array{Point,1}:
 Point(1, 101)
 Point(2, 102)
 Point(3, 103)
 Point(4, 104)
 Point(5, 105)

 julia> view = StructView(points)
5-element StructView{Point,1,IndexLinear()}:
 Point(1, 101)
 Point(2, 102)
 Point(3, 103)
 Point(4, 104)
 Point(5, 105)
 julia> view.x
5-element FieldView{Any,:x,1,IndexLinear(),false}:
 1
 2
 3
 4
 5
 julia> view.y
5-element FieldView{Any,:y,1,IndexLinear(),false}:
 101
 102
 103
 104
 105
 ```
## Example usage to view point coordinates, where coordinates are complex numbers

```julia
julia> struct ComplexPoint
       x::Complex{Int}
       y::Complex{Int}
end

julia> points = [ComplexPoint(i+2im, i + 100im) for i in 1:5]
5-element Array{ComplexPoint,1}:
 ComplexPoint(1 + 2im, 1 + 100im)
 ComplexPoint(2 + 2im, 2 + 100im)
 ComplexPoint(3 + 2im, 3 + 100im)
 ComplexPoint(4 + 2im, 4 + 100im)
 ComplexPoint(5 + 2im, 5 + 100im)

julia> view = StructView(points)
5-element StructView{ComplexPoint,1,IndexLinear()}:
 ComplexPoint(1 + 2im, 1 + 100im)
 ComplexPoint(2 + 2im, 2 + 100im)
 ComplexPoint(3 + 2im, 3 + 100im)
 ComplexPoint(4 + 2im, 4 + 100im)
 ComplexPoint(5 + 2im, 5 + 100im)

julia> view.x
5-element StructView{Complex{Int64},1,IndexLinear()}:
 1 + 2im
 2 + 2im
 3 + 2im
 4 + 2im
 5 + 2im

 julia> view.y.re
5-element FieldView{Int64,:re,1,IndexLinear(),false}:
 1
 2
 3
 4
 5
 ```

 `StructView` lets you to update data in the parent array. If the data in the parent array is mutable the appropriate field will be updated. If the data type in the parant array is immutable the new objects with updated field will be set to the parent array.

 ## Example usage to update fields
 
 ```julia
julia> points = [ComplexPoint(i+2im, i + 100im) for i in 1:5]
5-element Array{ComplexPoint,1}:
 ComplexPoint(1 + 2im, 1 + 100im)
 ComplexPoint(2 + 2im, 2 + 100im)
 ComplexPoint(3 + 2im, 3 + 100im)
 ComplexPoint(4 + 2im, 4 + 100im)
 ComplexPoint(5 + 2im, 5 + 100im)

julia> view.y.im .+= 10000
5-element FieldView{Int64,:im,1,IndexLinear(),false}:
 10100
 10100
 10100
 10100
 10100

julia> points
5-element Array{ComplexPoint,1}:
 ComplexPoint(1 + 2im, 1 + 10100im)
 ComplexPoint(2 + 2im, 2 + 10100im)
 ComplexPoint(3 + 2im, 3 + 10100im)
 ComplexPoint(4 + 2im, 4 + 10100im)
 ComplexPoint(5 + 2im, 5 + 10100im)
```

`FieldView` is a simple field viewer of the array of struct

## Example usage to view field
```julia
julia> struct Point
       x
       y
end

julia> points = [Point(i, i + 100) for i in 1:5]
5-element Array{Point,1}:
 Point(1, 101)
 Point(2, 102)
 Point(3, 103)
 Point(4, 104)
 Point(5, 105)

 julia> view = FieldView{:x}(points)
5-element FieldView{Any,:x,1,IndexLinear(),false}:
 1
 2
 3
 4
 5
```

Update logic is the same (mutate mutable objects or create a copy with updated field in the parant array)
## Example usage to update field

```julia
julia> view[2] = 300
300

julia> points
5-element Array{Point,1}:
 Point(1, 101)  
 Point(300, 102)
 Point(3, 103)  
 Point(4, 104)  
 Point(5, 105)  
```
