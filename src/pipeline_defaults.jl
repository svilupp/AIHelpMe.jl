### Global for history, replies, etc
const CONV_HISTORY = Vector{Vector{PT.AbstractMessage}}()
const CONV_HISTORY_LOCK = ReentrantLock()
const MAX_HISTORY_LENGTH = 1
const LAST_RESULT = Ref{Union{Nothing, RT.AbstractRAGResult}}(nothing)
const MAIN_INDEX = Ref{Union{Nothing, RT.AbstractChunkIndex}}(nothing)
"""
    ALLOWED PACKS

Currently available packs are:
- `:julia` - Julia documentation, standard library docstrings and a few extras (for Julia v1.10)
- `:tidier` - Tidier.jl organization documentation (as of 7th April 2024)
- `:makie` - Makie.jl organization documentation and a few extras (as of 30th March 2024)
"""
const ALLOWED_PACKS = [:julia, :tidier, :makie]

### Globals for configuration
# These serve as reference models to be injected in the absence of inputs, 
# but the actual used for the query is primarily provided aihelpme directly or via the active RAG_KWARGS
const MODEL_CHAT = "gpt4t"
const MODEL_EMBEDDING = "text-embedding-3-large"

# Loaded up with `update_pipeline!` later once RAG CONFIGURATIONS is populated
const RAG_KWARGS = Ref{NamedTuple}()
const RAG_CONFIG = Ref{RT.AbstractRAGConfig}()
const LOADED_CONFIG_KEY = Ref{String}("")  # get the current config key

"""
    RAG_CONFIGURATIONS

A dictionary of RAG configurations, keyed by a unique symbol (eg, `bronze`).
Each entry contains a dictionary with keys `:config` and `:kwargs`,
where `:config` is the RAG configuration object (`AbstractRAGConfig`) and `:kwargs` the NamedTuple of corresponding kwargs.

Available Options:
- `:bronze`: A simple configuration for a bronze pipeline, using truncated binary embeddings (dimensionality: 1024) and no re-ranking or refinement.
- `:silver`: A simple configuration for a bronze pipeline, using truncated binary embeddings (dimensionality: 1024) but also enables re-ranking and refinement with a web-search.
- `:gold`: A more complex configuration, similar to `:simpler`, but using a standard embeddings (dimensionality: 3072, type: Float32). It also leverages re-ranking and refinement with a web-search.
"""
const RAG_CONFIGURATIONS = let MODEL_CHAT = MODEL_CHAT, MODEL_EMBEDDING = MODEL_EMBEDDING
    RAG_CONFIGURATIONS = Dict{Symbol, Dict{Symbol, Any}}()
    ## Bronze
    RAG_CONFIGURATIONS[:bronze] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
            retriever = RT.SimpleRetriever(; embedder = RT.BinaryBatchEmbedder())),
        :kwargs => (
            retriever_kwargs = (;
                top_k = 100,
                top_n = 5,
                rephraser_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = 1024,
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = 1024,
                    model = MODEL_EMBEDDING),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))
    ## Silver - reranking + web-search
    RAG_CONFIGURATIONS[:silver] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
            retriever = RT.SimpleRetriever(;
                embedder = RT.BinaryBatchEmbedder(), reranker = RT.CohereReranker()),
            generator = RT.SimpleGenerator(; refiner = RT.TavilySearchRefiner())),
        :kwargs => (
            retriever_kwargs = (;
                top_k = 100,
                top_n = 5,
                rephraser_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = 1024,
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    truncate_dimension = 1024,
                    model = MODEL_EMBEDDING),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))
    ## Gold  - reranking + web-search
    RAG_CONFIGURATIONS[:gold] = Dict{Symbol, Any}(
        :config => RT.RAGConfig(;
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
                    model = MODEL_EMBEDDING),
                tagger_kwargs = (;
                    model = MODEL_CHAT)),
            generator_kwargs = (;
                answerer_kwargs = (;
                    model = MODEL_CHAT),
                embedder_kwargs = (;
                    model = MODEL_EMBEDDING),
                refiner_kwargs = (;
                    model = MODEL_CHAT))))

    RAG_CONFIGURATIONS
end

"Returns the configuration key for the given `cfg` and `kwargs` to use the relevant artifacts."
function get_config_key(cfg::AbstractRAGConfig, kwargs::NamedTuple)
    emb_model = getpropertynested(kwargs, [:embedder_kwargs], :model)
    emb_dim = getpropertynested(kwargs, [:embedder_kwargs], :truncate_dimension, 0)
    emb_eltype = RT.EmbedderEltype(cfg.retriever.embedder)
    string(replace(emb_model, "-" => ""), "-",
        emb_dim, "-", emb_eltype)
end

"""
    update_pipeline!(option::Symbol = :bronze; model_chat = MODEL_CHAT,
        model_embedding = MODEL_EMBEDDING)

Updates the default RAG pipeline to one of the pre-configuration options and sets the requested chat and embedding models.

This is a good way to update model types to change between OpenAI models and Ollama models.

See available pipeline options via `keys(RAG_CONFIGURATIONS)`.

Logic:
- Updates the global `MODEL_CHAT` and `MODEL_EMBEDDING` to the requested models.
- Updates the global `RAG_CONFIG` and `RAG_KWARGS` to the requested `option`.
- Updates the global `LOADED_CONFIG_KEY` to the configuration key for the given `option` and `kwargs` (used by the artifact system to download the correct knowledge packs).

# Example
```julia
update_pipeline!(:bronze; model_chat = "gpt4t")
```
You don't need to re-load your index if you just change the chat model.

You can switch the pipeline to Ollama models:
Note: only 1 Ollama model is supported for embeddings now! You must select "nomic-embed-text"!
```julia
update_pipeline!(:bronze; model_chat = "mistral:7b-instruct-v0.2-q4_K_M",model_embedding="nomic-embed-text)

# You must download the corresponding knowledge packs via `load_index!` (because you changed the embedding model)
load_index!(:julia) # or whichever other packs you want!
```
"""
function update_pipeline!(option::Symbol = :bronze; model_chat = MODEL_CHAT,
        model_embedding = MODEL_EMBEDDING, verbose::Bool = true)
    global RAG_CONFIGURATIONS, RAG_CONFIG, RAG_KWARGS, MODEL_CHAT, MODEL_EMBEDDING, LOADED_CONFIG_KEY
    @assert haskey(RAG_CONFIGURATIONS, option) "Invalid option: $option. Select one of: $(join(keys(RAG_CONFIGURATIONS),", "))"

    ## Update model references
    MODEL_CHAT = model_chat
    MODEL_EMBEDDING = model_embedding

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

    ## Set the options
    config_key = get_config_key(config, kwargs)
    ## detect significant changes
    !isempty(LOADED_CONFIG_KEY[]) && LOADED_CONFIG_KEY[] != config_key &&
        @warn "Core RAG pipeline configuration has changed! You must re-build your index with `AIHelpMe.load_index!()`!"
    LOADED_CONFIG_KEY[] = config_key
    RAG_KWARGS[] = kwargs
    RAG_CONFIG[] = config

    verbose &&
        @info "Updated RAG pipeline to `:$option` (Configuration key: \"$config_key\")."
    return nothing
end