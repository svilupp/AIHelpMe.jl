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

Working:
Since HTMML structure is complex, we need to figure out when do we insert the extracted text in `parsed_text` 
ie., should we add the text of child hierarchy and then insert or should we insert now and let the child hierarchy make another insertion.  
For this we employ multiple checks. If the current node is heading, directly insert into `parsed_text`. 
If the current node is a code block, return the text inside code block with backticks. 
If the node is neither heading nor code, then we'll need to go deeper in the hierarchy. 
if the curretnt node is anything from the list ["p", "li", "dt", "dd", "pre", "b", "strong", "i", "cite", "address", "em", "td"]
it is assumed that everything inside the tag is part of a single text block with inline code. 
But when we go deeper and if there is a code block with size > 50 chars, then our assumption was false. 
To correct this, we first insert the previously extracted text, next we insert the current code and additionally indicate the parent recursion iteration 
that the current iteration has inserted the previously parsed text, so there is no need for parent iteration to insert the text block again. 
We indicate this by a return flag `is_text_inserted`

# Arguments
- `node`: The root HTML node 
- `args[1]`: heading_hierarchy - Dict used to store metadata
- `args[2]`: parsed_text - Vector of Dicts to store parsed text and metadata
- `args[3]`: child_new - Bool to specify if the current block (child) is part of previous block or not. 
                        If it's not, then a new insertion needs to be created in parsed_text
- `args[4]`: prev_text - String which contains previous text
"""
function process_node!(node::Gumbo.HTMLElement, args...)
    heading_hierarchy = length(args) >= 1 ? args[1] : Dict{String,Any}()
    parsed_text = length(args) >= 2 ? args[2] : Vector{Dict{String,Any}}()
    child_new = length(args) >= 3 ? args[3] : true
    prev_text = length(args) >= 4 ? args[4] : ""

    tag_name = String(Gumbo.tag(node))

    ## return statements
    # `is_code` specifies if the block is code or not
    is_code = false

    # `is_text_inserted` is a flag which specifies if the text is inserted in the subsequent recursion iteration. 
    is_text_inserted = false

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
        return "", is_code, is_text_inserted

        # if the current tag is <code>, then get it's textual value and return it with backticks (``)
    elseif tag_name == "code"
        # Start a new code block
        code_content = "`" * strip(Gumbo.text(node)) * "`"
        is_code = true
        return code_content, is_code, is_text_inserted
    else
        text_to_insert = ""

        # Recursively process the child node for text content
        children = collect(AbstractTrees.children(node))
        num_children = length(children)

        for (index, child) in enumerate(children)

            # if the current tag belongs in the list, it is assumed that all the text/code should be part of a single paragraph/block, unless,
            # there occurs a code block with >50 chars, then, previously parsed text is inserted first, then the code block is inserted. 
            if tag_name in ["p", "li", "dt", "dd", "pre", "b", "strong", "i", "cite", "address", "em", "td"]
                recieved_text, is_code, is_text_inserted = process_node!(child, heading_hierarchy, parsed_text, false, prev_text * " " * text_to_insert)
            else
                recieved_text, is_code, is_text_inserted = process_node!(child, heading_hierarchy, parsed_text, child_new, prev_text * " " * text_to_insert)
            end

            # changing `text_to_insert` to "" to avoid inserting `text_to_insert` again (as it was inserted by the child recursion call)
            if is_text_inserted
                text_to_insert = ""
                prev_text = ""
            end

            # to separate the code into serparate blocks if the code is large and part of text on the webpage
            if !isempty(strip(recieved_text)) && is_code == true && length(recieved_text) > 50

                if (!isempty(strip(prev_text * " " * text_to_insert)))
                    push!(parsed_text,
                        Dict("text" => strip(prev_text * " " * text_to_insert),
                            "metadata" => copy(heading_hierarchy)))
                    text_to_insert = ""
                    prev_text = ""
                    is_text_inserted = true
                end

                push!(parsed_text,
                    Dict("code" => strip(recieved_text),
                        "metadata" => copy(heading_hierarchy)))
                is_code = false
                recieved_text = ""
            end

            # if the code block is last part of the loop then due to is_code::bool, whole text_to_insert becomes code 
            # (code is returned with backticks. If code is not inline and is supposed to be a separate block, 
            # then this case is handled earlier where size of code>50 )
            if index == num_children
                is_code = false
            end

            if !isempty(strip(recieved_text))
                text_to_insert = text_to_insert * " " * recieved_text
            end
        end

        # if `child_new` is false, this means new child (new entry in `parsed_text`) should not be created, hence, return the text.  
        if (child_new == false)
            return text_to_insert, is_code, is_text_inserted
        end

        # insert `text_to_insert` to `parsed_text`
        if !isempty(strip(text_to_insert))
            if is_code == true
                push!(parsed_text,
                    Dict("code" => strip(text_to_insert),
                        "metadata" => copy(heading_hierarchy)))
            else
                push!(parsed_text,
                    Dict("text" => strip(text_to_insert),
                        "metadata" => copy(heading_hierarchy)))
            end
        end

    end
    return "", is_code, is_text_inserted
end

"""
multiple dispatch for process_node() when node is of type Gumbo.HTMLText
"""
function process_node!(
    node::Gumbo.HTMLText, args...)
    is_code = false
    is_text_inserted = false
    return strip(Gumbo.text(node)), is_code, is_text_inserted
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

    parsed_text = Vector{Dict{String,Any}}()
    heading_hierarchy = Dict{String,Any}()
    process_node!(content_, heading_hierarchy, parsed_text)
    return parsed_text
end
