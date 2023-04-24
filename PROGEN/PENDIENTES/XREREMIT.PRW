
#Include "Protheus.ch"
#Include "TopConn.ch"



User Function REAREMI()



	Local UserActua:=RetCodUsr()
	Local oButton1
	Local oButton2
	Local oGroup1
	Local oMultiGe1
	Local cMultiGe1 := "PRODUTO                        "
	Local oMultiGe2
	Local cMultiGe2 := "OS    "
	Local oMultiGe3
	Local cMultiGe3 := "                 "
	Local oSay1
	Local oSay2
	Local oSay3
	Static oDlg


	if UserActua<>"000027"  //TOTVSADM
		Return
	EndIF


	DEFINE MSDIALOG oDlg TITLE "Rehacer Remito - OS" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL
	@ 009, 007 GROUP oGroup1 TO 239, 290 PROMPT "Remito de Salida - Orden de Separación" OF oDlg COLOR 0, 16777215 PIXEL
	@ 022, 013 SAY oSay1 PROMPT "Indique por favor los parametros para realizar la busqueda" SIZE 211, 009 OF oDlg COLORS 0, 16777215 PIXEL

	@ 217, 021 BUTTON oButton1 PROMPT "Generar" SIZE 048, 014 action processa({|| fProcessa(cMultiGe1,cMultiGe2,cMultiGe3) }, "Processando...") OF oDlg PIXEL
	@ 215, 230 BUTTON oButton2 PROMPT "Salir" SIZE 044, 016 ACTION   oDlg:End() OF oDlg PIXEL


	@ 061, 017 SAY oSay1 PROMPT "Producto:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 061, 071 MSGET oMultiGe1 VAR cMultiGe1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 075, 017 SAY oSay2 PROMPT "Orden de Separación:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 071 MSGET oMultiGe2 VAR cMultiGe2 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 089, 017 SAY oSay3 PROMPT "Clave:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 089, 071 MSGET oMultiGe3 VAR cMultiGe3 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL



	ACTIVATE MSDIALOG oDlg CENTERED
Return




Return




Static Function fProcessa(cProd,cOrdesep,cClave)
	Local aArea       := GetArea()
	Local aAreaX3     := SX3->(GetArea())
	Local nAux        := 0
	Local oFWMsExcel
	Local oExcel
	Local cDiretorio  := GetTempPath()
	// Local cArquivo    := 'zQry2Excel.xml'
	Local dData := DTOC(DATE())
	Local dtime := Time()
	Local cArquivo    := alltrim(cOrdesep) +"_"+ dData +"_"+ dtime+".xml"
	cArquivo := replace(cArquivo,"/","")
	cArquivo := replace(cArquivo,":","")
	Local cArqFull    := cDiretorio + cArquivo
	Local cWorkSheet  := "REMITO_ORIGINAL"
	Local cTable      := ""
	Local aColunas    := {}
	Local aEstrut     := {}
	Local aLinhaAux   := {}
	Local cTitulo     := ""
	Local nTotal      := 0
	Local nAtual      := 0
	Local Upd :=""
	Default cQryAux   := ""
	Default cTitAux   := "Tutulo de la consulta"

	cTable := cTitAux

	if (Len(AllTrim(cProd))>5)
		if (Len(AllTrim(cOrdesep))>=5)

			cQryAux := " DROP TABLE IF EXISTS TTR_SDB "
			n1Statu :=TCSqlExec(cQryAux)
			cQryAux := " DROP TABLE IF EXISTS TTS_CB9 "
			n1Statu :=TCSqlExec(cQryAux)


			cQryAux := " SELECT DB.* FROM "+RetSqlName("SDB")+ " DB "
			cQryAux += " INNER JOIN "+RetSqlName("SD2")+ " D2 "
			cQryAux += " ON D2_DOC=DB_DOC "
			cQryAux += " AND D2_SERIE='R' "
			cQryAux += " AND D2.D_E_L_E_T_<>'*'  "
			cQryAux += " WHERE  "
			cQryAux += " DB_ESTORNO=''  "
			cQryAux += " AND D2_ORDSEP='" + AllTrim(cOrdesep) +"' "
			cQryAux += " AND DB_PRODUTO='" + AllTrim(cProd) +"' "
			cQryAux += " AND DB.D_E_L_E_T_<>'*'  "




			cWorkSheet  := "REMITO_ANTES"
			n1Statu :=TCSqlExec(cQryAux)
			if (n1Statu < 0)
				MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
			Else

				//Se tiver a consulta
				If !Empty(cQryAux)
					TCQuery cQryAux New Alias "QRY_AUX"
					DbSelectArea('SX3')
					SX3->(DbSetOrder(2)) //X3_CAMPO
					//Percorrendo a estrutura
					aEstrut := QRY_AUX->(DbStruct())
					ProcRegua(Len(aEstrut))
					For nAux := 1 To Len(aEstrut)
						IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
						cTitulo := ""
						If SX3->(DbSeek(aEstrut[nAux][1]))
							cTitulo := Alltrim(SX3->X3_TITULO)
							If SX3->X3_TIPO == 'D'
								TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
							EndIf
						Else
							cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
						EndIf

						aAdd(aColunas, cTitulo)
					Next
					oFWMsExcel := FWMSExcel():New()
					oFWMsExcel:AddworkSheet(cWorkSheet)
					oFWMsExcel:AddTable(cWorkSheet, cTable)
					For nAux := 1 To Len(aColunas)
						oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
					Next
					DbSelectArea("QRY_AUX")
					QRY_AUX->(DbGoTop())
					Count To nTotal
					ProcRegua(nTotal)
					nAtual := 0
					QRY_AUX->(DbGoTop())
					While !QRY_AUX->(EoF())
						nAtual++
						IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

						aLinhaAux := Array(Len(aColunas))
						For nAux := 1 To Len(aEstrut)
							aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
						Next
						oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
						QRY_AUX->(DbSkip())
					EndDo


					QRY_AUX->(DbCloseArea())



				EndIf
			EndIf





			if (trim(cClave)=='1010124125')
				Upd := " SELECT DB_ORDSEP,DB_FILIAL,DB_ITEM,DB_ESTORNO,DB_PRODUTO,DB_LOCAL,DB_LOCALIZ,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_TIPONF,DB_TM,DB_ORIGEM,DB_QUANT,DB_DATA,DB_LOTECTL,DB_NUMLOTE,'11111111111111111111' DB_NUMSERI,DB_NUMSEQ,DB_TIPO,DB_EMPENHO,DB_QTSEGUM,DB_EMP2,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RHFUNC,DB_RECHUM,DB_RECFIS,DB_OCORRE,DB_ANOMAL,DB_ENDDES,DB_ESTDES,DB_CARGA,DB_ESTFIS,DB_HRINI,DB_DATAFIM,DB_HRFIM,DB_UNITIZ,DB_ATUEST,DB_STATUS,DB_PRIORI,DB_ORDTARE,DB_ORDATIV,DB_IDOPERA,DB_SEQCAR,DB_REGWMS,DB_MAPSEP,DB_MAPCON,DB_ENDSERV,DB_QTDERRO,DB_RECCON,DB_RECEMB,DB_QTDORI,DB_IDDCF,DB_SEQPRI,DB_QTDLID,DB_IDMOVTO,DB_OP,ROW_NUMBER() OVER( ORDER BY R_E_C_N_O_) DB_SDOC,D_E_L_E_T_, R_E_C_N_O_,R_E_C_D_E_L_ "
				Upd += " INTO TTR_SDB "
				Upd += " FROM (SELECT DISTINCT "
				Upd += " D2_ORDSEP DB_ORDSEP,DB_FILIAL,DB_ITEM,DB_ESTORNO,DB_PRODUTO,DB_LOCAL,DB_LOCALIZ,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_TIPONF,DB_TM,DB_ORIGEM,DB_QUANT,DB_DATA,DB_LOTECTL,DB_NUMLOTE,'' DB_NUMSERI,DB_NUMSEQ,DB_TIPO,DB_EMPENHO,DB_QTSEGUM,DB_EMP2,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RHFUNC,DB_RECHUM,DB_RECFIS,DB_OCORRE,DB_ANOMAL,DB_ENDDES,DB_ESTDES,DB_CARGA,DB_ESTFIS,DB_HRINI,DB_DATAFIM,DB_HRFIM,DB_UNITIZ,DB_ATUEST,DB_STATUS,DB_PRIORI,DB_ORDTARE,DB_ORDATIV,DB_IDOPERA,DB_SEQCAR,DB_REGWMS,DB_MAPSEP,DB_MAPCON,DB_ENDSERV,DB_QTDERRO,DB_RECCON,DB_RECEMB,DB_QTDORI,DB_IDDCF,DB_SEQPRI,DB_QTDLID,DB_IDMOVTO,DB_OP,DB_SDOC,DB.D_E_L_E_T_, DB.R_E_C_N_O_,DB.R_E_C_D_E_L_ "
				Upd += " FROM "+RetSqlName("SDB")+ " DB "
				Upd += " INNER JOIN "+RetSqlName("SD2")+ " D2 "
				Upd += " ON D2_DOC=DB_DOC "
				Upd += " AND D2_SERIE='R' "
				Upd += " AND D2.D_E_L_E_T_<>'*'  "
				Upd += " WHERE  "
				Upd += " DB_ESTORNO=''  "
				Upd += " AND D2_ORDSEP='" + AllTrim(cOrdesep) +"' "
				Upd += " AND DB_PRODUTO='" + AllTrim(cProd) +"' "
				Upd += " AND DB.D_E_L_E_T_<>'*') R  "


				n1Statud :=TCSqlExec(Upd)

				if (n1Statud < 0)
					MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
				EndIf


				Upd := " SELECT "
				Upd += " CB9_FILIAL,CB9_ORDSEP,CB9_CODETI,CB9_PROD,CB9_EMBALD,CB9_VOLUME,CB9_ITEM,CB9_SEQUEN,CB9_DISPID,CB9_QTESEP,CB9_ITESEP,CB9_CODEMB,CB9_CODSEP,CB9_STATUS,CB9_QTEEMB,CB9_LOTECT,CB9_NUMLOT,CB9_LOCAL,CB9_LCALIZ,CB9_SUBVOL,CB9_LOTSUG,CB9_SLOTSU,CB9_QTEEBQ,CB9_PEDIDO,CB9_NUMSER,ROW_NUMBER() OVER( ORDER BY R_E_C_N_O_) CB9_DOC,CB9_NSERSU,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_ "
				Upd += " INTO TTS_CB9 "
				Upd += " FROM "+RetSqlName("CB9")+ " "
				Upd += " WHERE "
				Upd += " CB9_ORDSEP='" + AllTrim(cOrdesep) +"' "
				Upd += " AND CB9_PROD='" + AllTrim(cProd) +"' "
				Upd += " AND D_E_L_E_T_<>'*' "

				n1Statud :=TCSqlExec(Upd)

				if (n1Statud < 0)
					MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
				EndIf


				Upd := " UPDATE TTR_SDB SET DB_NUMSERI= CB9_NUMSER "
				Upd += " FROM TTS_CB9 "
				Upd += " INNER JOIN TTR_SDB "
				Upd += " ON CB9_ORDSEP=DB_ORDSEP "
				Upd += " AND DB_PRODUTO=CB9_PROD "
				Upd += " AND CB9_DOC=DB_SDOC "

				n1Statud :=TCSqlExec(Upd)

				if (n1Statud < 0)
					MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
				EndIf

				Upd := "  UPDATE "+RetSqlName("SDB")+ " "
				Upd += "  SET DB_NUMSERI=TDB.DB_NUMSERI "
				Upd += "  FROM TTR_SDB TDB"
				Upd += " WHERE "+RetSqlName("SDB")+ ".DB_DOC=TDB.DB_DOC AND "+RetSqlName("SDB")+ ".R_E_C_N_O_=TDB.R_E_C_N_O_"
				n1Statud :=TCSqlExec(Upd)
				if (n1Statud < 0)
					MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
				EndIf


				// Upd := " INSERT INTO "+RetSqlName("SDB")+ " "
				// Upd += " SELECT "
				// Upd += " DB_FILIAL,DB_ITEM,DB_ESTORNO,DB_PRODUTO,DB_LOCAL,DB_LOCALIZ,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_TIPONF,DB_TM,DB_ORIGEM,DB_QUANT,DB_DATA,DB_LOTECTL,DB_NUMLOTE,CB9_NUMSER DB_NUMSERI,DB_NUMSEQ,DB_TIPO,DB_EMPENHO,DB_QTSEGUM,DB_EMP2,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RHFUNC,DB_RECHUM,DB_RECFIS,DB_OCORRE,DB_ANOMAL,DB_ENDDES,DB_ESTDES,DB_CARGA,DB_ESTFIS,DB_HRINI,DB_DATAFIM,DB_HRFIM,DB_UNITIZ,DB_ATUEST,DB_STATUS,DB_PRIORI,DB_ORDTARE,DB_ORDATIV,DB_IDOPERA,DB_SEQCAR,DB_REGWMS,DB_MAPSEP,DB_MAPCON,DB_ENDSERV,DB_QTDERRO,DB_RECCON,DB_RECEMB,DB_QTDORI,DB_IDDCF,DB_SEQPRI,DB_QTDLID,DB_IDMOVTO,DB_OP,''DB_SDOC,DB.D_E_L_E_T_,ISNULL((SELECT MAX(DB1.R_E_C_N_O_) FROM "+RetSqlName("SDB")+ " DB1) + ROW_NUMBER() OVER( ORDER BY DB.R_E_C_N_O_),1) AS R_E_C_N_O_,DB.R_E_C_D_E_L_ "
				// Upd += " FROM TTR_SDB DB "
				// Upd += " INNER JOIN TTS_CB9 "
				// Upd += " ON DB_ORDSEP=CB9_ORDSEP "
				// Upd += " AND DB_PRODUTO=CB9_PROD "
				// Upd += " AND CB9_DOC=DB_SDOC "
				// Upd += " GROUP BY "
				// Upd += " DB_FILIAL,DB_ITEM,DB_ESTORNO,DB_PRODUTO,DB_LOCAL,DB_LOCALIZ,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,DB_TIPONF,DB_TM,DB_ORIGEM,DB_QUANT,DB_DATA,DB_LOTECTL,DB_NUMLOTE,CB9_NUMSER,DB_NUMSEQ,DB_TIPO,DB_EMPENHO,DB_QTSEGUM,DB_EMP2,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RHFUNC,DB_RECHUM,DB_RECFIS,DB_OCORRE,DB_ANOMAL,DB_ENDDES,DB_ESTDES,DB_CARGA,DB_ESTFIS,DB_HRINI,DB_DATAFIM,DB_HRFIM,DB_UNITIZ,DB_ATUEST,DB_STATUS,DB_PRIORI,DB_ORDTARE,DB_ORDATIV,DB_IDOPERA,DB_SEQCAR,DB_REGWMS,DB_MAPSEP,DB_MAPCON,DB_ENDSERV,DB_QTDERRO,DB_RECCON,DB_RECEMB,DB_QTDORI,DB_IDDCF,DB_SEQPRI,DB_QTDLID,DB_IDMOVTO,DB_OP,DB_SDOC,DB.D_E_L_E_T_,DB.R_E_C_N_O_,DB.R_E_C_D_E_L_ "
				// n1Statud :=TCSqlExec(Upd)

			else
				MsgAlert("Clave de Proceso Incorrecta","TERMINADO")
				return
			EndIF




			aColunas    := {}
			aEstrut     := {}
			aLinhaAux   := {}
			cTitulo     := ""
			nTotal      := 0
			nAtual      := 0

			cQryAuxCB8 := " SELECT * FROM "+RetSqlName("CB8")+ " "
			cQryAuxCB8 += " WHERE  "
			cQryAuxCB8 += "  CB8_ORDSEP='" + AllTrim(cOrdesep) +"' "
			cQryAuxCB8 += " AND CB8_PROD='" + AllTrim(cProd) +"' "
			cQryAuxCB8 += " AND D_E_L_E_T_<>'*'  "


			cWorkSheet  := "CB8"
			n1Statu :=TCSqlExec(cQryAuxCB8)
			if (n1Statu < 0)
				MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
			Else

				//Se tiver a consulta
				If !Empty(cQryAuxCB8)
					TCQuery cQryAuxCB8 New Alias "QRY_AUX"
					DbSelectArea('SX3')
					SX3->(DbSetOrder(2)) //X3_CAMPO
					//Percorrendo a estrutura
					aEstrut := QRY_AUX->(DbStruct())
					ProcRegua(Len(aEstrut))
					For nAux := 1 To Len(aEstrut)
						IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
						cTitulo := ""
						If SX3->(DbSeek(aEstrut[nAux][1]))
							cTitulo := Alltrim(SX3->X3_TITULO)
							If SX3->X3_TIPO == 'D'
								TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
							EndIf
						Else
							cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
						EndIf

						aAdd(aColunas, cTitulo)
					Next
					oFWMsExcel:AddworkSheet(cWorkSheet)
					oFWMsExcel:AddTable(cWorkSheet, cTable)
					For nAux := 1 To Len(aColunas)
						oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
					Next
					DbSelectArea("QRY_AUX")
					QRY_AUX->(DbGoTop())
					Count To nTotal
					ProcRegua(nTotal)
					nAtual := 0
					QRY_AUX->(DbGoTop())
					While !QRY_AUX->(EoF())
						nAtual++
						IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

						aLinhaAux := Array(Len(aColunas))
						For nAux := 1 To Len(aEstrut)
							aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
						Next
						oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
						QRY_AUX->(DbSkip())
					EndDo


					QRY_AUX->(DbCloseArea())

				EndIf
			EndIf



			aColunas    := {}
			aEstrut     := {}
			aLinhaAux   := {}
			cTitulo     := ""
			nTotal      := 0
			nAtual      := 0

			cQryAuxCB9 := " SELECT * FROM "+RetSqlName("CB9")+ " "
			cQryAuxCB9 += " WHERE  "
			cQryAuxCB9 += "  CB9_ORDSEP='" + AllTrim(cOrdesep) +"' "
			cQryAuxCB9 += " AND CB9_PROD='" + AllTrim(cProd) +"' "
			cQryAuxCB9 += " AND D_E_L_E_T_<>'*'  "


			cWorkSheet  := "CB9"
			n1Statu :=TCSqlExec(cQryAuxCB9)
			if (n1Statu < 0)
				MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
			Else

				//Se tiver a consulta
				If !Empty(cQryAuxCB9)
					TCQuery cQryAuxCB9 New Alias "QRY_AUX"
					DbSelectArea('SX3')
					SX3->(DbSetOrder(2)) //X3_CAMPO
					//Percorrendo a estrutura
					aEstrut := QRY_AUX->(DbStruct())
					ProcRegua(Len(aEstrut))
					For nAux := 1 To Len(aEstrut)
						IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
						cTitulo := ""
						If SX3->(DbSeek(aEstrut[nAux][1]))
							cTitulo := Alltrim(SX3->X3_TITULO)
							If SX3->X3_TIPO == 'D'
								TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
							EndIf
						Else
							cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
						EndIf

						aAdd(aColunas, cTitulo)
					Next
					oFWMsExcel:AddworkSheet(cWorkSheet)
					oFWMsExcel:AddTable(cWorkSheet, cTable)
					For nAux := 1 To Len(aColunas)
						oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
					Next
					DbSelectArea("QRY_AUX")
					QRY_AUX->(DbGoTop())
					Count To nTotal
					ProcRegua(nTotal)
					nAtual := 0
					QRY_AUX->(DbGoTop())
					While !QRY_AUX->(EoF())
						nAtual++
						IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

						aLinhaAux := Array(Len(aColunas))
						For nAux := 1 To Len(aEstrut)
							aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
						Next
						oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
						QRY_AUX->(DbSkip())
					EndDo


					QRY_AUX->(DbCloseArea())

				EndIf
			EndIf



			aColunas    := {}
			aEstrut     := {}
			aLinhaAux   := {}
			cTitulo     := ""
			nTotal      := 0
			nAtual      := 0

			cQryAux := " SELECT DISTINCT DB.* FROM "+RetSqlName("SDB")+ " DB "
			cQryAux += " INNER JOIN "+RetSqlName("SD2")+ " D2 "
			cQryAux += " ON D2_DOC=DB_DOC "
			cQryAux += " AND D2_SERIE='R' "
			cQryAux += " AND D2.D_E_L_E_T_<>'*'  "
			cQryAux += " WHERE  "
			cQryAux += " DB_ESTORNO=''  "
			cQryAux += " AND D2_ORDSEP='" + AllTrim(cOrdesep) +"' "
			cQryAux += " AND DB_PRODUTO='" + AllTrim(cProd) +"' "
			cQryAux += " AND DB.D_E_L_E_T_<>'*'  "


			cWorkSheet  := "SDB DESPUES"
			n1Statu :=TCSqlExec(cQryAux)
			if (n1Statu < 0)
				MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
			Else

				//Se tiver a consulta
				If !Empty(cQryAux)
					TCQuery cQryAux New Alias "QRY_AUX"
					DbSelectArea('SX3')
					SX3->(DbSetOrder(2)) //X3_CAMPO
					//Percorrendo a estrutura
					aEstrut := QRY_AUX->(DbStruct())
					ProcRegua(Len(aEstrut))
					For nAux := 1 To Len(aEstrut)
						IncProc("Incluindo coluna "+cValToChar(nAux)+" de "+cValToChar(Len(aEstrut))+"...")
						cTitulo := ""
						If SX3->(DbSeek(aEstrut[nAux][1]))
							cTitulo := Alltrim(SX3->X3_TITULO)
							If SX3->X3_TIPO == 'D'
								TCSetField("QRY_AUX", aEstrut[nAux][1], "D")
							EndIf
						Else
							cTitulo := Capital(Alltrim(aEstrut[nAux][1]))
						EndIf

						aAdd(aColunas, cTitulo)
					Next
					oFWMsExcel:AddworkSheet(cWorkSheet)
					oFWMsExcel:AddTable(cWorkSheet, cTable)
					For nAux := 1 To Len(aColunas)
						oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
					Next
					DbSelectArea("QRY_AUX")
					QRY_AUX->(DbGoTop())
					Count To nTotal
					ProcRegua(nTotal)
					nAtual := 0
					QRY_AUX->(DbGoTop())
					While !QRY_AUX->(EoF())
						nAtual++
						IncProc("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")

						aLinhaAux := Array(Len(aColunas))
						For nAux := 1 To Len(aEstrut)
							aLinhaAux[nAux] := &("QRY_AUX->"+aEstrut[nAux][1])
						Next
						oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
						QRY_AUX->(DbSkip())
					EndDo


					QRY_AUX->(DbCloseArea())

				EndIf
			EndIf

			oFWMsExcel:Activate()
			oFWMsExcel:GetXMLFile(cArqFull)
			If ApOleClient("msexcel")
				oExcel := MsExcel():New()
				oExcel:WorkBooks:Open(cArqFull)
				oExcel:SetVisible(.T.)
				oExcel:Destroy()
			Else
				If ExistDir("C:\Program Files (x86)\LibreOffice 5")
					WaitRun('C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "'+cDiretorio+cArquivo+'"', 1)

					//Senão, abre o XML pelo programa padrão
				Else
					ShellExecute("open", cArquivo, "", cDiretorio, 1)
				EndIf
			EndIf

			RestArea(aAreaX3)
			RestArea(aArea)
		else
			MsgAlert("Orden de separación incorrecta","TERMINADO")
			return


		EndIF

	else
		MsgAlert("Producto invalido","TERMINADO")
		return
	EndIF
Return



