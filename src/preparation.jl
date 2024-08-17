"""
    docdata_to_source(data::AbstractDict)

Creates a source path from a given DocStr record
"""
function docdata_to_source(data::AbstractDict)
    linenumber = get(data, :linenumber, 0)
    mod = get(data, :module, "-") |> string
    func = get(data, :binding, "-") |> string
    path = get(data, :path, "-") |> string
    string(mod, "::", path, "::", linenumber, "::", func)
end

"""
    docextract(d::DocStr, sep::AbstractString = "\n\n")

Extracts the documentation from a DocStr record.
Separates the individual docs within `DocStr` with `sep`.
"""
function docextract(d::DocStr, sep::AbstractString = "\n\n")
    io = IOBuffer()
    for part in d.text
        if part isa String
            write(io, part, sep)
            # else
            #     @info d.data[:binding] typeof(part)
            #     @info part
        end
    end
    docs = String(take!(io))
    source = hasproperty(d, :data) ? docdata_to_source(d.data) : ""
    return docs, source
end

"""
    docextract(d::MultiDoc, sep::AbstractString = "\n\n")

Extracts the documentation from a MultiDoc record (separates the individual docs within `DocStr` with `sep`)
"""
function docextract(d::MultiDoc, sep::AbstractString = "\n\n")
    docs, sources = String[], String[]
    for v in values(d.docs)
        doc, source = docextract(v, sep)
        push!(docs, doc)
        push!(sources, source)
    end
    return docs, sources
end

"""
    docextract(mod::Module)

Extracts the documentation from a given (loaded) module.
"""
function docextract(mod::Module)
    all_docs, all_sources = String[], String[]
    # Module doc might be in README.md instead of the META dict
    push!(all_docs, doc(mod) |> stripmd)
    push!(all_sources, string(nameof(mod), "::", "/README.md", "::", 0, "::", nameof(mod)))
    dict = meta(mod; autoinit = false)
    isnothing(dict) && return all_docs, all_sources
    for (k, v) in dict
        docs, sources = docextract(v)
        append!(all_docs, docs)
        sources = !isnothing(pkgdir(mod)) ? remove_pkgdir.(sources, Ref(mod)) : sources
        append!(all_sources, sources)
    end
    all_docs, all_sources
end

"""
    docextract(modules::Vector{Module} = Base.Docs.modules)

Extracts the documentation from a vector of `modules`.
"""
function docextract(modules::Vector{Module} = Base.Docs.modules)
    all_docs, all_sources = String[], String[]
    for mod in modules
        docs, sources = docextract(mod)
        append!(all_docs, docs)
        append!(all_sources, sources)
    end
    all_docs, all_sources
end

"""
    RT.build_index(mod::Module; verbose::Int = 1, kwargs...)

Build `index` from the documentation of a given module `mod`.
"""
function RT.build_index(mod::Module; verbose::Int = 1, kwargs...)
    global RAG_CONFIG, RAG_KWARGS

    ## Extract docstrings
    all_docs, all_sources = docextract(mod)

    ## Extract current configuration 
    # New default chunk size 384 (unless user provides different)
    chunker_kwargs_ = (; sources = all_sources, max_length = 384)
    chunker_kwargs = haskey(kwargs, :chunker_kwargs) ?
                     merge(kwargs[:chunker_kwargs], chunker_kwargs_) : chunker_kwargs_

    embedder_kwargs_ = RT.getpropertynested(
        RAG_KWARGS[], [:retriever_kwargs], :embedder_kwargs, nothing)
    # Note: force Matrix{Bool} structure for now, switch to Int8-based binary embeddings with the latest PT
    embedder_kwargs = haskey(kwargs, :embedder_kwargs) ?
                      merge(
        (; return_type = Matrix{Bool}), embedder_kwargs_, kwargs[:embedder_kwargs]) :
                      merge((; return_type = Matrix{Bool}), embedder_kwargs_)

    new_index = RT.build_index(RAG_CONFIG[].indexer, all_docs;
        kwargs...,
        embedder_kwargs, chunker = RT.TextChunker(), chunker_kwargs,
        verbose, index_id = nameof(mod))
end

"""
    RT.build_index(modules::Vector{Module} = Base.Docs.modules; verbose::Int = 1,
        kwargs...)

Build index from the documentation of the currently loaded modules.
If `modules` is empty, it will use all currently loaded modules.
"""
function RT.build_index(modules::Vector{Module} = Base.Docs.modules; verbose::Int = 1,
        kwargs...)
    global RAG_CONFIG, RAG_KWARGS

    all_docs, all_sources = docextract(modules)
    ## Extract current configuration
    # New default chunk size 384 (unless user provides different)
    chunker_kwargs_ = (; sources = all_sources, max_length = 384)
    chunker_kwargs = haskey(kwargs, :chunker_kwargs) ?
                     merge(kwargs[:chunker_kwargs], chunker_kwargs_) : chunker_kwargs_

    # Note: force Matrix{Bool} structure for now, switch to Int8-based binary embeddings with the latest PT
    embedder_kwargs_ = RT.getpropertynested(
        RAG_KWARGS[], [:retriever_kwargs], :embedder_kwargs, nothing)
    embedder_kwargs = haskey(kwargs, :embedder_kwargs) ?
                      merge(
        (; return_type = Matrix{Bool}), embedder_kwargs_, kwargs[:embedder_kwargs]) :
                      merge((; return_type = Matrix{Bool}), embedder_kwargs_)

    new_index = RT.build_index(RAG_CONFIG[].indexer, all_docs;
        kwargs...,
        embedder_kwargs, chunker = RT.TextChunker(), chunker_kwargs,
        verbose, index_id = :all_modules)
end
