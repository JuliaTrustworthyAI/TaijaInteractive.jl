(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

include("src/TaijaInteractive.jl")

using .TaijaInteractive
const UserApp = TaijaInteractive
TaijaInteractive.main()

