"""
    aihelp"user_question"[model_alias] -> AIMessage

The `aihelp""` string macro generates an AI response to a given user question by using `aihelp` under the hood.
It will automatically try to provide the most relevant bits of the documentation (from the index) to the LLM to answer the question.

See also `aihelp!""` if you want to reply to the provided message / continue the conversation.

## Arguments
- `user_question` (String): The question to be answered by the AI model.
- `model_alias` (optional, any): Provide model alias of the AI model (see `MODEL_ALIASES`).

## Returns
`AIMessage` corresponding to the input prompt.

## Example
```julia
result = aihelp"Hello, how are you?"
# AIMessage("Hello! I'm an AI assistant, so I don't have feelings, but I'm here to help you. How can I assist you today?")
```

If you want to interpolate some variables or additional context, simply use string interpolation:
```julia
a=1
result = aihelp"What is `\$a+\$a`?"
# AIMessage("The sum of `1+1` is `2`.")
```

If you want to use a different model, eg, GPT-4, you can provide its alias as a flag:
```julia
result = aihelp"What is `1.23 * 100 + 1`?"gpt4t
# AIMessage("The answer is 124.")
```
"""
macro aihelp_str(user_question, flags...)
    global CONV_HISTORY, MAX_HISTORY_LENGTH, MAIN_INDEX
    model = isempty(flags) ? PT.MODEL_CHAT : only(flags)
    prompt = Meta.parse("\"$(escape_string(user_question))\"")
    quote
        conv = aihelp($(esc(MAIN_INDEX)), $(esc(prompt));
            model = $(esc(model)),
            return_all = true)
        PT.push_conversation!($(esc(CONV_HISTORY)), conv, $(esc(MAX_HISTORY_LENGTH)))
        last(conv)
    end
end

"""
    aihelp!"user_question"[model_alias] -> AIMessage

The `aihelp!""` string macro is used to continue a previous conversation with the AI model. 

It appends the new user prompt to the last conversation in the tracked history (in `AIHelpMe.CONV_HISTORY`) and generates a response based on the entire conversation context.
If you want to see the previous conversation, you can access it via `AIHelpMe.CONV_HISTORY`, which keeps at most last `PromptingTools.MAX_HISTORY_LENGTH` conversations.

It does NOT provide new context from the documentation. To do that, start a new conversation with `aihelp"<question>"`.

## Arguments
- `user_question` (String): The follow up question to be added to the existing conversation.
- `model_alias` (optional, any): Specify the model alias of the AI model to be used (see `PT.MODEL_ALIASES`). If not provided, the default model is used.

## Returns
`AIMessage` corresponding to the new user prompt, considering the entire conversation history.

## Example
To continue a conversation:
```julia
# start conversation as normal
aihelp"How to create a dictionary?" 

# ... wait for reply and then react to it:

# continue the conversation (notice that you can change the model, eg, to more powerful one for better answer)
aihelp!"Can you create it from named tuple?"gpt4t
# AIMessage("Yes, you can create a dictionary from a named tuple ...")
```

## Usage Notes
- This macro should be used when you want to maintain the context of an ongoing conversation (ie, the last `ai""` message).
- It automatically accesses and updates the global conversation history.
- If no conversation history is found, it raises an assertion error, suggesting to initiate a new conversation using `ai""` instead.

## Important
Ensure that the conversation history is not too long to maintain relevancy and coherence in the AI's responses. The history length is managed by `MAX_HISTORY_LENGTH`.
"""
macro aihelp!_str(user_question, flags...)
    global CONV_HISTORY, LAST_CONTEXT, MAIN_INDEX
    model = isempty(flags) ? PT.MODEL_CHAT : only(flags)
    prompt = Meta.parse("\"$(escape_string(user_question))\"")
    quote
        @assert !isempty($(esc(CONV_HISTORY))) "No conversation history found. Please use `aihelp\"\"` instead."
        # grab the last conversation, drop system messages
        old_conv = $(esc(CONV_HISTORY))[end]
        conv = aigenerate(vcat(old_conv, [PT.UserMessage($(esc(prompt)))]);
            model = $(esc(model)),
            return_all = true)
        # replace the last conversation with the new one
        $(esc(CONV_HISTORY))[end] = conv
        # 
        last(conv)
    end
end