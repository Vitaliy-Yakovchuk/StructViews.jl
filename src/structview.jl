struct StructView{T, N} <: AbstractView{T, N}
    parent
    fields

    StructView{T, N}(parent, fields) where {T, N} = new{T, N}(parent, fields)
end

function _createfieldview(parenttype, parent, field)
    t = fieldtype(parenttype, field)
    fieldview = FieldView{t, field, ndims(parent)}(parent)

    if !(t isa DataType || t isa UnionAll) || t === Any
        return fieldview
    end
    fields = fieldnames(t)
    if isempty(fields) 
        return fieldview
    else
        return StructView(fieldview)
    end
end

function _getfields(parent::A) where {A<:AbstractArray}
    type = eltype(parent)
    fields = fieldnames(type)
    
    return NamedTuple{fields}([_createfieldview(type, parent, field) for field in fields])
end

function StructView(parent::A) where {A<:AbstractArray}
    fields = _getfields(parent)
    StructView{eltype(parent), ndims(parent)}(parent, fields)
end

@inline Base.getindex(view::StructView, i...) = getindex(view.parent, i...)

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
