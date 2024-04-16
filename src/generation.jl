"Extract the requested output type from the RAGResult"
function finalize_output(result, return_all)
    output = if return_all
        result
    elseif haskey(result.conversations, :final_answer) &&
           !isempty(result.conversations[:final_answer])
        result.conversations[:final_answer][end]
    elseif haskey(result.conversations, :answer) &&
           !isempty(result.conversations[:answer])
        result.conversations[:answer][end]
    else
        throw(ArgumentError("No conversation found in the result"))
    end
end

"""
    aihelp(cfg::RT.AbstractRAGConfig, index::RT.AbstractChunkIndex,
        question::AbstractString;
        verbose::Integer = 1,
        model = MODEL_CHAT,
        return_all::Bool = false)

Generates a response for a given question using a Retrieval-Augmented Generation (RAG) approach over Julia documentation. 

# Arguments
- `cfg::AbstractRAGConfig`: The RAG configuration.
- `index::AbstractChunkIndex`: The chunk index (contains chunked and embedded documentation).
- `question::AbstractString`: The question to be answered.
- `model::String`: A chat/generation model used for generating the final response, default is `MODEL_CHAT`.

# Returns
- If `return_context` is `false`, returns the generated message (`msg`).
- If `return_context` is `true`, returns a tuple of the generated message (`msg`) and the RAG context (`rag_context`).

# Notes
- The function first finds the closest chunks of documentation to the question (via `embeddings`).
- It reranks the candidates and builds a "context" for the RAG model (ie, information to be provided to the LLM model together with the user question).
- The `chunks_window_margin` allows including surrounding chunks for richer context, considering they are from the same source.
- The function currently supports only single `ChunkIndex`. 
- Function always saves the last context in global `LAST_CONTEXT` for inspection of sources/context regardless of `return_context` value.

# Examples

Using `aihelp` to get a response for a question:
```julia
index = build_index(...)  # create an index that contains Makie.jl documentation
question = "How to make a barplot in Makie.jl?"
msg = aihelp(index, question)

# or simply
msg = aihelp(index; question)
```

"""
function aihelp(cfg::RT.AbstractRAGConfig, index::RT.AbstractChunkIndex,
        question::AbstractString;
        verbose::Integer = 1,
        model = MODEL_CHAT,
        return_all::Bool = false, search::Union{Nothing, Bool} = nothing, rerank::Union{
            Nothing, Bool} = nothing)
    global LAST_RESULT, CONV_HISTORY_LOCK, RAG_KWARGS

    ## Grab the active kwargs
    kwargs = RAG_KWARGS[]
    # Update chat model
    setpropertynested(kwargs,
        [:rephraser_kwargs, :tagger_kwargs, :answerer_kwargs, :refiner_kwargs],
        :model, model)

    result = airag(cfg, index, question; verbose, return_all = true, kwargs...)
    lock(CONV_HISTORY_LOCK) do
        LAST_RESULT[] = result
    end
    return finalize_output(result, return_all)
end

function aihelp(question::AbstractString;
        kwargs...)
    global MAIN_INDEX, RAG_CONFIG
    @assert !isnothing(MAIN_INDEX[]) "MAIN_INDEX is not loaded. Use `load_index!` to load an index."
    ## default kwargs and models are injected inside of main aihelp function
    aihelp(RAG_CONFIG[], MAIN_INDEX[], question; kwargs...)
end
