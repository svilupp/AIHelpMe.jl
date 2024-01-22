"""
    aihelp([index::RAG.AbstractChunkIndex,]
        question::AbstractString;
        rag_template::Symbol = :RAGAnswerFromContext,
        top_k::Int = 100, top_n::Int = 5,
        minimum_similarity::AbstractFloat = -1.0,
        maximum_cross_similarity::AbstractFloat = 1.0,
        rerank_strategy::RAG.RerankingStrategy = (!isempty(PT.COHERE_API_KEY) ?
                                                  RAG.CohereRerank() : RAG.Passthrough()),
        annotate_sources::Bool = true,
        model_embedding::String = PT.MODEL_EMBEDDING, model_chat::String = PT.MODEL_CHAT,
        chunks_window_margin::Tuple{Int, Int} = (1, 1),
        return_context::Bool = false, verbose::Integer = 1,
        rerank_kwargs::NamedTuple = NamedTuple(),
        api_kwargs::NamedTuple = NamedTuple(),
        kwargs...)

Generates a response for a given question using a Retrieval-Augmented Generation (RAG) approach over Julia documentation. 

# Arguments
- `index::AbstractChunkIndex`: The chunk index (contains chunked and embedded documentation).
- `question::AbstractString`: The question to be answered.
- `rag_template::Symbol`: Template for the RAG model, defaults to `:RAGAnswerFromContext`.
- `top_k::Int`: Number of top candidates to retrieve based on embedding similarity.
- `top_n::Int`: Number of candidates to return after reranking. This is how many will be sent to the LLM model.
- `minimum_similarity::AbstractFloat`: Minimum similarity threshold (between -1 and 1) for filtering chunks based on embedding similarity. Defaults to -1.0.
- `maximum_cross_similarity::AbstractFloat`: Maximum cross-similarity threshold to avoid sending duplicate documents. NOT IMPLEMENTED YET
- `rerank_strategy::RerankingStrategy`: Strategy for reranking the retrieved chunks. Defaults to `Passthrough()` or `CohereRerank` depending on whether `COHERE_API_KEY` is set.
- `model_embedding::String`: Model used for embedding the question, default is `PT.MODEL_EMBEDDING`.
- `model_chat::String`: Model used for generating the final response, default is `PT.MODEL_CHAT`.
- `chunks_window_margin::Tuple{Int,Int}`: The window size around each chunk to consider for context building. See `?build_context` for more information.
- `return_context::Bool`: If `true`, returns the context used for RAG along with the response.
- `return_all::Bool`: If `true`, returns all messages in the conversation (helpful to continue conversation later).
- `verbose::Bool`: If `true`, enables verbose logging.
- `rerank_kwargs`: Reranking parameters that will be forwarded to the reranking strategy
- `api_kwargs`: API parameters that will be forwarded to the API calls

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
function aihelp(index::RAG.AbstractChunkIndex,
    question::AbstractString;
    rag_template::Symbol=:RAGAnswerFromContext,
    top_k::Int=100, top_n::Int=5,
    minimum_similarity::AbstractFloat=-1.0,
    maximum_cross_similarity::AbstractFloat=1.0,
    rerank_strategy::RAG.RerankingStrategy=(!isempty(PT.COHERE_API_KEY) ?
                                            RAG.CohereRerank() : RAG.Passthrough()),
    annotate_sources::Bool=true,
    model_embedding::String=PT.MODEL_EMBEDDING, model_chat::String=PT.MODEL_CHAT,
    chunks_window_margin::Tuple{Int,Int}=(1, 1),
    return_context::Bool=false, verbose::Integer=1,
    rerank_kwargs::NamedTuple=NamedTuple(),
    api_kwargs::NamedTuple=NamedTuple(),
    kwargs...)
    ## Note: Supports only single ChunkIndex for now
    global LAST_CONTEXT, CONV_HISTORY_LOCK

    ## Checks
    @assert top_k > 0 "top_k must be positive"
    @assert top_n > 0 "top_n must be positive"
    @assert top_k >= top_n "top_k must be greater than or equal to top_n"
    @assert minimum_similarity >= -1.0 && minimum_similarity <= 1.0 "minimum_similarity must be between -1 and 1"
    @assert maximum_cross_similarity >= -1.0 && maximum_cross_similarity <= 1.0 "maximum_cross_similarity must be between -1 and 1"
    ## TODO: implement maximum_cross_similarity filter

    @assert chunks_window_margin[1] >= 0 && chunks_window_margin[2] >= 0 "Both `chunks_window_margin` values must be non-negative"
    placeholders = only(aitemplates(rag_template)).variables # only one template should be found
    @assert (:question in placeholders) && (:context in placeholders) "Provided RAG Template $(rag_template) is not suitable. It must have placeholders: `question` and `context`."

    cost_tracker = Threads.Atomic{Float64}(0.0)

    ## Embedding step
    msg = aiembed(question,
        RAG._normalize;
        verbose=(verbose > 1),
        model=model_embedding,
        api_kwargs)
    Threads.atomic_add!(cost_tracker, PT.call_cost(msg, model_embedding)) # track costs
    question_emb = msg.content .|> Float32 # no need for Float64
    emb_candidates = RAG.find_closest(index, question_emb; top_k, minimum_similarity)

    filtered_candidates = emb_candidates
    reranked_candidates = RAG.rerank(rerank_strategy,
        index,
        question,
        filtered_candidates;
        verbose=(verbose > 1), top_n, rerank_kwargs...)

    ## Build the context
    sources = RAG.sources(index)[reranked_candidates.positions]
    context = RAG.build_context(index, reranked_candidates; chunks_window_margin)
    if annotate_sources
        context = [annotate_chunk_with_source(chunk, src)
                   for (chunk, src) in zip(context, sources)]
    end

    ## LLM call
    msg = aigenerate(rag_template; question,
        context=join(context, "\n\n"), model=model_chat,
        verbose=(verbose > 1),
        api_kwargs,
        kwargs...)
    last_msg = msg isa PT.AIMessage ? msg : last(msg)
    Threads.atomic_add!(cost_tracker, PT.call_cost(last_msg, model_chat)) # track costs
    (verbose >= 1) &&
        @info "Done generating response. Total cost: \$$(round(cost_tracker[],digits=3))"

    ## Always create and save the context to global LAST_CONTEXT (for reference)
    rag_context = RAG.RAGContext(;
        question,
        answer=last_msg.content,
        context,
        sources,
        emb_candidates,
        tag_candidates=nothing,
        filtered_candidates,
        reranked_candidates)
    lock(CONV_HISTORY_LOCK) do
        PT.LAST_CONTEXT = rag_context
    end

    if return_context # for evaluation
        return msg, rag_context
    else
        return msg
    end
end

function aihelp(question::AbstractString;
    kwargs...)
    global MAIN_INDEX
    @assert !isnothing(MAIN_INDEX) "MAIN_INDEX is not loaded. Use `load_index!` to load an index."
    aihelp(MAIN_INDEX, question; kwargs...)
end