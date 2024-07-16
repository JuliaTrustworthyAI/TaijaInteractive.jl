using Documenter, TaijaInteractive

## ??? 
makedocs(;
    modules=[TaijaInteractive],
    sitename="TaijaInteractive.jl Documentation",
    repo=Documenter.Remotes.GitHub("juliatrustworthyai", "TaijaInteractive.jl"),
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://gitlab.ewi.tudelft.nl/cse2000-software-project/2023-2024/cluster-h/06e/taijainteractive.jl.git",
        assets=String[],
        size_threshold_ignore=["reference.md"],
    ),
    pages=[
        "🏠 Home" => "index.md",
        "🫣 Tutorials" => [
            "Overview" => "tutorials/index.md",
            "Simple Example" => "tutorials/simpleExample.md",
            "Whistle-Stop Tour" => "tutorials/whistleStop.md",
            "Handling Data" => "tutorials/data.md",
            "Handling Models" => "tutorials/model.md",
            "Handling Counterfactual" => "tutorials/counterfactual.md",
            "Handling Conformal" => "tutorials/conformal.md",
            "Handling Laplace Redux" => "tutorials/laplace.md",
        ],
        "🤓 Explanation" => [
            "Overview" => "explanations/index.md",
            "Software Architecture" => "explanations/softwareArchitecture.md",
            "Database Setup" => "explanations/database.md",
            "Frontend Views" => "explanations/views.md",
        ],
        "Extending The App" => "tutorials/extensions.md"
        "Reference" => "reference.md",
        "Conventions" => "conventions.md",
    ],
)
