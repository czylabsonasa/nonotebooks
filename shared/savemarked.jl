# word-counter :-) from K-R

function savemarked()
  #herein=readdir(".")
  #idx=findfirst(x->startswith(x,"project_"),herein)
  #(idx===nothing) && return
  within="main.jl"
  
  lines=split(read(within,String),'\n',keepempty=true)

  state=(pat="",n0=-1)
  for n in 1:length(lines)
    theline=lines[n]|>lstrip
    if startswith(theline,"#--->")
      if state.pat!=""
        open("../shared/$(state.pat).jl","w") do f 
          println(f, join(lines[state.n0+1:n-1],'\n'))
          printstyled(stderr,"saved $(state.pat).jl\n",color=:yellow)
        end
      else
        state=(pat=split(theline,">")[2],n0=n)
      end
    end
  end
end
