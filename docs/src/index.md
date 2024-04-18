```@raw html
---
layout: home

hero:
  name: AIHelpMe.jl
  tagline: AI-Enhanced Coding Assistance for Julia
  description: AIHelpMe harnesses the power of Julia's extensive documentation and advanced AI models to provide tailored coding guidance. By integrating with PromptingTools.jl, it offers a unique, AI-assisted approach to answering your coding queries directly in Julia's environment.
  image:
    src: https://img.icons8.com/dusk/64/swiss-army-knife--v1.png
    alt: Swiss Army Knife
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
  - icon: <img width="64" height="64" src="https://img.icons8.com/clouds/100/000000/artificial-intelligence.png" alt="AI Assistance"/>
    title: AI-Powered Assistance
    details: 'Get accurate, context-aware answers to your coding queries using advanced AI models. Enhance your productivity with AI-driven insights tailored to your needs.'

  - icon: <img width="64" height="64" src="https://img.icons8.com/external-flatart-icons-flat-flatarticons/64/000000/external-interface-user-interface-flatart-icons-flat-flatarticons.png" alt="Ease of Use"/>
    title: Easy-to-Use Interface
    details: 'Quickly input your questions through a simple interface using functions and macros, designed for effortless integration into your Julia environment.'

  - icon: <img width="64" height="64" src="https://img.icons8.com/external-flatart-icons-outline-flatarticons/64/000000/external-money-business-and-trade-flatart-icons-outline-flatarticons.png" alt="Cost-Effective"/>
    title: Cost-Effective Solution
    details: 'Save on API calls with pre-embedded documentation, optimizing costs without sacrificing access to essential tools and information.'

---
```



<p style="margin-bottom:2cm"></p>

<div class="vp-doc" style="width:80%; margin:auto">

<h1> Why AIHelpMe.jl? </h1>

AI models, while powerful, often produce inaccurate or outdated information, known as "hallucinations," particularly with smaller models that lack specific domain knowledge. 

AIHelpMe addresses these challenges by incorporating "knowledge packs" filled with preprocessed, up-to-date Julia information. This ensures that you receive not only faster but also more reliable and contextually accurate coding assistance. 

With AIHelpMe, you benefit from enhanced AI reliability tailored specifically to Julia’s unique environment, leading to better, more informed coding decisions.


<h2> Getting Started </h2>

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


For more information, see the [Quick Start Guide](@ref) section.

<br>

</div>
