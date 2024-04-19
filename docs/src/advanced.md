# Advanced

## Using Ollama Models

AIHelpMe can use Ollama (locally-hosted) models, but the knowledge packs are available for only one embedding model: "nomic-embed-text"!

You must set `model_embedding="nomic-embed-text"` and `embedding_dimension=0` (maximum dimension available) for everything to work correctly!

Example:

```julia
using PromptingTools: register_model!, OllamaSchema
using AIHelpMe: update_pipeline!, load_index!

# register model names with the Ollama schema - if needed!
# eg, register_model!(; name="mistral:7b-instruct-v0.2-q4_K_M",schema=OllamaSchema())

# you can use whichever chat model you like! Llama 3 8b is the best trade-of right now and it's already known to PromptingTools.
update_pipeline!(:bronze; model_chat = "llama3",model_embedding="nomic-embed-text", embedding_dimension=0)


# You must download the corresponding knowledge packs via `load_index!` (because you changed the embedding model)
load_index!()
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

You can use the Preference setting mechanism (`?PREFERENCES`) to change the default settings.
```julia
AIHelpMe.set_preferences!("MODEL_CHAT" => "llama3", "MODEL_EMBEDDING" => "nomic-embed-text", "EMBEDDING_DIMENSION" => 0)
```

## Code Execution

Use `AICode` on the generated answers.

For example:
```julia
using PromptingTools.Experimental.AgentTools: AICode

msg = aihelp"Write a code to sum up 1+1"
cb = AICode(msg)
# Output: AICode(Success: True, Parsed: True, Evaluated: True, Error Caught: N/A, StdOut: True, Code: 1 Lines)
```

If you want to access the extracted code, simply use `cb.code`. If there is an error, you can see it in `cb.error`.

See the docstrings to learn more about it!

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

## Save Your Preferences

You can now leverage the amazing Preferences.jl mechanism to save your default choices of the chat model, embedding model, embedding dimension, and which knowledge packs to load on start.

For example, if you wanted to switch to Ollama-based pipeline, you could persist the configuration with:

```julia
AIHelpMe.set_preferences!("MODEL_CHAT" => "llama3", "MODEL_EMBEDDING" => "nomic-embed-text", "EMBEDDING_DIMENSION" => 0)
```
This will create a file `LocalPreferences.toml` in your project directory that will remember these choices across sessions.

See `AIHelpMe.PREFERENCES` for more details.

## Debugging Poor Answers

We're using a Retrieval-Augmented Generation (RAG) pipeline, which consists of two major steps:

1. Generate a "context" snippet from the question and the current context.
2. Generate an "answer" from the context.
3. (Optional) Generate a refined answer (only some pipelines will have this).

If you're not getting good answers / the answers you would expect, you need to understand if the problem is in step 1 or step 2.

First, get the `RAGResult` (the full detail of the pipeline and its intermediate steps):
```julia
using AIHelpMe: pprint, last_result

# This will help you access how was the last answer generated
result = last_result()

# You can pretty-print the result
pprint(result)
```

**Checking the Context**
Check the `result.context` - is it using the right snippets ("knowledge") from the knowledge packs?
Alternatively, you can add it directly to the pretty-printed answer:
```julia
pprint(result; add_context=true, add_scores=false)
```

How is the context produced? 

It's a function of your pipeline setting (see below) and the knowledge packs loaded (`AIHelpMe.LOADED_PACKS`).

A quick way to diagnose the context pipeline:

- See a quick overview of the embedding configuration with `AIHelpMe.get_config_key()` (it captures the embedding model, dimension, and element type).
- See the pipeline configuration (which steps) with `AIHelpMe.RAG_CONFIG[]`.
- See the individual kwargs provided to the pipeline with `AIHelpMe.RAG_KWARGS[]`.

The simplest fix for "poor" context is to enable reranking (`rerank=true`).

Other angles to consider:
- Are you sure if the source information is present in the knowledge pack? Can it be added (see `?update_index`)?
- Was the question phrased poorly? Can we ask the same in a more sensible way?
- Try different models, dimensions, element types (Bool is less precise than Float32, etc.)

**Checking the First Answer**

Check the original answer (`result.answer`) - is it correct?

Assuming the context was good, but the answer is not we need to find out if it's because of the model or because of the prompt template.
- Is it that you're using a weak chat model? Try different models. Does it improve?
- Is the prompt template not suitable for your questions? Experiment with tweaking the prompt template.

**Checking the Refined Answer**

You always see the final answer by default (`result.final_answer`). 
Is it different from `result.answer`? That means the `refiner` step in the RAG pipeline has been used. 

Debug it in the same way as the first answer. 
- Is it the context provided to the refiner? 
- Is it the answer from the refiner? If yes, is it because of the model? Or because of the prompt template?

## Help Us Improve and Debug

It would be incredibly helpful if you could share examples when the RAG pipeline fails.
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
