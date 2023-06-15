#include "protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun�ao    � XVALDES � Autor � Duvan Hernandez      � Data � 14/06/23 ���
������������������������������������������������������������������������Ĵ��
���Descri�ao �                                                           ���
������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFAT                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/

user function XVALDES(cClien,cLoja,cProd,cLisPre,cCant,cValLP,cTipo)
    Local aArea    := GetArea()
	Local cPdes    := "0"
	Local cVaDes   := "0"

	_cAQuery := " SELECT ACP_PERDES FROM  " +RetSQLName('ACO')+" ACO "
	_cAQuery += " INNER JOIN " +RetSQLName('ACP')+" ACP
	_cAQuery += " ON ACP_CODREG = ACO_CODREG
	_cAQuery += " AND ACP.D_E_L_E_T_ <>'*'
	_cAQuery += " WHERE ACO.D_E_L_E_T_ <>'*' 
	_cAQuery += " AND ACO_CODCLI ='"+cClien+"'
	_cAQuery += " AND ACO_LOJA ='"+cLoja+"'
	_cAQuery += " AND ACP_CODPRO='"+cProd+"'
	_cAQuery += " AND '"+time()+"'  BETWEEN ACO_HORADE AND ACO_HORATE
	_cAQuery += " AND ACO_CODTAB = '"+cLisPre+"'

    TcQuery _cAQuery New Alias "_aQRY"
    dbSelectArea("_aQRY")
    cPdes :=(_aQRY)->ACP_PERDES

    _aQRY->(dbCloseArea())

    If cPdes > 0

		If cTipo="P"
			cVaDes := cPdes
		Else	
			cVaDes :=(cValLP*cCant)*cPdes/100
		Endif


    Endif

    // Customiza��o de usu�rio...
   RestArea(aArea)
Return cVaDes


