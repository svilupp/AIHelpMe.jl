# Loaded up with `update_pipeline!` later once RAG CONFIGURATIONS is populated
global RAG_KWARGS::NamedTuple = NamedTuple()
global RAG_CONFIG::RT.AbstractRAGConfig = RAGConfig() # just initialize, it will be changed
global LOADED_CONFIG_KEY::String = "" # get the current config key

"""
    RAG_CONFIGURATIONS

A dictionary of RAG configurations, keyed by a unique symbol (eg, `bronze`).
Each entry contains a dictionary with keys `:config` and `:kwargs`,
where `:config` is the RAG configuration object (`AbstractRAGConfig`) and `:kwargs` the NamedTuple of corresponding kwargs.

Available Options:
- `:bronze`: A simple configuration for a bronze pipeline, using truncated binary embeddings (dimensionality: 1024) and no re-ranking or refinement.
- `:silver`: A simple configuration for a bronze pipeline, using truncated binary embeddings (dimensionality: 1024) but also enables re-ranking step.
- `:gold`: A more complex configuration, similar to `:simpler`, but using a standard embeddings (dimensionality: 3072, type: Float32). It also leverages re-ranking and refinement with a web-search.
"""
global RAG_CONFIGURATIONS::Dict{Symbol, Dict{Symbol, Any}} = Dict{
    Symbol, Dict{Symbol, Any}}()

## Load configurations
let MODEL_CHAT = MODEL_CHAT, MODEL_EMBEDDING = MODEL_EMBEDDING,
    RAG_CONFIGURATIONS = RAG_CONFIGURATIONS
    ## Bronze
    RAG_CONFIGURATIONS[:bronze] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
            indexer = RT.SimpleIndexer(; embedder = RT.BinaryBatchEmbedder()),
            retriever = RT.SimpleRetriever(; embedder = RT.BinaryBatchEmbedder())),
        :kwargs => (
            retriever_kwargs = (;
                top_k = 100,
                top_n = 5,
                rephraser_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = EMBEDDING_DIMENSION,
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))
    ## Silver - reranking added
    RAG_CONFIGURATIONS[:silver] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
            indexer = RT.SimpleIndexer(; embedder = RT.BinaryBatchEmbedder()),
            retriever = RT.SimpleRetriever(;
                embedder = RT.BinaryBatchEmbedder(), reranker = RT.CohereReranker())),
        :kwargs => (
            retriever_kwargs = (;
                top_k = 100,
                top_n = 5,
                rephraser_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = EMBEDDING_DIMENSION,
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))
    ## Gold  - reranking + web-search
    RAG_CONFIGURATIONS[:gold] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
            indexer = RT.SimpleIndexer(; embedder = RT.BatchEmbedder()),
            retriever = RT.SimpleRetriever(;
                embedder = RT.BatchEmbedder(), reranker = RT.CohereReranker()),
            generator = RT.SimpleGenerator(; refiner = RT.TavilySearchRefiner())),
        :kwargs => (
            retriever_kwargs = (;
                top_k = 100,
                top_n = 5,
                rephraser_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = nothing,
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))
end

"Returns the configuration key for the given `cfg` and `kwargs` to use the relevant artifacts."
function get_config_key(
        cfg::AbstractRAGConfig = RAG_CONFIG, kwargs::NamedTuple = RAG_KWARGS)
    emb_model = getpropertynested(kwargs, [:embedder_kwargs], :model)
    emb_dim = getpropertynested(kwargs, [:embedder_kwargs], :truncate_dimension, 0)
    emb_eltype = RT.EmbedderEltype(cfg.retriever.embedder)
    string(replace(emb_model, "-" => ""), "-",
        emb_dim, "-", emb_eltype)
end
# with defaults

"""
    update_pipeline!(option::Symbol = :bronze; model_chat = MODEL_CHAT,
        model_embedding = MODEL_EMBEDDING, verbose::Bool = true, embedding_dimension::Integer = EMBEDDING_DIMENSION)

Updates the default RAG pipeline to one of the pre-configuration options and sets the requested chat and embedding models.

This is a good way to update model types to change between OpenAI models and Ollama models.

See available pipeline options via `keys(RAG_CONFIGURATIONS)`.

Logic:
- Updates the global `MODEL_CHAT` and `MODEL_EMBEDDING` to the requested models.
- Updates the global `EMBEDDING_DIMENSION` for the requested embedding dimensionality after truncation (`embedding_dimension`).
- Updates the global `RAG_CONFIG` and `RAG_KWARGS` to the requested `option`.
- Updates the global `LOADED_CONFIG_KEY` to the configuration key for the given `option` and `kwargs` (used by the artifact system to download the correct knowledge packs).

# Example
```julia
update_pipeline!(:bronze; model_chat = "gpt4t")
```
You don't need to re-load your index if you just change the chat model.

You can switch the pipeline to Ollama models:
Note: only 1 Ollama embedding model is supported for embeddings now! You must select "nomic-embed-text" and if you do, set `embedding_dimension=0` (maximum dimension available)

```julia
update_pipeline!(:bronze; model_chat = "llama3", model_embedding="nomic-embed-text", embedding_dimension=0)

# You must download the corresponding knowledge packs via `load_index!` (because you changed the embedding model)
load_index!()
```
"""
function update_pipeline!(
        option::Symbol = :bronze; model_chat::Union{String, Nothing} = nothing,
        model_embedding::Union{String, Nothing} = nothing, verbose::Bool = true,
        embedding_dimension::Union{Integer, Nothing} = nothing)
    global RAG_CONFIGURATIONS, RAG_CONFIG, RAG_KWARGS, MODEL_CHAT, MODEL_EMBEDDING, EMBEDDING_DIMENSION, LOADED_CONFIG_KEY

    ## Set from globals if not provided
    model_chat = !isnothing(model_chat) ? model_chat : MODEL_CHAT
    model_embedding = !isnothing(model_embedding) ? model_embedding : MODEL_EMBEDDING
    ## Do not set embedding dimensions, we might need to extract it from kwargs

    ## WARN about limited support for nomic-embed-text -- we need to create repeatable process
    if model_embedding == "nomic-embed-text"
        @warn "Knowledge packs for `nomic-embed-text` are currently not built automatically, so they might be missing / outdated. Please switch to OpenAI `text-embedding-3-large` for the best experience."
    end

    @assert haskey(RAG_CONFIGURATIONS, option) "Invalid option: $option. Select one of: $(join(keys(RAG_CONFIGURATIONS),", "))"
    @assert (isnothing(embedding_dimension)||embedding_dimension in [0, 1024]) "Invalid embedding_dimension: $(embedding_dimension). Supported: 0 (no truncation) or 1024. See the available artifacts."
    ## Model-specific checks, they do not fail but at least warn
    if model_embedding == "nomic-embed-text" &&
       !(iszero(embedding_dimension) || isnothing(embedding_dimension))
        @warn "Invalid configuration for knowledge packs! For `nomic-embed-text`, `embedding_dimension` must be 0. See the available artifacts."
    end
    if model_embedding == "text-embedding-3-large" &&
       !(embedding_dimension in [1024, 0] || isnothing(embedding_dimension))
        @warn "Invalid configuration for knowledge packs! For `text-embedding-3-large`, `embedding_dimension` must be 0 or 1024. See the available artifacts."
    end

    config = RAG_CONFIGURATIONS[option][:config]
    kwargs = RAG_CONFIGURATIONS[option][:kwargs]
    # update models in kwargs to the ones requested
    kwargs = setpropertynested(
        kwargs, [:rephraser_kwargs, :tagger_kwargs, :answerer_kwargs, :refiner_kwargs],
        :model, model_chat
    )
    kwargs = setpropertynested(
        kwargs, [:embedder_kwargs],
        :model, model_embedding
    )
    ## change truncate_embeddings
    if !isnothing(embedding_dimension)
        kwargs = setpropertynested(
            kwargs, [:embedder_kwargs], :truncate_dimension, embedding_dimension)
    else
        ## load the value from defaults in config -- to match the artifacts
        val = getpropertynested(kwargs, [:embedder_kwargs], :truncate_dimension, nothing)
        embedding_dimension = isnothing(val) ? 0 : val
    end

    ## Update GLOBAL variables
    MODEL_CHAT = model_chat
    MODEL_EMBEDDING = model_embedding
    EMBEDDING_DIMENSION = embedding_dimension

    ## Set the options
    config_key = get_config_key(config, kwargs)
    ## detect significant changes
    !isempty(LOADED_CONFIG_KEY) && LOADED_CONFIG_KEY != config_key &&
        @warn "Core RAG pipeline configuration has changed! You must re-build your index with `AIHelpMe.load_index!()`!"
    LOADED_CONFIG_KEY = config_key
    RAG_KWARGS = kwargs
    RAG_CONFIG = config

    verbose &&
        @info "Updated RAG pipeline to `:$option` (Configuration key: \"$config_key\")."
    return nothing
end