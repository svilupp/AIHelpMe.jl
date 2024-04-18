using AIHelpMe: RAG_CONFIGURATIONS, RAG_KWARGS, RAG_CONFIG, docextract, LAST_RESULT,
                last_result, MAIN_INDEX, MODEL_CHAT, MODEL_EMBEDDING, update_pipeline!
using PromptingTools: TestEchoOpenAISchema

@testset "aihelp" begin
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

    # remember prior settings
    current_index = MAIN_INDEX[]
    current_chat_model = MODEL_CHAT
    current_emb_model = MODEL_EMBEDDING
    current_dimensionality = getpropertynested(
        RAG_KWARGS[], [:embedder_kwargs], :truncate_dimension, nothing)

    ## Change for our test
    MAIN_INDEX[] = index
    update_pipeline!(:bronze; model_chat = "mockgen",
        model_embedding = "mockemb", truncate_dimension = 0)

    question = "ABC?"
    cfg = RAG_CONFIG[]
    kwargs = RAG_KWARGS[]
    ## Simple RAG pre-run
    msg = airag(cfg, index; question, kwargs...)
    @test msg.content == "new answer"

    ## run for a message
    msg = aihelp(cfg, index, question)
    @test msg.content == "new answer"
    @test LAST_RESULT[].final_answer == "new answer"

    ## run for result
    result = aihelp(cfg, index, question; return_all = true)
    @test result isa RT.RAGResult
    @test result.final_answer == "new answer"
    @test LAST_RESULT[] == result

    # short hand
    msg = aihelp(index, question)
    @test msg.content == "new answer"
    msg = aihelp(question)
    @test msg.content == "new answer"

    ## run macros
    ## msg = aihelp"test"
    ## @test msg.content == "new answer"
    ## msg = aihelp"test"mockgen
    ## @test msg.content == "new answer"
    ## msg = aihelp!"test"mockgen
    ## @test msg.content == "new answer"

    ## Return previous settings
    update_pipeline!(:bronze; model_chat = current_chat_model,
        model_embedding = current_emb_model, truncate_dimension = current_dimensionality)
    MAIN_INDEX[] = current_index
end