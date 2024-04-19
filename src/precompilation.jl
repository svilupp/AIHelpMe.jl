## Mock run for aihelp
# remember prior settings
RAG_CONFIG[] = RT.RAGConfig(;
    indexer = RT.SimpleIndexer(; embedder = RT.BinaryBatchEmbedder()),
    retriever = RT.SimpleRetriever(;
        embedder = RT.BinaryBatchEmbedder(), reranker = RT.CohereReranker()))
RAG_KWARGS[] = (
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
        embedder_kwargs = (;
            truncate_dimension = EMBEDDING_DIMENSION,
            model = MODEL_EMBEDDING),
        refiner_kwargs = (;
            model = MODEL_CHAT)))

current_chat_model = MODEL_CHAT
current_emb_model = MODEL_EMBEDDING
current_dimensionality = EMBEDDING_DIMENSION

# corresponds to OpenAI API v1
response1 = Dict(:data => [Dict(:embedding => ones(128))],
    :usage => Dict(:total_tokens => 2, :prompt_tokens => 2, :completion_tokens => 0))
schema1 = TestEchoOpenAISchema(; response = response1, status = 200)
response2 = Dict(
    :choices => [
        Dict(:message => Dict(:content => "new answer"), :finish_reason => "stop")
    ],
    :usage => Dict(:total_tokens => 3,
        :prompt_tokens => 2,
        :completion_tokens => 1))
schema2 = TestEchoOpenAISchema(; response = response2, status = 200)

PT.register_model!(; name = "mockemb", schema = schema1)
PT.register_model!(; name = "mockgen", schema = schema2)

index = ChunkIndex(chunks = ["chunk1", "chunk2"],
    embeddings = ones(128, 2),
    tags = nothing,
    tags_vocab = nothing,
    sources = ["source1", "source2"])
MAIN_INDEX[] = index

## Change for our test
update_pipeline!(:bronze; model_chat = "mockgen",
    model_embedding = "mockemb", embedding_dimension = 0)

question = "ABC?"
cfg = RAG_CONFIG[]
kwargs = RAG_KWARGS[]
## Simple RAG pre-run
msg = airag(cfg, index; question, kwargs...)

## run for a message
msg = aihelp(cfg, index, question)

## run for result
result = aihelp(cfg, index, question; return_all = true)
pprint(result)

# short hand
msg = aihelp(index, question)
msg = aihelp(question)

## run macros
msg = aihelp"test"
msg = aihelp"test"mockgen
msg = aihelp!"test"

## Return previous settings -- not needed, it's only for precompilation
update_pipeline!(:bronze; model_chat = current_chat_model,
    model_embedding = current_emb_model, embedding_dimension = current_dimensionality)

###  Index loading
index = load_index!(:tidier)
index = load_index!([:tidier])
load_index!(index)
# Return to previous settings

### END OF PRECOMPILE
