using AIHelpMe
using Documenter

DocMeta.setdocmeta!(AIHelpMe, :DocTestSetup, :(using AIHelpMe); recursive = true)

makedocs(;
    modules = [AIHelpMe],
    authors = "J S <49557684+svilupp@users.noreply.github.com> and contributors",
    sitename = "AIHelpMe.jl",
    format = Documenter.HTML(;
        repolink = "https://github.com/svilupp/AIHelpMe.jl",
        canonical = "https://svilupp.github.io/PromptingTools.jl",
        edit_link = "main",
        assets = String[],),
    pages = [
        "Home" => "index.md",
        "F.A.Q" => "faq.md",
        "Reference" => "reference.md",
    ],)

deploydocs(;
    repo = "github.com/svilupp/AIHelpMe.jl",
    devbranch = "main",)
