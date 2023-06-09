#INCLUDE "PROTHEUS.CH"



 /*/{Protheus.doc} QTDRESTANTE
    (long_description)
    @type  Function
    @author M&H
    @since 05/11/2022
    @version version
    @return return_var, return_type, return_description
    /*/


User Function QTDRESTANTE()

Local C6QTDRES := 0

IF !INCLUI
    If Alltrim(gdfieldget("C6_PRODUTO"))<>''
     C6QTDRES := SC6->C6_QTDENT
    else
     C6QTDRES := 0
    EndIf  
 //   C6QTDRES := (SC6->C6_QTDVEN)-(SC6->C6_QTDEMP)-(SC6->C6_QTDENT)
ENDIF 
Return C6QTDRES


