
  # the backtracking solution
  # it is a naive implementation w/o any smartness,
  # just administration

  function graphcol_bt(G::Vector{Vector{Int}}, maxcol::Int) # max number of colors
    # the actual color are in 1..maxcol
    N = length(G)

    forbidden = fill(0, maxcol, N)
    # colors currently forbidden for a particular node
    # forbidden=already reserved by some of its neighbour
    # reserved if >0

    # actual and returned colorings
    color = fill(0, N) # for work with
    color_ret = fill(0, N)

    # modifies the forbidden and color arrays
    function paint(node, c)
      oldc = color[node]
      if oldc > 0
        for t in G[node]
          forbidden[oldc, t] -= 1
        end
      end

      color[node] = c
      (c == 0) && return

      for t in G[node]
        forbidden[c, t] += 1
      end
    end

    found = false
    paint(1, 1)

    function trav(node)
      if node > N
        found = true
        color_ret .= color
        return
      end


      for c = 1:maxcol
        (forbidden[c, node] > 0) && continue
        paint(node, c)
        trav(node + 1)
        found && break
      end

      paint(node, 0) # restore the original state
    end # of trav

    trav(2)
    (found, color_ret)
  end


  # a method (variant) that takes a Graph() instance and returns a similar
  # object that is returned by Graphs.random_greedy_color
  # (imitating by namedtuple)
  function graphcol_bt(G::Graph, maxcol::Int) # max number of colors
    GG = [Int[] for n = 1:nv(G)]
    for e in edges(G)
      a, b = src(e), dst(e)
      push!(GG[a], b)
      push!(GG[b], a)
    end
    found, color = graphcol_bt(GG, maxcol)
    if found
      (num_colors = length(Set(color)), colors = color)
    else
      (num_colors = -1, colors = nothing)
    end
  end

