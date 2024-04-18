using AIHelpMe
using Documenter

DocMeta.setdocmeta!(AIHelpMe, :DocTestSetup, :(using AIHelpMe); recursive = true)

makedocs(;
    modules = [AIHelpMe],
    authors = "J S <49557684+svilupp@users.noreply.github.com> and contributors",
    repo = "https://github.com/svilupp/AIHelpMe.jl/blob/{commit}{path}#{line}",
    sitename = "AIHelpMe.jl",
    ## format = Documenter.HTML(;
    ##     repolink = "https://github.com/svilupp/AIHelpMe.jl",
    ##     canonical = "https://svilupp.github.io/AIHelpMe.jl",
    ##     edit_link = "main",
    ##     assets = String[]),
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "https://github.com/svilupp/AIHelpMe.jl",
        devbranch = "main",
        devurl = "dev",
        deploy_url = "svilupp.github.io/AIHelpMe.jl"
    ),
    draft = false,
    source = "src",
    build = "build",
    pages = [
        "Home" => "index.md",
        "Introduction" => "introduction.md",
        "Advanced" => "advanced.md",
        "F.A.Q" => "faq.md",
        "Reference" => "reference.md"
    ])

deploydocs(;
    repo = "github.com/svilupp/AIHelpMe.jl",
    target = "build",
    push_preview = true,
    branch = "gh-pages",
    devbranch = "main")
