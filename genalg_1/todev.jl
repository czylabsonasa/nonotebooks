if !("src" in LOAD_PATH)
  push!(LOAD_PATH,"src")
end

using Revise

import Pkg
function todev()
  if Pkg.project().path != pwd()*"/Project.toml"
    Pkg.activate(".")

    pkgs=[
      "StatsBase", "DataStructures", "Distributions", "CairoMakie",
    ]

    Pkg.add.(pkgs)

    Pkg.instantiate()
  end
end
