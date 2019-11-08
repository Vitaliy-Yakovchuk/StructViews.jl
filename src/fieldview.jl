struct FieldView{T, F, N, IT} <: AbstractView{T, N}
    parent
    
    FieldView{T, F, N}(parent) where {T, F, N} = new{T, F, N, IndexStyle(parent)}(parent)

    FieldView{T, F}(parent) where {T, F} = new{T, F, ndims(parent), IndexStyle(parent)}(parent)
    FieldView{F}(parent) where {T, F} = new{fieldtype(eltype(parent), F), F, ndims(parent), IndexStyle(parent)}(parent)
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

Base.@propagate_inbounds function Base.getindex(view::FieldView, I::Vararg{Union{Int, Colon}, N}) where {N}
    arr = parent(view)[I...]
    return FieldView{eltype(arr), structfield(view), ndims(arr)}(arr)
end

Base.@propagate_inbounds function Base.setindex!(view::FieldView, v, i::Int) 
    element = getindex(parent(view), i)
    field = structfield(view)
    Base.setfield!(element, field, v)
end

Base.@propagate_inbounds function Base.setindex!(view::FieldView, v, I::Vararg{Int, N}) where {N}
    element = getindex(parent(view), I...)
    field = structfield(view)
    Base.setfield!(element, field, v)
end

index_type(::Type{FieldView{T, F, N, IT}}) where {T, F, N, IT} = IT
