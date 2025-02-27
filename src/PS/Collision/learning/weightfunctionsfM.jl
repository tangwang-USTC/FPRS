
"""
  The best weight function will decided by least-mean-square-error (LMSE) algorithm, which applys
      1. DOg-Leg in module LeastSquaresOptim.jl;
      2. Levenberg-Marquardt's (LM) algorithm in module LsqFit.jl or LeastSquaresOptim.jl;
      3. Guass-Newton's (GN) algorithm in module GaussNewton.jl method,
      with some basic models relative to the original function.

  For the distribution function `𝒇(v) = 𝒇ₗ(v)`, the weight function will be models in `fL0DMz.jl`:

  Totally, there will be `3s` or `3(ℓ+1)` parameters which will be decided by LMSE method.

"""

# # Normalized Harmonic models for Besselian distribution
 # p = [uai, vthi]
modelDMc(p,ℓ::Int64) = (ℓ + 0.5) * sqrt2pi / p^3  # p = vthi

function modelDMexp(v,p,ℓ::Int64)

    ℓ ≥ 1 || throw(ArgumentError("When `ℓ == 1`, please using function `modelDMexp(v,p)`!"))
    if p[1] == 0
        return (v,p,ℓ::Int64) -> 0p[1] * p[1] * v
    else
        if p[1] > 0
            return (v,p,ℓ::Int64) -> modelDMc(p[2],ℓ) * p[2] / (2p[1]).^0.5 ./ v.^0.5 .*
              exp.(- (v.^2 / p[2]^2 .+ p[1]^2 / p[2]^2)) .* besseli.(0.5+ℓ,(2p[1] / p[2]^2 * v))
        else
            if isodd(ℓ)
                return (v,p,ℓ::Int64) -> - modelDMc(p[2],ℓ) * p[2] / (-2p[1]).^0.5 ./ v.^0.5 .*
                  exp.(- (v.^2 / p[2]^2 .+ p[1]^2 / p[2]^2)) .* besseli.(0.5+ℓ,(-2p[1] / p[2]^2 * v))
            else
                return (v,p,ℓ::Int64) -> modelDMc(p[2],ℓ) * p[2] / (-2p[1]).^0.5 ./ v.^0.5 .*
                  exp.(- (v.^2 / p[2]^2 .+ p[1]^2 / p[2]^2)) .* besseli.(0.5+ℓ,(-2p[1] / p[2]^2 * v))
            end
        end
    end
end

# Especially, when `ℓ = 0`
function modelDMexp(v,p)
    
    if p[1] == 0.0
        return (v,p) -> exp.(- (v / p[2]).^2) / p[2]^3 + 0p[2] * v
    else
        if p[1] > 0
            return (v,p) -> sqrt2pi/2 / p[2]^3 * p[2] / (2p[1]).^0.5 ./ v.^0.5 .*
                     exp.(- (v.^2 / p[2]^2 .+ p[1]^2 / p[2]^2)) .* besseli.(0.5,(2p[1] / p[2]^2 * v))
        else
            return (v,p) -> sqrt2pi/2 / p[2]^3 * p[2] / (-2p[1]).^0.5 ./ v.^0.5 .*
                     exp.(- (v.^2 / p[2]^2 .+ p[1]^2 / p[2]^2)) .* besseli.(0.5,(-2p[1] / p[2]^2 * v))
        end
    end
end

# When `v = 0`   # modelDMc(p[2],ℓ) * √(2 / π)

# modelDMv0c(p,ℓ::Int64) = 1 / prod(3:2:(2ℓ-1)) / p^3
# modelDMexpv0(v::Float64,μu,p,ℓ::Int64) = modelDMv0c(μu,p[2],ℓ) *
#                 exp(- ((v^2 + p[1]^2) / p[2]^2)) * (2p[1] / p[2]^2 * v)^ℓ
modelDMexpv0(v::Float64,p,ℓ::Int64) = 0.0

modelDMexpv0(v::Float64,p) = exp.(- ((v.^2 .+ p[1]^2) / p[2]^2)) / p[2]^3


"""
  ⚈ Normalization of target function `ys` is performed defaultly.

  ✴ What is the best initial guess parameters `p` in LsqFit ?

  Input:
    vs:
    ys:
    u: = ûa[isp], the priori information to chose the initial parameter of the model.
    isnormal: (= true default) which denotes that `ys → ys / maximum(abs.(ys))`
    p: guess value of single harmonic model

  Outputs:
    counts,pa,modelM = fvLmodel(vs,ys,nai,uai,vthi;
                yscale=yscale,restartfit=restartfit,
                maxIterTR=maxIterTR,autodiff=autodiff,
                factorMethod=factorMethod,show_trace=show_trace,
                p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
    counts,pa,modelM = fvLmodel(vs,ys,nai,uai,vthi,ℓ;
                yscale=yscale,restartfit=restartfit,
                maxIterTR=maxIterTR,autodiff=autodiff,
                factorMethod=factorMethod,show_trace=show_trace,
                p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
"""

# # Single sub-model when `ℓ = 0`, `p = [wᵢ, σᵢ, uᵢ] = [nai,uai,vthi]`.
function fvLmodel(vs::AbstractVector{T},ys::AbstractVector{T},nai::T,uai::T,vthi::T;
    Nubs::Int64=2,yscale::T=1.0,restartfit::Vector{Int}=[0,0,100],maxIterTR::Int64=1000,
    autodiff::Symbol=:forward,factorMethod::Symbol=:QR,show_trace::Bool=false,
    p_tol::Float64=1e-18,f_tol::Float64=1e-18,g_tol::Float64=1e-18,is_fit::Bool=false) where{T}

    if yscale == 1.0
        p = [nai,uai,vthi]
    else
        p = [nai/yscale,uai,vthi]
    end
    modelDM(v,p) = p[1] * modelDMexp(v,p[2:3])(v,p[2:3])
    modelDMv0(v,p) = p[1] * modelDMexpv0(v,p[2:3])
    if is_fit
        lbs = zeros(T,3)
        ubs = p * Nubs
        counts, poly = fitTRMs(modelDM,vs,ys,copy(p),lbs,ubs;
                    restartfit=restartfit,maxIterTR=maxIterTR,autodiff=autodiff,
                    factorMethod=factorMethod,show_trace=show_trace,
                    p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
        return counts, poly.minimizer, modelDM, modelDMv0
    else
        return 0, p, modelDM, modelDMv0
    end
    # p = poly.minimizer         # the vector of best model1 parameters
    # inner_maxIterLM = poly.iterations
    # is_converged = poly.converged
    # pssr = poly.ssr                         # sum(abs2, fcur)
    # is_x_converged = poly.x_converged
    # is_f_converged = poly.f_converged
    # is_g_converged = poly.g_converged
    # optim_method = poly.optimizer
end

# # Single sub-model when `ℓ ≥ 1`, `p = [wᵢ, σᵢ, uᵢ]`
# # Optional upper and/or lower bounds on the free parameters can be passed as an argument
function fvLmodel(vs::AbstractVector{T},ys::AbstractVector{T},nai::T,uai::T,vthi::T,ℓ::Int64;
    Nubs::Int64=2,yscale::T=1.0,restartfit::Vector{Int}=[0,0,100],maxIterTR::Int64=1000,
    autodiff::Symbol=:forward,factorMethod::Symbol=:QR,show_trace::Bool=false,
    p_tol::Float64=1e-18,f_tol::Float64=1e-18,g_tol::Float64=1e-18,is_fit::Bool=false) where{T}

    if yscale == 1.0
        p = [nai,uai,vthi]
    else
        p = [nai/yscale,uai,vthi]
    end
    modelDM(v,p) = p[1] * modelDMexp(v,p[2:3],ℓ)(v,p[2:3],ℓ)
    # modelDMv0(v,p) = p[1] * modelDMexpv0(v,p[2:3],ℓ)
    modelDMv0(v,p) = 0.0
    if is_fit
        lbs = zeros(T,3)
        ubs = p * Nubs
        counts, poly = fitTRMs(modelDM,vs,ys,copy(p),lbs,ubs;restartfit=restartfit,
                    maxIterTR=maxIterTR,autodiff=autodiff,factorMethod=factorMethod,
                    show_trace=show_trace,p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
        return counts, poly.minimizer, modelDM, modelDMv0
    else
        return 0, p, modelDM, modelDMv0
    end
    # p = poly.minimizer         # the vector of best model1 parameters
    # inner_maxIterLM = poly.iterations
    # is_converged = poly.converged
    # pssr = poly.ssr                         # sum(abs2, fcur)
    # is_x_converged = poly.x_converged
    # is_f_converged = poly.f_converged
    # is_g_converged = poly.g_converged
    # optim_method = poly.optimizer
end

"""
  Input:
    vs:
    ys:

  Outputs:
    counts,pa,modelDM = fvLmodel(vs,ys,nai,uai,vthi;nMod=nMod,
                yscale=yscale,restartfit=restartfit,
                maxIterTR=maxIterTR,autodiff=autodiff,
                factorMethod=factorMethod,show_trace=show_trace,
                p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
    counts,pa,modelDM = fvLmodel(vs,ys,nai,uai,vthi,ℓ;nMod=nMod,
                yscale=yscale,restartfit=restartfit,
                maxIterTR=maxIterTR,autodiff=autodiff,
                factorMethod=factorMethod,show_trace=show_trace,
                p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
"""

# # [nMod], Mixture model when `ℓ = 0`
function fvLmodel(vs::AbstractVector{T},ys::AbstractVector{T},nai::AbstractVector{T},
    uai::AbstractVector{T},vthi::AbstractVector{T};nMod::Int64=2,Nubs::Int64=2,
    yscale::Float64=1.0,restartfit::Vector{Int}=[0,0,100],maxIterTR::Int64=1000,
    autodiff::Symbol=:forward,factorMethod::Symbol=:QR,show_trace::Bool=false,
    p_tol::Float64=1e-18,f_tol::Float64=1e-18,g_tol::Float64=1e-18,is_fit::Bool=false) where{T}

    p = zeros(T,3nMod)
    counters = 0
    if yscale == 1.0
        for i in 1:nMod
            counters += 1
            p[counters] = nai[i]
            counters += 1
            p[counters] = uai[i]
            counters += 1
            p[counters] = vthi[i]
        end
    else
        for i in 1:nMod
            counters += 1
            p[counters] = nai[i] / yscale
            counters += 1
            p[counters] = uai[i]
            counters += 1
            p[counters] = vthi[i]
        end
    end
    ubs = p * Nubs
    lbs = zeros(3nMod)
    if nMod == 2
        modelDM2(v,p) = p[1] * modelDMexp(v,p[2:3])(v,p[2:3]) + p[4] * modelDMexp(v,p[5:6])(v,p[5:6])
        modelDM2v0(v,p) = p[1] * modelDMexpv0(v,p[2:3]) + p[4] * modelDMexpv0(v,p[5:6])
        if is_fit
            counts, poly = fitTRMs(modelDM2,vs,ys,copy(p),lbs,ubs;restartfit=restartfit,
                        maxIterTR=maxIterTR,autodiff=autodiff,factorMethod=factorMethod,
                        show_trace=show_trace,p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
            return counts, poly.minimizer, modelDM2, modelDM2v0
        else
            return 0, p, modelDM2, modelDM2v0
        end
    elseif nMod == 3
        modelDM3(v,p) = p[1] * modelDMexp(v,p[2:3])(v,p[2:3]) + p[4] * modelDMexp(v,p[5:6])(v,p[5:6]) +
                        p[7] * modelDMexp(v,p[8:9])(v,p[8:9])
        modelDM3v0(v,p) = p[1] * modelDMexpv0(v,p[2:3]) + p[4] * modelDMexpv0(v,p[5:6]) + p[7] * modelDMexpv0(v,p[8:9])
        if is_fit
            counts, poly = fitTRMs(modelDM3,vs,ys,copy(p),lbs,ubs;restartfit=restartfit,
                        maxIterTR=maxIterTR,autodiff=autodiff,factorMethod=factorMethod,
                        show_trace=show_trace,p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
            return counts, poly.minimizer, modelDM3, modelDM3v0
        else
            return 0, p, modelDM3, modelDM3v0
        end
    else
        error("`nMod` must be not more than 3 now!")
    end
end

# # [nMod], Mixture model when `ℓ ≥ 1`
function fvLmodel(vs::AbstractVector{T},ys::AbstractVector{T},nai::AbstractVector{T},
    uai::AbstractVector{T},vthi::AbstractVector{T},ℓ::Int64;nMod::Int64=2,Nubs::Int64=2,
    yscale::Float64=1.0,restartfit::Vector{Int}=[0,0,100],maxIterTR::Int64=1000,
    autodiff::Symbol=:forward,factorMethod::Symbol=:QR,show_trace::Bool=false,
    p_tol::Float64=1e-18,f_tol::Float64=1e-18,g_tol::Float64=1e-18,is_fit::Bool=false) where{T}

    p = zeros(T,3nMod)
    counters = 0
    if yscale == 1.0
        for i in 1:nMod
            counters += 1
            p[counters] = nai[i]
            counters += 1
            p[counters] = uai[i]
            counters += 1
            p[counters] = vthi[i]
        end
    else
        for i in 1:nMod
            counters += 1
            p[counters] = nai[i] / yscale
            counters += 1
            p[counters] = uai[i]
            counters += 1
            p[counters] = vthi[i]
        end
    end
    lbs = zeros(3nMod)
    ubs = p * Nubs
    if nMod == 2
        modelDM2(v,p) = p[1] * modelDMexp(v,p[2:3],ℓ)(v,p[2:3],ℓ) + p[4] * modelDMexp(v,p[5:6],ℓ)(v,p[5:6],ℓ)
        # modelDM2v0(v,p) = p[1] * modelDMexpv0(v,p[2:3],ℓ) + p[4] * modelDMexpv0(v,p[5:6],ℓ)
        modelDM2v0(v,p) = 0.0
        if is_fit
            counts, poly = fitTRMs(modelDM2,vs,ys,copy(p),lbs,ubs;restartfit=restartfit,
                        maxIterTR=maxIterTR,autodiff=autodiff,factorMethod=factorMethod,
                        show_trace=show_trace,p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
            return counts, poly.minimizer, modelDM2, modelDM2v0
        else
            return 0, p, modelDM2, modelDM2v0
        end
    elseif nMod == 3
        modelDM3(v,p) = p[1] * modelDMexp(v,p[2:3],ℓ)(v,p[2:3],ℓ) + p[4] * modelDMexp(v,p[5:6],ℓ)(v,p[5:6],ℓ) +
                        p[7] * modelDMexp(v,p[8:9],ℓ)(v,p[8:9],ℓ)
        # modelDM3v0(v,p) = p[1] * modelDMexpv0(v,p[2:3],ℓ) + p[4] * modelDMexpv0(v,p[5:6],ℓ) + p[7] * modelDMexpv0(v,p[8:9],ℓ)
        modelDM3v0(v,p) = 0.0
        if is_fit
            counts, poly = fitTRMs(modelDM3,vs,ys,copy(p),lbs,ubs;restartfit=restartfit,
                        maxIterTR=maxIterTR,autodiff=autodiff,factorMethod=factorMethod,
                        show_trace=show_trace,p_tol=p_tol,f_tol=f_tol,g_tol=g_tol)
            return counts, poly.minimizer, modelDM3, modelDM3v0
        else
            return 0, p, modelDM3, modelDM3v0
        end
    else
        error("`nMod` must be not more than 3 now!")
    end
end
