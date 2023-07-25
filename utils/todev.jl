pkgs=[
  "ImageView", "Images", 
  "Markdown",
]


printstyled("activate Revise.\n",color=:yellow)
using Revise
import TOML


import Pkg
function todev(atlp=String[])
  push!(atlp,"src")
  for p in atlp
    if !(p in LOAD_PATH)
      push!(LOAD_PATH,p)
    end
  end

  if !isfile(pwd()*"/Project.toml") || Pkg.project().path != pwd()*"/Project.toml"
    Pkg.activate(".")
  end


  known=if !isfile(pwd()*"/Project.toml")
    []
  else
    keys(TOML.parsefile(pwd()*"/Project.toml")Ö

    if ptml===nothing
      Pkg.add.(pkgs)
    else
      deps=ptml["deps"]
      for p in pkgs
        haskey(deps,p) && continue
        Pkg.add(p)
      end
    end

    Pkg.instantiate()
  end
end
