
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103BUT  ºAutor  ³Marco A. Fabian Hdez      ºFecha ³  05/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³o	Crea el botón para el Prorrateo Automático, esto en el menú principal al incluir una Factura de Entrada.         ³
//³o	Despliega el cuadro de diálogo para seleccionar el archivo y cargar los datos en la tabla de Pre-Prorrateo (ZZ1).³
//³o	El Item seleccionado lo cambia a estado de "Prorrateado".                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#INCLUDE "rwmake.ch"

User Function MT103BUT()

Local aBotao 		// Juan Pablo Astorga 15.07.19

aBotao :={{"POSCLI",{|| Rotina()},"Arch.Prorr"}}

/* if GETMV("MV_PRORINC")=="S"     //Prorrateo solo al Incluir la Factura de Compras
	if inclui
		aBotao :={{"POSCLI",{|| Rotina()},"Arch.Prorr"}}
	endif
Else                //Incluye Prorrateo al Visualizar la Factura
	aBotao :={{"POSCLI",{|| Rotina()},"Arch.Prorr"}}
endif
 */

Return aBotao


Static Function Rotina()

Local cPerg	:=  "RATEIO01"  //no. de juego de preguntas
Local nPosProd	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_COD"})
Local nPosCant	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_QUANT"})
Local nPosVal	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_VUNIT"})
Local nPosTot	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_TOTAL"})
Local nPosTes	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_TES"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracion de Variables                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private oLeTxt

Private cString := "ZZ1"

//AjustaSX1(cPerg)
Pergunte(cPerg,.F.)
if empty(M->F1_FORNECE) .or. empty(M->F1_LOJA) .or. empty(M->F1_DOC)
	msgalert("Faltan de llenar datos del encabezado, VERIFIQUE","Validación Encabezado")
elseif empty(aCols[n,nPosProd]) .or. empty(aCols[n,nPosCant]) .or. empty(aCols[n,nPosVal]) .or. empty(aCols[n,nPosTot]) .or. empty(aCols[n,nPosTes])
	msgalert("Complete los datos de Producto, Cantidad, Valor y TES","Validación Detalle")
Else
	
	dbSelectArea("ZZ1")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montaje de la pantalla de procesamiento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Lectura de Archivo Texto")
	@ 02,05 TO 080,190 //@ 02,10 TO 080,190
	@ 10,018 Say ""
	@ 18,018 Say " Este programa leerá el contenido del archivo texto seleccionado"
	@ 26,018 Say "     para el Prorrateo por Empleado y Estructura de Costos "
	@ 50,040 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg) // Boton de Parametros		//línea 70  , col 70
	@ 50,090 BMPBUTTON TYPE 01 ACTION OkLeTxt()
	@ 50,140 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
	
	Activate Dialog oLeTxt Centered
endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion: ³ OKLETXT  º Autor ³ Marco A. Fabian Hdez º Fecha ³  06/12/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescripcion ³ Funcion llamada por el boton OK en la pantalla inicial deº±±
±±º            ³ procesamiento. Ejecuta la lectura del archivo texto.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OkLeTxt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura del archivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nHdl    := fOpen(mv_par01,83) //68)

Private cEOL    := "CHR(13)+CHR(10)"
If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

If nHdl == -1
	MsgAlert("El archivo de nombre "+mv_par01+" no se puede abrir! Compruebe los parámetros.","Atención")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa la regla de procesamiento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Processa({|| RunCont() },"Procesando...")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion: ³ RUNCONT  º Autor ³ Marco A. Fabian Hdez º Fecha ³  06/12/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescripcion ³ Funcion auxiliar llamada por PROCESSA.La funcion PROCESSAº±±
±±º         ³ monta la ventana con la regla de procesamiento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont

Local nTamFile, nTamLin, cBuffer, nBtLidos
Local cQryZZ1	:= ""
Local cZZ1		:= "TABZZ1"
Local cCodZZ1	:= ""
local nTot		:= 0
Local cQryREC	:= ""
Local cRECU		:= "RECURS"
Local lCompl := .T.
Local nLinea	:= 0
Local aError	:= {}
Local cComa		:= ""
Local cLinErro	:= ""
Local cMnsj	:= ""
Local i:= 0
Local nPosTot	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_TOTAL"})
Local nPosItem	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_ITEM"})
Local nPosPror	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_RATEIO"})
Local nPosProd	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_COD"})
Local nPosTG	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_TIPOGTO"})
Local nPosItm	:= AScan(aHeader,   {|x| AllTrim(Upper(x[2])) == "D1_ITEM"})
Local cFlin		:= chr(13)+chr(10)
Local x:= 0
Local y:= 0
Local nTotFat:= 0
Local lgrab:= .T.
Local cTpGto

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Lay-Out del archivo Texto generado:                                º
//ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
//ºCampo           ³ Inicio ³ Tamaño                               º
//ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
//º ZZ1_CODREC     ³ 01  ³ 06   -> Codigo del Recurso      º
//º ZZ1_CUSTO1     ³ 07  ³ 14   -> Valor prorrateado       º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

//Borra la tabla temporal al inicio del proceso
cDelZZ1 := "DELETE FROM  " + RetSqlName("ZZ1")
nResZZ1:= TcSqlExec(cDelZZ1)
IF nResZZ1 <> 0
	msgAlert("No logro eliminar datos de la tabla ZZ1","Borrado")
Else
	//msgalert("tabla ZZ1 borrada")
ENDIF
//Fin de borrado

For x:= 1 to len(aCols)
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 188+Len(cEOL)
	cBuffer  := Space(nTamLin) // Variablel para creación de la línea del registro para lectura
	cItmNF:= aCols[x,nPosItm]
	
	nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Lectura de la primera línea del archivo texto
	
	//MsgAlert(cBuffer,"Linea TXT")
	
	ProcRegua(nTamFile) // Número de registros a procesar
	nTot:= 0
	nTotFat:= 0
	While nBtLidos >= nTamLin
		nLinea+= 1
		if cItmNF == Substr(cBuffer,01,04)
			//Código y Nombre del Recurso
			cCodEmpl:= Substr(cBuffer,05,06)
			cPryResp:= Substr(cBuffer,27,12)
			//Codigos de Entes
			cCCosto	:= Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_CC")		//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CC")
			cItmCon	:= Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_ITEMC")	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_ITEM")
			cClaVal := Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_CLVL")	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CLVL")
			cTipoGto:= Substr(cBuffer,26,1)
			// ++++++++++++++++++++ VALIDACIONES PREVIAS +++++++++++++++++++//
			
			if empty(alltrim(Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_MAT")))
				lcompl:= .F.
				cMnsj:= "Cód. Empleado Inválido: "+cCodEmpl
				aadd(aError,{nLinea,cMnsj})
			Endif
			//Validación de Empleado dado de Baja
			//Validación denegada por Jair Vargas para poder afectar empleados con baja.
			/*if alltrim(Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_SITFOLH")) == "D"
				lcompl:= .F.
				cMnsj:= "Empleado No Activo: "+cCodEmpl
				aadd(aError,{nLinea,cMnsj})
			Endif */
			
			if empty(alltrim(Posicione("CTT",1,xFilial("CTT")+cCCosto,"CTT_CUSTO")))
				lcompl:= .F.
				cMnsj:= "Direc-Depto Inválido: "+cCCosto
				aadd(aError,{nLinea,cMnsj})
			Endif
			
			if empty(alltrim(Posicione("CTD",1,xFilial("CTD")+cItmCon,"CTD_ITEM")))
				lcompl:= .F.
				cMnsj:= "Segm-Nego Inválido: "+cItmCon
				aadd(aError,{nLinea,cMnsj})
			Endif
			
			if empty(alltrim(Posicione("CTH",1,xFilial("CTH")+cClaVal,"CTH_CLVL")))
				lcompl:= .F.
				cMnsj:= "Cli-Dir-Suc Inválido: "+cClaVal
				aadd(aError,{nLinea,cMnsj})
			Endif
			
			if empty(alltrim(Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_COD")))
				lcompl:= .F.
				cMnsj:= "Proyecto Inválido"+cPryResp
				aadd(aError,{nLinea,cMnsj})
			Endif
			if val(cTipoGto) > 3 .or. val(cTipoGto)<= 0
				lcompl:= .F.
				cMnsj:= "Tipo de Gasto Inválido (solo 1,2,3): "+cTipoGto
				aadd(aError,{nLinea,cMnsj})
			Endif
			
			// Acumula el total para validar contra el valor capturado en la NF
			if lCompl
				nTot+= NoRound(Val(Substr(cBuffer,11,12)),02)+(NoRound(Val(Substr(cBuffer,24,2)),02)/100)
			endif
		endif
		nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Lectura de la próxima línea del archivo texto
		
		dbSkip()
	EndDo
	
	if lCompl
		nTotFat:= aCols[x,nPosTot]
		//msgalert(nTotFat,"Total digitado")
		//msgalert(nTot,"Total TXT")
		if nTot == nTotFat	// Si Total TXT es igual a Total de Factura
			cItZZ1:= "00"
			//-->Borrado
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			nTamLin  := 188+Len(cEOL)//75+Len(cEOL)
			cBuffer  := Space(nTamLin) // Variablel para creación de la línea del registro para lectura
			nBtLidos := fRead(nHdl,@cBuffer,nTamLin) //dbGotop()
			While nBtLidos >= nTamLin
				if cItmNF == Substr(cBuffer,01,04)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Incrementa la regla                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					IncProc()
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Graba los campos obteniendo los valores de la linea leida del archivo texto.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					cItZZ1:= soma1(cItZZ1)	//2508	strzero(val(cItZZ1)+1,2)
					
					dbSelectArea(cString)
					RecLock(cString,.T.)
					ZZ1->ZZ1_FILIAL 	:= xFilial("ZZ1")
					//    03           20             06           02  = 31
					ZZ1->ZZ1_CODPRO		:= M->F1_SERIE + M->F1_DOC + M->F1_FORNECE + M->F1_LOJA //"000001" //cCodZZ1
					ZZ1->ZZ1_ITEMNF		:= aCols[x,nPosItem]
					ZZ1->ZZ1_ITEM		:= cItZZ1
					
					//+++++ Extracción del txt ++++++//
					
					//Código y Nombre del Recurso
					cCodEmpl:= Substr(cBuffer,05,06)
					ZZ1->ZZ1_CODEMP := cCodEmpl
					ZZ1->ZZ1_DSCEMP := alltrim(Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_NOME"))
					
					//Valor Pago
					ZZ1->ZZ1_NTOPGO 	:= NoRound(Val(Substr(cBuffer,11,12)),02)+(NoRound(Val(Substr(cBuffer,24,2)),02)/100)
					
					//PROYECTO-RESPONSABLE
					cPryResp:= Substr(cBuffer,27,12)
					
					//Codigos de Entes Contables basados en el PROYECTO-RESPONSABLE
					cCCosto	:= Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_CC")		//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CC")
					cItmCon	:= Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_ITEMC")	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_ITEM")
					cClaVal := Posicione("ZPY",1,xFilial("ZPY")+cPryResp,"ZPY_CLVL")	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CLVL")
					ZZ1->ZZ1_CCOS	:= cCCosto	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CC")
					ZZ1->ZZ1_ICON	:= cItmCon	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_ITEM")
					ZZ1->ZZ1_CLVL 	:= cClaVal	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_CLVL")
					ZZ1->ZZ1_PROY 	:= cPryResp	//Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_PROY")+Posicione("SRA",1,xFilial("SRA")+cCodEmpl,"RA_RESPROY")
					ZZ1->ZZ1_XTIGTO := Substr(cBuffer,26,1)
					//Determinar la Cta de Gto Adm, Gto Vta, Cto Vta. de acuerdo al Layout TXT.
					cTipGto:= Substr(cBuffer,26,1)	// aCols[n,nPosTG] --> Al inicio se configuró con el código de Tipo Gasto del Item.
					cProd:= aCols[x,nPosProd]
					cCtaGVta:= alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_XCONCO"))
					cCtaGAdm:= alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_CONTA"))
					cCtaCost:= alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_XCONCL"))
					ZZ1->ZZ1_CTACON	:= alltrim(if(cTipGto=="1",cCtaGVta, if(cTipGto=="2",cCtaGAdm,if(cTipGto=="3",cCtaCost,"")) ))
					
					//Situación del prorrateo
					ZZ1->ZZ1_PRORR	:= "N"
					ZZ1->ZZ1_HISTO	:= alltrim(Substr(cBuffer,39,150))
					MSUnLock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Lectura de la proxima linea del archivo texto.                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				endif
				nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Lectura de la próxima línea del archivo texto
				dbSkip()
			EndDo
			
			aCols[x,nPosPror]:= "1"	//Prorrateado: 1= SI, 2= NO
			
			//Aviso("Carga Completa","El Archivo ha sido cargado correctamente",{"OK"})
		Else
			msgalert("El monto informado no coincide con el Total del Archivo Cargado...","Valida Valores")
			lgrab:= .F.
		Endif
		
	Else
		cLinErro:= ""
		for i:= 1 to len(aError)
			cLinErro:= cLinErro+cValtochar(aError[i,1])+" --> "+alltrim(aError[i,2])+cFlin
		next
		Aviso("¡Atencion! NO se cargaron los registros","	Verifica las líneas: "+cLinErro,{"OK"})
		lgrab:= .F.
	endif
next

if lGrab
	if !inclui
		if GETMV("MV_PRORINC")=="N"
			Prorrat()
		endif
	Else
		Aviso("Carga Completa","El Archivo ha sido cargado correctamente",{"OK"})
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Debe cerrar el archivo texto, asi como tambien el dialogo creado en la  ³
//³ funcion anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

fClose(nHdl)
Close(oLeTxt)

Return


Static Function Prorrat

Local cCod:= M->F1_SERIE+M->F1_DOC+M->F1_FORNECE+M->F1_LOJA
Local nTot:= 0
Local cQryZZ1:= ""
Local cZZ1:= "TABZZ1"
Local cQryAFU:= ""
Local cAFU	:= "TABAFU"
Local cItem:= "00"
Local nTotPrc:= 0
Local nTotPag:= 0
Local c1Ser:= M->F1_SERIE
Local c1Doc:= M->F1_DOC
Local c1Prv:= M->F1_FORNECE
Local c1Loj:= M->F1_LOJA
Local cModal:=M->F1_NATUREZ	//Si es la modalidad CPRORATIVA (Prorrateo IVA)
Local cCtaMod:= Posicione("SED",1,xFilial("SED")+cModal,"ED_CONTA")
Local cEstrCos := ""
Local cTpGto   := ""
//Si existe previamente la factura en la tabla de Prorrateos, la borra para que se vuelva a crear.
cDelSDE:= " DELETE From "+retSQLName("SDE")+" "
cDelSDE+= " where DE_FILIAL = '"+xFilial("SDE")+"' "
cDelSDE+= " and DE_SERIE = '"+c1Ser+"' "
cDelSDE+= " and DE_DOC = '"+c1Doc+"' "
cDelSDE+= " and DE_FORNECE = '"+c1Prv+"' "
cDelSDE+= " and DE_LOJA = '"+c1Loj+"' "
cDelSDE+= " and D_E_L_E_T_ <>'*'
IF TcSqlExec(cDelSDE) <> 0
	msgAlert("¡Atención!","No logro eliminar datos de la tabla SDE")
ENDIF

cQryZZ1:= " Select * from "+RetSQLName("ZZ1")
cQryZZ1+= " Where D_E_L_E_T_ <>'*' "
cQryZZ1+= " and ZZ1_CODPRO = '"+cCod+"' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryZZ1),cZZ1,.F.,.T.)
//Calcula el Total del valor a Prorratear
While (cZZ1)->(!EOF())
	nTot+= (cZZ1)->ZZ1_NTOPGO
	(cZZ1)->(dbSkip())
enddo

cItem:= "00"
(cZZ1)->(dbgotop())
While (cZZ1)->(!EOF())
	cSerP:= substr((cZZ1)->ZZ1_CODPRO,1,3)
	cDocP:= substr((cZZ1)->ZZ1_CODPRO,4,20)
	cPrvP:= substr((cZZ1)->ZZ1_CODPRO,24,6)
	cLojP:= substr((cZZ1)->ZZ1_CODPRO,30,2)
	cCodEmpl:= (cZZ1)->ZZ1_CODEMP
	nNetoPag:= (cZZ1)->ZZ1_NTOPGO
	cItem:= soma1(cItem)	//strzero(val(cItem)+1,2)
	
	cEstrCos := "003."+Substr((cZZ1)->ZZ1_CLVL,1,4)+"."+Substr((cZZ1)->ZZ1_CLVL,5,3)+"."+Substr((cZZ1)->ZZ1_CLVL,8,2)
	cEstrCos += "."+Substr((cZZ1)->ZZ1_ICON,1,2)+"."+Substr((cZZ1)->ZZ1_ICON,3,2)
	cEstrCos += "."+Substr((cZZ1)->ZZ1_PROY,1,6)+"."+Substr((cZZ1)->ZZ1_PROY,7,6)
	cEstrCos += "."+Substr((cZZ1)->ZZ1_CCOS,1,2)+"."+Substr((cZZ1)->ZZ1_CCOS,3,3)
	cEstrCos += "."+(cZZ1)->ZZ1_CODEMP
	
	dbSelectArea("SDE")
	dbSetOrder(1)
	
	Begin Transaction
	Reclock("SDE",.T.)
	SDE->DE_FILIAL	:= xFilial("SDE")
	SDE->DE_SERIE	:= cSerP
	SDE->DE_DOC		:= cDocP
	SDE->DE_FORNECE	:= cPrvP
	SDE->DE_LOJA	:= cLojP
	SDE->DE_ITEMNF	:= (cZZ1)->ZZ1_ITEMNF
	SDE->DE_ITEM	:= cItem	//(cZZ1)->ZZ1_ITEM		
	
	nPorc:= Round((nNetoPag/nTot)*100,2)
	
	SDE->DE_PERC	:= nPorc
	SDE->DE_CC      := (cZZ1)->ZZ1_CCOS
	SDE->DE_CONTA	:= (cZZ1)->ZZ1_CTACON
	SDE->DE_ITEMCTA := (cZZ1)->ZZ1_ICON
	SDE->DE_CLVL	:= (cZZ1)->ZZ1_CLVL
	SDE->DE_XCODEMP	:= (cZZ1)->ZZ1_CODEMP
	SDE->DE_XNOMEMP	:= alltrim(Posicione("SRA",1,xFilial("SRA")+(cZZ1)->ZZ1_CODEMP,"RA_NOME"))
	SDE->DE_CUSTO1	:= nNetoPag			//round(nNetoPag*(nPorc/100),2)
	SDE->DE_XPROY	:= (cZZ1)->ZZ1_PROY
	SDE->DE_XHISTO	:= (cZZ1)->ZZ1_HISTO
	SDE->DE_XESTRCO := cEstrCos
	SDE->DE_XTIGTO	:= (cZZ1)->ZZ1_XTIGTO
	MsUnLock()
	//De acuerdo a la modalidad Desglosa o no el IVA
	//++++++++++++++++++++++++++++++++++++++++++++++
	if cModal == "CPRORATIVA"
		cItem:= soma1(cItem)
		Reclock("SDE",.T.)
		SDE->DE_FILIAL	:= xFilial("SDE")
		SDE->DE_SERIE	:= cSerP
		SDE->DE_DOC		:= cDocP
		SDE->DE_FORNECE	:= cPrvP
		SDE->DE_LOJA	:= cLojP
		SDE->DE_ITEMNF	:= (cZZ1)->ZZ1_ITEMNF
		SDE->DE_ITEM	:= cItem	//(cZZ1)->ZZ1_ITEM		
		
		nPorc:= Round((nNetoPag/nTot)*100,2)
		
		SDE->DE_PERC	:= nPorc
		SDE->DE_CC      := (cZZ1)->ZZ1_CCOS
		SDE->DE_CONTA	:= cCtaMod	//(cZZ1)->ZZ1_CTACON
		SDE->DE_ITEMCTA := (cZZ1)->ZZ1_ICON
		SDE->DE_CLVL	:= (cZZ1)->ZZ1_CLVL
		SDE->DE_XCODEMP	:= (cZZ1)->ZZ1_CODEMP
		SDE->DE_XNOMEMP	:= alltrim(Posicione("SRA",1,xFilial("SRA")+(cZZ1)->ZZ1_CODEMP,"RA_NOME"))
		SDE->DE_CUSTO1	:= nNetoPag*.16 //nNetoPag
		SDE->DE_XPROY	:= (cZZ1)->ZZ1_PROY
		SDE->DE_XHISTO	:= "IVA: "+(cZZ1)->ZZ1_HISTO
		SDE->DE_XESTRCO := cEstrCos
		SDE->DE_XTIGTO	:= (cZZ1)->ZZ1_XTIGTO
		MsUnLock()
	Endif
	//++++++++++++++++++++++++++++++++++++++++++++++
	dbCloseArea()
	
	end transaction
	(cZZ1)->(dbSkip())
Enddo
(cZZ1)->(dbCloseArea())

Aviso("Prorrateo","Prorrateo cargado correctamente",{"OK"})

Return
