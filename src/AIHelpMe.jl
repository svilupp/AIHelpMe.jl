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

## Globals
const CONV_HISTORY = Vector{Vector{PT.AbstractMessage}}()
const CONV_HISTORY_LOCK = ReentrantLock()
const MAX_HISTORY_LENGTH = 1
const LAST_CONTEXT = Ref{Union{Nothing, RAG.RAGContext}}(nothing)
const MAIN_INDEX = Ref{Union{Nothing, RAG.AbstractChunkIndex}}(nothing)
function __init__()
    ## Load index
    MAIN_INDEX[] = load_index!()
end

end
