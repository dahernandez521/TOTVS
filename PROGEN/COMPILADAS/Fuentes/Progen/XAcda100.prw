#INCLUDE "Acda100.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "DBTREE.CH"

User Function XuACDA100Re()
	Local lContinua      := .T.
	Local lCustRel		 := ExistBlock("ACD100RE")
	Local cCustRel		 := ""
	Local lACDR100		:= SuperGetMV("MV_ACDR100",.F.,.F.)
	Private cString      := "CB7"
	Private aOrd         := {}
	Private cDesc1       := STR0053 //"Este programa tem como objetivo imprimir informacoes das"
	Private cDesc2       := STR0007 //"Ordens de Separacao"
	Private cPict        := ""
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "ACDA100R" // Coloque aqui o nome do programa para impressao no cabecalho
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
	Private wnrel        := "ACDA100R" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas como Parametros                                ณ
	//ณ MV_PAR01 = Ordem de Separacao de       ?                            ณ
	//ณ MV_PAR02 = Ordem de Separacao Ate      ?                            ณ
	//ณ MV_PAR03 = Data de Emissao de          ?                            ณ
	//ณ MV_PAR04 = Data de Emissao Ate         ?                            ณ
	//ณ MV_PAR05 = Considera Ordens encerradas ?                            ณ
	//ณ MV_PAR06 = Imprime Codigo de barras    ?                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lCustRel
		cCustRel := ExecBlock("ACD100RE",.F.,.F.)
		If ExistBlock(cCustRel)
			ExecBlock( cCustRel, .F., .F.)
		EndIf
	ElseIf lACDR100
		ACDR100()
	Else
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
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ Relatorioบ Autor ณ Anderson Rodrigues บ Data ณ  29/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

STATIC Function Relatorio()

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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ Imprime  บ Autor ณ Anderson Rodrigues บ Data ณ  12/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela funcao Relatorio              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Imprime(lRet)
	Local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
	Local cPedido := Alltrim(CB7->CB7_PEDIDO)
	Local cCliente:= Alltrim(CB7->CB7_CLIENT)
	Local cLoja   := Alltrim(CB7->CB7_LOJA	)
	Local cNota   := Alltrim(CB7->CB7_NOTA)
	Local cSerie  := Alltrim(CB7->&(SerieNfId("CB7",3,"CB7_SERIE")))
	Local cOP     := Alltrim(CB7->CB7_OP)
	Local cStatus := RetStatus(CB7->CB7_STATUS)
	Local nWidth  := 0.050
	Local nHeigth := 0.75
	Local oPr

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

	@ 06, 000 Psay STR0058+cOrdSep //"Ordem de Separacao: "

	If CB7->CB7_ORIGEM == "1" // Pedido de Venda
		@ 06, 035 Psay STR0059+cPedido 	 //"Pedido de Venda: "
		@ 06, 065 Psay STR0060+cCliente+" - "+STR0061+cLoja //"Cliente: "###"Loja: "
		@ 06, 095 Psay STR0119+cStatus //"Status: "
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

	@ ++nLin, 000 Psay Replicate("=",147)
	nLin++

	@nLin, 000 Psay STR0029 //"Produto"
	@nLin, 032 Psay STR0065 //"Armazem"
	@nLin, 042 Psay STR0066 //"Endereco"
	@nLin, 058 Psay STR0067 //"Lote"
	@nLin, 070 Psay STR0068 //"SubLote"
	@nLin, 079 Psay STR0069 //"Numero de Serie"
	@nLin, 101 Psay STR0070 //"Qtd Original"
	@nLin, 116 Psay STR0071 //"Qtd a Separar"
	@nLin, 132 Psay STR0072 //"Qtd a Embalar"

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	While ! CB8->(EOF()) .and. (CB8->CB8_ORDSEP == cOrdSep)
		nLin++
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 06
			@nLin, 000 Psay STR0029 //"Produto"
			@nLin, 032 Psay STR0065 //"Armazem"
			@nLin, 042 Psay STR0066 //"Endereco"
			@nLin, 058 Psay STR0067 //"Lote"
			@nLin, 070 Psay STR0068 //"SubLote"
			@nLin, 079 Psay STR0069 //"Numero de Serie"
			@nLin, 101 Psay STR0070 //"Qtd Original"
			@nLin, 116 Psay STR0071 //"Qtd a Separar"
			@nLin, 132 Psay STR0072 //"Qtd a Embalar"
		Endif
		@nLin, 000 Psay CB8->CB8_PROD
		@nLin, 032 Psay CB8->CB8_LOCAL
		@nLin, 042 Psay CB8->CB8_LCALIZ
		@nLin, 058 Psay CB8->CB8_LOTECT
		@nLin, 070 Psay CB8->CB8_NUMLOT
		@nLin, 079 Psay CB8->CB8_NUMSER
		@nLin, 099 Psay CB8->CB8_QTDORI Picture "@E 999,999,999.99"
		@nLin, 114 Psay CB8->CB8_SALDOS Picture "@E 999,999,999.99"
		@nLin, 130 Psay CB8->CB8_SALDOE Picture "@E 999,999,999.99"
		CB8->(DbSkip())
	Enddo

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza impressao                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

STATIC Function Fim()

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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ RetStatusบ Autor ณ Anderson Rodrigues บ Data ณ  04/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela funcao Imprime                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

STATIC Function RetStatus(cStatus)
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



