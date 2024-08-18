import{_ as s,c as e,o as i,a7 as a}from"./chunks/framework.Bl7K-eUc.js";const u=JSON.parse('{"title":"Advanced","description":"","frontmatter":{},"headers":[],"relativePath":"advanced.md","filePath":"advanced.md","lastUpdated":null}'),t={name:"advanced.md"},n=a(`<h1 id="Advanced" tabindex="-1">Advanced <a class="header-anchor" href="#Advanced" aria-label="Permalink to &quot;Advanced {#Advanced}&quot;">​</a></h1><h2 id="Using-Ollama-Models" tabindex="-1">Using Ollama Models <a class="header-anchor" href="#Using-Ollama-Models" aria-label="Permalink to &quot;Using Ollama Models {#Using-Ollama-Models}&quot;">​</a></h2><p>AIHelpMe can use Ollama (locally-hosted) models, but the knowledge packs are available for only one embedding model: &quot;nomic-embed-text&quot;!</p><p>You must set <code>model_embedding=&quot;nomic-embed-text&quot;</code> and <code>embedding_dimension=0</code> (maximum dimension available) for everything to work correctly!</p><p>Example:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> PromptingTools</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> register_model!, OllamaSchema</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> update_pipeline!, load_index!</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># register model names with the Ollama schema - if needed!</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># eg, register_model!(; name=&quot;mistral:7b-instruct-v0.2-q4_K_M&quot;,schema=OllamaSchema())</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># you can use whichever chat model you like! Llama 3 8b is the best trade-of right now and it&#39;s already known to PromptingTools.</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">update_pipeline!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">:bronze</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">; model_chat </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;llama3&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,model_embedding</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;nomic-embed-text&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, embedding_dimension</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">0</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span>
<span class="line"></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># You must download the corresponding knowledge packs via \`load_index!\` (because you changed the embedding model)</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">load_index!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p>Let&#39;s ask a question:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;How to create a named tuple?&quot;</span></span></code></pre></div><div class="language-plaintext vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">plaintext</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span>[ Info: Done with RAG. Total cost: \\$0.0</span></span>
<span class="line"><span>PromptingTools.AIMessage(&quot;In Julia, you can create a named tuple by enclosing key-value pairs in parentheses with the keys as symbols preceded by a colon, separated by commas. For example:</span></span>
<span class="line"><span>...continues</span></span></code></pre></div><p>You can use the Preference setting mechanism (<code>?PREFERENCES</code>) to change the default settings.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">set_preferences!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;MODEL_CHAT&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;llama3&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;MODEL_EMBEDDING&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;nomic-embed-text&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;EMBEDDING_DIMENSION&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 0</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h2 id="Code-Execution" tabindex="-1">Code Execution <a class="header-anchor" href="#Code-Execution" aria-label="Permalink to &quot;Code Execution {#Code-Execution}&quot;">​</a></h2><p>Use <code>AICode</code> on the generated answers.</p><p>For example:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> PromptingTools</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Experimental</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">AgentTools</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AICode</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">msg </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;Write a code to sum up 1+1&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">cb </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> AICode</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(msg)</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Output: AICode(Success: True, Parsed: True, Evaluated: True, Error Caught: N/A, StdOut: True, Code: 1 Lines)</span></span></code></pre></div><p>If you want to access the extracted code, simply use <code>cb.code</code>. If there is an error, you can see it in <code>cb.error</code>.</p><p>See the docstrings to learn more about it!</p><h2 id="Extending-the-Knowledge-Base" tabindex="-1">Extending the Knowledge Base <a class="header-anchor" href="#Extending-the-Knowledge-Base" aria-label="Permalink to &quot;Extending the Knowledge Base {#Extending-the-Knowledge-Base}&quot;">​</a></h2><p>The package by default ships with pre-processed embeddings for all Julia standard libraries, DataFrames and PromptingTools. Thanks to the amazing Julia Artifacts system, these embeddings are downloaded/cached/loaded every time the package starts.</p><p>Note: The below functions are not yet exported. Prefix them with <code>AIHelpMe.</code> to use them.</p><h3 id="Building-and-Updating-Indexes" tabindex="-1">Building and Updating Indexes <a class="header-anchor" href="#Building-and-Updating-Indexes" aria-label="Permalink to &quot;Building and Updating Indexes {#Building-and-Updating-Indexes}&quot;">​</a></h3><p>AIHelpMe allows users to enhance its capabilities by embedding documentation from any loaded Julia module. Utilize <code>new_index = build_index(module)</code> to create an index for a specific module (or a vector of modules).</p><p>To update an existing index, including newly imported packages, use <code>new index = update_index(module)</code> or simply <code>update_index()</code> to include all unrecognized modules. We will add and embed only the new documentation to avoid unnecessary duplication and cost.</p><h3 id="Managing-Indexes" tabindex="-1">Managing Indexes <a class="header-anchor" href="#Managing-Indexes" aria-label="Permalink to &quot;Managing Indexes {#Managing-Indexes}&quot;">​</a></h3><p>Once an index is built or updated, you can choose to serialize it for later use or set it as the primary index.</p><p>To use your newly created index as the main source for queries, execute <code>load_index!(new_index)</code>. Alternatively, load a pre-existing index from a file using <code>load_index!(file_path)</code>.</p><p>The main index for queries is held in the global variable <code>AIHelpMe.MAIN_INDEX[]</code>.</p><h2 id="Save-Your-Preferences" tabindex="-1">Save Your Preferences <a class="header-anchor" href="#Save-Your-Preferences" aria-label="Permalink to &quot;Save Your Preferences {#Save-Your-Preferences}&quot;">​</a></h2><p>You can now leverage the amazing Preferences.jl mechanism to save your default choices of the chat model, embedding model, embedding dimension, and which knowledge packs to load on start.</p><p>For example, if you wanted to switch to Ollama-based pipeline, you could persist the configuration with:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">set_preferences!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;MODEL_CHAT&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;llama3&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;MODEL_EMBEDDING&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;nomic-embed-text&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;EMBEDDING_DIMENSION&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> =&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 0</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>This will create a file <code>LocalPreferences.toml</code> in your project directory that will remember these choices across sessions.</p><p>See <code>AIHelpMe.PREFERENCES</code> for more details.</p><h2 id="Debugging-Poor-Answers" tabindex="-1">Debugging Poor Answers <a class="header-anchor" href="#Debugging-Poor-Answers" aria-label="Permalink to &quot;Debugging Poor Answers {#Debugging-Poor-Answers}&quot;">​</a></h2><p>We&#39;re using a Retrieval-Augmented Generation (RAG) pipeline, which consists of two major steps:</p><ol><li><p>Generate a &quot;context&quot; snippet from the question and the current context.</p></li><li><p>Generate an &quot;answer&quot; from the context.</p></li><li><p>(Optional) Generate a refined answer (only some pipelines will have this).</p></li></ol><p>If you&#39;re not getting good answers / the answers you would expect, you need to understand if the problem is in step 1 or step 2.</p><p>First, get the <code>RAGResult</code> (the full detail of the pipeline and its intermediate steps):</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> pprint, last_result</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># This will help you access how was the last answer generated</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">result </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> last_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># You can pretty-print the result</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(result)</span></span></code></pre></div><p><strong>Checking the Context</strong> Check the <code>result.context</code> - is it using the right snippets (&quot;knowledge&quot;) from the knowledge packs? Alternatively, you can add it directly to the pretty-printed answer:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(result; add_context</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, add_scores</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>How is the context produced?</p><p>It&#39;s a function of your pipeline setting (see below) and the knowledge packs loaded (<code>AIHelpMe.LOADED_PACKS</code>).</p><p>A quick way to diagnose the context pipeline:</p><ul><li><p>See a quick overview of the embedding configuration with <code>AIHelpMe.get_config_key()</code> (it captures the embedding model, dimension, and element type).</p></li><li><p>See the pipeline configuration (which steps) with <code>AIHelpMe.RAG_CONFIG[]</code>.</p></li><li><p>See the individual kwargs provided to the pipeline with <code>AIHelpMe.RAG_KWARGS[]</code>.</p></li></ul><p>The simplest fix for &quot;poor&quot; context is to enable reranking (<code>rerank=true</code>).</p><p>Other angles to consider:</p><ul><li><p>Are you sure if the source information is present in the knowledge pack? Can it be added (see <code>?update_index</code>)?</p></li><li><p>Was the question phrased poorly? Can we ask the same in a more sensible way?</p></li><li><p>Try different models, dimensions, element types (Bool is less precise than Float32, etc.)</p></li></ul><p><strong>Checking the First Answer</strong></p><p>Check the original answer (<code>result.answer</code>) - is it correct?</p><p>Assuming the context was good, but the answer is not we need to find out if it&#39;s because of the model or because of the prompt template.</p><ul><li><p>Is it that you&#39;re using a weak chat model? Try different models. Does it improve?</p></li><li><p>Is the prompt template not suitable for your questions? Experiment with tweaking the prompt template.</p></li></ul><p><strong>Checking the Refined Answer</strong></p><p>You always see the final answer by default (<code>result.final_answer</code>). Is it different from <code>result.answer</code>? That means the <code>refiner</code> step in the RAG pipeline has been used.</p><p>Debug it in the same way as the first answer.</p><ul><li><p>Is it the context provided to the refiner?</p></li><li><p>Is it the answer from the refiner? If yes, is it because of the model? Or because of the prompt template?</p></li></ul><h2 id="Help-Us-Improve-and-Debug" tabindex="-1">Help Us Improve and Debug <a class="header-anchor" href="#Help-Us-Improve-and-Debug" aria-label="Permalink to &quot;Help Us Improve and Debug {#Help-Us-Improve-and-Debug}&quot;">​</a></h2><p>It would be incredibly helpful if you could share examples when the RAG pipeline fails. We&#39;re particularly interested in cases where the answer you get is wrong because of the &quot;bad&quot; context provided.</p><p>Let&#39;s say you ran a question and got a wrong answer (or some other aspect is worth reporting).</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;how to create tuples in julia?&quot;</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Bad answer somehow...</span></span></code></pre></div><p>You can access the underlying pipeline internals (what context was used etc.)</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># last result (debugging object RAGResult)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">result</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">last_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># If you want to see the actual context snippets, use \`add_context=true\`</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(result)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Or access the fields in RAGResult directly, eg,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">result</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">context</span></span></code></pre></div><p>Let&#39;s save this result for debugging later into JSON.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">PromptingTools</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> JSON3</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">config_key </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">get_config_key</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">() </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># &quot;nomicembedtext-0-Bool&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">JSON3</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">write</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;rag-makie-xyzyzyz-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">$(config_key)</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">-20240419.json&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, result)</span></span></code></pre></div><p>Now, you want to let us know. Please share the above JSON with a few notes of what you expected/what is wrong via a Github Issue or on Slack (<code>#generative-ai</code> channel)!</p>`,65),l=[n];function p(h,o,d,r,k,c){return i(),e("div",null,l)}const E=s(t,[["render",p]]);export{u as __pageData,E as default};
