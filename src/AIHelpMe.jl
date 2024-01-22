module AIHelpMe

using Preferences, Serialization, LinearAlgebra, SparseArrays
using LazyArtifacts
using Base.Docs: DocStr, MultiDoc, doc, meta
using REPL: stripmd

using PromptingTools
using PromptingTools.Experimental.RAGTools
using SHA: sha256, bytes2hex
const PT = PromptingTools
const RAG = PromptingTools.Experimental.RAGTools

## export load_index!, last_context, update_index!
## export remove_pkgdir, annotate_source, find_new_chunks
include("utils.jl")

## export docdata_to_source, docextract, build_index
include("preparation.jl")

export aihelp
include("generation.jl")

export @aihelp_str, @aihelp!_str
include("macros.jl")

function __init__()
    ## Globals
    CONV_HISTORY::Vector{Vector{<:Any}} = Vector{Vector{<:Any}}()
    CONV_HISTORY_LOCK::ReentrantLock = ReentrantLock()
    MAX_HISTORY_LENGTH::Int = 1
    MAIN_INDEX::Union{Nothing, RAG.AbstractChunkIndex} = nothing
    LAST_CONTEXT::Union{Nothing, RAG.RAGContext} = nothing
    ## Load index
    # TODO: load_index!()
end

end
