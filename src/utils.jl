remove_pkgdir(filepath::AbstractString, mod::Module) = replace(filepath, pkgdir(mod) => "")

"""
    find_new_chunks(old_chunks::AbstractVector{<:AbstractString},
        new_chunks::AbstractVector{<:AbstractString})

Identifies the new chunks in `new_chunks` that are not present in `old_chunks`.

Returns a mask of chunks that are new (not present in `old_chunks`).

Uses SHA256 hashes to dedupe the strings quickly and effectively.
"""
function find_new_chunks(old_chunks::AbstractVector{<:AbstractString},
        new_chunks::AbstractVector{<:AbstractString})
    ## hash the chunks for easier search
    old = bytes2hex.(sha256.(old_chunks)) |> sort
    new = bytes2hex.(sha256.(new_chunks))

    new_items = falses(length(new_chunks))
    for i in eachindex(new, new_items)
        idx = searchsortedfirst(old, new[i])
        # check if idx is a genuine match, if not, it's a new item
        if idx > lastindex(old)
            new_items[i] = true
        elseif old[idx] != new[i]
            new_items[i] = true
        end
    end
    return new_items
end

function annotate_chunk_with_source(chunk::AbstractString, src::AbstractString)
    # parts: module, filepath, line, function
    parts = split(src, "::")
    return """
-- Source: Documentation of $(parts[end]) --
$chunk
-- End of Source --"""
end

"""
    last_context()

Returns the RAGContext from the last `aihelp` call. 
It can be useful to see the sources/references used by the AI model to generate the response.

If you're using `aihelp()` make sure to set `return_context = true` to return the context.
"""
last_context() = PT.LAST_CONTEXT

"""
    load_index!(index::RAG.AbstractChunkIndex;
        verbose::Bool = 1, kwargs...)

Loads the provided `index` into the global variable `MAIN_INDEX`.

If you don't have an `index` yet, use `build_index` to build one from your currently loaded packages (see `?build_index`)

# Example
```julia
# build an index from some modules, keep empty to embed all loaded modules (eg, `build_index()`) 
index = AIH.build_index([DataFramesMeta, DataFrames, CSV])
AIH.load_index!(index)
```
"""
function load_index!(index::RAG.AbstractChunkIndex;
        verbose::Bool = true, kwargs...)
    global MAIN_INDEX
    MAIN_INDEX = index
    verbose && @info "Loaded index into MAIN_INDEX"
    return index
end
"""
    load_index!(file_path::Union{Nothing, AbstractString} = nothing;
        verbose::Bool = true, kwargs...)

Loads the serialized index in `file_path` into the global variable `MAIN_INDEX`.
If not provided, it will download the latest index from the AIHelpMe.jl repository (more cost-efficient).
"""
function load_index!(file_path::Union{Nothing, AbstractString} = nothing;
        verbose::Bool = true, kwargs...)
    global MAIN_INDEX
    if !isnothing(file_path)
        @assert endswith(file_path, ".jls") "Provided file path must end with `.jls` (serialized Julia object)."
        file_str = "from file $(file_path) "
    else
        artifact_path = artifact"juliaextra"
        file_path = joinpath(artifact_path, "docs-index.jls")
        file_str = " "
    end
    index = deserialize(file_path)
    @assert index isa RAG.AbstractChunkIndex "Provided file path must point to a serialized RAG index (Deserialized type: $(typeof(index)))."
    verbose && @info "Loaded index $(file_str)into MAIN_INDEX"
    MAIN_INDEX = index

    return index
end

"""
    update_index(index::RAG.AbstractChunkIndex = MAIN_INDEX,
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Integer = 1,
        separators = ["\\n\\n", ". ", "\\n"], max_length::Int = 256,
        model::AbstractString = PT.MODEL_EMBEDDING,
        kwargs...)
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Bool = true, kwargs...)

Updates the provided `index` with the documentation of the provided `modules`.

Deduplicates against the `index.sources` and embeds only the new document chunks (as measured by a hash).

Returns the updated `index` (new instance).

# Example
If you loaded some new packages and want to add them to your MAIN_INDEX (or any `index` you use), run:
```julia
# To update the MAIN_INDEX
AHM.update_index() |> AHM.load_index!

# To update an explicit index
index = AHM.update_index(index)
```
"""
function update_index(index::RAG.AbstractChunkIndex = MAIN_INDEX,
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Integer = 1,
        separators = ["\n\n", ". ", "\n"], max_length::Int = 256,
        model::AbstractString = PT.MODEL_EMBEDDING,
        kwargs...)
    ##
    cost_tracker = Threads.Atomic{Float64}(0.0)
    ## Extract docs
    all_docs, all_sources = docextract(modules)
    ## Split into chunks
    output_chunks, output_sources = RAG.get_chunks(all_docs;
        reader = :docs, sources = all_sources, separators, max_length)
    ## identify new items
    mask = find_new_chunks(index.chunks, output_chunks)
    ## Embed new items
    embeddings = RAG.get_embeddings(output_chunks[mask];
        verbose = (verbose > 1),
        cost_tracker,
        model,
        kwargs...)

    ## Update index
    @assert size(embeddings, 2)==sum(mask) "Number of embeddings must match the number of new chunks (mask: $(sum(mask)), embeddings: $(size(embeddings,2)))"
    new_index = ChunkIndex(; index.id,
        chunks = vcat(index.chunks, output_chunks[mask]),
        sources = vcat(index.sources, output_sources[mask]),
        embeddings = hcat(index.embeddings, embeddings),
        index.tags, index.tags_vocab)

    (verbose > 0) && @info "Index built! (cost: \$$(round(cost_tracker[], digits=3)))"
    return new_index
end
