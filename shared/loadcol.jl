
# .col extension is a must
function loadcol(gfile::String; tolg = false, toopt = false)
  _e(msg) = error("loadcol: $(msg)")

  !isfile(gfile) && _e("no such file")
  sfile = split(gfile, '.')
  (sfile[end] != "col") && _e("wrong extension")
  gstring = split(read(gfile, String), '\n', keepempty = false)

  num_colors = -1
  E = []
  nV, nE, tV = -1, -1, -1
  for line in gstring
    sline = split(line, keepempty = false)
    (sline[1] == "c") && continue

    if sline[1] == "p" # only the last counts, but must precede the first 'p' line, bcos it  is used in a sanity check
      nV, nE = parse.(Int, sline[3:end])
      continue
    end
    if sline[1] == "e"
      a, b = parse.(Int, split(line)[2:end])
      if a < 1 || a > nV || b < 1 || b > nV
        _e("vertex is out of range")
      end
      push!(E, (a, b))
      continue
    end
    if sline[1] == "num_colors"
      num_colors = parse(Int, sline[2])
      continue
    end
  end
  if nV < 0 || nE < 0 || length(E) != nE
    _e("wrong data")
  end
  G = Graph()
  add_vertices!(G, nV)
  for (a, b) in E
    add_edge!(G, a, b)
  end
  if tolg == true
    sfile = join(sfile[1:end-1], '.')
    savegraph("$(sfile).lg", G)
    printstyled(stderr, "saved $(sfile).lg\n"; color = :green)
  end
  if num_colors > 0 && toopt == true
    open("$(sfile).opt", "w") do f
      println(f, num_colors)
    end
    printstyled(stderr, "saved $(sfile).opt\n"; color = :yellow)
  end
  G
end

