#INCLUDE "PROTHEUS.CH"


User Function LOCXPE01()

    local aBotao := {}

    if funname()=="MATA466N"    //NCP
        aAdd(aBotao,{'Carga Masiva',{|| u_STHWMS06() } , 'Carga Masiva' , 'Carga Masiva' })
    endif

    if funname()=="MATA102DN"    //Devol.Remision
        aAdd(aBotao,{'Carga Masiva',{|| u_STHWMS05() } , 'Carga Masiva' , 'Carga Masiva' })
    endif

    //SetKey(VK_F9,{|| u_STHWMS05() } )

Return(aBotao)

