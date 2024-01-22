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
    RAG.build_index(mod::Module; verbose::Int = 1, kwargs...)

Build `index` from the documentation of a given module `mod`.
"""
function RAG.build_index(mod::Module; verbose::Int = 1, kwargs...)
    docs, sources = docextract(mod)
    RAG.build_index(docs; reader = :docs,
        sources,
        extract_metadata = false, verbose,
        index_id = nameof(mod), kwargs...)
end

"""
    RAG.build_index(modules::Vector{Module} = Base.Docs.modules; verbose::Int = 1,
        separators = ["\n\n", ". ", "\n"], max_length::Int = 256,
        kwargs...)

Build index from the documentation of the currently loaded modules.
If `modules` is empty, it will use all currently loaded modules.
"""
function RAG.build_index(modules::Vector{Module} = Base.Docs.modules; verbose::Int = 1,
        separators = ["\n\n", ". ", "\n"], max_length::Int = 256,
        kwargs...)
    all_docs, all_sources = docextract(modules)
    RAG.build_index(all_docs;
        separators,
        max_length,
        reader = :docs,
        extract_metadata = false,
        verbose,
        index_id = :all_index,
        sources = all_sources)
end
