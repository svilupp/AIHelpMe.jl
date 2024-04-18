using AIHelpMe: docextract

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
