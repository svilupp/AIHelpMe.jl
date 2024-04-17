using AIHelpMe
using Test
using Aqua

@testset "Code quality (Aqua.jl)" begin
    ## disable piracy check -- we're pirating PT repository - build_index() which is not exported
    Aqua.test_all(AIHelpMe; piracy = false)
end

@testset "AIHelpMe.jl" begin
    include("generation.jl")
end
