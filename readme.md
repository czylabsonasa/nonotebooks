#### project_0
* back to the good old repl+revise+geany+a little jupyter(lab)
* workflow:
  * cd target_dir; start julia; include("todev.jl"); develop src/module or main.jl...
  * main.ipynb/main.md are only for see the pictorial results
* todev -> modify LOAD_PATH + Revise + Pkg related stuff
* tomdcode -> render the source code into the notebook (Markdown.jl)


#### [graphcol_1](graphcol_1)
* graph coloring basics - a remake of [https://towardsdatascience.com/graph-coloring-with-networkx](https://towardsdatascience.com/graph-coloring-with-networkx-88c45f09b8f4) in julia

#### [graphcol_2](graphcol_2)
* `graphcol_bt`: apply a simple backtracking/exhaustive search method for the graph in graphcol_1.


#### [graphcol_3](graphcol_3)
* load dimacs graph files/ convert them to lg format: `loadcol`
* some tests w/ the greedy
  
#### [genalg_1](genalg_1)
* simple genetic algorithm in julia - implementation based (at least partly) on [this](https://pub.towardsai.net/genetic-algorithm-ga-introduction-with-example-code-e59f9bc58eaf), with source on [github](https://github.com/towardsai/tutorials/blob/master/genetic-algorithm-tutorial/implementation.py)

