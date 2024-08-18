using AIHelpMe: get_config_key, MODEL_CHAT, MODEL_EMBEDDING, update_pipeline!,
                RAG_CONFIGURATIONS, RAG_CONFIG, RAG_KWARGS

@testset "get_config_key" begin
    cfg = RT.RAGConfig()
    kwargs = RAG_CONFIGURATIONS[:bronze][:kwargs]
    @test get_config_key(cfg, kwargs) == "textembedding3large-0-Float32"

    ## change kwargs
    cfg.retriever.embedder = RT.BinaryBatchEmbedder()
    kwargs2 = setpropertynested(
        kwargs, [:embedder_kwargs],
        :model, "mock-emb"
    )
    kwargs2 = setpropertynested(
        kwargs2, [:embedder_kwargs],
        :truncate_dimension, 100
    )
    @test get_config_key(cfg, kwargs2) == "mockemb-100-Bool"
    @test get_config_key() == get_config_key(RAG_CONFIG, RAG_KWARGS)
end

@testset "update_pipeline!" begin
    # remember prior settings
    current_chat_model = MODEL_CHAT
    current_emb_model = MODEL_EMBEDDING

    update_pipeline!(:silver; model_chat = "A", model_embedding = "B")
    @test MODEL_CHAT == "A"
    @test MODEL_EMBEDDING == "B"
    # return back to original
    update_pipeline!(
        :bronze; model_chat = current_chat_model, model_embedding = current_emb_model)
    @test MODEL_CHAT == current_chat_model
    @test MODEL_EMBEDDING == current_emb_model
end