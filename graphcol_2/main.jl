include("todev.jl"); todev(["../graphcol_1/src"])

using graphcol_1
using graphcol_2
using Graphs

printstyled("some small tests w/ cyclic graphs\n",color=:white)
for t in 1:2
  n = rand(3:9)
  G2 = cycle_graph(n)
  printstyled("\nvertices => $(n)\n",color=:yellow)
  printstyled("\nusing 3 colors:\n",color=:green)
  @time a = graphcol_bt(G2, 3)
  println("  ",a)
  printstyled("\nusing 2 colors:\n",color=:green)
  @time b = graphcol_bt(G2, 2)
  println(b)
end

# and use graphcol_bt for the original data of project_1
data = graphcol_1_data()
G = data.G
printstyled("""\n\nthe "courses" graph\n""",color=:yellow)
printstyled("\nusing 9 colors:\n",color=:green)
@time ok = graphcol_bt(G, 9)
println(ok)
printstyled("\nusing 8 colors:\n",color=:green)
@time nok = graphcol_bt(G, 8)
println(nok)
