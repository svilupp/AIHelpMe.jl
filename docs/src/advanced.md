# Advanced

To be updated...

## Using Ollama models
AIHelpMe can use Ollama models, but the knowledge packs are available for only one embedding model: "nomic-embed-text"!

You must set `model_embedding="nomic-embed-text"` and `truncate_dimension=0` (maximum dimension available) for everything to work correctly!

Example:

```julia
update_pipeline!(:bronze; model_chat = "mistral:7b-instruct-v0.2-q4_K_M",model_embedding="nomic-embed-text", truncate_dimension=0)

# You must download the corresponding knowledge packs via `load_index!` (because you changed the embedding model)
load_index!(:julia) # or whichever other packs you want!
```

Let's ask a question:

```julia
aihelp"How to create a named tuple?"
```

```plaintext

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

The main index for queries is held in the global variable `AIHelpMe.MAIN_INDEX`.
