# Frequently Asked Questions

**Q: Is it expensive to embed all my documentation?**
A: No, embedding a comprehensive set of documentation is surprisingly cost-effective. Embedding around 170 modules, including all standard libraries and more, costs approximately 8 cents and takes less than 30 seconds. 
To save you money, we have already embedded the Julia standard libraries and made them available for download via Artifacts. 
We expect that any further knowledge base extensions should be at most a few cents (see [Extending the Knowledge Base](#extending-the-knowledge-base)).

**Q: How much does it cost to ask a question?**
A: Each query incurs only a fraction of a cent, depending on the length and chosen model.

**Q: How accurate are the answers?**
A: Like any other Generative AI answers, ie, it depends and you should always double-check.

**Q: Can I use it without the internet?**
A: Not at the moment. It might be possible in the future, as PromptingTools.jl supports local LLMs.

**Q: Why do we need Cohere API Key?**
A: Cohere's API is used to re-rank the best matching snippets from the documentation. It's free to use in limited quantities (ie, ~thousand requests per month), which should be enough for most users. Re-ranking improves the quality and accuracy of the answers.