# Notes for Makie evaluation

This folder contains the first iteration of the Q&A evaluation data set for Makie.jl ecosystem knowledge pack.

Source: Makie.jl repo, gh-pages branch, "dev" folder in each package. Cut-off date 2024-03-30.

To load the data, simply use:

```julia
using JSON3
fn = "makie_evals.json"
qa_evals_questions = JSON3.read(fn, Vector{RT.QAEvalItem});
```

## Files available:

- `makie_evals_questions_only.json` - Questions only, generated manually
- `makie_evals.json` - Q&A evaluation data set (context, question, answer), generated automatically with `build_qa_evals` functionality and filtered down.
