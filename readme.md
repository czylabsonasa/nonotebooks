#### project_0
* back to the good old repl+revise+geany/micro+a little jupyter(lab)
* workflow:
  * cd target_dir -> start julia -> develop src/module and/or main.jl <-
  * main.ipynb is only for presenting the results
* todev -> modify LOAD_PATH + Revise + Pkg related stuff
* tomdcode -> render the source code into the notebook (Markdown.jl)


#### [graphcol_1](graphcol_1)
* graph coloring basics - a remake of [https://towardsdatascience.com/graph-coloring-with-networkx](https://towardsdatascience.com/graph-coloring-with-networkx-88c45f09b8f4) in julia

#### [graphcol_2](graphcol_2)
* `graphcol_bt`: apply a simple backtracking/exhaustive search method for the graph in graphcol_1.


#### [graphcol_3](graphcol_3)
* load dimacs graph files/ convert them to lg format: `loadcol`
* some tests w/ the greedy+graphcol_bt
  
#### [genalg_1](genalg_1)
* simple genetic algorithm in julia - implementation based (at least partly) on [this](https://pub.towardsai.net/genetic-algorithm-ga-introduction-with-example-code-e59f9bc58eaf), with source on [github](https://github.com/towardsai/tutorials/blob/master/genetic-algorithm-tutorial/implementation.py)

#### [genalg_2](genalg_2)
* a draft version (with lot of todos) of a refined genalg_1 

