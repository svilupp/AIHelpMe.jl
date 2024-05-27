using AIHelpMe: docextract, build_index

# create an empty module
module ABC123
# empty module
end
# create an empty module with a function
module ABC1234
export f
"some text"
f() = nothing
end

@testset "docextract" begin
    all_docs, all_sources = docextract(ABC123)
    @test length(all_docs) == 1
    @test occursin("No docstring or readme file found", all_docs[1])
    @test length(all_sources) == 1
    @test occursin("ABC123", all_sources[1])

    all_docs, all_sources = docextract([ABC1234])
    @test length(all_docs) == 2
    @test occursin("some text", all_docs[2])
    @test length(all_sources) == 2
    @test occursin("ABC1234", all_sources[2])
end

@testset "build_index" begin
    # test with a mock server
    PORT = rand(9000:31000)
    PT.register_model!(; name = "mock-emb", schema = PT.CustomOpenAISchema())
    PT.register_model!(; name = "mock-meta", schema = PT.CustomOpenAISchema())
    PT.register_model!(; name = "mock-gen", schema = PT.CustomOpenAISchema())

    echo_server = HTTP.serve!(PORT; verbose = -1) do req
        content = JSON3.read(req.body)

        if content[:model] == "mock-gen"
            user_msg = last(content[:messages])
            response = Dict(
                :choices => [
                    Dict(:message => user_msg, :finish_reason => "stop")
                ],
                :model => content[:model],
                :usage => Dict(:total_tokens => length(user_msg[:content]),
                    :prompt_tokens => length(user_msg[:content]),
                    :completion_tokens => 0))
        elseif content[:model] == "mock-emb"
            response = Dict(
                :data => [Dict(:embedding => ones(Float32, 1536))
                          for i in 1:length(content[:input])],
                :usage => Dict(:total_tokens => length(content[:input]),
                    :prompt_tokens => length(content[:input]),
                    :completion_tokens => 0))
        elseif content[:model] == "mock-meta"
            user_msg = last(content[:messages])
            response = Dict(
                :choices => [
                    Dict(:finish_reason => "stop",
                    :message => Dict(:tool_calls => [
                        Dict(:function => Dict(:arguments => JSON3.write(MaybeTags([
                        Tag("yes", "category")
                    ]))))]))],
                :model => content[:model],
                :usage => Dict(:total_tokens => length(user_msg[:content]),
                    :prompt_tokens => length(user_msg[:content]),
                    :completion_tokens => 0))
        else
            @info content
        end
        return HTTP.Response(200, JSON3.write(response))
    end

    # One module
    index = build_index(AIHelpMe; verbose = 2, embedder_kwargs = (; model = "mock-emb"),
        tagger_kwargs = (; model = "mock-meta"), api_kwargs = (;
            url = "http://localhost:$(PORT)"))
    @test index.embeddings == ones(Bool, 1024, length(index.chunks))
    @test all(x -> occursin("AIHelpMe", x), index.sources)
    @test index.tags == nothing
    @test index.tags_vocab == nothing

    # Many modules
    index = build_index(
        [AIHelpMe, Test]; verbose = 2, embedder_kwargs = (; model = "mock-emb"),
        tagger_kwargs = (; model = "mock-meta"), api_kwargs = (;
            url = "http://localhost:$(PORT)"))
    @test index.embeddings == ones(Bool, 1024, length(index.chunks))
    @test all(x -> occursin("AIHelpMe", x) || occursin("Test", x), index.sources)
    @test index.tags == nothing
    @test index.tags_vocab == nothing

    # clean up
    close(echo_server)
end