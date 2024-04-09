include("parser.jl")
# using Gumbo: tag

"""
    get_base_url(url::AbstractString)

Extracts the base url.

# Arguments
- `url`: The url string of which, the base url needs to be extracted
"""
function get_base_url(url::AbstractString)
    parsed_url = URIs.URI(url)
    base_url = string(parsed_url.scheme, "://", parsed_url.host,
        parsed_url.port != nothing ? ":" * string(parsed_url.port) : "", parsed_url.path)
    return base_url
end


"""
    parse_url(url::AbstractString)

Initiator and main function to parse HTML from url

# Arguments
- `url`: URL string to parse

# Returns
- A Vector of Dict containing Heading/Text/Code along with a Dict of respective metadata

# Usage
parsed_text = parse_url("https://docs.julialang.org/en/v1/base/multi-threading/")

# Example
Let the HTML be:
<!DOCTYPE html>
    <html>
    <body>

    <h1>Heading 1</h1>
        <h2>Heading 2</h2>
            <p>para 1</p>
            <h3>Heading 3</h3>
                <code>this is my code block</code>
            <h3>This is another h3 under Heading 2</h3>
                <p>This is a paragraph with <code>inline code</code></p>

        <h2>Heading 2_2</h2>
            <p>para ewg</p>

    </body>
    </html>

Output: 
Any[
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1"), "heading" => "Heading 1")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2"), "heading" => "Heading 2")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2"), "text" => "para 1")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "Heading 3", "h2" => "Heading 2"), "heading" => "Heading 3")
    Dict{String, Any}("code" => "```julia this is my code block```", "metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "Heading 3", "h2" => "Heading 2"))
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "This is another h3 under Heading 2", "h2" => "Heading 2"), "heading" => "This is another h3 under Heading 2")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "This is another h3 under Heading 2", "h2" => "Heading 2"), "text" => "This is a paragraph with  inline code")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2_2"), "heading" => "Heading 2_2")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2_2"), "text" => "para ewg")
]
"""
function parse_url(url::AbstractString)

    ## TODO: Input should be Vector of URL strings to parse multiple URLs
    base_url = get_base_url(url)
    r = HTTP.get(base_url)
    r_parsed = parsehtml(String(r.body))

    # Getting title of the document 
    # title = [el
    #          for el in AbstractTrees.PreOrderDFS(r_parsed.root)
    #          if el isa HTMLElement && tag(el) == :title] .|> text |> Base.Fix2(join, " / ")

    content_ = [el
                for el in AbstractTrees.PreOrderDFS(r_parsed.root)
                if el isa HTMLElement && getattr(el, "class", nothing) == "content"] |> only

    parsed_text = Vector{Dict{String,Any}}()
    heading_hierarchy = Dict{Symbol,Any}()

    process_node!(content_, heading_hierarchy, parsed_text)
    return parsed_text
end
