```@raw html
---
layout: home

hero:
  name: AIHelpMe.jl
  tagline: AI-Enhanced Coding Assistance for Julia
  description: AIHelpMe harnesses the power of Julia's extensive documentation and advanced AI models to provide tailored coding guidance. By integrating with PromptingTools.jl, it offers a unique, AI-assisted approach to answering your coding queries directly in Julia's environment.
  image:
    src: https://img.icons8.com/dusk/196/message-bot.png
    alt: Friendly robot
  actions:
    - theme: brand
      text: Introduction
      link: /introduction
    - theme: alt
      text: Advanced
      link: /advanced
    - theme: alt
      text: F.A.Q.
      link: /faq
    - theme: alt
      text: View on GitHub
      link: https://github.com/svilupp/AIHelpMe.jl

features:
  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/online-support--v2.png" alt="AI Assistance"/>
    title: AI-Powered Assistance
    details: Get (more) accurate, context-aware answers to your coding queries using advanced AI models. Enhance your productivity with AI-driven insights tailored to your needs.

  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/easy.png" alt="easy to use"/>
    title: Easy-to-Use Interface
    details: Quickly input your questions through a simple interface using functions and macros, designed for effortless integration into your Julia environment.

  - icon: <img width="64" height="64" src="https://img.icons8.com/dusk/64/cheap.png" alt="cost-effective"/>
    title: Cost-Effective Solution
    details: Save on API calls with pre-embedded documentation, optimizing costs without sacrificing access to essential tools and information.

---
```

## Why AIHelpMe.jl?

AI models, while powerful, often produce inaccurate or outdated information, known as "hallucinations," particularly with smaller models that lack specific domain knowledge. 

AIHelpMe addresses these challenges by incorporating "knowledge packs" filled with preprocessed, up-to-date Julia information. This ensures that you receive not only faster but also more reliable and contextually accurate coding assistance. 

Most importantly, AIHelpMe is designed to be uniquely yours! You can customize the RAG pipeline however you want, bring any additional knowledge (eg, your currently loaded packages) and use it to get more accurate answers on something that's not even public!

## Getting Started

To install AIHelpMe, use the Julia package manager and the address of the repository (it's not yet registered):

```julia
using Pkg
Pkg.add(url="https://github.com/svilupp/AIHelpMe.jl")
```

You'll need to have the OpenAI API key with charged credit (see the [How to Obtain API Keys](@ref)).

```julia
using AIHelpMe
# Requires OPENAI_API_KEY environment variable!
aihelp"how to create tuples in julia?"

# You can even specify which model you want, eg, for simple and fast answers use "gpt3t" = GPT-3.5 Turbo
aihelp"how to create tuples in julia?"gpt3t
```

Or use the full form `aihelp()` and understand better not just the answer, but the sources used to produce it
```julia
using AIHelpMe: last_result, pprint

result=aihelp("how to create tuples in julia?", return_all=true)
pprint(result)

# you can achieve the same with aihelp"" macros, by simply calling the "last_result"
pprint(last_result())
```
For more information, see the [Quick Start Guide](@ref) section. For setting up AIHelpMe with locally-hosted models, see the [Using Ollama Models](@ref) section.