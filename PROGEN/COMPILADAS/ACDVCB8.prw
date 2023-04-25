#include "protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

user function ACDVCB8()
    Local aArea    := GetArea()
    Local lREt     := .t.
    Local nCant    := 0
    Local nQtde    :=Paramixb[1]
    Local cArm     :=Paramixb[2]
    Local cEnd     :=Paramixb[3]
    Local cProd    :=Paramixb[4]
    Local cLote    :=Paramixb[5]
    Local cSLote   :=Paramixb[6]
    Local cLoteNew :=Paramixb[7]
    Local cSLoteNew:=Paramixb[8]
    Local cNumSer  :=Paramixb[11]
    Local cCodCB0  :=Paramixb[10]


    //vALIDAMOS QUE PRODUCTO TENGA SERIAL
    IF EMPTY(cNumSer)
         VtAlert("Producto:  "+cProd+" No cuenta con SERIAL Informado no puede realizar toma ","A V I S O",.T.,1000) //"Aviso"
       // VtAlert("Producto:  "+cProd+" No cuenta con SERIAL Informado no puede realizar toma ","A V I S O",.t.,4000,1) //"Aviso"
           RestArea(aArea)
        return .F.
    EndIF 

    //Validamos que el SERIAL no exista en la CB9



    /*
    VtAlert("Producto:  "+cProd,"A V I S O",.t.,4000,4) //"Aviso"
    VtAlert("Serial"+cNumSer,"A V I S O",.t.,4000,4) //"Aviso"
    */

    ConOut("*******************************************")
    ConOut("*******************************************")
    ConOut("*******************************************")
    ConOut("Producto:  "+cProd)
    ConOut("*******************************************")
    ConOut("Producto:  "+Paramixb[11])
    ConOut("*******************************************")
    ConOut("*******************************************")
    ConOut("*******************************************")


    _cAQuery := " SELECT COUNT(*) AS DATO FROM  "+RetSQLName('CB9')+" WHERE D_E_L_E_T_ <> '*' "
    // _cAQuery += " AND CB9_ORDSEP = = '"+aFact[2]+"' "
    _cAQuery += "AND CB9_PROD = '"+cProd+"' "
    _cAQuery += "AND CB9_NUMSER = '"+cNumSer+"' "
    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    While !_aQRY->(EOF())
        nCant := _aQRY->DATO
        _aQRY->(dbSkip())
    EndDo
    _aQRY->(dbCloseArea())


    If nCant >= 1
        VtAlert("El numero de serie escaneado ya existe en la tabla lectura(CB9).","A V I S O",.T.,1000) //"Aviso"
       // VtAlert("El numero de serie escaneado ya existe en la tabla cb9","A V I S O",.t.,4000,1) //"Aviso"
        lRet := .F.
     //   RestArea(aArea)
     //   Return .F.
    else
        lRet := .T.
    //    RestArea(aArea)
    //    Return .T.
    Endif
    //25-04-2023 
    _cAQuery := " SELECT R_E_C_N_O_ AS ID FROM  "+RetSQLName('SDC')+" WHERE "
    _cAQuery += "     DC_FILIAL  = '"+CB8->CB8_FILIAL+"' "
    _cAQuery += " AND DC_PRODUTO = '"+CB8->CB8_PROD+"' "
    _cAQuery += " AND DC_PEDIDO  = '"+CB8->CB8_PEDIDO+"' "
    _cAQuery += " AND DC_NUMSERI = '"+CB8->CB8_NUMSER+"' "
    _cAQuery += " AND D_E_L_E_T_ <> '*'  "
    TcQuery _cAQuery New Alias "_SDC"
    dbSelectArea("_SDC")
    nIDSDC := 0
    If _SDC->(!EOF())
        nIDSDC := _SDC->ID        
    EndIf
    _SDC->(dbCloseArea())
    If nIDSDC >  0

        dbSelectArea("SDC")
        dbGoTo(nIDSDC)
        //baja empenho
        dbSelectArea("SBF")
        SBF->(dbSetOrder(4))
		If SBF->(dbSeek(xFilial("SBF")+SDC->(DC_PRODUTO+DC_NUMSERIE)))
		    SBF->(GravaBFEmp("-",1,"F",.T.,SDC->DC_QUANT))
		EndIf

        //empenho    
        dbSelectArea("SBF")
        SBF->(dbSetOrder(4))
		If SBF->(dbSeek(xFilial("SBF")+SDC->(DC_PRODUTO+cNumSer)))
		    SBF->(GravaBFEmp("+",1,"F",.T.,SDC->DC_QUANT))
		EndIf

    Else 
         VtAlert("El numero de serie escaneado no existe en la tabla lectura(SDC).","A V I S O",.T.,1000) //"Aviso"     
    EndIf 

    // Customização de usuário...
   RestArea(aArea)
Return lRet
