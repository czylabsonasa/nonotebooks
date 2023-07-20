include("todev.jl"); todev()

using graphcol_1

using Graphs, Colors, DataFrames, StatsBase, CairoMakie, GraphMakie
using ImageView: imshow
using Images


# read the data
data = graphcol_1_data()
G = data.G
num_of_students = data.num_of_students
num_of_courses = data.num_of_courses
header = data.header


# plot the graph
deg = degree(G)
oriG = graphplot(
  G,
  node_size = deg,
  node_color = "Purple",
  edge_color = "LightGray",
  edge_width = 0.5,
)
hidedecorations!(scene.axis)
printstyled("the original graph:\n",color=:blue)
if isdefined(Main,:_JLAB_)
  oriG|>display # from repl, it overwrites the previous png (display.png)
else
  save("oriG.png",oriG)
  imshow(load("oriG.png"))
end


# as in networkX in Graph.jl there is a "builtin" method 
# greedy_color(G; reps) to generate 
# colorings, therefore we'll use it
# it returns an object w/ num_colors and colors fields
# we need col.num_colors dates for the exams
printstyled("\nexecute greedy_color:\n", color=:blue)
@time the_coloring = greedy_color(G; reps = 100)


dc = distinguishable_colors(the_coloring.num_colors, colorant"blue")

# first is the innermost
the_shells = [[] for c = 1:the_coloring.num_colors]
for v in vertices(G)
  push!(the_shells[the_coloring.colors[v]], v)
end
sort!(the_shells, by = x -> length(x))

colored_G = graphplot(
  G,
  layout = GraphMakie.Shell(; nlist = the_shells),
  node_size = deg,
  node_color = dc[the_coloring.colors],
  edge_color = "LightGray",
  edge_width = 0.5,
)
hidedecorations!(colored_G.axis)
printstyled("\nthe colored graph (shell layout):\n",color=:blue)
if isdefined(Main,:_JLAB_)
  colored_G|>display # from repl, it overwrites the previous png (display.png)
else
  save("colored_G.png",colored_G)
  imshow(load("colored_G.png"))
end


# we need maxcolsize rooms
cm = the_coloring.colors |> countmap
mincolsize, maxcolsize = extrema(nc for (c, nc) in cm)

# build the final table
# exams for courses with the color 'k' will be held on the 'k'-th date given
table = fill("-", the_coloring.num_colors, maxcolsize) # indices for filling in
idx = fill(0, the_coloring.num_colors)
for i = 1:num_of_courses
  ri = the_coloring.colors[i]
  ci = (idx[ri] += 1)
  table[ri, ci] = header[i]
end


printstyled("\na possible exam schedule:\n", color=:blue)
df = DataFrame(
  hcat("Exam-" .* string.(1:the_coloring.num_colors), table),
  vcat("Exam", "Room-" .* string.(1:maxcolsize)),
)|>display

