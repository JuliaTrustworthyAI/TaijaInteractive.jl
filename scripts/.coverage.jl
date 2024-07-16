using Pkg
Pkg.test("TaijaInteractive"; coverage=true) # run runtests

Pkg.add("Coverage") #add coverage
using Coverage
coverage = process_folder() #add lines in src
coverage = append!(coverage, process_folder("app")) #add lines in app
covered_lines, total_lines = get_summary(coverage)
println("(", covered_lines / total_lines * 100, "%) covered") # print coverage
open("lcov.info", "w") do io #put 'report' into lcov.info
    LCOV.write(io, coverage)
end;
clean_folder(".")#remove .cov files
Pkg.rm("Coverage")# Remove Coverage
