# tvar: logical, int-kind, float-kind 

module genalg_2
  using StatsBase, DataStructures, Distributions
  
  mutable struct _CHROME{TO,TV}
    obj::TO
    arr::Vector{TV}
  end

  const _NVAR=5
  const _TVAR=Float64
  const _TOBJ=Float64
  const _OBJ(x)=sum(x.^2)
  const _LB=0
  const _UB=1
  const _SIGMA_MUT=0.1
  const _P_MUT=0.05
  const _POP_SIZE=20
  const _OFF_PROP=1.0
  const _BETA=1.0
  const _MAX_STEP=500
  const _IDLE=nothing
  const _TOL=1e-4

  function mkadjust(T::DataType,LB,UB; mode::Symbol=:default)
    if mode===:default
      if T===Bool
        x->x
      else
        x->min(UB, max(LB, x))
      end
    else
      error("mkadjust: unsupported mode -> $(mode)")
    end
  end

  function mkmutate(T::DataType,SIGMA_MUT::Float64; mode::Symbol=:default)
    if mode===:default
      if T===Bool
        x->!x
      else
        mutdist=Normal(0, SIGMA_MUT)
        mutstep()=if T<:AbstractFloat
          rand(mutdist)
        else
          round(rand(mutdist), RoundingMode{:FromZero}())
        end
        x->x+mutstep()
      end
    else
      error("mkmutate: unsupported mode -> $(mode)")
    end
  end

  function mkcross(NVAR::Int; mode::Symbol=:default)
    if mode in [:default,:uniform]
      function (p1, p2, c1, c2)
        for i = 1:NVAR
          c1.arr[i], c2.arr[i] = if rand() < 0.5
            p1.arr[i], p2.arr[i]
          else
            p2.arr[i], p1.arr[i]
          end
        end
      end
    elseif mode===:point1
      function (p1, p2, c1, c2)
        cop=rand(2:NVAR-1) # NVAR>2
        c1.arr[1:cop],c2.arr[1:cop]=p1.arr[1:cop],p2.arr[1:cop]
        c1.arr[cop+1:NVAR],c2.arr[cop+1:NVAR]=p2.arr[cop+1:NVAR],p1.arr[cop+1:NVAR]
      end
    else
      error("mkcross: unsupported mode -> $(mode)")
    end
  end

  # get the urn to choose from
  function geturn(T::DataType,LB,UB)
    if T==Bool
      Bool
    else
      if T<:AbstractFloat
        Uniform(LB, UB)
      else
        DiscreteUniform(LB, UB)
      end
    end
  end
 

  function mkga(
    ;
    NVAR::Int=_NVAR,
    TVAR=_TVAR,
    TOBJ=_TOBJ,
    OBJ::Function=_OBJ,
    LB=_LB,
    UB=_UB,
    ADJUST::Union{Function,Symbol}=:default,
    MUTATE::Union{Function,Symbol}=:default,
    SIGMA_MUT::Float64=_SIGMA_MUT,
    P_MUT::Float64=_P_MUT,
    CROSS::Union{Function,Symbol}=:default,
    RANDINST::Union{Function,Symbol}=:default,
    POP_SIZE::Int=_POP_SIZE,
    OFF_PROP::Float64=_OFF_PROP,
    BETA::Float64=_BETA,
    SELECT::Union{Function,Symbol}=:default,
    MAX_STEP::Int=_MAX_STEP,
    IDLE::Union{Int,Nothing}=_IDLE,
    TOL::Float64=_TOL,
    OBSERVE::Function=(x...)->nothing
  )
    CHROME=_CHROME{TOBJ,TVAR}
    
    obj=OBJ
    obj!(x)=x.obj=obj(x.arr)

    LB::TVAR=TVAR(LB)
    UB::TVAR=TVAR(UB)

    adjust=if ADJUST isa Symbol
      adjust=mkadjust(TVAR,LB,UB; mode=ADJUST)
    else
      ADJUST
    end
    
    function adjust!(x) 
      x.arr .= adjust.(x.arr)
    end

    mutate=if MUTATE isa Symbol
      mutate=mkmutate(TVAR,SIGMA_MUT; mode=MUTATE)
    else
      MUTATE
    end
    
    function mutate!(x)
      IDX = (1:NVAR)[rand(NVAR).<P_MUT]
      x.arr[IDX] = adjust.(mutate.(x.arr[IDX]))
    end


    (cross!)=if CROSS isa Symbol
      mkcross(NVAR; mode=CROSS)
    else
      CROSS
    end

    
    randinst=if RANDINST isa Symbol
      ()->rand(geturn(TVAR,LB,UB),NVAR) # _todo_ randinst for permutations (for example) -> mkrandinst with mode...
    else
      RANDINST
    end

    function choose() 
      arr = randinst()
      CHROME(obj(arr),arr)
    end
    
    OFF_SIZE = (((POP_SIZE * OFF_PROP) |> ceil |> Int) ÷ 2) * 2
    
    # the definition of mkselect got here because select should know about a plenty 
    # of (already defined) functions and passing all of them inside the ga() would be "ugly"...
    function mkselect(; mode::Symbol=:default)
      if mode in [:default,:fitprop]
        function(pool,POP,OFF)
          d=1e-12
          w = Weights([exp(-BETA*POP[i].obj)+d for i = 1:POP_SIZE]) # the +d is to avoid a full zero `w` (and the error messages...-> _TODO_: computed BETA->sum(obj)? max(obj))
          @assert sum(w)>0
          idx = sample(1:POP_SIZE, w, OFF_SIZE; replace = true)
          for i = 1:2:OFF_SIZE
            p1, p2 = POP[idx[i]], POP[idx[i+1]]
            c1, c2 = OFF[i], OFF[i+1]
            cross!(p1, p2, c1, c2)
            mutate!(c1)
            obj!(c1)
            mutate!(c2)
            obj!(c2)
          end
          sort!(pool; by = x -> x.obj)
          pool[1]
        end
      else
        error("mkselsect: unsupported mode -> $(mode)")
      end
    end

    select=if SELECT isa Symbol
      mkselect(;mode=SELECT)
    else
      SELECT
    end
    
    
    # the process will stop at `step` if gbest[step] and gbest[step-idle+1] close to each other (no improvement in the last `idle` length interval)	
    if IDLE===nothing
      IDLE=min(30, floor(0.1 * MAX_STEP)|>Int)
    end
    
    INF=typemax(TOBJ)

    parstr = """POP_SIZE=$(POP_SIZE) OFF_SIZE=$(OFF_SIZE) MAX_STEP=$(MAX_STEP)
      P_MUT=$(P_MUT) SIGMA_MUT=$(SIGMA_MUT) BETA=$(BETA)"""


    function ga()
      gbest = choose()
      gbest.obj = INF

      tail = CircularBuffer{TOBJ}(IDLE)
      for i = 1:IDLE
        push!(tail, INF)
      end

      status = ("MAX_STEP", MAX_STEP)
      pool_size = (POP_SIZE + OFF_SIZE)
      pool = [choose() for k = 1:pool_size]

      POP = view(pool, 1:POP_SIZE)
      OFF = view(pool, (POP_SIZE+1):pool_size)

      for step = 1:MAX_STEP
        
        lbest = select(pool, POP, OFF)

        #println(POP)

        if lbest.obj < gbest.obj
          gbest = deepcopy(lbest)
        end
        
        OBSERVE(POP,gbest.obj)

        push!(tail, gbest.obj)
        if last(tail) + TOL > first(tail)
          status = ("IDLE", step)
          break
        end
      end # of main loop
      
      (best=gbest, status=status, parstr=parstr)

    end # of ga()
    ga
  end # of mkga()
  export mkga

end # of module
