import{_ as s,c as i,o as e,a7 as a}from"./chunks/framework.vS6Ax6Cj.js";const g=JSON.parse(`{"title":"","description":"","frontmatter":{"layout":"home","hero":{"name":"AIHelpMe.jl","tagline":"AI-Enhanced Coding Assistance for Julia","description":"AIHelpMe harnesses the power of Julia's extensive documentation and advanced AI models to provide tailored coding guidance. By integrating with PromptingTools.jl, it offers a unique, AI-assisted approach to answering your coding queries directly in Julia's environment.","image":{"src":"https://img.icons8.com/dusk/196/message-bot.png","alt":"Friendly robot"},"actions":[{"theme":"brand","text":"Introduction","link":"/introduction"},{"theme":"alt","text":"Advanced","link":"/advanced"},{"theme":"alt","text":"F.A.Q.","link":"/faq"},{"theme":"alt","text":"View on GitHub","link":"https://github.com/svilupp/AIHelpMe.jl"}]},"features":[{"icon":"<img width=\\"64\\" height=\\"64\\" src=\\"https://img.icons8.com/dusk/64/online-support--v2.png\\" alt=\\"AI Assistance\\"/>","title":"AI-Powered Assistance","details":"Get (more) accurate, context-aware answers to your coding queries using advanced AI models. Enhance your productivity with AI-driven insights tailored to your needs."},{"icon":"<img width=\\"64\\" height=\\"64\\" src=\\"https://img.icons8.com/dusk/64/easy.png\\" alt=\\"easy to use\\"/>","title":"Easy-to-Use Interface","details":"Quickly input your questions through a simple interface using functions and macros, designed for effortless integration into your Julia environment."},{"icon":"<img width=\\"64\\" height=\\"64\\" src=\\"https://img.icons8.com/dusk/64/cheap.png\\" alt=\\"cost-effective\\"/>","title":"Cost-Effective Solution","details":"Save on API calls with pre-embedded documentation, optimizing costs without sacrificing access to essential tools and information."}]},"headers":[],"relativePath":"index.md","filePath":"index.md","lastUpdated":null}`),t={name:"index.md"},n=a(`<h2 id="Why-AIHelpMe.jl?" tabindex="-1">Why AIHelpMe.jl? <a class="header-anchor" href="#Why-AIHelpMe.jl?" aria-label="Permalink to &quot;Why AIHelpMe.jl? {#Why-AIHelpMe.jl?}&quot;">​</a></h2><p>AI models, while powerful, often produce inaccurate or outdated information, known as &quot;hallucinations,&quot; particularly with smaller models that lack specific domain knowledge.</p><p>AIHelpMe addresses these challenges by incorporating &quot;knowledge packs&quot; filled with preprocessed, up-to-date Julia information. This ensures that you receive not only faster but also more reliable and contextually accurate coding assistance.</p><p>Most importantly, AIHelpMe is designed to be uniquely yours! You can customize the RAG pipeline however you want, bring any additional knowledge (eg, your currently loaded packages) and use it to get more accurate answers on something that&#39;s not even public!</p><h2 id="Getting-Started" tabindex="-1">Getting Started <a class="header-anchor" href="#Getting-Started" aria-label="Permalink to &quot;Getting Started {#Getting-Started}&quot;">​</a></h2><p>To install AIHelpMe, use the Julia package manager and the package name:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Pkg</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Pkg</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">add</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;AIHelpMe&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>You&#39;ll need to have the OpenAI API key with charged credit (see the <a href="/svilupp.github.io/AIHelpMe.jl/v0.4.0/introduction#How-to-Obtain-API-Keys">How to Obtain API Keys</a>).</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Requires OPENAI_API_KEY environment variable!</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;how to create tuples in julia?&quot;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># You can even specify which model you want, eg, for simple and fast answers use &quot;gpt3t&quot; = GPT-3.5 Turbo</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;how to create tuples in julia?&quot;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">gpt3t</span></span></code></pre></div><p>Or use the full form <code>aihelp()</code> and understand better not just the answer, but the sources used to produce it</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> AIHelpMe</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> last_result, pprint</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">result</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aihelp</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;how to create tuples in julia?&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, return_all</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(result)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># you can achieve the same with aihelp&quot;&quot; macros, by simply calling the &quot;last_result&quot;</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">pprint</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">last_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">())</span></span></code></pre></div><p>For more information, see the <a href="/svilupp.github.io/AIHelpMe.jl/v0.4.0/introduction#Quick-Start-Guide">Quick Start Guide</a> section. For setting up AIHelpMe with locally-hosted models, see the <a href="/svilupp.github.io/AIHelpMe.jl/v0.4.0/advanced#Using-Ollama-Models">Using Ollama Models</a> section.</p>`,12),l=[n];function o(p,h,r,d,c,u){return e(),i("div",null,l)}const y=s(t,[["render",o]]);export{g as __pageData,y as default};
