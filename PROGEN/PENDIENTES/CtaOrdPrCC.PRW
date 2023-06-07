#Include "Protheus.ch"
#Include "TopConn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtaOrdPrCC  ºAutor  ³Microsiga           º Data ³  11/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene la cuenta contable del producto de acuerdo         º±±
±±º          ³ al centro de costos informado en el detalle del documento  º±±
±±º          ³ del Modulo Producción.                        		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CtaOrdPrCC(ccCostos,cCodPro,cBodega)

Local cCuenta:= ""
Local aArea  := GetArea()
Local TM	 := SD3->D3_TM

	DBSelectArea("SB1")
	DBSetOrder(1)
    DBSeek(xFilial("SB1")+cCodPro)  
 	

   	DBSelectArea("CTT")
   	DBSetOrder(1)
  	DBSeek(xFilial("CTT")+ccCostos)
    CtpGto:=CTT->CTT_XTPCC     

IF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'001/501/003/503'

	cCuenta := GETMV("MV_XVARI1")

ELSEIF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'012/510'

	cCuenta := GETMV("MV_XVARI2")

ELSEIF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'033/603'

	cCuenta := GETMV("MV_XVARI3")

ELSEIF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'035/605'

	cCuenta := GETMV("MV_XVARI4")


ELSEIF Posicione("SF5",1,xFilial("SF5")+TM,"F5_CODIGO")$'601/031/607/609/611/037/038/039'

		IF '51'$CtpGto //Costos de operaciones de administración o compras generales
			cCuenta:= SB1->B1_XGTADM
		ELSEIF '52'$CtpGto //Costos de operaciones comerciales     
			cCuenta:= SB1->B1_XGTCOM
		ELSEIF '73'$CtpGto //Costos de operaciones operativos      
			cCuenta:= SB1->B1_XGTOPE
		ELSEIF '55'$CtpGto //Costos asociados a innovacion
			cCuenta:= SB1->B1_XGTINN
		ELSEIF '15'$CtpGto //Costos asociados a activos en curso
			cCuenta:= SB1->B1_XGTATF
		ELSEIF '17'$CtpGto //Costos asociados a proyectos
			cCuenta:= SB1->B1_XGTPRY
		ENDIF
ELSE
			cCuenta := SB1->B1_XCUSGAS
EndIf

RestArea(aArea)

Return(cCuenta)
