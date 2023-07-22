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
  const _obj(x)=sum(x.^2)
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

 
  function mkga(
    ;
    NVAR::Int=_NVAR,
    TVAR=_TVAR,
    TOBJ=_TOBJ,
    obj::Function=_obj,
    LB=_LB,
    UB=_UB,
    adjust::Union{Function,Nothing}=nothing,
    mutate::Union{Function,Nothing}=nothing,
    SIGMA_MUT::Float64=_SIGMA_MUT,
    P_MUT::Float64=_P_MUT,
    #cross -> _todo_
    #choose -> _todo_
    POP_SIZE::Int=_POP_SIZE,
    OFF_PROP::Float64=_OFF_PROP,
    BETA::Float64=_BETA,
    # selection -> _todo_
    MAX_STEP::Int=_MAX_STEP,
    IDLE::Union{Int,Nothing}=_IDLE,
    TOL::Float64=_TOL,
  )
    CHROME=_CHROME{TOBJ,TVAR}
    
    obj!(x)=x.obj=obj(x.arr)

    LB::TVAR=TVAR(LB)
    UB::TVAR=TVAR(UB)

    if adjust===nothing 
      adjust=if TVAR===Bool
        x::Bool->x
      else
        x->min(UB, max(LB, x))
      end
    end
    
    function adjust!(x) #if adjust is userdefined then this?... (same4mutate)
      x.arr .= adjust.(x.arr)
    end

    if mutate===nothing
      mutate=if TVAR===Bool
        x::Bool->!x
      else
        mutdist=Normal(0, SIGMA_MUT)
        mutstep()=if TVAR<:AbstractFloat
          rand(mutdist)
        else
          round(rand(mutdist), RoundingMode{:FromZero}())
        end
        x->adjust(x+mutstep())
      end
    end
    
    function mutate!(x)
      IDX = (1:NVAR)[rand(NVAR).<P_MUT]
      x.arr[IDX] = mutate.(x.arr[IDX])
    end

    # default+user?
    function cross!(p1, p2, c1, c2)
      for i = 1:NVAR
        c1.arr[i], c2.arr[i] = if rand() < 0.5
          p1.arr[i], p2.arr[i]
        else
          p2.arr[i], p1.arr[i]
        end
      end
    end

    # random chromosome
    choosen=if TVAR==Bool
      (n::Int)->rand(Bool,n)
    else
      if TVAR<:AbstractFloat
        (n::Int)->rand(Uniform(LB, UB), n)
      else
        (n::Int)->rand(DiscreteUniform(LB, UB), n)
      end
    end

    function choose() 
      arr = choosen(NVAR)
      CHROME(obj(arr),arr)
    end
    
    OFF_SIZE = (((POP_SIZE * OFF_PROP) |> ceil |> Int) ÷ 2) * 2

    # user+default?...
    function selection(pool, POP, OFF)
      w = Weights([exp(-BETA*POP[i].obj) for i = 1:POP_SIZE])
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

    # the process will stop at `step` if gbest[step] and gbest[step-idle+1] close to each other (no improvement in the last `idle` length interval)	
    if IDLE===nothing
      IDLE=min(30, floor(0.1 * MAX_STEP)|>Int)
    end
    
    STOP = (IDLE = IDLE, TOL = TOL)

    parstr = """POP_SIZE=$(POP_SIZE) OFF_SIZE=$(OFF_SIZE) MAX_STEP=$(MAX_STEP)
      P_MUT=$(P_MUT) SIGMA_MUT=$(SIGMA_MUT) BETA=$(BETA)"""

    INF=typemax(TOBJ)

    function ga()
      trace = Float32[]
      gbest = choose()
      gbest.obj = INF

      tail = CircularBuffer{Float64}(STOP.IDLE)
      for i = 1:STOP.IDLE
        push!(tail, Inf)
      end

      status = ("MAX_STEP", MAX_STEP)
      pool_size = (POP_SIZE + OFF_SIZE)
      pool = [choose() for k = 1:pool_size]

      POP = view(pool, 1:POP_SIZE)
      OFF = view(pool, (POP_SIZE+1):pool_size)

      for step = 1:MAX_STEP
        lbest = selection(pool, POP, OFF)

        #println(POP)


        if lbest.obj < gbest.obj
          gbest = deepcopy(lbest)
        end
        push!(trace, gbest.obj)

        push!(tail, gbest.obj)
        if last(tail) + STOP.TOL > first(tail)
          status = ("IDLE", step)
          break
        end
      end # of main loop
      gbest, status, trace, parstr

    end # of ga()
    ga
  end # of mkga()
  export mkga

end # of module
