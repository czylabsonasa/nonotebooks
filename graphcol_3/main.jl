include("todev.jl"); todev(["../graphcol_2/src"])
using graphcol_2: graphcol_bt
using Graphs

#### convert the col's to lg's
printstyled("convert the col's to lg's in a directory\n",color=:light_white)
for f in readdir("../data/col-instances/"; join = true)
  sf = split(f, '.')
  if sf[end] == "col"
    jf = join(sf[1:end-1], '.')
    isfile("$(jf).lg") && isfile("$(jf).opt") && continue
    loadcol(f; tolg = true, toopt = true)
  end
end

# test 
printstyled("""
\nperform some tests w/ the newly converted data+graphcol_bt
note, that we know optimum and it will be used
""",color=:light_blue)
G = loadgraph("../data/col-instances/queen5_5.lg")
opt = parse(Int, read("../data/col-instances/queen5_5.opt", String))
printstyled("\ndata: queen5_5.lg, opt=$(opt)\n", color=:light_yellow)
printstyled("\ngraphcol_bt+coloring w/ $(opt-1) colors\n", color=:green)
@time graphcol_bt(G, opt - 1) |> println
printstyled("\ngraphcol_bt+coloring w/ $(opt) colors\n", color=:green)
@time graphcol_bt(G, opt) |> println
reps=33
printstyled("\ngreedy_color, reps=$(reps)\n", color=:green)
@time greedy_color(G, reps = reps) |> println
