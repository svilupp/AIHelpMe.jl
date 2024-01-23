var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = AIHelpMe","category":"page"},{"location":"#AIHelpMe","page":"Home","title":"AIHelpMe","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for AIHelpMe.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [AIHelpMe]","category":"page"},{"location":"#AIHelpMe.aihelp-Tuple{PromptingTools.Experimental.RAGTools.AbstractChunkIndex, AbstractString}","page":"Home","title":"AIHelpMe.aihelp","text":"aihelp([index::RAG.AbstractChunkIndex,]\n    question::AbstractString;\n    rag_template::Symbol = :RAGAnswerFromContext,\n    top_k::Int = 100, top_n::Int = 5,\n    minimum_similarity::AbstractFloat = -1.0,\n    maximum_cross_similarity::AbstractFloat = 1.0,\n    rerank_strategy::RAG.RerankingStrategy = (!isempty(PT.COHERE_API_KEY) ?\n                                              RAG.CohereRerank() : RAG.Passthrough()),\n    annotate_sources::Bool = true,\n    model_embedding::String = PT.MODEL_EMBEDDING, model_chat::String = PT.MODEL_CHAT,\n    chunks_window_margin::Tuple{Int, Int} = (1, 1),\n    return_context::Bool = false, verbose::Integer = 1,\n    rerank_kwargs::NamedTuple = NamedTuple(),\n    api_kwargs::NamedTuple = NamedTuple(),\n    kwargs...)\n\nGenerates a response for a given question using a Retrieval-Augmented Generation (RAG) approach over Julia documentation. \n\nArguments\n\nindex::AbstractChunkIndex: The chunk index (contains chunked and embedded documentation).\nquestion::AbstractString: The question to be answered.\nrag_template::Symbol: Template for the RAG model, defaults to :RAGAnswerFromContext.\ntop_k::Int: Number of top candidates to retrieve based on embedding similarity.\ntop_n::Int: Number of candidates to return after reranking. This is how many will be sent to the LLM model.\nminimum_similarity::AbstractFloat: Minimum similarity threshold (between -1 and 1) for filtering chunks based on embedding similarity. Defaults to -1.0.\nmaximum_cross_similarity::AbstractFloat: Maximum cross-similarity threshold to avoid sending duplicate documents. NOT IMPLEMENTED YET\nrerank_strategy::RerankingStrategy: Strategy for reranking the retrieved chunks. Defaults to Passthrough() or CohereRerank depending on whether COHERE_API_KEY is set.\nmodel_embedding::String: Model used for embedding the question, default is PT.MODEL_EMBEDDING.\nmodel_chat::String: Model used for generating the final response, default is PT.MODEL_CHAT.\nchunks_window_margin::Tuple{Int,Int}: The window size around each chunk to consider for context building. See ?build_context for more information.\nreturn_context::Bool: If true, returns the context used for RAG along with the response.\nreturn_all::Bool: If true, returns all messages in the conversation (helpful to continue conversation later).\nverbose::Bool: If true, enables verbose logging.\nrerank_kwargs: Reranking parameters that will be forwarded to the reranking strategy\napi_kwargs: API parameters that will be forwarded to the API calls\n\nReturns\n\nIf return_context is false, returns the generated message (msg).\nIf return_context is true, returns a tuple of the generated message (msg) and the RAG context (rag_context).\n\nNotes\n\nThe function first finds the closest chunks of documentation to the question (via embeddings).\nIt reranks the candidates and builds a \"context\" for the RAG model (ie, information to be provided to the LLM model together with the user question).\nThe chunks_window_margin allows including surrounding chunks for richer context, considering they are from the same source.\nThe function currently supports only single ChunkIndex. \nFunction always saves the last context in global LAST_CONTEXT for inspection of sources/context regardless of return_context value.\n\nExamples\n\nUsing aihelp to get a response for a question:\n\nindex = build_index(...)  # create an index that contains Makie.jl documentation\nquestion = \"How to make a barplot in Makie.jl?\"\nmsg = aihelp(index, question)\n\n# or simply\nmsg = aihelp(index; question)\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.docdata_to_source-Tuple{AbstractDict}","page":"Home","title":"AIHelpMe.docdata_to_source","text":"docdata_to_source(data::AbstractDict)\n\nCreates a source path from a given DocStr record\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.docextract","page":"Home","title":"AIHelpMe.docextract","text":"docextract(d::DocStr, sep::AbstractString = \"\n\n\")\n\nExtracts the documentation from a DocStr record. Separates the individual docs within DocStr with sep.\n\n\n\n\n\n","category":"function"},{"location":"#AIHelpMe.docextract-2","page":"Home","title":"AIHelpMe.docextract","text":"docextract(d::MultiDoc, sep::AbstractString = \"\n\n\")\n\nExtracts the documentation from a MultiDoc record (separates the individual docs within DocStr with sep)\n\n\n\n\n\n","category":"function"},{"location":"#AIHelpMe.docextract-3","page":"Home","title":"AIHelpMe.docextract","text":"docextract(modules::Vector{Module} = Base.Docs.modules)\n\nExtracts the documentation from a vector of modules.\n\n\n\n\n\n","category":"function"},{"location":"#AIHelpMe.docextract-Tuple{Module}","page":"Home","title":"AIHelpMe.docextract","text":"docextract(mod::Module)\n\nExtracts the documentation from a given (loaded) module.\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.find_new_chunks-Tuple{AbstractVector{<:AbstractString}, AbstractVector{<:AbstractString}}","page":"Home","title":"AIHelpMe.find_new_chunks","text":"find_new_chunks(old_chunks::AbstractVector{<:AbstractString},\n    new_chunks::AbstractVector{<:AbstractString})\n\nIdentifies the new chunks in new_chunks that are not present in old_chunks.\n\nReturns a mask of chunks that are new (not present in old_chunks).\n\nUses SHA256 hashes to dedupe the strings quickly and effectively.\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.last_context-Tuple{}","page":"Home","title":"AIHelpMe.last_context","text":"last_context()\n\nReturns the RAGContext from the last aihelp call.  It can be useful to see the sources/references used by the AI model to generate the response.\n\nIf you're using aihelp() make sure to set return_context = true to return the context.\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.load_index!","page":"Home","title":"AIHelpMe.load_index!","text":"load_index!(file_path::Union{Nothing, AbstractString} = nothing;\n    verbose::Bool = true, kwargs...)\n\nLoads the serialized index in file_path into the global variable MAIN_INDEX. If not provided, it will download the latest index from the AIHelpMe.jl repository (more cost-efficient).\n\n\n\n\n\n","category":"function"},{"location":"#AIHelpMe.load_index!-Tuple{PromptingTools.Experimental.RAGTools.AbstractChunkIndex}","page":"Home","title":"AIHelpMe.load_index!","text":"load_index!(index::RAG.AbstractChunkIndex;\n    verbose::Bool = 1, kwargs...)\n\nLoads the provided index into the global variable MAIN_INDEX.\n\nIf you don't have an index yet, use build_index to build one from your currently loaded packages (see ?build_index)\n\nExample\n\n# build an index from some modules, keep empty to embed all loaded modules (eg, `build_index()`) \nindex = AIH.build_index([DataFramesMeta, DataFrames, CSV])\nAIH.load_index!(index)\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.update_index","page":"Home","title":"AIHelpMe.update_index","text":"update_index(index::RAG.AbstractChunkIndex = MAIN_INDEX,\n    modules::Vector{Module} = Base.Docs.modules;\n    verbose::Integer = 1,\n    separators = [\"\\n\\n\", \". \", \"\\n\"], max_length::Int = 256,\n    model::AbstractString = PT.MODEL_EMBEDDING,\n    kwargs...)\n    modules::Vector{Module} = Base.Docs.modules;\n    verbose::Bool = true, kwargs...)\n\nUpdates the provided index with the documentation of the provided modules.\n\nDeduplicates against the index.sources and embeds only the new document chunks (as measured by a hash).\n\nReturns the updated index (new instance).\n\nExample\n\nIf you loaded some new packages and want to add them to your MAIN_INDEX (or any index you use), run:\n\n# To update the MAIN_INDEX\nAHM.update_index() |> AHM.load_index!\n\n# To update an explicit index\nindex = AHM.update_index(index)\n\n\n\n\n\n","category":"function"},{"location":"#PromptingTools.Experimental.RAGTools.build_index","page":"Home","title":"PromptingTools.Experimental.RAGTools.build_index","text":"RAG.build_index(modules::Vector{Module} = Base.Docs.modules; verbose::Int = 1,\n    separators = [\"\n\n\", \". \", \" \"], max_length::Int = 256,         kwargs...)\n\nBuild index from the documentation of the currently loaded modules. If modules is empty, it will use all currently loaded modules.\n\n\n\n\n\n","category":"function"},{"location":"#PromptingTools.Experimental.RAGTools.build_index-Tuple{Module}","page":"Home","title":"PromptingTools.Experimental.RAGTools.build_index","text":"RAG.build_index(mod::Module; verbose::Int = 1, kwargs...)\n\nBuild index from the documentation of a given module mod.\n\n\n\n\n\n","category":"method"},{"location":"#AIHelpMe.@aihelp!_str-Tuple{Any, Vararg{Any}}","page":"Home","title":"AIHelpMe.@aihelp!_str","text":"aihelp!\"user_question\"[model_alias] -> AIMessage\n\nThe aihelp!\"\" string macro is used to continue a previous conversation with the AI model. \n\nIt appends the new user prompt to the last conversation in the tracked history (in AIHelpMe.CONV_HISTORY) and generates a response based on the entire conversation context. If you want to see the previous conversation, you can access it via AIHelpMe.CONV_HISTORY, which keeps at most last PromptingTools.MAX_HISTORY_LENGTH conversations.\n\nIt does NOT provide new context from the documentation. To do that, start a new conversation with aihelp\"<question>\".\n\nArguments\n\nuser_question (String): The follow up question to be added to the existing conversation.\nmodel_alias (optional, any): Specify the model alias of the AI model to be used (see PT.MODEL_ALIASES). If not provided, the default model is used.\n\nReturns\n\nAIMessage corresponding to the new user prompt, considering the entire conversation history.\n\nExample\n\nTo continue a conversation:\n\n# start conversation as normal\naihelp\"How to create a dictionary?\" \n\n# ... wait for reply and then react to it:\n\n# continue the conversation (notice that you can change the model, eg, to more powerful one for better answer)\naihelp!\"Can you create it from named tuple?\"gpt4t\n# AIMessage(\"Yes, you can create a dictionary from a named tuple ...\")\n\nUsage Notes\n\nThis macro should be used when you want to maintain the context of an ongoing conversation (ie, the last ai\"\" message).\nIt automatically accesses and updates the global conversation history.\nIf no conversation history is found, it raises an assertion error, suggesting to initiate a new conversation using ai\"\" instead.\n\nImportant\n\nEnsure that the conversation history is not too long to maintain relevancy and coherence in the AI's responses. The history length is managed by MAX_HISTORY_LENGTH.\n\n\n\n\n\n","category":"macro"},{"location":"#AIHelpMe.@aihelp_str-Tuple{Any, Vararg{Any}}","page":"Home","title":"AIHelpMe.@aihelp_str","text":"aihelp\"user_question\"[model_alias] -> AIMessage\n\nThe aihelp\"\" string macro generates an AI response to a given user question by using aihelp under the hood. It will automatically try to provide the most relevant bits of the documentation (from the index) to the LLM to answer the question.\n\nSee also aihelp!\"\" if you want to reply to the provided message / continue the conversation.\n\nArguments\n\nuser_question (String): The question to be answered by the AI model.\nmodel_alias (optional, any): Provide model alias of the AI model (see MODEL_ALIASES).\n\nReturns\n\nAIMessage corresponding to the input prompt.\n\nExample\n\nresult = aihelp\"Hello, how are you?\"\n# AIMessage(\"Hello! I'm an AI assistant, so I don't have feelings, but I'm here to help you. How can I assist you today?\")\n\nIf you want to interpolate some variables or additional context, simply use string interpolation:\n\na=1\nresult = aihelp\"What is `$a+$a`?\"\n# AIMessage(\"The sum of `1+1` is `2`.\")\n\nIf you want to use a different model, eg, GPT-4, you can provide its alias as a flag:\n\nresult = aihelp\"What is `1.23 * 100 + 1`?\"gpt4t\n# AIMessage(\"The answer is 124.\")\n\n\n\n\n\n","category":"macro"}]
}
