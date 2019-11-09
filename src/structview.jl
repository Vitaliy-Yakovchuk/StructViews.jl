"""
    StructView{T, N, IT} <: AbstractView{T, N}
A type-view to array of structures as a structure of field arrays.
"""
struct StructView{T, N, IT} <: AbstractView{T, N}
    parent
    fields

    StructView{T, N}(parent, fields) where {T, N} = new{T, N, IndexStyle(parent)}(parent, fields)
end

function _hasnofields(t)
    !(t isa DataType || t isa UnionAll) || t === Any || (:abstract in propertynames(t) && t.abstract)
end

function _createfieldview(parenttype, parent, field, typestack)
    t = fieldtype(parenttype, field)
    fieldview = FieldView{t, field, ndims(parent)}(parent)

    if _hasnofields(t)
        return fieldview
    end
    fields = fieldnames(t)
    if isempty(fields) 
        return fieldview
    else
        return _newstructview(fieldview, typestack)
    end
end

function _getfields(parent::A, typestack) where {A<:AbstractArray}
    parenttype = eltype(parent)
    if _hasnofields(parenttype)
        return parent
    end
    fields = filter(collect(fieldnames(parenttype))) do field
        t = fieldtype(parenttype, field)
        return !(t in typestack)
    end
    return NamedTuple{(fields...,)}([_createfieldview(parenttype, parent, field, typestack) for field in fields])
end

function _newstructview(parent::A, typestack) where {A<:AbstractArray}
    push!(typestack, eltype(parent))
    fields = _getfields(parent, typestack)
    delete!(typestack, eltype(parent))
    StructView{eltype(parent), ndims(parent)}(parent, fields)
end

"""
    StructView(parent::AbstractArray)
Create a new StructView, a view to array of structures as a structure of field arrays.
"""
function StructView(parent::A) where {A<:AbstractArray}
    typestack = Set(Type[])
    _newstructview(parent, typestack)
end


Base.@propagate_inbounds Base.getindex(view::StructView, i...) = getindex(view.parent, i...)

Base.@propagate_inbounds Base.setindex!(view::StructView, v, i...) = setindex!(view.parent, v, i...)

@inline Base.parent(view::StructView) = view.parent

function Base.getproperty(view::StructView, field::Symbol)
    fields = getfield(view, :fields)
    if haskey(fields, field)
        return fields[field]
    end
    return getfield(view, field)
end

function Base.propertynames(view::StructView)
    return (fieldnames(StructView)..., keys(view.fields)...)
end

function Base.push!(view::StructView{T, 1, IT}, item) where {T, IT}
    push!(parent(view), item)
    return view
end

Base.pop!(view::StructView{T, 1, IT}) where {T, IT} = pop!(parent(view))

function Base.append!(view::StructView{T, 1, IT}, iter) where {T, IT} 
    append!(parent(view), iter)
    return view
end

index_type(::Type{StructView{T, N, IT}}) where {T, N, IT} = IT
