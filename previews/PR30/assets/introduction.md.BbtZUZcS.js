import{_ as e,c as i,o as s,a7 as a}from"./chunks/framework.Bl7K-eUc.js";const t="/svilupp.github.io/AIHelpMe.jl/previews/PR30/assets/tidier2.QEt-6Bdl.png",n="/svilupp.github.io/AIHelpMe.jl/previews/PR30/assets/makie2.BCYCgGTc.png",y=JSON.parse('{"title":"Introduction","description":"","frontmatter":{},"headers":[],"relativePath":"introduction.md","filePath":"introduction.md","lastUpdated":null}'),o={name:"introduction.md"},l=a(`<h1 id="Introduction" tabindex="-1">Introduction <a class="header-anchor" href="#Introduction" aria-label="Permalink to &quot;Introduction {#Introduction}&quot;">​</a></h1><p>Welcome to AIHelpMe.jl, your go-to for getting answers to your Julia coding questions.</p><p>AIhelpMe is a simple wrapper around RAG functionality in PromptingTools.</p><p>It provides three extras:</p><ul><li><p>(hopefully), a simpler interface to handle RAG configurations (there are thousands of possible configurations)</p></li><li><p>pre-computed embeddings for key “knowledge” in the Julia ecosystem (we refer to them as “knowledge packs”)</p></li><li><p>ability to quickly incorporate any additional knowledge (eg, your currently loaded packages) into the &quot;assistant&quot;</p></li></ul><div class="caution custom-block github-alert"><p class="custom-block-title">This is only a prototype! We have not tuned it yet, so your mileage may vary! Always check your results from LLMs!</p><p></p></div><h2 id="What-is-RAG?" tabindex="-1">What is RAG? <a class="header-anchor" href="#What-is-RAG?" aria-label="Permalink to &quot;What is RAG? {#What-is-RAG?}&quot;">​</a></h2><p>RAG, short for Retrieval-Augmented Generation, is a way to reduce hallucinations of your model and improve its response by directly providing the relevant source knowledge into the prompt.</p><p>See more details <a href="https://aws.amazon.com/what-is/retrieval-augmented-generation" target="_blank" rel="noreferrer">here</a>.</p><h2 id="What-is-a-knowledge-pack?" tabindex="-1">What is a knowledge pack? <a class="header-anchor" href="#What-is-a-knowledge-pack?" aria-label="Permalink to &quot;What is a knowledge pack? {#What-is-a-knowledge-pack?}&quot;">​</a></h2><p>A knowledge pack is a collection of pre-computed embeddings for a specific set of documents. The documents are typically related to a specific topic or area of interest or package ecosystem (eg, Makie.jl documentation site with all its packages). The embeddings are computed using a specific embedding model and are used to improve the quality of the generated responses by providing the relevant source knowledge directly to the prompt.</p><p>We currently provide 3 knowledge packs:</p><ul><li><p><code>:julia</code> - Julia documentation, standard library docstrings and a few extras</p></li><li><p><code>:tidier</code> - Tidier.jl organization documentation</p></li><li><p><code>:makie</code> - Makie.jl organization documentation</p></li></ul><p>You can load all of them with <code>AIHelpMe.load_index!([:julia, :tidier, :makie])</code>.</p><p>It is EXTREMELY IMPORTANT to use the SAME embedding model in <code>aihelp()</code> queries as the one used to build the knowledge pack. That is why you have to be careful changing the RAG pipeline configuration - always use the dedicated utility <code>update_pipeline!()</code>.</p><h2 id="Installation" tabindex="-1">Installation <a class="header-anchor" href="#Installation" aria-label="Permalink to &quot;Installation {#Installation}&quot;">​</a></h2><p>To install AIHelpMe, use the Julia package manager and the package name:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Pkg</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Pkg</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">add</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;AIHelpMe&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p><strong>Prerequisites:</strong></p><ul><li><p>Julia (version 1.10 or later).</p></li><li><p>Internet connection for API access.</p></li><li><p>OpenAI API keys with available credits. See <a href="/svilupp.github.io/AIHelpMe.jl/previews/PR30/introduction#how-to-obtain-api-keys">How to Obtain API Keys</a>.</p></li><li><p>For optimal performance, get also Cohere API key (free for community use) and Tavily API key (free for community use).</p></li></ul><p>All setup should take less than 5 minutes!</p><h2 id="Quick-Start-Guide" tabindex="-1">Quick Start Guide <a class="header-anchor" href="#Quick-Start-Guide" aria-label="Permalink to &quot;Quick Start Guide {#Quick-Start-Guide}&quot;">​</a></h2><ol><li><strong>Basic Usage</strong>:</li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;How do I implement quicksort in Julia?&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><div class="language-plaintext vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">plaintext</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span>[ Info: Done generating response. Total cost: \\$0.015</span></span>
<span class="line"><span>AIMessage(&quot;To implement quicksort in Julia, you can use the \`sort\` function with the \`alg=QuickSort\` argument.&quot;)</span></span></code></pre></div><p>Note: As a default, we load only the Julia documentation and docstrings for standard libraries. The default model used is GPT-4 Turbo.</p><p>You can pretty-print the answer using <code>pprint</code> if you return the full RAGResult (<code>return_all=true</code>). If displayed in REPL, it will use color highlights as well (magenta color = text not from the &quot;context&quot;).</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> pprint</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">result </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> aihelp</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;How do I implement quicksort in Julia?&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, return_all</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(result)</span></span></code></pre></div><div class="language-plaintext vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">plaintext</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span>--------------------</span></span>
<span class="line"><span>QUESTION(s)</span></span>
<span class="line"><span>--------------------</span></span>
<span class="line"><span>- How do I implement quicksort in Julia?</span></span>
<span class="line"><span></span></span>
<span class="line"><span>--------------------</span></span>
<span class="line"><span>ANSWER</span></span>
<span class="line"><span>--------------------</span></span>
<span class="line"><span>To implement quicksort in Julia, you can use the [5,1.0]\`sort\`[1,1.0] function with the [1,1.0]\`alg=QuickSort\`[1,1.0] argument.[2,1.0]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>--------------------</span></span>
<span class="line"><span>SOURCES</span></span>
<span class="line"><span>--------------------</span></span>
<span class="line"><span>1. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Functions</span></span>
<span class="line"><span>2. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Functions</span></span>
<span class="line"><span>3. https://docs.julialang.org/en/v1.10.2/base/sort/index.html::Sorting and Related Functions/Sorting Algorithms</span></span>
<span class="line"><span>4. SortingAlgorithms::/README.md::0::SortingAlgorithms</span></span>
<span class="line"><span>5. AIHelpMe::/README.md::0::AIHelpMe</span></span></code></pre></div><p>Note: You can see the model cheated because it can see this very documentation...</p><p>Note 2: The square brackets represent the corresponding source and the strength of association (1.0 is the highest), eg, <code>[1,1.0]</code> indicates high confidence in the sentences having high overlap with the chunk in source #1.</p><ol><li><strong><code>aihelp</code> Macro</strong>:</li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;how to implement quicksort in Julia?&quot;</span></span></code></pre></div><ol><li><strong>Follow-up Questions</strong>:</li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp!</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;Can you elaborate on the \`sort\` function?&quot;</span></span></code></pre></div><p>Note: The <code>!</code> is required for follow-up questions. <code>aihelp!</code> does not add new context/more information - to do that, you need to ask a new question.</p><ol><li><strong>Pick faster models</strong>:</li></ol><p>Eg, for simple questions, GPT 3.5 might be enough, so use the alias &quot;gpt3t&quot;:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;Elaborate on the \`sort\` function and quicksort algorithm&quot;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">gpt3t</span></span></code></pre></div><div class="language-plaintext vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">plaintext</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span>[ Info: Done generating response. Total cost: \\$0.002 --&gt;</span></span>
<span class="line"><span>AIMessage(&quot;The \`sort\` function in programming languages, including Julia.... continues for a while!</span></span></code></pre></div><ol><li><strong>Debugging</strong>:</li></ol><p>How did you come up with that answer? Check the &quot;context&quot; provided to the AI model (ie, the documentation snippets that were used to generate the answer):</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> pprint, last_result</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">last_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">())</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Output: Pretty-printed Question + Context + Answer with color highlights</span></span></code></pre></div><p>Examples of the highlighted output:</p><p><img src="`+t+'" alt=""></p><p><img src="'+n+'" alt=""></p><p>The color highlights show you which words were NOT supported by the provided context (magenta = completely new, blue = partially new). It&#39;s an intuitive way to see which function names or variables are made up versus which ones were in the context.</p><p>The square brackets represent the corresponding source and the strength of association (1.0 is the highest), eg, <code>[1,1.0]</code> indicates high confidence in the sentences having high overlap with the chunk in source #1.</p><p>You can change the kwargs of <code>pprint</code> to hide the annotations or potentially even show the underlying context (snippets from the documentation):</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">last_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(); add_context </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, add_scores </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><div class="tip custom-block github-alert"><p class="custom-block-title">Your results will significantly improve if you enable re-ranking of the context to be provided to the model (eg, `aihelp(..., rerank=true)`) or change pipeline to `update_pipeline!(:silver)`. It requires setting up Cohere API key but it&#39;s free for community use.</p><p></p><p>[!TIP] Do you want to safely execute the generated code? Use <code>AICode</code> from <code>PromptingTools.Experimental.AgentToolsAI.</code>. It can executed the code in a scratch module and catch errors if they happen (eg, apply directly to <code>AIMessage</code> response like <code>AICode(msg)</code>).</p></div><p>Noticed some weird answers? Please let us know! See <a href="/svilupp.github.io/AIHelpMe.jl/previews/PR30/advanced#Help-Us-Improve-and-Debug">Help Us Improve and Debug</a>.</p><p>If you want to use locally-hosted models, see the <a href="/svilupp.github.io/AIHelpMe.jl/previews/PR30/advanced#Using-Ollama-Models">Using Ollama Models</a> section.</p><p>If you want to customize your setup, see <code>AIHelpMe.PREFERENCES</code>.</p><h2 id="How-to-Obtain-API-Keys" tabindex="-1">How to Obtain API Keys <a class="header-anchor" href="#How-to-Obtain-API-Keys" aria-label="Permalink to &quot;How to Obtain API Keys {#How-to-Obtain-API-Keys}&quot;">​</a></h2><h3 id="OpenAI-API-Key:" tabindex="-1">OpenAI API Key: <a class="header-anchor" href="#OpenAI-API-Key:" aria-label="Permalink to &quot;OpenAI API Key: {#OpenAI-API-Key:}&quot;">​</a></h3><ol><li><p>Visit <a href="https://openai.com/api/" target="_blank" rel="noreferrer">OpenAI&#39;s API portal</a>.</p></li><li><p>Sign up and generate an API Key.</p></li><li><p>Charge some credits ($5 minimum but that will last you for a lost time).</p></li><li><p>Set it as an environment variable or a local preference in PromptingTools.jl. See the <a href="https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key" target="_blank" rel="noreferrer">instructions</a>.</p></li></ol><h3 id="Cohere-API-Key:" tabindex="-1">Cohere API Key: <a class="header-anchor" href="#Cohere-API-Key:" aria-label="Permalink to &quot;Cohere API Key: {#Cohere-API-Key:}&quot;">​</a></h3><ol><li><p>Sign up at <a href="https://dashboard.cohere.com/welcome/register" target="_blank" rel="noreferrer">Cohere&#39;s registration page</a>.</p></li><li><p>After registering, visit the <a href="https://dashboard.cohere.com/api-keys" target="_blank" rel="noreferrer">API keys section</a> to obtain a free, rate-limited Trial key.</p></li><li><p>Set it as an environment variable or a local preference in PromptingTools.jl. See the <a href="https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key" target="_blank" rel="noreferrer">instructions</a>.</p></li></ol><h3 id="Tavily-API-Key:" tabindex="-1">Tavily API Key: <a class="header-anchor" href="#Tavily-API-Key:" aria-label="Permalink to &quot;Tavily API Key: {#Tavily-API-Key:}&quot;">​</a></h3><ol><li><p>Sign up at <a href="https://app.tavily.com/sign-in" target="_blank" rel="noreferrer">Tavily</a>.</p></li><li><p>After registering, generate an API key on the <a href="https://app.tavily.com/home" target="_blank" rel="noreferrer">Overview page</a>. You can get a free, rate-limited Trial key.</p></li><li><p>Set it as an environment variable or a local preference in PromptingTools.jl. See the <a href="https://siml.earth/PromptingTools.jl/dev/frequently_asked_questions#Configuring-the-Environment-Variable-for-API-Key" target="_blank" rel="noreferrer">instructions</a>.</p></li></ol><h2 id="Usage" tabindex="-1">Usage <a class="header-anchor" href="#Usage" aria-label="Permalink to &quot;Usage {#Usage}&quot;">​</a></h2><p><strong>Formulating Questions</strong>:</p><ul><li>Be clear and specific for the best results. Do mention the programming language (eg, Julia) and the topic (eg, &quot;quicksort&quot;) when it&#39;s not obvious from the context.</li></ul><p><strong>Example Queries</strong>:</p><ul><li><p>Simple question: <code>aihelp&quot;What is a DataFrame in Julia?&quot;</code></p></li><li><p>Using a model: <code>aihelp&quot;best practices for error handling in Julia&quot;gpt4t</code></p></li><li><p>Follow-up: <code>aihelp!&quot;Could you provide an example?&quot;</code></p></li><li><p>Debug errors (use <code>err</code> REPL variable):</p></li></ul><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">## define mock function to trigger method error</span></span>\n<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">f</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">::</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Int</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> x</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">^</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">2</span></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">f</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Int8</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">2</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">))</span></span>\n<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># we get: ERROR: MethodError: no method matching f(::Int8)</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Help is here:</span></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;What does this error mean? </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">\\$</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">err&quot;</span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"> # Note the $err to interpolate the stacktrace</span></span></code></pre></div><div class="language-plaintext vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">plaintext</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span>[ Info: Done generating response. Total cost: \\$0.003</span></span>\n<span class="line"><span></span></span>\n<span class="line"><span>AIMessage(&quot;The error message &quot;MethodError: no method matching f(::Int8)&quot; means that there is no method defined for function `f` that accepts an argument of type `Int8`. The error message also provides the closest candidate methods that were found, which are `f(::Any, !Matched::Any)` and `f(!Matched::Int64)` in the specified file `embed_all.jl` at lines 45 and 61, respectively.&quot;)</span></span></code></pre></div><h2 id="How-it-works" tabindex="-1">How it works <a class="header-anchor" href="#How-it-works" aria-label="Permalink to &quot;How it works {#How-it-works}&quot;">​</a></h2><p>AIHelpMe leverages <a href="https://github.com/svilupp/PromptingTools.jl" target="_blank" rel="noreferrer">PromptingTools.jl</a> to communicate with the AI models.</p><p>We apply a Retrieval Augment Generation (RAG) pattern, ie,</p><ul><li><p>we pre-process all available documentation (and &quot;embed it&quot; to convert text snippets into numbers)</p></li><li><p>when a question is asked, we look up the most relevant documentation snippets</p></li><li><p>we feed the question and the documentation snippets to the AI model</p></li><li><p>the AI model generates the answer</p></li><li><p>(sometimes) we run a web search to find additional relevant information and ask the model to refine the answer</p></li></ul><p>This ensures that the answers are not only based on general AI knowledge but are also specifically tailored to Julia&#39;s ecosystem and best practices.</p><p>Visit an introduction to RAG tools in <a href="https://svilupp.github.io/PromptingTools.jl/dev/extra_tools/rag_tools_intro" target="_blank" rel="noreferrer">PromptingTools.jl</a>.</p><h2 id="Future-Directions" tabindex="-1">Future Directions <a class="header-anchor" href="#Future-Directions" aria-label="Permalink to &quot;Future Directions {#Future-Directions}&quot;">​</a></h2><p>AIHelpMe is continuously evolving. Future updates may include:</p><ul><li><p>Tools to trace the provenance of answers (ie, where did the answer come from?).</p></li><li><p>Creation of a gold standard Q&amp;A dataset for evaluation.</p></li><li><p>Refinement of the RAG ingestion pipeline for optimized chunk processing and deduplication.</p></li><li><p>Introduction of context filtering to focus on specific modules.</p></li><li><p>Transition to a more sophisticated multi-turn conversation design.</p></li><li><p>Enhancement of the marginal information provided by the RAG context.</p></li><li><p>Expansion of content sources beyond docstrings, potentially including documentation sites and community resources like Discourse or Slack posts.</p></li></ul><p>Please note that this is merely a pre-release to gauge the interest in this project.</p>',78),p=[l];function r(h,d,c,u,g,k){return s(),i("div",null,p)}const f=e(o,[["render",r]]);export{y as __pageData,f as default};
