# TaijaInteractive

Documentation for [TaijaInteractive.jl](https://github.com/juliatrustworthyai/TaijaInteractive.jl).

`TaijaInteractive.jl` is a package for connecting [Taija](https://github.com/JuliaTrustworthyAI) packages with a graphical user interface. Taija currently covers a range of approaches towards making AI systems more trustworthy. Currently, [Counterfactual explanations](https://github.com/JuliaTrustworthyAI/CounterfactualExplanations.jl?tab=readme-ov-file), [Conformal predictions](https://github.com/JuliaTrustworthyAI/ConformalPrediction.jl) and [Laplace Reductinos](https://github.com/JuliaTrustworthyAI/LaplaceRedux.jl) are supported.
## 🚩 Installation

### Installing the package
You can install the stable release from [Julia’s General Registry](https://github.com/JuliaRegistries/General) as follows:

``` julia
using Pkg
Pkg.add("TaijaInteractive")
```

`TaijaInteractive.jl` is under active development. To install the development version of the package you can run the following command:

``` julia
using Pkg
Pkg.add(url="https://github.com/juliatrustworthyai/TaijaInteractive.jl")
```

### Setting up the project

To set up the project, follow these steps:

0. Make sure you have [Julia](https://julialang.org/) installed.

1. Open a terminal and navigate to the project's repository directory.

2. Start Julia by typing `julia` in the terminal.

3. Activate the project:
   - Press `]` to enter the package manager
   - Run `activate .` to activate the project in the current directory

4. Run the `bootstrap.jl` file:
   - Right-click on the `bootstrap.jl` file
   - Select "Execute file in REPL"

### Setting up the database (SQLite)

After the REPL is loaded, set up the database by running the following commands:

```julia
using SearchLight
using SearchLightSQLite

SearchLight.Migrations.init() # Run this only the first time
SearchLight.Configuration.load() |> SearchLight.connect
SearchLight.Migrations.up()
```

To ensure all tables are up, run:
```julia
SearchLight.Migrations.status()
```

If a table is not up, you can fix it by running:
```julia
SearchLight.Migrations.up("TableName") # Replace "TableName" with the actual table name from the status output
```

## 🤔 Background and Motivation

The Taija Ecosystem offers a suite of powerful tools for advanced data analysis and machine learning, including the TaijaCounterfactual package. However, these packages often require users to have coding experience and a deep understanding of the underlying algorithms. This creates a barrier for individuals who could benefit from these tools but lack the necessary technical skills.

> "The power of the Web is in its universality. Access by everyone regardless of disability is an essential aspect."
>
> — Adam Osborne, in [*Times Magazine*](https://time.com/archive/6699317/the-computer-moves-in/), 1983

## 🔮 Enter:  TaijaInteractive

TaijaInteractive is a user-friendly package that enables individuals with no coding experience to easily run various packages within the Taija Ecosystem, including TaijaCounterfactual. By providing an intuitive interface and abstracting away the complexities, TaijaInteractive makes these powerful tools accessible to a wider audience.

Key benefits of TaijaInteractive include:

- Accessibility: Democratizes access to advanced data analysis tools for users with limited technical skills.
- Streamlined workflow: Simplifies the process of running complex analyses from multiple Taija packages.
- Integration: Seamlessly integrates with the entire Taija Ecosystem, allowing users to leverage its full power.


## 🔍 Usage Example

A typical use case scenario will look like follows. Below we create a new board and enter it by clicking on it.

Then we add a local dataset from our own machine.

Afterwards we train a model on that dataset.

Finally we create a counterfactual explanation.

## 🎯 Goals and Limitations

The goal of TaijaInteractive is to contribute to the efforts towards making the Taija Ecosystem more accessible and user-friendly. By providing an intuitive interface for running various packages within the ecosystem, TaijaInteractive aims to enable users with limited coding experience to leverage the power of these tools.

However, it's important to note that TaijaInteractive is not a replacement for understanding the underlying algorithms and their limitations. While it simplifies the process of running analyses, users should still be aware of the assumptions and constraints of the packages they are using.

TaijaInteractive's ambition is to enhance the package through the following features:

1. Extend support to all Taija packages, ensuring that users can leverage the full power of the ecosystem through a single, intuitive interface.
2. We want to make sure that TaijaInteractive is easily extandible for future developers.

## 🛠 Contribute

Contributions of any kind are very much welcome! Take a look at the [issue](https://github.com/JuliaTrustworthyAI/TaijaInteractive.jl/issues) to see what things we are currently working on. If you have an idea for a new feature or want to report a bug, please open a new issue.

### Development

If your looking to contribute code, it may be helpful to check out the [Explanation]() section of the docs.

#### Testing

Please always make sure to add tests for any new features or changes.

#### Documentation

If you add new features or change existing ones, please make sure to update the documentation accordingly. The documentation is written in [Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/) and is located in the `docs/src` folder.
