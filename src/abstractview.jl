abstract type AbstractView{T, N} <: AbstractArray{T, N} end

@inline Base.size(view::AbstractView) = size(parent(view))
