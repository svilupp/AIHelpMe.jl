# Advanced

## Using Ollama Models
AIHelpMe can use Ollama models (locally-hosted models), but the knowledge packs are available for only one embedding model: "nomic-embed-text"!

You must set `model_embedding="nomic-embed-text"` and `truncate_dimension=0` (maximum dimension available) for everything to work correctly!

Example:

```julia
using PromptingTools: register_model!, OllamaSchema
using AIHelpMe: update_pipeline!, load_index!

# register model names with the Ollama schema
register_model!(; name="mistral:7b-instruct-v0.2-q4_K_M",schema=OllamaSchema())
register_model!(; name="nomic-embed-text",schema=OllamaSchema())

# you can use whichever chat model you like!
update_pipeline!(:bronze; model_chat = "mistral:7b-instruct-v0.2-q4_K_M",model_embedding="nomic-embed-text", truncate_dimension=0)


# You must download the corresponding knowledge packs via `load_index!` (because you changed the embedding model)
load_index!(:julia) # or whichever other packs you want!
```

Let's ask a question:

```julia
aihelp"How to create a named tuple?"
```

```plaintext
[ Info: Done with RAG. Total cost: \$0.0
PromptingTools.AIMessage("In Julia, you can create a named tuple by enclosing key-value pairs in parentheses with the keys as symbols preceded by a colon, separated by commas. For example:
...continues
```


## Extending the Knowledge Base

The package by default ships with pre-processed embeddings for all Julia standard libraries, DataFrames and PromptingTools.
Thanks to the amazing Julia Artifacts system, these embeddings are downloaded/cached/loaded every time the package starts.

Note: The below functions are not yet exported. Prefix them with `AIHelpMe.` to use them.

### Building and Updating Indexes
AIHelpMe allows users to enhance its capabilities by embedding documentation from any loaded Julia module. 
Utilize `new_index = build_index(module)` to create an index for a specific module (or a vector of modules). 

To update an existing index, including newly imported packages, use `new index = update_index(module)` or simply `update_index()` to include all unrecognized modules. We will add and embed only the new documentation to avoid unnecessary duplication and cost.

### Managing Indexes
Once an index is built or updated, you can choose to serialize it for later use or set it as the primary index. 

To use your newly created index as the main source for queries, execute `load_index!(new_index)`. Alternatively, load a pre-existing index from a file using `load_index!(file_path)`. 

The main index for queries is held in the global variable `AIHelpMe.MAIN_INDEX[]`.


## Help Us Improve and Debug

It would be incredibly helpful if you could share examples when the pipeline fails.
We're particularly interested in cases where the answer you get is wrong because of the "bad" context provided.

Let's say you ran a question and got a wrong answer (or some other aspect is worth reporting).
```julia
aihelp"how to create tuples in julia?"
# Bad answer somehow...
```

You can access the underlying pipeline internals (what context was used etc.)

```julia
# last result (debugging object RAGResult)
result=AIHelpMe.last_result()

# If you want to see the actual context snippets, use `add_context=true`
AIHelpMe.pprint(result)

# Or access the fields in RAGResult directly, eg,
result.context
```

Let's save this result for debugging later into JSON.
```julia
using AIHelpMe.PromptingTools: JSON3
config_key = AIHelpMe.get_config_key() # "nomicembedtext-0-Bool"
JSON3.write("rag-makie-xyzyzyz-$(config_key)-20240419.json", result)
```

Now, you want to let us know. Please share the above JSON with a few notes of what you expected/what is wrong via a Github Issue or on Slack (`#generative-ai` channel)!
