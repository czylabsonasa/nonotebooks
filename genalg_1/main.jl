using genalg_1
using CairoMakie

@time (best,status,trace,parstr)=ga1()
println(best,"\n",status)
set_theme!(theme_dark())
update_theme!(;Axis=(;title=parstr),resolution=(800,600))
lines(trace)
