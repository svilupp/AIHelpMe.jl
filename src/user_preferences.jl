# Defines the preference setting mechanism, some of the pipeline/config values are loaded/set in `src/pipeline_defaults.jl`

### Global variables
### Global for history, replies, etc
const CONV_HISTORY = Vector{Vector{PT.AbstractMessage}}()
const CONV_HISTORY_LOCK = ReentrantLock()
const MAX_HISTORY_LENGTH = 1
global LAST_RESULT::Union{Nothing, RT.AbstractRAGResult} = nothing
global MAIN_INDEX::Union{Nothing, RT.AbstractChunkIndex} = nothing

"""
    ALLOWED PACKS

Currently available packs are:
- `:julia` - Julia documentation, standard library docstrings and a few extras (for Julia v1.10)
- `:juliadata` - JuliaData.jl organization documentation, eg, DataFrames.jl and similar packages
- `:genie` - GenieFramework organization documentation, eg, Genie.jl, Stipple.jl, StippleUI.jl, etc
- `:plots` - Plots.jl organization documentation, eg, Plots.jl, StatsPlots.jl, etc
- `:makie` - Makie.jl organization documentation
- `:tidier` - Tidier.jl organization documentation
- `:sciml` - SciML organization documentation

These packs have been sourced and packaged with DocsScraper.jl.
"""
const ALLOWED_PACKS = [:julia, :juliadata, :tidier, :sciml, :plots, :makie, :genie]

"""
    LOADED_PACKS

The knowledge packs that are currently loaded in the index.
"""
global LOADED_PACKS::Vector{Symbol} = @load_preference("LOADED_PACKS",
    default=["julia"]) .|> Symbol

### Globals for configuration
# These serve as reference models to be injected in the absence of inputs, 
# but the actual used for the query is primarily provided aihelpme directly or via the active RAG_KWARGS
global MODEL_CHAT::String = @load_preference("MODEL_CHAT",
    default="gpt4t")
global MODEL_EMBEDDING::String = @load_preference("MODEL_EMBEDDING",
    default="text-embedding-3-large")
global EMBEDDING_DIMENSION::Int = @load_preference("EMBEDDING_DIMENSION",
    default=1024)
###

"""
    PREFERENCES

You can set preferences for AIHelpMe by using the `set_preferences!`.
    It will create a `LocalPreferences.toml` file in your current directory and will reload your prefences from there.

Check your preferences by calling `get_preferences(key::String)`.
    
# Available Preferences (for `set_preferences!`)
- `MODEL_CHAT`: The default model to use for aigenerate and most ai* calls. See `PromptingTools.MODEL_REGISTRY` for a list of available models or define your own with `PromptingTools.register_model!`.
- `MODEL_EMBEDDING`: The default model to use for aiembed (embedding documents). See `PromptingTools.MODEL_REGISTRY` for a list of available models or define your own with `PromptingTools.register_model!`.
- `EMBEDDING_DIMENSION`: The dimension of the embedding vector. Defaults to 1024 (truncated OpenAI embedding). Set to 0 to use the maximum allowed dimension.
- `LOADED_PACKS`: The knowledge packs that are loaded on restart/refresh (`load_index!()`).
"""
const PREFERENCES = nothing

"Keys that are allowed to be set via `set_preferences!`"
const ALLOWED_PREFERENCES = [
    "MODEL_CHAT",
    "MODEL_EMBEDDING",
    "EMBEDDING_DIMENSION",
    "LOADED_PACKS"]

"""
    set_preferences!(pairs::Pair{String, <:Any}...)

Set preferences for AIHelpMe. See `?PREFERENCES` for more information. 

See also: `get_preferences`

# Example

Change your API key and default model:
```julia
# EMBEDDING_DIMENSION of 0 means the maximum allowed
AIHelpMe.set_preferences!("MODEL_CHAT" => "llama3", "MODEL_EMBEDDING" => "nomic-embed-text", "EMBEDDING_DIMENSION" => 0)
```
"""
function set_preferences!(pairs::Pair{String, <:Any}...)
    global ALLOWED_PREFERENCES, LOADED_PACKS
    for (key, value) in pairs
        @assert key in ALLOWED_PREFERENCES "Unknown preference '$key'! (Allowed preferences: $(join(ALLOWED_PREFERENCES,", "))"
        value_ = if key == "EMBEDDING_DIMENSION"
            value_int = convert(Int, value)
            @assert value_int>=0 "EMBEDDING_DIMENSION must be >= 0!"
            setproperty!(@__MODULE__, Symbol(key), value_int)
            @set_preferences!(key=>value_int)
        elseif key == "LOADED_PACKS"
            value_vecstr = value isa Symbol ? [string(value)] : string.(value)
            LOADED_PACKS = Symbol.(value_vecstr)
            @set_preferences!(key=>value_vecstr)
        else
            setproperty!(@__MODULE__, Symbol(key), value)
            @set_preferences!(key=>value)
        end
    end
    @info "Preferences set; restart your Julia session for this change to take effect!"
end
"""
    get_preferences(key::String)

Get preferences for AIHelpMe. See `?PREFERENCES` for more information.

See also: `set_preferences!`

# Example
```julia
AIHelpMe.get_preferences("MODEL_CHAT")
```
"""
function get_preferences(key::String)
    global ALLOWED_PREFERENCES
    @assert key in ALLOWED_PREFERENCES "Unknown preference '$key'! (Allowed preferences: $(join(ALLOWED_PREFERENCES,", "))"
    getproperty(@__MODULE__, Symbol(key))
end