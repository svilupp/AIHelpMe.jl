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

"""
    last_result()

Returns the RAGResult from the last `aihelp` call. 
It can be useful to see the sources/references used by the AI model to generate the response.

If you're using `aihelp()` make sure to set `return_all = true` to return the RAGResult.
"""
last_result() = LAST_RESULT

"Hacky function to load a HDF5 file into a ChunkIndex object. Only bare-bone ChunkIndex is supported right now."
function load_index_hdf5(path::AbstractString; verbose::Bool = true)
    @assert isfile(path) "Index path does not exist! (Provided: $path)"

    verbose && @info "Loading index from $path"
    fid = h5open(path, "r")
    @assert all(x -> haskey(fid, x), ["chunks", "sources", "embeddings"]) "Index is missing fields! (Required: chunks, sources, embeddings)"
    id = if haskey(fid, "id")
        read(fid["id"]) |> Symbol
    else
        gensym("index")
    end
    index = RT.ChunkIndex(; id, chunks = read(fid["chunks"]),
        sources = read(fid["sources"]), embeddings = read(fid["embeddings"]))
    close(fid)
    return index
end