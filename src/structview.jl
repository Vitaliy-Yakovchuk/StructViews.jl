struct StructView{T, N} <: AbstractArray{T, N}
    parent
    fields

    StructView{T, N}(parent, fields) where {T, N} = new{T, N}(parent, fields)
end

function _getfields(parent::A) where {A<:AbstractArray}
    fields = fieldnames(eltype(parent))
    return fields
end

function StructView(parent::A) where {A<:AbstractArray}
    fields = _getfields(parent)
    StructView{eltype(parent), ndims(parent)}(parent, fields)
end

Base.size(view::StructView) = size(view.parent)

Base.getindex(view::StructView, i...) = getindex(view.parent, i...)

Base.parent(view::StructView) = view.parent
