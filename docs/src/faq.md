# Frequently Asked Questions

##Is it expensive to embed all my documentation?
No, embedding a comprehensive set of documentation is surprisingly cost-effective. Embedding around 170 modules, including all standard libraries and more, costs approximately 8 cents and takes less than 30 seconds. 
To save you money, we have already embedded the Julia standard libraries and made them available for download via Artifacts. 
We expect that any further knowledge base extensions should be at most a few cents (see [Extending the Knowledge Base](#extending-the-knowledge-base)).

## How much does it cost to ask a question?
Each query incurs only a fraction of a cent, depending on the length and chosen model.

## Can I use the Cohere Trial API Key for commercial projects?
No, a trial key is only for testing purposes. But it takes only a few clicks to switch to Production API. The cost is only $1 per 1000 searches (!!!) and has many other benefits.

## How accurate are the answers?
Like any other Generative AI answers, ie, it depends and you should always double-check.

## Can I use it without the internet?
Not at the moment. It might be possible in the future, as PromptingTools.jl supports local LLMs.

## Why do we need Cohere API Key?
Cohere's API is used to re-rank the best matching snippets from the documentation. It's free to use in limited quantities (ie, ~thousand requests per month), which should be enough for most users. Re-ranking improves the quality and accuracy of the answers.

## Why do we need Tavily API Key?
Tavily is used for the web search results to augment your answers. It's free to use in limited quantities.

## Can we use Ollama (locally-hosted) models?
Yes! See the [Using Ollama Models](@ref) section.


