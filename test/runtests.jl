using AIHelpMe
using PromptingTools
using PromptingTools.Experimental.RAGTools
const PT = PromptingTools
const RT = PromptingTools.Experimental.RAGTools
using PromptingTools: HTTP, JSON3
using HDF5, Serialization
using Test
using Aqua

@testset "Code quality (Aqua.jl)" begin
    ## disable piracy check -- we're pirating PT repository - build_index() which is not exported
    Aqua.test_all(AIHelpMe; piracy = false)
end

@testset "AIHelpMe.jl" begin
    include("utils.jl")
    include("preparation.jl")
    include("pipeline_defaults.jl")
    include("generation.jl")
end
