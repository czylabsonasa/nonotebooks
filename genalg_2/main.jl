include("todev.jl"); todev()
using genalg_2

using StatsBase
using CairoMakie, ImageView, Images
CairoMakie.activate!(;visible=false)

function showplot(p; name="noname")
  if isdefined(Main,:_JLAB_)
    p|>display
  else
    save("$(name).png",p)
    imshow(load("$(name).png"); name=name)
  end
end


function mkobserve(info)
  function observe(POP,best)
    push!(info.bests,best)
    objs=[p.obj for p in POP]
    push!(info.means,mean(objs))
    push!(info.vars,var(objs; corrected=false))
  end
  observe
end

set_theme!(theme_ggplot2())
# test 
printstyled("""
\nperform some tests w/ the newly developed `ga()`
""",color=:light_blue)

printstyled("\nproblem: the square function w/ NVAR=5 variables and Float64 variable types\n", color=:light_yellow)

trace=(bests=Float64[],means=Float64[],vars=Float64[])
#ga=mkga(; OBSERVE=mkobserve(trace), NVAR=22)
ga=mkga(; NVAR=22)


@time ret=ga()
println(ret.best,"\n",ret.status)
parstr=ret.parstr*"\n square, NVAR=5, TVAR=Float64"
exit(0)

update_theme!(;Axis=(;title=parstr),resolution=(800,600))

showplot(lines(trace.bests); name="bests")
showplot(lines(trace.means); name="means")
showplot(lines(trace.vars); name="vars")




#printstyled("\nproblem: the square function NVAR=15, TVAR=Int32\n", color=:light_yellow)
#trace=Float64[]
#ga=mkga(; TVAR=Int32, NVAR=15, OBSERVE=mkobserve(trace))
#@time ret=ga()
#println(ret.best,"\n",ret.status)
#parstr=ret.parstr*"\n square, NVAR=15, TVAR=Int32, TOBJ=Int32"
#update_theme!(;Axis=(;title=parstr),resolution=(800,600))
#p2=lines(trace)
#if isdefined(Main,:_JLAB_)
#  p2|>display 
#else
#  save("p2.png",p2)
#  imshow(load("p2.png"); name="p2")
#end
