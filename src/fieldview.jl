struct FieldView{T, F, N} <: AbstractView{T, N}
    parent
    
    FieldView{T, F, N}(parent) where {T, F, N} = new{T, F, N}(parent)

    FieldView{T, F}(parent) where {T, F} = new{T, F, ndims(parent)}(parent)
    FieldView{F}(parent) where {T, F} = new{eltype(parent), F, ndims(parent)}(parent)
end

@inline structfield(fieldview::FieldView{T, F, N}) where {T, F, N} = F

@inline Base.parent(view::FieldView) = view.parent

@inline function Base.getindex(view::FieldView, i::Int) 
    element = getindex(parent(view), i)
    field = structfield(view)
    return Base.getfield(element, field)
end

@inline function Base.getindex(view::FieldView, I::Vararg{Int, N}) where {N}
    element = getindex(parent(view), I...)
    field = structfield(view)
    return Base.getfield(element, field)
end

function Base.getindex(view::FieldView, I::Vararg{Union{Int, Colon}, N}) where {N}
    arr = parent(view)[I...]
    return FieldView{eltype(arr), structfield(view), ndims(arr)}(arr)
end
