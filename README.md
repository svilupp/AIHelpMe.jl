# AIHelpMe [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://svilupp.github.io/AIHelpMe.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://svilupp.github.io/AIHelpMe.jl/dev/) [![Build Status](https://github.com/svilupp/AIHelpMe.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/svilupp/AIHelpMe.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/svilupp/AIHelpMe.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/svilupp/AIHelpMe.jl) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

# AIHelpMe: Enhanced Coding Assistance for Julia

AIHelpMe harnesses the power of Julia's extensive documentation and advanced AI models to provide tailored coding guidance. By integrating with PromptingTools.jl, it offers a unique, AI-assisted approach to answering your coding queries directly in Julia's environment.

Note: This is only a proof-of-concept. If there is enough interest, we will fine-tune the RAG pipeline for better performance.

## Features

- **AI-Powered Assistance**: Get context-aware answers to your coding questions.
- **Easy-to-Use Interface**: Simple function and macro to input your questions.
- **Flexible Querying**: Use different AI models for varied insights and performance versus cost trade-offs.
- **Cost-Effective**: Download pre-embedded documentation to save on API calls.

## Installation

To install AIHelpMe, use the Julia package manager and the address of the repository (it's not yet registered):

```julia
using Pkg
Pkg.add("https://github.com/svilupp/AIHelpMe.jl")
```

**Prerequisites:**

- Julia (version 1.10 or later).
- Internet connection for API access.
- OpenAI and Cohere API keys (recommended for optimal performance). See [How to Obtain API Keys](#how-to-obtain-api-keys).

All setup should take less than 5 minutes!

## Quick Start Guide

1. **Basic Usage**:
   ```julia
   using AIHelpMe
   aihelp("How do I implement quicksort in Julia?")
    ```

    ```plaintext
   [ Info: Done generating response. Total cost: $0.001
   AIMessage("To implement quicksort in Julia, you can use the `sort` function with the `alg=QuickSort` argument.")
   ```

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

4. **Pick stronger models**:
    Eg, "gpt4t" is an alias for GPT-4 Turbo:
    ```julia
    aihelp"Elaborate on the `sort` function and quicksort algorithm"gpt4t
    ```
    ```plaintext
    [ Info: Done generating response. Total cost: $0.002 -->
    AIMessage("The `sort` function in programming languages, including Julia.... continues for a while!
    ```

## How to Obtain API Keys

### OpenAI API Key:
1. Visit [OpenAI's API portal](https://openai.com/api/).
2. Sign up or log in.
3. Follow the instructions to generate an API key.

### Cohere API Key:
1. Go to [Cohere's platform](https://cohere.ai/).
2. Create an account.
3. Navigate to the API section to get your key.

## Usage

**Formulating Questions**:
- Be clear and specific for the best results.

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

## How it works

AIHelpMe leverages [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl) to communicate with the AI models.

We apply a Retrieval Augment Generation (RAG) pattern, ie, 
- we pre-process all available documentation (and "embed it" to convert text snippets into numbers)
- when a question is asked, we look up the most relevant documentation snippets
- we feed the question and the documentation snippets to the AI model
- the AI model generates the answer

This ensures that the answers are not only based on general AI knowledge but are also specifically tailored to Julia's ecosystem and best practices.

## FAQs

**Q: How accurate are the answers?**
A: Like any other Generative AI answers, ie, it depends and you should always double-check.

**Q: Can I use it without the internet?**
A: Not at the moment. It might be possible in the future, as PromptingTools.jl supports local LLMs.

**Q: Why do we need Cohere API Key?**
A: Cohere's API is used to re-rank the best matching snippets from the documentation. It's free to use in limited quantities (ie, ~thousand requests per month), which should be enough for most users. Re-ranking improves the quality and accuracy of the answers.
