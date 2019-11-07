abstract type AbstractView{T, N} <: AbstractArray{T, N} end

@inline Base.size(view::AbstractView) = size(parent(view))

@inline Base.eltype(view::AbstractView{T, N}) where {T, N} = T

@inline Base.ndims(view::AbstractView{T, N}) where {T, N} = N
