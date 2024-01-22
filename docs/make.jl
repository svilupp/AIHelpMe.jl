using AIHelpMe
using Documenter

DocMeta.setdocmeta!(AIHelpMe, :DocTestSetup, :(using AIHelpMe); recursive = true)

makedocs(;
    modules = [AIHelpMe],
    authors = "J S <49557684+svilupp@users.noreply.github.com> and contributors",
    sitename = "AIHelpMe.jl",
    format = Documenter.HTML(;
        canonical = "https://svilupp.github.io/AIHelpMe.jl",
        edit_link = "main",
        assets = String[],),
    pages = [
        "Home" => "index.md",
    ],)

deploydocs(;
    repo = "github.com/svilupp/AIHelpMe.jl",
    devbranch = "main",)
