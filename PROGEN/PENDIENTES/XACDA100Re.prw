#include "protheus.ch"
#INCLUDE "Acda100x.ch"

User Function xACD10Re()
	Local lContinua      := .T.
	Private cString      := "CB7"
	Private aOrd         := {}
	Private cDesc1       := STR0053 //"Este programa tem como objetivo imprimir informacoes das"
	Private cDesc2       := STR0007 //"Ordens de Separacao"
	Private cPict        := ""
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "G"
	Private nomeprog     := "ACD10xR" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := {STR0117,1,STR0118,2,2,1,"",1}  //"Zebrado"###"Administracao"
	Private nLastKey     := 0
	Private cPerg        := "ACD100"
	Private titulo       := STR0054 //"Impressao das Ordens de Separacao"
	Private nLin         := 06
	Private Cabec1       := ""
	Private Cabec2       := ""
	Private cbtxt        := STR0055 //"Regsitro(s) lido(s)"
	Private cbcont       := 0
	Private CONTFL       := 01
	Private m_pag        := 01
	Private lRet         := .T.
	Private imprime      := .T.
	Private wnrel        := "ACD10R" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas como Parametros                                ³
	//³ MV_PAR01 = Ordem de Separacao de       ?                            ³
	//³ MV_PAR02 = Ordem de Separacao Ate      ?                            ³
	//³ MV_PAR03 = Data de Emissao de          ?                            ³
	//³ MV_PAR04 = Data de Emissao Ate         ?                            ³
	//³ MV_PAR05 = Considera Ordens encerradas ?                            ³
	//³ MV_PAR06 = Imprime Codigo de barras    ?                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,Nil,.F.,aOrd,.F.,Tamanho,,.T.)

	Pergunte(cPerg,.F.)

	If	nLastKey == 27
		lContinua := .F.
	EndIf

	If	lContinua
		SetDefault(aReturn,cString)
	EndIf

	If	nLastKey == 27
		lContinua := .F.
	EndIf

	If	lContinua
		RptStatus({|| Relatorio() },Titulo)
	EndIf

	CB7->(DbClearFilter())
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³ Relatorioº Autor ³ Anderson Rodrigues º Data ³  29/10/04   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ SIGAACD                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Relatorio()

	CB7->(DbSetOrder(1))
	CB7->(DbSeek(xFilial("CB7")+MV_PAR01,.T.)) // Posiciona no 1o.reg. satisfatorio
	SetRegua(RecCount()-Recno())

	While ! CB7->(EOF()) .and. (CB7->CB7_ORDSEP >= MV_PAR01 .and. CB7->CB7_ORDSEP <= MV_PAR02)
		If CB7->CB7_DTEMIS < MV_PAR03 .or. CB7->CB7_DTEMIS > MV_PAR04 // Nao considera as ordens que nao tiver dentro do range de datas
			CB7->(DbSkip())
			Loop
		Endif
		If MV_PAR05 == 2 .and. CB7->CB7_STATUS == "9" // Nao Considera as Ordens ja encerradas
			CB7->(DbSkip())
			Loop
		Endif
		CB8->(DbSetOrder(1))
		If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
			CB7->(DbSkip())
			Loop
		EndIf
		IncRegua(STR0056)  //"Imprimindo"
		If lAbortPrint
			@nLin,00 PSAY STR0057 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		Imprime()
		CB7->(DbSkip())
	Enddo
	Fim()
Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³ Imprime  º Autor ³ Anderson Rodrigues º Data ³  12/09/03   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela funcao Relatorio              º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ SIGAACD                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Imprime(lRet)
	Local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
	Local cPedido := Alltrim(CB7->CB7_PEDIDO)
	Local cPedidoEnc := Alltrim(CB7->CB7_PEDIDO)

	Local cCliente:= Alltrim(CB7->CB7_CLIENT)
	Local cLoja   := Alltrim(CB7->CB7_LOJA	)
	Local cNota   := Alltrim(CB7->CB7_NOTA)
	Local cSerie  := Alltrim(CB7->&(SerieNfId("CB7",3,"CB7_SERIE")))
	Local cOP     := Alltrim(CB7->CB7_OP)
	Local cStatus := RetStatus(CB7->CB7_STATUS)
	Local nWidth  := 0.050
	Local nHeigth := 0.75
	Local oPr



	Local cCliEntr := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_CLIENT")
	Local cCliLoj  := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_LOJAENT")
	Local cCliName := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XNOME"))
	Local cClidrec := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XENDENT"))
	Local cCliDepa := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XESTNOM"))
	Local cCliMunc := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMUN"))
	Local cMensaje := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMENINT"))
	Local cMennint := ""
	Local nLinea := 0
	Local i 		:= 0





	cMennint = zMemoToA(cMensaje,70)


	Local _cAliOS  := GetNextAlias()
	Local cQueryOS := ""

	IF Len(cPedido)<1
		cPedido := Alltrim(CB8->CB8_PEDIDO)
		cCliEntr := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_CLIENT")
		cCliLoj  := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_LOJAENT")
		cCliName := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XNOME"))
		cClidrec := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XENDENT"))
		cCliDepa := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XESTNOM"))
		cCliMunc := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMUN"))
		cMensaje := Alltrim(Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_XMENINT"))
	ENDIF

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

	@ 06, 000 Psay STR0058+cOrdSep //"Ordem de Separacao: "

	If CB7->CB7_ORIGEM == "1" // Pedido de Venda
		@ 06, 035 Psay STR0059+cPedidoEnc 	 //"Pedido de Venda: "
		@ 06, 075 Psay STR0060+Alltrim(cCliEntr)+" - "+"Tienda: "+Alltrim(cCliLoj)+" - "+Alltrim(cCliName)+" - "+STR0119+cStatus
		if (LEN(cMennint)<>0)
			nLinea = 7.2
			for i := 1 to Len(cMennint)
				@ nLinea, 000 Psay AllTrim(cMennint[i])
				if i == 1
					@ 7.2, 075 Psay "Direccion Entreg: "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc)
				endif
				nLinea = nLinea + 1
			next
		else
			@ 7.2, 075 Psay "Direccion Entreg: "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc)
		endif
		//@ 7.2, 0mon00 Psay AllTrim(cMensaje)
		//@ 7.2, 075 Psay "Direccion Entreg: "+Alltrim(cClidrec)+" "+Alltrim(cCliDepa)+" "+Alltrim(cCliMunc)
		//    @ 06, 065 Psay STR0060+cCliente+" - "+STR0061+cLoja //"Cliente: "###"Loja: "
		//	@ 06, 095 Psay STR0119+cStatus //"Status: "
	Elseif CB7->CB7_ORIGEM == "2" // Nota Fiscal de Saida
		@ 06, 035 Psay STR0062+cNota+STR0063+cSerie //"Nota Fiscal: "###" - Serie: "
		@ 06, 075 Psay STR0060+cCliente+" - "+STR0061+cLoja //"Cliente: "###"Loja: "
		@ 06, 105 Psay STR0119+cStatus //"Status: "
	Elseif CB7->CB7_ORIGEM == "3" // Ordem de Producao
		@ 06, 035 Psay STR0064+cOP //"Ordem de Producao: "
		@ 06, 070 Psay STR0119+cStatus //"Status: "
	Endif

	If MV_PAR06 == 1 .And. aReturn[5] # 1
		oPr:= ReturnPrtObj()
		MSBAR3("CODE128",2.8,0.8,cOrdSep,oPr,Nil,Nil,Nil,nWidth,nHeigth,.t.,Nil,"B",Nil,Nil,Nil,.f.)
		nLin := 11
	Else
		nLin := 07
	EndIf

	if (LEN(cMennint)<>0)
		nlin = nLinea-1
	endif
	@ ++nLin, 000 Psay Replicate("=",215)
	nLin++
	lin_pag_next =  nLin

	/*@nLin, 000 Psay STR0029 //"Produto"
@nLin, 032 Psay STR0065 //"Armazem"
@nLin, 042 Psay STR0066 //"Endereco"
@nLin, 058 Psay STR0067 //"Lote"
@nLin, 070 Psay STR0068 //"SubLote"
@nLin, 079 Psay STR0069 //"Numero de Serie"
@nLin, 101 Psay STR0070 //"Qtd Original"
@nLin, 116 Psay STR0071 //"Qtd a Separar"
@nLin, 132 Psay STR0072 //"Qtd a Embalar"
@nLin, 148 Psay "Ubicacion 1"
	@nLin, 164 Psay "Ubicacion 2"*/

	@nLin, 000 Psay STR0029 //"Produto"
	@nLin, 030 Psay STR0030 //"Descripcion"
	@nLin, 088 Psay STR0065 //"Armazem"
	// @nLin, 072 Psay STR0066 //"Endereco"
	// @nLin, 088 Psay STR0067 //"Lote"
	// @nLin, 100 Psay STR0068 //"SubLote"
	@nLin, 100 Psay "UM"
	@nLin, 105 Psay STR0198 //"Qtd Liberada"
	@nLin, 125 Psay STR0070 //"Qtd Original"
	@nLin, 140 Psay STR0071 //"Qtd a Separar"
	//@nLin, 142 Psay STR0072 //"Qtd a Embalar"
	@nLin, 160 Psay "Ubic 1"
	@nLin, 170 Psay "Ubic 2"
	@nLin, 185 Psay "Obs"



	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))  // CONSULTA


	cQueryOS := " SELECT CB8_FILIAL, CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_DESC, B1_UM, B1_XUBICA1, B1_XUBICA2, CB8_LOCAL, CB8_LCALIZ,CB8_LOTECT, CB8_NUMLOT,"
	//CAMPO ADICONAL A LA CONSULTA
	cQueryOS += "  C9_QTDLIB, "
	//FIN CAMPO ADICIONAL
	cQueryOS += " SUM(CB8_QTDORI) AS CB8_QTDORI, SUM(CB8_SALDOS) AS CB8_SALDOS, SUM(CB8_SALDOE) AS CB8_SALDOE FROM "+ RetSqlName("CB8") +" CB8"
	cQueryOS += " INNER JOIN "+ RetSqlName("SB1") + " SB1 ON CB8_PROD = B1_COD AND SB1.D_E_L_E_T_ <> '*' "

	//AGREGA CONSULTA EXTRA PARA VALIDAR CANTIDAD LIBERADA VS CANTIDAD SEPARADA
	cQueryOS += " INNER JOIN "+ RetSqlName("SC9") + " SC9 "
	cQueryOS += " ON CB8.CB8_ORDSEP=SC9.C9_ORDSEP "
	cQueryOS += " AND CB8.CB8_PEDIDO=SC9.C9_PEDIDO "
	cQueryOS += " AND CB8.CB8_PROD=SC9.C9_PRODUTO "
	cQueryOS += " AND SC9.D_E_L_E_T_ <> '*' "
	// FIN CONSULTA EXTRA


	cQueryOS += " WHERE CB8_ORDSEP = '" + cOrdSep + "' AND CB8.D_E_L_E_T_ <>'*' "
	cQueryOS += " GROUP BY CB8_FILIAL, CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_DESC, B1_UM, B1_XUBICA1, B1_XUBICA2, CB8_LOCAL, CB8_LCALIZ, CB8_LOTECT, CB8_NUMLOT, "
	cQueryOS += " CB8_ORDSEP, CB8_PEDIDO, CB8_PROD, B1_XUBICA1, B1_XUBICA2"
	//CAMPO ADICONAL AL AGRUPAMIENTO
	cQueryOS += "  ,C9_QTDLIB"
	//FIN CAMPO ADICIONAL
	cQueryOS += " ORDER BY CB8_FILIAL, B1_XUBICA1, B1_XUBICA2
	cQueryOS := ChangeQuery(cQueryOS)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQueryOS), _cAliOS, .F., .T.)

	// If !(_cAliOS)->(EOF())
	// := (_cAliOS)->
	//cQuery := ChangeQuery(cQuery)
	//dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), _cAlias, .F., .T.)



	//While ! CB8->(EOF()) .and. (CB8->CB8_ORDSEP == cOrdSep)
	While ! (_cAliOS)->(EOF()) //.and. ((_cAliOS)->CB8_ORDSEP == cOrdSep)
		nLin++
		If nLin > 59 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			//nLin := 07
			nLin = lin_pag_next
			@nLin, 000 Psay STR0029 //"Produto"
			@nLin, 030 Psay STR0030 //"Descripcion"
			@nLin, 088 Psay STR0065 //"Armazem"
			// @nLin, 072 Psay STR0066 //"Endereco"
			// @nLin, 088 Psay STR0067 //"Lote"
			// @nLin, 100 Psay STR0068 //"SubLote"
			@nLin, 100 Psay "UM"
			@nLin, 105 Psay STR0198 //"Qtd Liberada"
			@nLin, 125 Psay STR0070 //"Qtd Original"
			@nLin, 140 Psay STR0071 //"Qtd a Separar"
			//@nLin, 142 Psay STR0072 //"Qtd a Embalar"
			@nLin, 160 Psay "Ubica 1"
			@nLin, 170 Psay "Ubic 2"
			@nLin, 185 Psay "Obs"
			nLin++
		Endif

		@nLin, 000 Psay (_cAliOS)->CB8_PROD
		@nLin, 030 Psay (_cAliOS)->B1_DESC
		@nLin, 091 Psay (_cAliOS)->CB8_LOCAL
		// @nLin, 072 Psay (_cAliOS)->CB8_LCALIZ
		// @nLin, 088 Psay (_cAliOS)->CB8_LOTECT
		// @nLin, 100 Psay (_cAliOS)->CB8_NUMLOT
		@nLin, 101 Psay (_cAliOS)->B1_UM
		@nLin, 105 Psay (_cAliOS)->C9_QTDLIB Picture "@E 9,999,999"
		@nLin, 125 Psay (_cAliOS)->CB8_QTDORI Picture "@E 9,999,999"
		@nLin, 140 Psay (_cAliOS)->CB8_SALDOS Picture "@E 9,999,999"
		//@nLin, 142 Psay (_cAliOS)->CB8_SALDOE Picture "@E 9,999,999"
		@nLin, 160 Psay (_cAliOS)->B1_XUBICA1
		@nLin, 170 Psay (_cAliOS)->B1_XUBICA2
		@nLin, 189 Psay "_____________________________"
		(_cAliOS)->(DbSkip())
	Enddo

	(_cAliOS)->(dbCloseArea())

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function Fim()

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RetStatusº Autor ³ Anderson Rodrigues º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela funcao Imprime                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RetStatus(cStatus)
	Local cDescri:= " "

	If Empty(cStatus) .or. cStatus == "0"
		cDescri:= STR0073 //"Nao iniciado"
	ElseIf cStatus == "1"
		cDescri:= STR0074 //"Em separacao"
	ElseIf cStatus == "2"
		cDescri:= STR0075 //"Separacao finalizada"
	ElseIf cStatus == "3"
		cDescri:= STR0076 //"Em processo de embalagem"
	ElseIf cStatus == "4"
		cDescri:= STR0077 //"Embalagem Finalizada"
	ElseIf cStatus == "5"
		cDescri:= STR0078 //"Nota gerada"
	ElseIf cStatus == "6"
		cDescri:= STR0079 //"Nota impressa"
	ElseIf cStatus == "7"
		cDescri:= STR0080 //"Volume impresso"
	ElseIf cStatus == "8"
		cDescri:= STR0081 //"Em processo de embarque"
	ElseIf cStatus == "9"
		cDescri:=  STR0082 //"Finalizado"
	EndIf

Return(cDescri)

Static Function zMemoToA(cTexto, nMaxCol, cQuebra, lTiraBra)
	Local aTexto    := {}
	Local aAux      := {}
	Local nAtu      := 0
	Default cTexto  := ''
	Default nMaxCol := 60
	Default cQuebra := ';'
	Default lTiraBra:= .T.

	//Quebrando o Array, conforme -Enter-
	aAux:= StrTokArr(cTexto,Chr(13))

	//Correndo o Array e retirando o tabulamento
	For nAtu:=1 TO Len(aAux)
		aAux[nAtu]:=StrTran(aAux[nAtu],Chr(10),'')
	Next

	//Correndo as linhas quebradas
	For nAtu:=1 To Len(aAux)

		//Se o tamanho de Texto, for maior que o número de colunas
		If (Len(aAux[nAtu]) > nMaxCol)

			//Enquanto o Tamanho for Maior
			While (Len(aAux[nAtu]) > nMaxCol)
				//Pegando a quebra conforme texto por parâmetro
				nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))

				//Caso não tenha, a última posição será o último espaço em branco encontrado
				If nUltPos == 0
					nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
				EndIf

				//Se não encontrar espaço em branco, a última posição será a coluna máxima
				If(nUltPos==0)
					nUltPos:=nMaxCol
				EndIf

				//Adicionando Parte da Sring (de 1 até a Úlima posição válida)
				aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))

				//Quebrando o resto da String
				aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
			EndDo

			//Adicionando o que sobrou
			aAdd(aTexto,aAux[nAtu])
		Else
			//Se for menor que o Máximo de colunas, adiciona o texto
			aAdd(aTexto,aAux[nAtu])
		EndIf
	Next

	//Se for para tirar os brancos
	If lTiraBra
		//Percorrendo as linhas do texto e aplica o AllTrim
		For nAtu:=1 To Len(aTexto)
			aTexto[nAtu] := Alltrim(aTexto[nAtu])
		Next
	EndIf
Return aTexto
