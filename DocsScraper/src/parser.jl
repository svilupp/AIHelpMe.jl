"""
Working:

Since HTML structure is complex, we need to figure out when do we insert the extracted text in parsed_text 
ie., should we add the text of child hierarchy and then insert or should we insert now and let the child hierarchy make another insertion.  
For this we employ multiple checks. If the current node is heading, directly insert into parsed_text.
If the current node is a code block, return the text inside code block with backticks.
If the node is neither heading nor code, then we'll need to go deeper in the hierarchy. 
if the current node's tag is from the list [:p, :li, :dt, :dd, :pre, :b, :strong, :i, :cite, :address, :em, :td]
it is assumed that everything inside the tag is part of a single text block with inline code. 
But when we go deeper and if there is a code block with size > 50 chars, then our assumption was false. 
To correct this, we first insert the previously extracted text, next we insert the current code and additionally indicate the parent recursion iteration 
that the current iteration has inserted the previously parsed text, so there is no need for parent iteration to insert the text block again. 
We indicate this by a return flag is_text_inserted
"""



"""
    insert_parsed_data!(heading_hierarchy::Dict{Symbol,Any}, 
        parsed_text::Vector{Dict{String,Any}}, 
        text_to_insert::AbstractString, 
        text_type::AbstractString)
    
Insert the text into parsed_text Vector

# Arguments
- heading_hierarchy: Dict used to store metadata
- parsed_text: Vector of Dicts to store parsed text and metadata
- text_to_insert: Text to be inserted
- text_type: The text to be inserted could be heading or a code block or just text
"""
function insert_parsed_data!(heading_hierarchy::Dict{Symbol,Any},
    parsed_text::Vector{Dict{String,Any}},
    text_to_insert::AbstractString,
    text_type::AbstractString)

    if !isempty(strip(text_to_insert))
        push!(parsed_text,
            Dict(text_type => strip(text_to_insert),
                "metadata" => copy(heading_hierarchy)))
    end
end



"""
    process_headings!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_text::Vector{Dict{String,Any}})

Process headings. If the current node is heading, directly insert into parsed_text. 

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_text: Vector of Dicts to store parsed text and metadata
"""
function process_headings!(node::Gumbo.HTMLElement,
    heading_hierarchy::Dict{Symbol,Any},
    parsed_text::Vector{Dict{String,Any}})

    tag_name = Gumbo.tag(node)
    # Clear headings of equal or lower level
    for k in collect(keys(heading_hierarchy))
        if Base.parse(Int, last(string(k))) >= Base.parse(Int, last(string(tag_name)))
            delete!(heading_hierarchy, k)
        end
    end
    heading_hierarchy[tag_name] = strip(Gumbo.text(node))
    insert_parsed_data!(heading_hierarchy, parsed_text, Gumbo.text(node), "heading")

    is_code = false
    is_text_inserted = false
    return "", is_code, is_text_inserted
end

"""
    process_code(node::Gumbo.HTMLElement)

Process code snippets. If the current node is a code block, return the text inside code block with backticks.

# Arguments
- node: The root HTML node
"""
function process_code(node::Gumbo.HTMLElement)
    ## TODO: the function implicitly assumes julia, can be easily improved by checking the code CLASS attribute. 

    # Start a new code block
    if (Gumbo.tag(node.parent) == :pre)
        code_content = "```julia " * strip(Gumbo.text(node)) * "```"
    else
        code_content = "`" * strip(Gumbo.text(node)) * "`"
    end
    is_code = true
    is_text_inserted = false
    return code_content, is_code, is_text_inserted
end

"""
    process_generic_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_text::Vector{Dict{String,Any}},
        child_new::Bool=true,
        prev_text::AbstractString="")

If the node is neither heading nor code
        

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_text: Vector of Dicts to store parsed text and metadata
- child_new: Bool to specify if the current block (child) is part of previous block or not. 
                If it's not, then a new insertion needs to be created in parsed_text
- prev_text: String which contains previous text
"""
function process_generic_node!(node::Gumbo.HTMLElement,
    heading_hierarchy::Dict{Symbol,Any},
    parsed_text::Vector{Dict{String,Any}},
    child_new::Bool=true,
    prev_text::AbstractString="")

    ## TODO: replace prev_text with IOBuffer 

    tag_name = Gumbo.tag(node)
    text_to_insert = ""
    # Recursively process the child node for text content
    children = collect(AbstractTrees.children(node))
    num_children = length(children)
    is_code = false
    is_text_inserted = false

    for (index, child) in enumerate(children)
        # if the current tag belongs in the list, it is assumed that all the text/code should be part of a single paragraph/block, unless,
        # there occurs a code block with >50 chars, then, previously parsed text is inserted first, then the code block is inserted. 

        if tag_name in [:p, :li, :dt, :dd, :pre, :b, :strong, :i, :cite, :address, :em, :td]
            received_text, is_code, is_text_inserted = process_node!(child, heading_hierarchy, parsed_text, false, prev_text * " " * text_to_insert)
        else
            received_text, is_code, is_text_inserted = process_node!(child, heading_hierarchy, parsed_text, child_new, prev_text * " " * text_to_insert)
        end

        # changing text_to_insert to "" to avoid inserting text_to_insert again (as it was inserted by the child recursion call)
        if is_text_inserted
            text_to_insert = ""
            prev_text = ""
        end

        # to separate the code into separate blocks if the code is large and part of text on the webpage
        if !isempty(strip(received_text)) && is_code == true && length(received_text) > 50

            if (!isempty(strip(prev_text * " " * text_to_insert)))
                insert_parsed_data!(heading_hierarchy, parsed_text, prev_text * " " * text_to_insert, "text")
                text_to_insert = ""
                prev_text = ""
                is_text_inserted = true
            end
            insert_parsed_data!(heading_hierarchy, parsed_text, received_text, "code")
            is_code = false
            received_text = ""
        end

        # if the code block is last part of the loop then due to is_code::bool, whole text_to_insert becomes code 
        # (code is returned with backticks. If code is not inline and is supposed to be a separate block, 
        # then this case is handled earlier where size of code>50 )
        if index == num_children
            is_code = false
        end

        if !isempty(strip(received_text))
            # print(io, " " * received_text)
            text_to_insert = text_to_insert * " " * received_text
        end
    end

    # if child_new is false, this means new child (new entry in parsed_text) should not be created, hence, return the text.  
    if (child_new == false)
        return text_to_insert, is_code, is_text_inserted
    end

    # insert text_to_insert to parsed_text
    if !isempty(strip(text_to_insert))
        insert_parsed_data!(heading_hierarchy, parsed_text, prev_text, "text") # if we're insert text in current node level, then we should insert the previous text if available, otherwise it'll be inserted when the control goes back to the parent call and hence, order of the insertion will be weird
        is_text_inserted = true
        is_code ? insert_parsed_data!(heading_hierarchy, parsed_text, text_to_insert, "code") : insert_parsed_data!(heading_hierarchy, parsed_text, text_to_insert, "text")
    end
    return "", is_code, is_text_inserted
end


"""
    process_node!(node::Gumbo.HTMLElement,
        heading_hierarchy::Dict{Symbol,Any},
        parsed_text::Vector{Dict{String,Any}},
        child_new::Bool=true,
        prev_text::AbstractString="")

Function to process a node

# Arguments
- node: The root HTML node 
- heading_hierarchy: Dict used to store metadata
- parsed_text: Vector of Dicts to store parsed text and metadata
- child_new: Bool to specify if the current block (child) is part of previous block or not. 
                If it's not, then a new insertion needs to be created in parsed_text
- prev_text: String which contains previous text
"""
function process_node!(node::Gumbo.HTMLElement,
    heading_hierarchy::Dict{Symbol,Any},
    parsed_text::Vector{Dict{String,Any}},
    child_new::Bool=true,
    prev_text::AbstractString="")

    tag_name = Gumbo.tag(node)
    if startswith(string(tag_name), "h") && isdigit(last(string(tag_name)))
        return process_headings!(node, heading_hierarchy, parsed_text)
    end

    if tag_name == :code
        return process_code(node)
    end

    return process_generic_node!(node, heading_hierarchy, parsed_text, child_new, prev_text)

end


"""
multiple dispatch for process_node!() when node is of type Gumbo.HTMLText
"""
function process_node!(node::Gumbo.HTMLText, args...)
    is_code = false
    is_text_inserted = false
    return strip(Gumbo.text(node)), is_code, is_text_inserted
end