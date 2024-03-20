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
    process_node!(node, heading_hierarchy::Dict, parsed_text::Vector)

Process the node recursively. The function recursively calls itself for every HTML hierarchy, thereby going deeper to retrieve the text.

# Arguments
- `node`: The root HTML node 
- `args[1]`: heading_hierarchy - Dict used to store metadata
- `args[2]`: parsed_text - Vector of Dicts to store parsed text and metadata
- 

# TODO:
- Inline code blocks are the ones present inside <p> or <li>. put `` around the inline code blocks. Make changes inside `elseif tag_name == "p" || tag_name == "li"`
"""
function process_node!(node::Gumbo.HTMLElement, args...)
    heading_hierarchy = length(args) >= 1 ? args[1] : Dict{String, Any}()
    parsed_text = length(args) >= 2 ? args[2] : Vector{Dict{String, Any}}()

    tag_name = String(Gumbo.tag(node))
    # process headings. Working: If the current tag is a heading, then, we remove all the smaller headings we stored (for metadata) from  
    # heading_hierarchy dictionary and add the current heading tag
    # This is done because, in the heading hierarchy, if we come back to the current heading, 
    # then there is no need to store the smaller headings we encountered earlier
    if startswith(tag_name, "h") && isdigit(last(tag_name))
        # Clear headings of equal or lower level
        for k in collect(keys(heading_hierarchy))
            if Base.parse(Int, last(k)) >= Base.parse(Int, last(tag_name))
                delete!(heading_hierarchy, k)
            end
        end
        heading_hierarchy[tag_name] = strip(Gumbo.text(node))
        push!(parsed_text,
            Dict("heading" => strip(Gumbo.text(node)),
                "metadata" => copy(heading_hierarchy)))

        # if the current tag is <code>, then get it's textual value and store in the dictionary with key as "code"
    elseif tag_name == "code"
        # Start a new code block
        code_content = strip(Gumbo.text(node))
        push!(parsed_text,
            Dict("code" => code_content, "metadata" => copy(heading_hierarchy)))
        return ""

        # if the current tag is <p> or <li>, then store the text of the whole tag 
    elseif tag_name == "p" || tag_name == "li"
        return strip(Gumbo.text(node))

        # if it's any other tag, then recursively call process_node function to go deeper in HTML hierarchy
    else
        # Recursively process the child node for text content, appending text for code blocks differently
        for child in AbstractTrees.children(node)
            recieved_text = process_node!(child, heading_hierarchy, parsed_text)

            if !isempty(strip(recieved_text))
                push!(parsed_text,
                    Dict("text" => strip(recieved_text),
                        "metadata" => copy(heading_hierarchy)))
            end
        end
    end
    return ""
end

"""
multiple dispatch for process_node() when node is of type Gumbo.HTMLText
"""
function process_node!(
        node::Gumbo.HTMLText, args...)
    return strip(Gumbo.text(node))
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
    Dict{String, Any}("code" => "this is my code block", "metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "Heading 3", "h2" => "Heading 2"))
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "This is another h3 under Heading 2", "h2" => "Heading 2"), "heading" => "This is another h3 under Heading 2")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h3" => "This is another h3 under Heading 2", "h2" => "Heading 2"), "text" => "This is a paragraph with  inline code")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2_2"), "heading" => "Heading 2_2")
    Dict{String, Any}("metadata" => Dict{Any, Any}("h1" => "Heading 1", "h2" => "Heading 2_2"), "text" => "para ewg")
]

# TODO:
- Input should be Vector of URL strings to parse multiple URLs
- Use multithreading to simultaneously parse multiple URLs
"""
function parse_url(url::AbstractString)
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

    parsed_text = Vector{Dict{String, Any}}()
    heading_hierarchy = Dict{String, Any}()
    process_node!(content_, heading_hierarchy, parsed_text)
    return parsed_text
end
