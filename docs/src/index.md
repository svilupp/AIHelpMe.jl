```@meta
CurrentModule = AIHelpMe
```

# AIHelpMe: "AI-Enhanced Coding Assistance for Julia"

Documentation for [AIHelpMe](https://github.com/svilupp/AIHelpMe.jl).

AIHelpMe harnesses the power of Julia's extensive documentation and advanced AI models to provide tailored coding guidance. By integrating with PromptingTools.jl, it offers a unique, AI-assisted approach to answering your coding queries directly in Julia's environment.

Note: This is only a proof-of-concept. If there is enough interest, we will fine-tune the RAG pipeline for better performance.

## Features

- **AI-Powered Assistance**: Get context-aware answers to your coding questions.
- **Easy-to-Use Interface**: Simple function and macro to input your questions.
- **Flexible Querying**: Use different AI models for varied insights and performance versus cost trade-offs.
- **Cost-Effective**: Download pre-embedded documentation to save on API calls.
- **Uniquely Tailored**: Leverage the currently loaded documentation, regardless of whether it's private or public.

## Installation

To install AIHelpMe, use the Julia package manager and the address of the repository (it's not yet registered):

```julia
using Pkg
Pkg.add(url="https://github.com/svilupp/AIHelpMe.jl")
```

**Prerequisites:**

- Julia (version 1.10 or later).
- Internet connection for API access.
- OpenAI API keys with available credits. See [How to Obtain API Keys](#how-to-obtain-api-keys).
- For optimal performance, get also Cohere API key (free for community use) and Tavily API key (free for community use).

All setup should take less than 5 minutes!

## Quick Start Guide

1. **Basic Usage**:
   ```julia
   using AIHelpMe
   aihelp("How do I implement quicksort in Julia?")
    ```

    ```plaintext
   [ Info: Done generating response. Total cost: $0.015
   AIMessage("To implement quicksort in Julia, you can use the `sort` function with the `alg=QuickSort` argument.")
   ```

   Note: As a default, we load only the Julia documentation and docstrings for standard libraries. The default model used is GPT-4 Turbo.

   You can pretty-print the answer using `pprint` if you return the full RAGResult (`return_all=true`):
   ```julia
   using AIHelpMe: pprint

   result = aihelp("How do I implement quicksort in Julia?", return_all=true)
   pprint(result)
   ```

   ```plaintext
   --------------------
   QUESTION(s)
   --------------------
   - How do I implement quicksort in Julia?

   --------------------
   ANSWER
   --------------------
   To implement quicksort in Julia, you can use the [5,1.0]`sort`[1,1.0] function with the [1,1.0]`alg=QuickSort`[1,1.0] argument.[2,1.0]

   --------------------
   SOURCES
   --------------------
   1. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Functions
   2. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Functions
   3. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Algorithms
   4. SortingAlgorithms::/README.md::0::SortingAlgorithms
   5. AIHelpMe::/README.md::0::AIHelpMe
   ```

   Note: You can see the model cheated because it can see this very documentation...

2. **`aihelp` Macro**:
   ```julia
   aihelp"how to implement quicksort in Julia?"
   ```

3. **Follow-up Questions**:
   ```julia
   aihelp!"Can you elaborate on the `sort` function?"
   ```
   Note: The `!` is required for follow-up questions.
   `aihelp!` does not add new context/more information - to do that, you need to ask a new question.

4. **Pick faster models**:
    Eg, for simple questions, GPT 3.5 might be enough, so use the alias "gpt3t":
    ```julia
    aihelp"Elaborate on the `sort` function and quicksort algorithm"gpt3t
    ```

    ```plaintext
    [ Info: Done generating response. Total cost: $0.002 -->
    AIMessage("The `sort` function in programming languages, including Julia.... continues for a while!
    ```

5. **Debugging**:
   How did you come up with that answer? Check the "context" provided to the AI model (ie, the documentation snippets that were used to generate the answer):
    ```julia
    AIHelpMe.pprint(AIHelpMe.LAST_RESULT[])
    # Output: Pretty-printed Question + Context + Answer with color highlights
    ```

    The color highlights show you which words were NOT supported by the provided context (magenta = completely new, blue = partially new). 
    It's a quite and intuitive way to see which function names or variables are made up versus which ones were in the context. 

    You can change the kwargs of `pprint` to hide the annotations or potentially even show the underlying context (snippets from the documentation):

    ```julia
    AIHelpMe.pprint(AIHelpMe.LAST_RESULT[]; add_context = true, add_scores = false)
    ```

## How to Obtain API Keys

### OpenAI API Key:
1. Visit [OpenAI's API portal](https://openai.com/api/).
2. Sign up and generate an API Key.
3. Charge some credits ($5 minimum but that will last you for a lost time).
4. Set it as an environment variable or a local preference in PromptingTools.jl. See the [instructions](https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key).

### Cohere API Key:
1. Sign up at [Cohere's registration page](https://dashboard.cohere.com/welcome/register).
2. After registering, visit the [API keys section](https://dashboard.cohere.com/api-keys) to obtain a free, rate-limited Trial key.
3. Set it as an environment variable or a local preference in PromptingTools.jl. See the [instructions](https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key).

### Tavily API Key:
1. Sign up at [Tavily](https://app.tavily.com/sign-in).
2. After registering, generate an API key on the [Overview page](https://app.tavily.com/home). You can get a free, rate-limited Trial key.
3. Set it as an environment variable or a local preference in PromptingTools.jl. See the [instructions](https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key).

## Usage

**Formulating Questions**:
- Be clear and specific for the best results. Do mention the programming language (eg, Julia) and the topic (eg, "quicksort") when it's not obvious from the context.

**Example Queries**:
- Simple question: `aihelp"What is a DataFrame in Julia?"`
- Using a model: `aihelp"best practices for error handling in Julia"gpt4t`
- Follow-up: `aihelp!"Could you provide an example?"`
- Debug errors (use `err` REPL variable):
```julia
## define mock function to trigger method error
f(x::Int) = x^2
f(Int8(2))
# we get: ERROR: MethodError: no method matching f(::Int8)

# Help is here:
aihelp"What does this error mean? $err" # Note the $err to interpolate the stacktrace
```

```plaintext
[ Info: Done generating response. Total cost: $0.003

AIMessage("The error message "MethodError: no method matching f(::Int8)" means that there is no method defined for function `f` that accepts an argument of type `Int8`. The error message also provides the closest candidate methods that were found, which are `f(::Any, !Matched::Any)` and `f(!Matched::Int64)` in the specified file `embed_all.jl` at lines 45 and 61, respectively.")
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

## How it works

AIHelpMe leverages [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl) to communicate with the AI models.

We apply a Retrieval Augment Generation (RAG) pattern, ie, 
- we pre-process all available documentation (and "embed it" to convert text snippets into numbers)
- when a question is asked, we look up the most relevant documentation snippets
- we feed the question and the documentation snippets to the AI model
- the AI model generates the answer

This ensures that the answers are not only based on general AI knowledge but are also specifically tailored to Julia's ecosystem and best practices.

## Future Directions

AIHelpMe is continuously evolving. Future updates may include:
- Tools to trace the provenance of answers (ie, where did the answer come from?).
- Creation of a gold standard Q&A dataset for evaluation.
- Refinement of the RAG ingestion pipeline for optimized chunk processing and deduplication.
- Introduction of context filtering to focus on specific modules.
- Transition to a more sophisticated multi-turn conversation design.
- Enhancement of the marginal information provided by the RAG context.
- Expansion of content sources beyond docstrings, potentially including documentation sites and community resources like Discourse or Slack posts.

Please note that this is merely a pre-release to gauge the interest in this project.