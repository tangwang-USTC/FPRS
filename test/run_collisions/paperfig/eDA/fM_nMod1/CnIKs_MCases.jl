
# [Cn, CI, CK, Cs]
is_out_CnIKs = false

is_CK_logy = true
is_Cn_logy = true
xlabel = "t"               

ylabel = string("Δnₛ")
if is_enforce_errdtnIKab
    title = string("")
    if is_Cn_logy
        iCasep = 1
        label = string(nnvocpM[iCasep])
        pCRDnM = plot(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                        ylabel=ylabel,yscale=:log10,
                        title=title)
        iCasep = 2
        label = string(nnvocpM[iCasep])
        pCRDnM = plot!(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                        label=label)
        if NCase ≥ 3
            iCasep = 3
            label = string(nnvocpM[iCasep])
            pCRDnM = plot!(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                            label=label)
        end
    else
        iCasep = 1
        label = string(nnvocpM[iCasep])
        pCRDnM = plot(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                        ylabel=ylabel,
                        title=title)
        iCasep = 2
        label = string(nnvocpM[iCasep])
        pCRDnM = plot!(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
        if NCase ≥ 3
            iCasep = 3
            label = string(nnvocpM[iCasep])
            pCRDnM = plot!(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
        end
    end
else
    if is_Cn_logy
        iCasep = 1
        label = string(nnvocpM[iCasep])
        pCRDnM = plot(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                        ylabel=ylabel,yscale=:log10)
        iCasep = 2
        label = string(nnvocpM[iCasep])
        pCRDnM = plot!(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                        label=label)
        if NCase ≥ 3
            iCasep = 3
            label = string(nnvocpM[iCasep])
            pCRDnM = plot!(tplotM[iCasep],abs.(CRDnM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                            label=label)
        end
    else
        iCasep = 1
        label = string(nnvocpM[iCasep])
        pCRDnM = plot(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                        ylabel=ylabel)
        iCasep = 2
        label = string(nnvocpM[iCasep])
        pCRDnM = plot!(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
        if NCase ≥ 3
            iCasep = 3
            label = string(nnvocpM[iCasep])
            pCRDnM = plot!(tplotM[iCasep],CRDnM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
        end
        
    end
end

ylabel = string("ΔKₛ")
if is_CK_logy
    iCasep = 1
    label = string(nnvocpM[iCasep])
    pCRDKM = plot(tplotM[iCasep],abs.(CRDKM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                    label=label,ylabel=ylabel,yscale=:log,
                    xlabel=xlabel)
    iCasep = 2
    label = string(nnvocpM[iCasep])
    pCRDKM = plot!(tplotM[iCasep],abs.(CRDKM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                    label=label)
    if NCase ≥ 3
        iCasep = 3
        label = string(nnvocpM[iCasep])
        pCRDKM = plot!(tplotM[iCasep],abs.(CRDKM[iCasep]).+epsT,line=(wline,linetypes[iCasep],linecolors[iCasep]),
                        label=label)
    end
else
    iCasep = 1
    label = string(nnvocpM[iCasep])
    pCRDKM = plot(tplotM[iCasep],CRDKM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),
                    label=label,ylabel=ylabel,
                    xlabel=xlabel)
    iCasep = 2
    label = string(nnvocpM[iCasep])
    pCRDKM = plot!(tplotM[iCasep],CRDKM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
    if NCase ≥ 3
        iCasep = 3
        label = string(nnvocpM[iCasep])
        pCRDKM = plot!(tplotM[iCasep],CRDKM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
    end
end

if is_Case_C01 && is_enforce_errdtnIKab == false
    tplotMC0 = deepcopy(tplotM)
    CRDnMC0 = deepcopy(CRDnM)
    CRDKMC0 = deepcopy(CRDKM)
end

pCnKM = display(plot(pCRDnM,pCRDKM,layout=(2,1)))
display(pCnKM)

plot(pCRDnM,pCRDKM,layout=(2,1))
savefig(string(file_fig_file,"_CnKM.png"))
  
if is_out_CnIKs
    
    ylabel = string("ΔIₛ")
    iCasep = 1
    label = string(nnvocpM[iCasep])
    pCRDIM = plot(tplotM[iCasep],CRDIM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                    ylabel=ylabel)
    iCasep = 2
    label = string(nnvocpM[iCasep])
    pCRDIM = plot!(tplotM[iCasep],CRDIM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
    if NCase ≥ 3
        iCasep = 3
        label = string(nnvocpM[iCasep])
        pCRDIM = plot!(tplotM[iCasep],CRDIM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
    end
    
    ylabel = string("Δsₛ")        # ("sₛ⁻¹∂ₜsₛ")
    iCasep = 1
    label = string(nnvocpM[iCasep])
    pCRDsM = plot(tplotM[iCasep],CRDsM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label,
                    ylabel=ylabel,
                    xlabel=xlabel)
    iCasep = 2
    label = string(nnvocpM[iCasep])
    pCRDsM = plot!(tplotM[iCasep],CRDsM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),label=label)
    if NCase ≥ 3
        iCasep = 3
        label = string(nnvocpM[iCasep])
        pCRDsM = plot!(tplotM[iCasep],CRDsM[iCasep],line=(wline,linetypes[iCasep],linecolors[iCasep]),
                      label=label)
    end

    pCnIKsM = display(plot(pCRDnM,pCRDIM,pCRDKM,pCRDsM,layout=(2,2)))
    display(pCnIKsM)
    
    plot(pCRDnM,pCRDIM,pCRDKM,pCRDsM,layout=(2,2))
    savefig(string(file_fig_file,"_CnIKsM.png"))

    if is_Case_C01 && is_enforce_errdtnIKab == false
        CRDIMC0 = deepcopy(CRDIM)
        CRDsMC0 = deepcopy(CRDsM)
    end
end