
"""
    load_index!(index::RT.AbstractChunkIndex;
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
function load_index!(index::RT.AbstractChunkIndex;
        verbose::Bool = true, kwargs...)
    global MAIN_INDEX
    MAIN_INDEX[] = index
    verbose && @info "Loaded index into MAIN_INDEX"
    return index
end
"""
    load_index!(file_path::AbstractString;
        verbose::Bool = true, kwargs...)

Loads the serialized index in `file_path` into the global variable `MAIN_INDEX`.

Supports `.jls` (serialized Julia object) and `.hdf5` (HDF5.jl) files.
"""
function load_index!(file_path::AbstractString;
        verbose::Bool = true, kwargs...)
    global MAIN_INDEX
    @assert endswith(file_path, ".jls")||endswith(file_path, ".hdf5") "Provided file path must end with `.jls` (serialized Julia object) or `.hdf5` (see HDF5.jl)."
    if endswith(file_path, ".jls")
        index = deserialize(file_path)
    elseif endswith(file_path, ".hdf5")
        index = load_index_hdf5(file_path)
    end
    @assert index isa RT.AbstractChunkIndex "Provided file path must point to a serialized RAG index (Deserialized type: $(typeof(index)))."
    verbose && @info "Loaded index a file $(file_path) into MAIN_INDEX"
    MAIN_INDEX[] = index

    return index
end

"""
    load_index!(packs::Vector{Symbol}=LOADED_PACKS[]; verbose::Bool = true, kwargs...)
    load_index!(pack::Symbol; verbose::Bool = true, kwargs...)

Loads one or more `packs` into the main index from our pre-built artifacts.

Availability of packs might vary depending on your pipeline configuration (ie, whether we have the correct embeddings for it).
See `AIHelpMe.ALLOWED_PACKS`

# Example
```julia
load_index!(:julia)
```

Or multiple packs
```julia
load_index!([:julia, :makie,:tidier])
```
"""
function load_index!(
        packs::Vector{Symbol} = LOADED_PACKS[]; verbose::Bool = true, kwargs...)
    global ALLOWED_PACKS, RAG_CONFIG, RAG_CONFIG
    @assert all(x -> x in ALLOWED_PACKS, packs) "Invalid pack(s): $(setdiff(packs, ALLOWED_PACKS)). Allowed packs: $(ALLOWED_PACKS)"

    config_key = get_config_key(RAG_CONFIG[], RAG_KWARGS[])
    indices = RT.ChunkIndex[]
    for pack in packs
        artifact_path = @artifact_str("$(pack)__$(config_key)")
        index = load_index_hdf5(joinpath(artifact_path, "pack.hdf5"); verbose = false)
        push!(indices, index)
    end
    # TODO: dedupe the index
    joined_index = reduce(vcat, indices)
    MAIN_INDEX[] = joined_index
    verbose && @info "Loaded index from packs: $(join(packs,", ")) into MAIN_INDEX"
    return joined_index
end

# Convenience method
load_index!(pack::Symbol) = load_index!([pack])

"""
    update_index(index::RT.AbstractChunkIndex = MAIN_INDEX[],
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Integer = 1,
        kwargs...)

Updates the provided `index` with the documentation of the provided `modules`.

Deduplicates against the `index.sources` and embeds only the new document chunks (as measured by a hash).

Returns the updated `index` (new instance).

For available configurations and customizations, see the corresponding modules and functions of `PromptingTools.Experimental.RAGTools` (eg, `build_index`).

# Example
If you loaded some new packages and want to add them to your MAIN_INDEX (or any `index` you use), run:
```julia
# To update the MAIN_INDEX as well
AIHelpMe.update_index() |> AHM.load_index!

# To update an explicit index
index = AIHelpMe.update_index(index)
```
"""
function update_index(index::RT.AbstractChunkIndex = MAIN_INDEX[],
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Integer = 1,
        kwargs...)
    ##
    global RAG_CONFIG, RAG_KWARGS
    ##
    cost_tracker = Threads.Atomic{Float64}(0.0)
    ## Extract docs
    all_docs, all_sources = docextract(modules)

    ## Build the new index -- E2E process disabled as it would duplicate a lot the docs we already have
    ##
    ##     new_index = RT.build_index(RAG_CONFIG[].indexer, all_docs, ;
    ##     embedder_kwargs, chunker = TextChunker(), chunker_kwargs,
    ##     verbose, kwargs...
    ## )

    ## Chunking
    chunker_kwargs_ = (; sources = all_sources)
    chunker_kwargs = haskey(kwargs, :chunker_kwargs) ?
                     merge(kwargs.chunker_kwargs, chunker_kwargs_) : chunker_kwargs_
    output_chunks, output_sources = RT.get_chunks(
        RT.TextChunker(), all_docs; chunker_kwargs...,
        verbose = (verbose > 1))

    ## identify new items
    mask = find_new_chunks(index.chunks, output_chunks)

    ## Embed new items
    embedder = RAG_CONFIG[].retriever.embedder
    embedder_kwargs_ = RT.getpropertynested(
        RAG_KWARGS[], [:retriever_kwargs], :embedder_kwargs, nothing)
    embedder_kwargs = haskey(kwargs, :embedder_kwargs) ?
                      merge(kwargs.embedder_kwargs, embedder_kwargs_) : embedder_kwargs_
    embeddings = RT.get_embeddings(embedder, output_chunks[mask];
        embedder_kwargs...,
        verbose = (verbose > 1),
        cost_tracker)
    ## match eltype
    embeddings = convert(typeof(index.embeddings), embeddings)

    ## TODO: add tagging in the future!

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