
#Include "Protheus.ch"
#Include "TopConn.ch"



User Function XMIGPREG()



	Local UserActua:=RetCodUsr()
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := "MIGRACIÓN GRUPO DE PREGUNTAS"
	Local oGroup1
	Local oMultiGe1
	Local cMultiGe1 := "010"
	Local oMultiGe2
	Local cMultiGe2 := "020"
	Local oMultiGe3
	Local cMultiGe3 := "GRUP_PREGUN         "
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay5
	Static oDlg


	if UserActua<>"000027"
		Return
	EndIF


	DEFINE MSDIALOG oDlg TITLE "MIGRACIÓN DE GRUPO DE PREGUNTAS" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL
	@ 009, 007 GROUP oGroup1 TO 239, 290 PROMPT "GRUPO DE PREGUNTAS" OF oDlg COLOR 0, 16777215 PIXEL
	@ 022, 013 SAY oSay1 PROMPT "Indique por favor los parametros para realizar la busqueda" SIZE 211, 009 OF oDlg COLORS 0, 16777215 PIXEL

	@ 217, 021 BUTTON oButton1 PROMPT "Generar" SIZE 048, 014 action processa({|| fProcessa(cMultiGe1,cMultiGe2,cMultiGe3,cGet1) }, "Processando...") OF oDlg PIXEL
	@ 215, 230 BUTTON oButton2 PROMPT "Salir" SIZE 044, 016 ACTION   oDlg:End() OF oDlg PIXEL

	@ 037, 017 SAY oSay5 PROMPT "Titulo de la Consulta:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 071 MSGET oGet1 VAR cGet1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL


	@ 061, 017 SAY oSay1 PROMPT "ORIGEN:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 061, 071 MSGET oMultiGe1 VAR cMultiGe1 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 075, 017 SAY oSay2 PROMPT "DESTINO:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 075, 071 MSGET oMultiGe2 VAR cMultiGe2 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 089, 017 SAY oSay3 PROMPT "Grupo preg:" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 089, 071 MSGET oMultiGe3 VAR cMultiGe3 SIZE 120, 010 OF oDlg COLORS 0, 16777215 PIXEL


	ACTIVATE MSDIALOG oDlg CENTERED
Return




Return




Static Function fProcessa(Origen,Destino,Grupo,cTitAux)
	Local aArea       := GetArea()
	Local aAreaX3     := SX3->(GetArea())
	Local nAux        := 0
	Local oFWMsExcel
	Local oExcel
	Local cDiretorio  := GetTempPath()
	// Local cArquivo    := 'zQry2Excel.xml'
	Local dData := DTOC(DATE())
	Local dtime := Time()
	Local cArquivo    := alltrim(cTitAux) +"_"+ dData +"_"+ dtime+".xml"
	cArquivo := replace(cArquivo,"/","")
	cArquivo := replace(cArquivo,":","")
	Local cArqFull    := cDiretorio + cArquivo
	Local cWorkSheet  := "GRUPO DE PREGUNTAS"
	Local cTable      := ""
	Local aColunas    := {}
	Local aEstrut     := {}
	Local aLinhaAux   := {}
	Local cTitulo     := ""
	Local nTotal      := 0
	Local nAtual      := 0
	Local Ins :=""
	Default cQryAux   := ""
	Default cTitAux   := "Tutulo de la consulta"

	cTable := cTitAux

	Ins := "SET IDENTITY_INSERT SX1"+Destino+" ON"
	Ins += " INSERT INTO SX1"+Destino+" "
	Ins += " (X1_GRUPO, "
	Ins += " X1_ORDEM, "
	Ins += " X1_PERGUNT, "
	Ins += " X1_PERSPA, "
	Ins += " X1_PERENG, "
	Ins += " X1_VARIAVL, "
	Ins += " X1_TIPO, "
	Ins += " X1_TAMANHO, "
	Ins += " X1_DECIMAL, "
	Ins += " X1_PRESEL, "
	Ins += " X1_GSC, "
	Ins += " X1_VALID, "
	Ins += " X1_VAR01, "
	Ins += " X1_DEF01, "
	Ins += " X1_DEFSPA1, "
	Ins += " X1_DEFENG1, "
	Ins += " X1_CNT01, "
	Ins += " X1_VAR02, "
	Ins += " X1_DEF02, "
	Ins += " X1_DEFSPA2, "
	Ins += " X1_DEFENG2, "
	Ins += " X1_CNT02, "
	Ins += " X1_VAR03, "
	Ins += " X1_DEF03, "
	Ins += " X1_DEFSPA3, "
	Ins += " X1_DEFENG3, "
	Ins += " X1_CNT03, "
	Ins += " X1_VAR04, "
	Ins += " X1_DEF04, "
	Ins += " X1_DEFSPA4, "
	Ins += " X1_DEFENG4, "
	Ins += " X1_CNT04, "
	Ins += " X1_VAR05, "
	Ins += " X1_DEF05, "
	Ins += " X1_DEFSPA5, "
	Ins += " X1_DEFENG5, "
	Ins += " X1_CNT05, "
	Ins += " X1_F3, "
	Ins += " X1_PYME, "
	Ins += " X1_GRPSXG, "
	Ins += " X1_HELP, "
	Ins += " X1_PICTURE, "
	Ins += " X1_IDFIL, "
	Ins += " R_E_C_N_O_, "
	Ins += " R_E_C_D_E_L_, "
	Ins += " D_E_L_E_T_)"
	Ins += " SELECT "
	Ins += " X1_GRUPO, "
	Ins += " X1_ORDEM, "
	Ins += " X1_PERGUNT, "
	Ins += " X1_PERSPA, "
	Ins += " X1_PERENG, "
	Ins += " X1_VARIAVL, "
	Ins += " X1_TIPO, "
	Ins += " X1_TAMANHO, "
	Ins += " X1_DECIMAL, "
	Ins += " X1_PRESEL, "
	Ins += " X1_GSC, "
	Ins += " X1_VALID, "
	Ins += " X1_VAR01, "
	Ins += " X1_DEF01, "
	Ins += " X1_DEFSPA1, "
	Ins += " X1_DEFENG1, "
	Ins += " X1_CNT01, "
	Ins += " X1_VAR02, "
	Ins += " X1_DEF02, "
	Ins += " X1_DEFSPA2, "
	Ins += " X1_DEFENG2, "
	Ins += " X1_CNT02, "
	Ins += " X1_VAR03, "
	Ins += " X1_DEF03, "
	Ins += " X1_DEFSPA3, "
	Ins += " X1_DEFENG3, "
	Ins += " X1_CNT03, "
	Ins += " X1_VAR04, "
	Ins += " X1_DEF04, "
	Ins += " X1_DEFSPA4, "
	Ins += " X1_DEFENG4, "
	Ins += " X1_CNT04, "
	Ins += " X1_VAR05, "
	Ins += " X1_DEF05, "
	Ins += " X1_DEFSPA5, "
	Ins += " X1_DEFENG5, "
	Ins += " X1_CNT05, "
	Ins += " X1_F3, "
	Ins += " X1_PYME, "
	Ins += " X1_GRPSXG, "
	Ins += " X1_HELP, "
	Ins += " X1_PICTURE, "
	Ins += " X1_IDFIL, "
	Ins += " ISNULL((SELECT MAX(R_E_C_N_O_) FROM SX1"+DESTINO+") + ROW_NUMBER() OVER( ORDER BY R_E_C_N_O_),1) AS R_E_C_N_O_, "
	Ins += " R_E_C_D_E_L_, "
	Ins += " ' ' "
	Ins += " FROM SX1"+Origen+"  WHERE D_E_L_E_T_ <> '*' AND X1_GRUPO='"+Grupo+"'"
	Ins += " AND NOT EXISTS (SELECT 1 FROM SX1"+Destino+" WHERE D_E_L_E_T_ <> '*' AND X1_GRUPO='"+Grupo+"')"

	Ins += "SET IDENTITY_INSERT SX1"+Destino+" OFF"
	n1Statu :=TCSqlExec(Ins)


	if (n1Statu < 0)
		MsgInfo("Error en la sintaxis de la consulta   TCSQLError() ;" + TCSQLError())
		Return
	ENDIF


	cQryAux := " SELECT * FROM SX1"+Destino+" WHERE D_E_L_E_T_ <> '*' AND X1_GRUPO='"+Grupo+"'"

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
Return



