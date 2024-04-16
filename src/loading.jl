
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
"""
function load_index!(file_path::AbstractString;
        verbose::Bool = true, kwargs...)
    global MAIN_INDEX
    @assert endswith(file_path, ".jls") "Provided file path must end with `.jls` (serialized Julia object)."
    index = deserialize(file_path)
    @assert index isa RT.AbstractChunkIndex "Provided file path must point to a serialized RAG index (Deserialized type: $(typeof(index)))."
    verbose && @info "Loaded index a file $(file_path) into MAIN_INDEX"
    MAIN_INDEX[] = index

    return index
end

function load_index!(packs::Vector{Symbol}; verbose::Bool = true, kwargs...)
    global ALLOWED_PACKS, RAG_CONFIG, RAG_CONFIG
    @assert all(x -> x in ALLOWED_PACKS, packs) "Invalid pack(s): $(setdiff(packs, ALLOWED_PACKS)). Allowed packs: $(ALLOWED_PACKS)"

    config_key = get_config_key(RAG_CONFIG[], RAG_KWARGS[])
    @info config_key
    indices = []
    for pack in packs
        artifact_path = @knowledge_pack pack config_key
        index = load_index_hdf5(joinpath(artifact_path, "pack.hdf5"))
        push!(indices, index)
    end
    # TODO: dedupe the index
    index = vcat(indices...)
    MAIN_INDEX[] = index
    verbose && @info "Loaded index from packs: $(join(packs,", ")) into MAIN_INDEX"
    return index
end

# Default load index
load_index!(pack::Symbol) = load_index!([pack])
load_index!() = load_index!(:julia)

"""
    update_index(index::RT.AbstractChunkIndex = MAIN_INDEX,
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
function update_index(index::RT.AbstractChunkIndex = MAIN_INDEX[],
        modules::Vector{Module} = Base.Docs.modules;
        verbose::Integer = 1,
        separators = ["\n\n", ". ", "\n"], max_length::Int = 256,
        model::AbstractString = MODEL_EMBEDDING,
        kwargs...)
    ##
    cost_tracker = Threads.Atomic{Float64}(0.0)
    ## Extract docs
    all_docs, all_sources = docextract(modules)
    ## Split into chunks
    output_chunks, output_sources = RT.get_chunks(all_docs;
        reader = :docs, sources = all_sources, separators, max_length)
    ## identify new items
    mask = find_new_chunks(index.chunks, output_chunks)
    ## Embed new items
    embeddings = RT.get_embeddings(output_chunks[mask];
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