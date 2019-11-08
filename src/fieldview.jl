struct FieldView{T, F, N, IT, M} <: AbstractView{T, N}
    parent
    
    FieldView{T, F, N}(parent) where {T, F, N} = new{T, F, N, IndexStyle(parent), eltype(parent).mutable ? (:mutable) : (:immutable)}(parent)

    FieldView{T, F}(parent) where {T, F} = new{T, F, ndims(parent), IndexStyle(parent), eltype(parent).mutable ? (:mutable) : (:immutable)}(parent)
    FieldView{F}(parent) where {T, F} = new{fieldtype(eltype(parent), F), F, ndims(parent), IndexStyle(parent), eltype(parent).mutable ? (:mutable) : (:immutable)}(parent)
end

@inline structfield(fieldview::FieldView{T, F, N, IT, M}) where {T, F, N, IT, M} = F

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

Base.@propagate_inbounds function Base.setindex!(view::FieldView{T, F, N, IT, :mutable}, v, i::Int) where {T, F, N, IT}
    element = getindex(parent(view), i)
    field = structfield(view)
    Base.setfield!(element, field, v)
end

Base.@propagate_inbounds function Base.setindex!(view::FieldView{T, F, N, IT, :mutable}, v, I::Vararg{Int, X}) where {T, F, N, IT, X}
    element = getindex(parent(view), I...)
    field = structfield(view)
    Base.setfield!(element, field, v)
end

function updateimmutable(view, element, v)
    field = structfield(view)
    type = typeof(element)
    fields = fieldnames(type)
    params = ntuple(length(fields)) do i
        f = fields[i]
        if f === field
            return v
        end
        return getfield(element, f)
    end
    return type(params...)
end

Base.@propagate_inbounds function Base.setindex!(view::FieldView{T, F, N, IT, :immutable}, v, i::Int) where {T, F, N, IT}
    element = getindex(parent(view), i)
    setindex!(parent(view), updateimmutable(view, element, v), i)
end

Base.@propagate_inbounds function Base.setindex!(view::FieldView{T, F, N, IT, :immutable}, v, I::Vararg{Int, X}) where {T, F, N, IT, X}
    element = getindex(parent(view), I...)
    setindex!(parent(view), updateimmutable(view, element, v), I...)
end

index_type(::Type{FieldView{T, F, N, IT, M}}) where {T, F, N, IT, M} = IT
