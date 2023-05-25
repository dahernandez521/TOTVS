#include "PROTHEUS.ch" 
#include "WMSXFUND.ch"
#define CLRF  Chr(13)+Chr(10)
#define RELDETEST 7

/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSXFUND                                                           |
+---------+--------------------------------------------------------------------+
|Autor    | Jackson Patrick Werka                                              |
+---------+--------------------------------------------------------------------+
|Data     | 05/05/2014                                                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Esta fun��o tem por objetivo reunir todas as informa��es relativas |
|         | ao processo de endere�amento do WMS, como busca de endere�os,      |
|         | valida��es de capacidade e gera��o dos movimentos de endere�amento.|
+---------+--------------------------------------------------------------------+

*/

/*/{Protheus.doc} WmsLogEnd
Indica se deve ou n�o imprimir o relat�rio de busca de endere�os.
Caso n�o seja passado o par�metro lSwLogEnd, a fun��o ir� apenas retornar
o valor atual do processamento indicando se deve ou n�o gerar o relat�rio.
Caso seja passado um valor para o parametro a fun��o ir� assumir que daquele
ponto em diante o indicativo do relat�rio deve ser o recebido e ir� retornar
o valor do parametro que estava anteriomente.
@author Jackson Patrick Werka
@since 10/09/2014

@param [lSwLogEnd], L�gico, Indicador se deve ou n�o gerar o relat�rio
@return L�gico Indica se existem dados para gerar o relat�rio
/*/
Static __lSwLogEnd := .F.
Function WmsLogEnd(lSwLogEnd)
Local lOldLogEnd := __lSwLogEnd
	If ValType(lSwLogEnd) == 'L'
		__lSwLogEnd := lSwLogEnd
	EndIf
Return lOldLogEnd

Static lWMSMULP  := ExistBlock("WMSMULP")  // PE para indiciar utiliza��o de multiplos pickings
Static lDLENDEOK := ExistBlock("DLENDEOK") // PE para indicar se utiliza ou n�o o endere�o para endere�amento
Static lDLGNSERI := ExistBlock("DLGNSERI") // PE para informar o n�mero de s�rie endere�ado pelo WMS
Static lDLGRVSTO := ExistBlock("DLGRVSTO") // PE antes da grava��o da movimenta��o de estoque de endere�amento
Static lWMSQYEND := ExistBlock("WMSQYEND") // PE para substituir a query padr�o de busca de endere�os para armazenagem
Static lWMSCPEND := ExistBlock("WMSCPEND") // PE para substituir a valida��o padr�o de cadastro dos produto no compartilhamento de endere�o

//�����������������������������������������������������������������������Ŀ
//� Formato do Array aParam150, que sera utilizado para passar Parametros �
//� a todas as funcoes cadastradas nas Tabelas executadas pela DLA150Serv.�
//�����������������������������������������������������������������������Ĵ
//� aParam150[01] = Produto                                               �
//� aParam150[02] = Armazem Origem                                        �
//� aParam150[03] = Documento                                             �
//� aParam150[04] = Serie                                                 �
//� aParam150[05] = Numero Sequencial                                     �
//� aParam150[06] = Quantidade a ser Movimentada                          �
//� aParam150[07] = Data da Movimentacao                                  �
//� aParam150[08] = Hora da Movimentacao                                  �
//� aParam150[09] = Servico                                               �
//� aParam150[10] = Tarefa                                                �
//� aParam150[11] = Atividade                                             �
//� aParam150[12] = Cliente/Fornecedor                                    �
//� aParam150[13] = Loja                                                  �
//� aParam150[14] = Tipo da Nota Fiscal                                   �
//� aParam150[15] = Item da Nota Fiscal                                   �
//� aParam150[16] = Tipo de Movimentacao                                  �
//� aParam150[17] = Origem de Movimentacao                                �
//� aParam150[18] = Lote                                                  �
//� aParam150[19] = Sub-Lote                                              �
//� aParam150[20] = Endereco Origem                                       �
//� aParam150[21] = Estrutura Fisica Origem                               �
//� aParam150[22] = Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)     �
//� aParam150[23] = Codigo da Carga                                       �
//� aParam150[24] = Nr. do Unitizador                                     �
//� aParam150[25] = Armazem Destino                                       �
//� aParam150[26] = Endereco Destino                                      �
//� aParam150[27] = Estrutura Fisica Destino                              �
//� aParam150[28] = Ordem da Tarefa                                       �
//� aParam150[29] = Ordem da Atividade                                    �
//� aParam150[30] = Recurso Humano                                        �
//� aParam150[31] = Recurso Fisico                                        �
//� aParam150[32] = Identificador do DCF DCF_ID                           �
//� aParam150[33] = Codigo da Norma informada no Docto de Entrada         �
//� aParam150[34] = Identificador exclusivo do Movimento no SDB           �
//�������������������������������������������������������������������������
/*/{Protheus.doc} WmsEndereca
Gera e/ou executa o endere�amento.
@author Jackson Patrick Werka
@since 10/09/2014

@param [lRadioF], L�gico, Indicador se utiliza radio frequ�ncia
@param [cStatRF], Caracter, Status do RF, onde: 1 - Gera��o, 2 - Execu��o

@return L�gico Endere�amento realizado com sucesso
/*/
Static __cMsgOsPr := ""
Function WmsEndereca(lRadioF, cStatRF, lCroosDock)
Local aAreaAnt  := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSB5   := SB5->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD2   := SD2->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local aAreaSD5   := SD5->(GetArea())

Local lRet      := .T.
Local cMensagem := ""
Local cProduto  := ""
Local cArmazem  := ""
Local cDocto    := ""
Local cSerie    := ""
Local cNumSeq   := ""
Local cOrigLan  := ""
Local nQuant    := 0
Local cEndOrig  := ""
Local cEstOrig  := ""
Local cCodZona  := ""
Local nOrdem    := 0
Local cSeek     := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cTipoNF   := ""
Local cTm       := ""
Local cItem     := ""
Local lOnlyPkg  := .F.

Default lRadioF    := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF    := '1'
Default lCroosDock := .F.

	//-- Considera os parametros passados pela aParam150
	If Type('aParam150') == 'A'
		cProduto := aParam150[01]
		cArmazem := aParam150[02]
		cDocto   := aParam150[03]
		cSerie   := aParam150[04]
		cNumSeq  := aParam150[05]
		nQuant   := aParam150[06]
		cEndOrig := aParam150[20]
		cEstOrig := aParam150[21]
	EndIf

	__cMsgOsPr := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(cProduto)+CLRF
	If !(lRet:=QtdComp(nQuant)>QtdComp(0))
		cMensagem := __cMsgOsPr
		cMensagem += WmsFmtMsg(STR0001,{{"[VAR01]",cProduto},{"[VAR02]",cArmazem}}) //"Quantidade inv�lida a enderecar para o Produto/Armaz�m [VAR01]/[VAR02]"
		WmsMessage(cMensagem,"WmsEndereca",1)
	EndIf

	If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
		
		//�����������������������������������������������������������������������Ŀ
		//� Posiciona o SB1                                                       �
		//�������������������������������������������������������������������������
		If lRet
			SB1->(DbSetOrder(1))
			If !(lRet:=SB1->(MsSeek(xFilial('SB1')+cProduto, .F.)))
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0002,{{"[VAR01]",cProduto}}) //"Produto [VAR01] n�o cadastrado. (SB1)"
				WmsMessage(cMensagem,"WmsEndereca",1)
			Else
				cArmazem := Iif(Empty(cArmazem),RetFldProd(SB1->B1_COD,"B1_LOCPAD"),cArmazem)
			EndIf
		EndIf

		//�����������������������������������������������������������������������Ŀ
		//� Posiciona o SB5                                                       �
		//�������������������������������������������������������������������������
		If lRet
			If ExistBlock('DLSB5END')
				aRetPE   := ExecBlock('DLSB5END', .F., .F., {cProduto})
				cCodZona := aRetPE[1]
				lRet     := aRetPE[2]
			Else
				SB5->(DbSetOrder(1))
				If !(lRet:=SB5->(MsSeek(xFilial('SB5')+ cProduto, .F.)))
					cMensagem := __cMsgOsPr
					cMensagem += WmsFmtMsg(STR0003,{{"[VAR01]",cProduto}}) //"Produto [VAR01] n�o cadastrado nos Dados Adicionais do Produto. (SB5)"
					WmsMessage(cMensagem,"WmsEndereca",1)
				Else
					cCodZona := SB5->B5_CODZON
					lOnlyPkg := (SB5->B5_NPULMAO == "2")
				EndIf
			EndIf
		EndIf

		//�����������������������������������������������������������������������Ŀ
		//� Posiciona o DC4                                                       �
		//�������������������������������������������������������������������������
		If lRet
			DC4->(DbSetOrder(1))
			If !DC4->(lRet:=DC4->(MsSeek(xFilial('DC4')+cCodZona)))
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0004,{{"[VAR01]",cCodZona}}) //"Zona de Armazenagem [VAR01] n�o cadastrada. (DC4)"
				WmsMessage(cMensagem,"WmsEndereca",1)
			EndIf
		EndIf
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//� Posiciona e Consiste SDA                                              �
	//�������������������������������������������������������������������������
	If lRet
		DbSelectArea('SDA')
		DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
		If !(lRet:=MsSeek(xFilial('SDA')+cProduto+cArmazem+cNumSeq+cDocto+cSerie, .F.))
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0005,{{"[VAR01]",cProduto},{"[VAR02]",cArmazem},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)}}) //"O registro de movimenta��o do Produto/Armaz�m/Doc/S�rie '####' n�o foi encontrado no Arquivo de Saldos a Enderecar (SDA)."
			WmsMessage(cMensagem,"WmsEndereca",1)
		ElseIf !(lRet:=lRet.And.(QtdComp(SDA->DA_SALDO)>QtdComp(0)))
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0006,{{"[VAR01]",cProduto},{"[VAR02]",cArmazem},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)}}) //"O Produto/Armaz�m/Doc/S�rie '###' n�o possui Saldo a Enderecar (SDA)."
			WmsMessage(cMensagem,"WmsEndereca",1)
		Else
			cOrigLan := SDA->DA_ORIGEM
		EndIf
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//� Posiciona e Consiste SD1, SD2, SD3 ou SD5                             �
	//�������������������������������������������������������������������������
	If lRet .And. cOrigLan$'SD1�SD2�SD3�SD5'
		DbSelectArea(cOrigLan)
		If cOrigLan == 'SD1'
			nOrdem := 5
			cSeek  := xFilial('SD1')+cProduto+cArmazem+cNumSeq
		ElseIf cOrigLan == 'SD2'
			nOrdem := 1
			cSeek  := xFilial('SD2')+cProduto+cArmazem+cNumSeq
		ElseIf cOrigLan == 'SD3'
			nOrdem := 3
			cSeek  := xFilial('SD3')+cProduto+cArmazem+cNumSeq
		Else
			nOrdem := 3
			cSeek  := xFilial('SD5')+cNumSeq+cProduto+cArmazem+SDA->DA_LOTECTL
		EndIf
		DbSetOrder(nOrdem)
		If !(MsSeek(cSeek, .F.))
			If (lRet:=!(cOrigLan=='SD3'))
				cCliFor := SDA->DA_CLIFOR
				cLoja   := SDA->DA_LOJA
				cTipoNF := SDA->DA_TIPONF
			Else
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0007,{{"[VAR01]",cProduto},{"[VAR02]",cArmazem},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)},{"[VAR05]",cOrigLan}}) //"O registro de movimenta��o do Produto/Armaz�m/Doc/S�rie [VAR01]/[VAR02]/[VAR03]/[VAR04] n�o foi encontrado no Arquivo de Origem ([VAR05])."
				WmsMessage(cMensagem,"WmsEndereca",1)
			EndIf
		ElseIf cOrigLan == 'SD1'
			cCliFor := SD1->D1_FORNECE
			cLoja   := SD1->D1_LOJA
			cTipoNF := SD1->D1_TIPO
			cTm     := SD1->D1_TES
			cItem   := SD1->D1_ITEM
		ElseIf cOrigLan == 'SD2'
			cCliFor := SD2->D2_CLIENTE
			cLoja   := SD2->D2_LOJA
			cTipoNF := SD2->D2_TIPO
			cTm     := SD2->D2_TES
			cItem   := SD2->D2_ITEM
		ElseIf cOrigLan == 'SD3'
			Do While SD3->(!Eof() .And. cSeek == D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ)
				If !Empty(SD3->D3_SERVIC)
					cItem:= '01'
					cTm := SD3->D3_TM
				EndIf
				SD3->(DbSkip())
			EndDo
		Else
			cCliFor := SD5->D5_CLIFOR
			cLoja   := SD5->D5_LOJA
		EndIf
	EndIf
	aParam150[12] := cCliFor         //-- Cliente/Fornecedor
	aParam150[13] := cLoja           //-- Loja
	aParam150[14] := cTipoNF         //-- Tipo da Nota Fiscal
	aParam150[15] := cItem           //-- Item da Nota Fiscal
	aParam150[16] := cTM             //-- Tipo de Movimentacao
	aParam150[17] := cOrigLan        //-- Origem do Lancamento

	//�����������������������������������������������������������������������Ŀ
	//� Forca a utilizacao de um Endereco Origem                              �
	//�������������������������������������������������������������������������
	If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
		If lRet .And. Empty(cEndOrig)
			If lRadioF .And. ISTelNet()
				DLAviso(lRadioF, 'SIGAWMS', STR0008) //O endere�o origem n�o foi informado
				lRet := .F.
			Else
				cEndOrig := Space(Len(SBF->BF_LOCALIZ))
				DLPergEnd(@cEndOrig,.T.,.T.,'1',cArmazem) //"Identifique a origem do Servi�o WMS:"
				If !Empty(cEndOrig)
					aParam150[20] := cEndOrig
				EndIf
				cEstOrig := Posicione('SBE',1,xFilial('SBE')+cArmazem+cEndOrig,'BE_ESTFIS')
				aParam150[21] := cEstOrig
			EndIf
		EndIf
	EndIf

	If lRet
		If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
			Begin Transaction
			If lCroosDock
				lRet := WmsEstCros(cProduto,cArmazem,@nQuant,cCodZona,lRadioF,cStatRF)
			Else
				lRet := WmsEndEnt(cProduto,cArmazem,@nQuant,lOnlyPkg,cCodZona,lRadioF,cStatRF)
			EndIf
			//-- Se houve algum erro aborta toda a transa��o
			If !lRet
				DisarmTransaction()
			EndIf
			End Transaction
		ElseIf lRadioF .And. cStatRF == '2'
			lRet := WmsMovEnd(aParam150)
		EndIf
	EndIf

RestArea(aAreaSB1)
RestArea(aAreaSB5)
RestArea(aAreaSD1)
RestArea(aAreaSD2)
RestArea(aAreaSD3)
RestArea(aAreaSD5)
RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} WmsEndCross
Permite efetuar o endere�amento nas estrturas do tipo crossdocking
@author Jackson Patrick Werka
@since 19/05/2015
/*/
Function WmsEndCross(lRadioF, cStatRF)
Return WmsEndereca(lRadioF,cStatRF,.T.)

/*/{Protheus.doc} WmsEndEnt
Permite efetuar o endere�amento da entrada pesquisando as estruturas da sequencia de
abastecimento do produto, levando em considera��es todas as varia��es de parametriza��o.
@author Jackson Patrick Werka
@since 10/09/2014

@param cProduto, Caracter, C�digo do produto
@param cLocDest, Caracter, Local destino para busca de endere�os
@param nQuant, Num�rico, Quantidade total a ser endere�ada. Passar por referencia @nQuant
@param lOnlyPkg, L�gico, Indica se o produto n�o endere�a em estrutura pulm�o
@param cZonaPrd, Caracter, Zona de armazenagem padr�o do produto.
@param lRadioF, L�gico, Indicador se utiliza radio frequ�ncia
@param cStatRF, Caracter, Status do RF, onde: 1 - Gera��o, 2 - Execu��o

@return L�gico Processou busca de endere�os com sucesso
/*/
Static Function WmsEndEnt(cProduto,cLocDest,nQuant,lOnlyPkg,cZonaPrd,lRadioF,cStatRF)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cMensagem := ""
Local aSeqAbast := {}
Local nSeqAbast := 0
Local cEstDest  := ""
Local nTipoEst  := 0
Local cCodNorma := ""
//-- MV_WMSZNSA
//-- .T. = Utiliza zona de armazenagem alternativa somente se for a ultima sequencia de abastecimento
//-- .F. = Utiliza zona de armazenagem alternativa para cada estrutura da sequencia de abastecimento
Local lPriorSA   := SuperGetMV('MV_WMSZNSA',.F.,.F.)
Local lZonaPrd   := .T.
Local lZonaAlt   := .F.
Local aNivEndOri := {}
//-- Tipo de Enderecamento WMS
//-- 1 - S� Endere�a Em Endere�os Vazios
//-- 2 - Tenta Antes Endere�os Parcialmente Cheios
//-- 3 - Tenta Antes Endere�os Parcialmente Cheios Sem Misturar Lotes
//-- 4 - Compartilha Endere�os Com Produtos Diferentes
Local cWmsTpEn   := '1'
Local nEndMinAux := 1 / (10 ** TamSX3('DC3_QTDUNI')[2])
Local nQtdMinEnd := 0
Local lQtdMinEnd := .F.
Local aSeqAbPkg  := {}
Local nQtdAgrup  := 0
Local lLogEnd    := Type("aLogEnd") == "A"

	//-- Posiciona na menor sequ�ncia de abastecimento do produto
	aSeqAbast := WmsSeqAbast(cLocDest,cProduto,1)
	If Len(aSeqAbast) <= 0
		cMensagem := __cMsgOsPr
		cMensagem += WmsFmtMsg(STR0009,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest}}) //"Produto/Armaz�m [VAR01]/[VAR02] n�o possui sequ�ncia de abastecimento cadastrada (DC3)."
		WmsMessage(cMensagem,"WmsEndEnt",1)
		lRet := .F.
	EndIf
	nSeqAbast := 1

	If lRet .And. lLogEnd
		AAdd(aLogEnd,{DCF->DCF_DOCTO,DCF->DCF_SERIE,cProduto,SB1->B1_DESC,SDA->DA_LOTECTL,nQuant,{}})
	EndIf

	//-- Realiza o endere�amento dos produtos at� que a quantidade seja zero
	Do While lRet .And. nSeqAbast <= Len(aSeqAbast) .And. QtdComp(nQuant) > QtdComp(0)
		DC3->(DbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
		DC3->(DbSeek(xFilial('DC3')+cProduto+cLocDest+aSeqAbast[nSeqAbast]))
		cEstDest   := DC3->DC3_TPESTR
		cCodNorma  := DC3->DC3_CODNOR
		nTipoEst   := DLTipoEnd(DC3->DC3_TPESTR)
		cWmsTpEn   := Iif(!Empty(DC3->DC3_TIPEND),DC3->DC3_TIPEND,'1')
		//-- Estrutura de Cross Docking e Box/Doca, n�o � considerada pelo endere�amento normal
		If nTipoEst != 3 .And. nTipoEst != 5
			DC8->(DbSetOrder(1))
			If DC8->(!MsSeek( xFilial("DC8") + cEstDest ))
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0010,{{"[VAR01]",cEstDest}}) //"Estrutura Fisica [VAR01] n�o cadastrada. (DC8)"
				WmsMessage(cMensagem,"WmsEndEnt",1)
				Loop
			EndIf
			If DC8->DC8_TPESTR == '2' .And. (AScan(aSeqAbPkg, aSeqAbast[nSeqAbast]) <= 0) //Picking
				AAdd(aSeqAbPkg,aSeqAbast[nSeqAbast])
			EndIf
			If lLogEnd
				AAdd(aLogEnd[Len(aLogEnd),RELDETEST],{WmsFmtMsg(STR0011,{{"[VAR01]",cLocDest},{"[VAR02]",cEstDest},{"[VAR03]",DC8->DC8_DESEST}}),cWmsTpEn,{}}) //"Armaz�m [VAR01] - Busca de endere�o na estrutura [VAR02] - [VAR03]"
			EndIf
			If lOnlyPkg .And. nTipoEst == 1 //N�o permite pulm�o
				AddMsgLog(cEstDest,'00','00','00','00',Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0014) //"Produto n�o utiliza estrutura pulm�o. (B5_NPULMAO)"
			Else
				If QtdComp(DC3->DC3_ENDMIN) > 0
					nQtdMinEnd := DC3->DC3_ENDMIN
					lQtdMinEnd := .T.
				Else
					nQtdMinEnd := nEndMinAux
				EndIf
				lRet := WmsEndEstr(cProduto,cLocDest,cEstDest,@nQuant,cWmsTpEn,lOnlyPkg,lPriorSA,lZonaPrd,cZonaPrd,cCodNorma,lRadioF,cStatRF,aNivEndOri,nQtdMinEnd,.T.)
			EndIf
		EndIf
		nSeqAbast++
		//Se prioriza a sequencia de abastecimento e chegou no fim, volta para pesquisar as alternativas
		If lPriorSA .And. nSeqAbast > Len(aSeqAbast) .And. !lZonaAlt
			nSeqAbast := 1
			lZonaPrd  := .F.
			lZonaAlt  := .T.
		EndIf
	EndDo
	// Se restou saldo menor que uma caixa e ao menos uma das estruturas possuia endere�amento m�nimo
	If lRet .And. QtdComp(nQuant) > 0 .And. lQtdMinEnd
		nQtdAgrup := RetQtdCx(cProduto)
		If QtdComp(nQuant) < QtdComp(nQtdAgrup)
			// Realiza mais uma busca somente entre os endere�os de picking sem considerar capacidade dos mesmos
			nSeqAbast := 1
			lZonaPrd  := .T.
			lZonaAlt  := .F.
			Do While lRet .And. nSeqAbast <= Len(aSeqAbPkg) .And. QtdComp(nQuant) > QtdComp(0)
				DC3->(DbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
				DC3->(DbSeek(xFilial('DC3')+cProduto+cLocDest+aSeqAbPkg[nSeqAbast]))
				cEstDest   := DC3->DC3_TPESTR
				cCodNorma  := DC3->DC3_CODNOR
				cWmsTpEn   := Iif(!Empty(DC3->DC3_TIPEND),DC3->DC3_TIPEND,'1')
				nQtdMinEnd := nEndMinAux
				DC8->(DbSetOrder(1))
				DC8->(MsSeek( xFilial("DC8") + cEstDest ))
				If lLogEnd
					AAdd(aLogEnd[Len(aLogEnd),RELDETEST],{WmsFmtMsg(STR0011,{{"[VAR01]",cLocDest},{"[VAR02]",cEstDest},{"[VAR03]",DC8->DC8_DESEST}})+" - Sem considerar capacidade",cWmsTpEn,{}}) //"Armaz�m [VAR01] - Busca de endere�o na estrutura [VAR02] - [VAR03]"
				EndIf
				lRet := WmsEndEstr(cProduto,cLocDest,cEstDest,@nQuant,cWmsTpEn,lOnlyPkg,lPriorSA,lZonaPrd,cZonaPrd,cCodNorma,lRadioF,cStatRF,aNivEndOri,nQtdMinEnd,.F.)
				nSeqAbast++
				//Se prioriza a sequencia de abastecimento e chegou no fim, volta para pesquisar as alternativas
				If lPriorSA .And. nSeqAbast > Len(aSeqAbPkg) .And. !lZonaAlt
					nSeqAbast := 1
					lZonaPrd  := .F.
					lZonaAlt  := .T.
				EndIf
			EndDo
		Else
			If lLogEnd
				AAdd(aLogEnd[Len(aLogEnd),RELDETEST],{WmsFmtMsg(STR0031,{{"[VAR01]",cLocDest}}),"",{}}) // Armaz�m [VAR01] - Busca de endere�o sem considerar capacidade
			EndIf
			If QtdComp(nQtdAgrup) > 0
				AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0032) // Restante superior a 2aUM do produto.
			Else
				AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0033) // Produto n�o possui 2aUM agrupadora.
			EndIf
		EndIf
	EndIf
	// Se sobrou saldo a endere�ar
	If lRet .And. QtdComp(nQuant) > 0
		cMensagem := __cMsgOsPr
		cMensagem += WmsFmtMsg(STR0012,{{"[VAR01]",Str(nQuant)}}) //"N�o foi poss�vel endere�ar toda a quantidade. Saldo restante ([VAR02])."
		WmsMessage(cMensagem,"WmsEndereca",1)
		__lSwLogEnd := .T.
		lRet := .F.
	EndIf

RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} WmsEndEstr
Efetua a pesquisa dos endere�os livres por estrutura e calcula a quantidade
que pode ser endere�ada em cada endere�o gerando as movimenta��es de estoque.
@author Jackson Patrick Werka
@since 10/09/2014

@param cProduto, Caracter, C�digo do produto
@param cLocDest, Caracter, Local destino para busca de endere�os
@param cEstDest, Caracter, Estrutura destino para busca de endere�os
@param nQuant, Num�rico, Quantidade total a ser endere�ada. Passar por referencia @nQuant
@param cWmsTpEn, Caracter, Tipo de endere�amento, conforme par�metro MV_WMSTPEN
@param lOnlyPkg, L�gico, Indica se o produto n�o endere�a em estrutura pulm�o
@param lPriorSA, L�gico, Indica se o produto prioriza endere�amento na zona de armazenagem do produto
@param lZonaPrd, L�gico, Indica que deve fazer a busca apenas pela zona do produto
@param cZonaPrd, Caracter, Zona de armazenagem padr�o do produto.
@param cCodNorma, Caracter, C�dido da norma do produto para a estrutura fisica
@param lRadioF, L�gico, Indicador se utiliza radio frequ�ncia
@param cStatRF, Caracter, Status do RF, onde: 1 - Gera��o, 2 - Execu��o
@param aNivEndOri, Array, Array que ir� conter os n�veis do primeiro endere�o encontrado
@param nQtdMinEnd, Num�rico, Quantidade m�nima para endere�amento na estrutura
@param lCapEstru, L�gico, Indica se a capacidade da estrutura dever� ser considerada

@return L�gico Processou busca de endere�os com sucesso
/*/
Static Function WmsEndEstr(cProduto,cLocDest,cEstDest,nQuant,cWmsTpEn,lOnlyPkg,lPriorSA,lZonaPrd,cZonaPrd,cCodNorma,lRadioF,cStatRF,aNivEndOri,nQtdMinEnd,lCapEstru)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cWmsMulP   := SuperGetMV("MV_WMSMULP", .F., "N")
Local nLimSBE    := SuperGetMV("MV_WMSNRPO", .F.,  10) //-- Limite de enderecos picking ocupados
Local nLimPKG    := 0
Local lFoundPkg  := .F.
Local cQuery     := ""
Local cAliasSBE  := ""
Local cAliasSBF  := ""
Local nTipoPerc  := 0
Local nCapEstru  := 0
Local nNormaEst  := 0
Local nCapEnder  := 0
Local nQtdNorma  := 0
Local nSaldoLot  := 0
Local nSaldoSBF  := 0
Local nSaldoRF   := 0
Local nSaldoEnd  := 0
Local cEndDest   := ""
Local cOrdSeq    := "00"
Local cOrdPrd    := "00"
Local cOrdSld    := "00"
Local cOrdMov    := "00"
Local nQtdEnd    := 0
Local nQtdMov    := 0
Local nTipoEst   := DLTipoEnd(cEstDest)
Local cTipoServ  := WmsTipServ(aParam150[09])  //-- Servico
Local cTarefa    := aParam150[10]  //-- Tarefa
Local cEndOrig   := aParam150[20]
Local cEstOrig   := aParam150[21]
Local aExcecoesO := {}  // Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {}  // Excecoes referentes ao Endereco DESTINO
Local nSldEndPrd := 0
Local nSldEndOut := 0
Local nSldRFPrd  := 0
Local nSldRFOut  := 0
Local lQrySldEnd := .T.
Local cUltEndPer := ""

	//-- Carregas as exce��es das atividades, somente da origem
	DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,aExcecoesO,Nil)

	If lWMSMULP .And. nTipoEst == 2
		cWmsMulP := Iif(ExecBlock("WMSMULP", .F., .F., {cProduto}), "S", "N")
	EndIf
	// Verifica se existem endere�os de picking ocupados para o produto
	If nTipoEst == 2 .And. !lOnlyPkg
		cQuery := "SELECT MIN(BE_LOCALIZ) BE_LOCALIZ, COUNT(*) BE_COUNT"
		cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
		cQuery += " WHERE BE_FILIAL = '"+xFilial('SBE')+"'"
		cQuery +=   " AND BE_LOCAL    = '"+cLocDest+"'"
		cQuery +=   " AND BE_ESTFIS   = '"+cEstDest+"' "
		cQuery +=   " AND SBE.D_E_L_E_T_  = ' '"
		If lRadioF
			cQuery += "AND ( "
		Else
			cQuery += "AND "
		EndIf
		cQuery += "EXISTS (SELECT 1 FROM "+RetSqlName('SBF')+" SBF"
		cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial('SBF')+"'"
		cQuery +=   " AND SBF.BF_LOCAL   = BE_LOCAL"
		cQuery +=   " AND SBF.BF_LOCALIZ = BE_LOCALIZ"
		cQuery +=   " AND SBF.BF_ESTFIS  = BE_ESTFIS"
		cQuery +=   " AND SBF.BF_PRODUTO = '"+cProduto+"'"
		cQuery +=   " AND SBF.BF_QUANT > 0"
		cQuery +=   " AND SBF.D_E_L_E_T_  = ' ')"
		If lRadioF
			cQuery += "OR EXISTS (SELECT 2 FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
			cQuery +=   " AND SDB.DB_ESTORNO = ' '"
			cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
			cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
			cQuery +=   " AND SDB.DB_LOCAL   = BE_LOCAL"
			cQuery +=   " AND SDB.DB_ENDDES  = BE_LOCALIZ"
			cQuery +=   " AND SDB.DB_ESTDES  = BE_ESTFIS"
			cQuery +=   " AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery +=   " AND SDB.D_E_L_E_T_ = ' '))"
		EndIf
		cQuery := ChangeQuery(cQuery)
		cAliasSBE := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
		If (cAliasSBE)->(!Eof())
			lFoundPkg := ((cAliasSBE)->BE_COUNT > 0)
			nLimPKG   := (cAliasSBE)->BE_COUNT
			cEndDest  := (cAliasSBE)->BE_LOCALIZ
		Else
			lFoundPkg := .F.
		EndIf
		(cAliasSBE)->(DbCloseArea())

		cAliasSBE := "" // Deve limpar por causa da valida��o do PE WMSQYEND

	EndIf

	// Deve buscar um endere�o com saldo do produto para ser utilizado como alvo 
	// no processo de endere�amento. Esta busca deve ser realizada somente uma vez,
	// para que os demais movimentos sejam gerados com base nesse mesmo endere�o.
	// Desta forma, todo o saldo do produto ser� armazenado em endere�os pr�ximos.
	If Len(aNivEndOri) <= 0
		FindEndSld(cProduto,cLocDest,cEstDest,cZonaPrd,lPriorSA,lZonaPrd,aNivEndOri,lRadioF)
	EndIf

	//Calcula a norma somente uma vez para a estrutura fisica, pois todos os endere�os
	//devem posuir a mesma norma, exceto quando possui percentual de ocupa��o
	nCapEstru := DLQtdNorma(cProduto, cLocDest, cEstDest)
	nNormaEst := DLQtdNorma(cProduto, cLocDest, cEstDest, /*cDesUni*/, .F.) //Considerar somente a norma

	If QtdComp(nCapEstru) <= 0
		AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0024) //"Estrutura com capacidade zerada."
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	If lWMSQYEND
		cAliasSBE := ExecBlock("WMSQYEND",.F.,.F.,{cProduto,cLocDest,cEstDest,SDA->DA_LOTECTL,SDA->DA_NUMLOTE})
		cAliasSBE := Iif(ValType(cAliasSBE)=="C",cAliasSBE,"")
	EndIf

	If Empty(cAliasSBE)
		cAliasSBE := QryEndEst(cProduto,cLocDest,cEstDest,SDA->DA_LOTECTL,SDA->DA_NUMLOTE,cWmsTpEn,lPriorSA,lZonaPrd,cZonaPrd,lRadioF,aNivEndOri,Iif(lCapEstru,nCapEstru,999999999),cCodNorma)
	EndIf

	If (cAliasSBE)->(Eof())
		AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0023) //"N�o encontrou nenhum endere�o dispon�vel."
		(cAliasSBE)->(DbCloseArea())
		RestArea(aAreaAnt)
		Return .T.
	EndIf

	// Tratar� o caso do ponto de entrada n�o retornar estes campos do SELECT
	lQrySldEnd := (cAliasSBE)->(FieldPos("SLD_OUTROS")) > 0
	//Aqui deve processar os endere�os encontrados
	Do While lRet .And. (cAliasSBE)->(!Eof()) .And. nQuant > 0
		// Se encontrou um endere�o e n�o utiliza m�ltiplos pickings, nem usa somente picking, 
		// sai do la�o e vai para pr�xima estrutura. A �nica exce��o ser� quando o endere�o
		// encontrado for aquele que j� possui saldo do produto.
		If !lOnlyPkg .And. nTipoEst == 2 .And. QtdComp((cAliasSBE)->SLD_PRODUT) <= 0 .And.;
		Iif(lQrySldEnd,QtdComp((cAliasSBE)->MOV_PRODUT) <= 0,.T.)
			If cWmsMulP == "N" .And. lFoundPkg
				AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,STR0015) //"Encontrou endere�o de picking. M�ltiplos = N�o"
				Exit
			EndIf
			//-- MV_WMSNRPO = Limite de enderecos picking ocupados
			If nLimSBE > 0 .And. nLimSBE <= nLimPKG
				AddMsgLog(cEstDest,"00","00","00","00",Space(TamSX3("BE_LOCALIZ")[1]),0,0,0,nQuant,0,WmsFmtMsg(STR0016,{{"[VAR01]",Str(nLimSBE)}})) //"Limite de endere�os picking ocupados ([VAR01])."
				Exit
			EndIf
		EndIf

		lFoundPkg  := .F.
		cOrdSeq    := PadR((cAliasSBE)->ZON_ORDEM,TamSX3("DCH_ORDEM")[1],'0') //Ordem Zona
		cOrdPrd    := StrZero((cAliasSBE)->PRD_ORDEM,2,0)     // Ordem Produto
		cOrdSld    := StrZero((cAliasSBE)->SLD_ORDEM,2,0)     // Ordem Saldo -- Endere�o Ocupado
		cOrdMov    := StrZero((cAliasSBE)->MOV_ORDEM,2,0)     // Ordem Movimenta��o -- Endere�o Ocupado
		cEndDest   := (cAliasSBE)->BE_LOCALIZ                 // C�digo do Endere�o
		nTipoPerc  := (cAliasSBE)->DCP_PEROCP                 // Indicador de percentual de ocupa��o -> 0-N�o compartilha;1-Produto;2-Geral;3-Outros Produtos/Normas;

		// Descarta se o endere�o possui um percentual de ocupa��o para outros produtos ou normas
		If nTipoPerc >= 3
			// S� loga uma vez, pois podem ter v�rios registros
			If !(cUltEndPer == cEndDest)
				AddMsgLog(cEstDest,"00","00","00","00",cEndDest,0,0,0,nQuant,0,STR0035) //"Percentual de ocupa��o para outro Produto/Norma."
				cUltEndPer := cEndDest
			EndIf
			(cAliasSBE)->(DbSkip())
			Loop
		EndIf

		// Descarta se o endere�o possui um percentual de ocupa��o somente para a norma,
		// caso j� tenha utilizado este endere�o com o cadastro por norma+produto - ordena��o
		If nTipoPerc == 2 .And. cUltEndPer == cEndDest
			(cAliasSBE)->(DbSkip()) // N�o loga neste caso
			Loop
		EndIf

		If nTipoPerc != 0
			cUltEndPer := cEndDest
		EndIf
		// lock do endere�o
		SBE->(dbGoTo((cAliasSBE)->RECNOSBE))
		SBE->(SoftLock("SBE"))
		// Busca saldos do endere�o
		nSldEndPrd := (cAliasSBE)->SLD_PRODUT  // Saldo no Endere�o para o Produto
		nSldEndOut := 0
		nSldRFPrd  := 0
		nSldRFOut  := 0
		If lQrySldEnd
			cAliasSBF = QryEndSel(cProduto,cLocDest,cEndDest,lRadioF)
			If (cAliasSBF)->(!Eof())
				nSldEndOut := (cAliasSBF)->SLD_OUTROS  // Saldo no Endere�o para outros Produtos
				nSldRFPrd  := (cAliasSBF)->MOV_PRODUT  // Saldo RF do Endere�o para o Produto
				nSldRFOut  := (cAliasSBF)->MOV_OUTROS  // Saldo RF do Endere�o para outros Produtos
			EndIf
			(cAliasSBF)->(dbCloseArea())
		Else
			// Saldo no Endere�o para outros Produtos
			nSldEndOut := WmsSaldoSBF(cLocDest,cEndDest,/*cProduto*/,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.F.,.F.,.F.,.F.,'2',.F./*lConSldRF*/)
			nSldEndOut -= nSldEndPrd
			// Saldo RF do Endere�o para o Produto
			nSldRFPrd := WmsSaldoSBF(cLocDest,cEndDest,cProduto,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.T.,.T.,.T.,.F.,'3',.T./*lConSldRF*/)
			// Saldo RF do Endere�o para outros Produtos
			nSldRFOut := WmsSaldoSBF(cLocDest,cEndDest,/*cProduto*/,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.T.,.T.,.T.,.F.,'3',.T./*lConSldRF*/)
			nSldRFOut -= nSldRFPrd
		EndIf
		// Se possui percentual de ocupa��o deve consultar o saldo somente do produto
		// Caso contr�rio deve consultar o saldo do endere�o por completo
		nSaldoSBF  := Iif(nTipoPerc==1,nSldEndPrd,(nSldEndPrd + nSldEndOut))
		nSaldoRF   := Iif(nTipoPerc==1,nSldRFPrd ,(nSldRFPrd  + nSldRFOut ))
		nSaldoEnd  := nSaldoSBF + nSaldoRF

		//Se n�o utiliza percentual de ocupa��o utiliza a capacidade da estrutura, sen�o calcula a do endere�o
		nCapEnder  := Iif(nTipoPerc==0,nCapEstru,DLQtdNorma(cProduto, cLocDest, cEstDest, /*cDesUni*/, .T., cEndDest)) //Considerar a qtd pelo nr de unitizadores

		If QtdComp(nCapEnder) <= 0
			AddMsgLog(cEstDest,"00","00","00","00",cEndDest,0,0,0,nQuant,0,STR0025) //"Endere�o com capacidade zerada."
			(cAliasSBE)->(DbSkip())
			Loop
		EndIf

		//Se procura s� endere�os vazios, n�o precisa consultar o saldo, pois j� foi descartado no SELECT
		If cWmsTpEn != "1"
			//Somente considera endere�o ocupado se o picking possui saldo, para picking sempre consulta o saldo completo
			If nTipoEst == 2 .And. QtdComp(nSaldoEnd) > QtdComp(0)
				lFoundPkg := .T.
			EndIf
			//Verifica se o endere�o possui capacidade, para comportar o produto
			If lCapEstru .And. QtdComp(nSaldoEnd) >= QtdComp(nCapEnder)
				AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,0,STR0017) //"Saldo do endere�o utiliza toda capacidade."
				(cAliasSBE)->(DbSkip())
				Loop
			EndIf
			//Deve consultar o saldo por lote neste momento, pois a consulta principal n�o filtra por lote
			If cWmsTpEn == "3" .And. QtdComp(nSaldoEnd) > 0
				nSaldoLot := WmsSaldoSBF(cLocDest,cEndDest,cProduto,/*cNumSerie*/,SDA->DA_LOTECTL,SDA->DA_NUMLOTE,.T.,.T.,.T.,.F.,'2',.T./*lConSldRF*/)
			Else
				//N�o precisa validar se endere�a sem misturar lotes, pois na consulta j� considerou o lote
				nSaldoLot := nSldEndPrd + nSldRFPrd
			EndIf
			//Se a quantidade de saldo do endere�o, for diferente da quantidade retornada
			//da query indica que o endere�o possui saldo relativo a algum outro produto ou lote
			If (QtdComp(nSaldoLot) != QtdComp(nSaldoEnd))
				//Produto n�o compartilha endere�o
				If cWmsTpEn != "4"
					AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,0,STR0018) //"Possui saldo de outros produtos/lotes."
					(cAliasSBE)->(DbSkip())
					Loop
				Else
					If !EndUsaComp(cProduto,cLocDest,cEstDest,cEndDest,cCodNorma,lRadioF)
						AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,0,STR0019) //"Possui produto que n�o compartilha endere�o."
						(cAliasSBE)->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
		EndIf
		//Ponto de entrada para verificar se o endere�o pode ser utilizado
		If lDLENDEOK
			xRetPE := ExecBlock("DLENDEOK", .F., .F., {cProduto, nQuant, (cAliasSBE)->RECNOSBE})
			If (ValType(xRetPE) == 'N' .And. xRetPE <= 0) .Or.;
				(ValType(xRetPE) == 'L' .And. !xRetPE)
				AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,0,STR0020) //"Endere�o descartado pelo PE DLENDEOK"
				(cAliasSBE)->(DbSkip())
				Loop
			EndIf
		EndIf

		If lCapEstru
			nQtdEnd := Min(nQuant,(nCapEnder-nSaldoEnd))
		Else
			nQtdEnd := nQuant
		EndIf

		// Ajusta a quantidade, pois deve ser m�ltipla do endere�amento m�nimo
		nQtdEnd := NoRound(nQtdEnd/nQtdMinEnd,0) * nQtdMinEnd
		If QtdComp(nQtdEnd) <= 0
			AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,0,WmsFmtMsg(STR0034,{{"[VAR01]",Str(nQtdMinEnd)}})) //"M�ltiplo menor que endere�amento m�nimo ([VAR01])."
			Exit
		EndIf

		//Se n�o utiliza percentual de ocupa��o utiliza a norma da estrutura, sen�o calcula a do endere�o
		nQtdNorma := Iif(nTipoPerc==0,nNormaEst,DLQtdNorma(cProduto, cLocDest, cEstDest, /*cDesUni*/, .F., cEndDest)) //Considerar somente a norma
		AddMsgLog(cEstDest,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndDest,nCapEnder,nSaldoSBF,nSaldoRF,nQuant,nQtdEnd,STR0022) //"Endere�o utilizado."

		//-- Verifica se a Atividade utiliza Radio Frequencia
		//-- Carregas as exce��es das atividades no destino
		DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,Nil,aExcecoesD)
		//-- Verifica se a tarefa utiliza RF
		lRadioF := DLTarUsaRF(cTipoServ,cTarefa,aExcecoesO,aExcecoesD)
		//Equanto for maior que uma norma, vai endere�ando a quantidade de uma norma
		While lRet .And. QtdComp(nQtdEnd) > 0
			nQtdMov := Min(nQtdEnd,nQtdNorma)
			lRet := WmsGrvEnd(cProduto,cLocDest,cEstDest,cEndDest,nQtdMov,lRadioF)
			If lRet
				nQtdEnd -= nQtdMov
				nQuant  -= nQtdMov
			EndIf
		EndDo
		// Libera endere�o
		SBE->(MsUnLock())
		If lRet
			//Indicando que encontrou um endere�o de picking
			lFoundPkg := (nTipoEst == 2)
			//Deve verificar se o n�mero de pickings ocupados n�o ultrapasou
			//S� deve considerar o que n�o tinha saldo, pois os que continham saldo j� foram considerados
			If nTipoEst == 2 .And. QtdComp(nSldEndPrd + nSldRFPrd) == QtdComp(0)
				nLimPKG++
			EndIf
		EndIf
		(cAliasSBE)->(DbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} QryEndEst
Monta a query respons�vel por buscar os endere�os poss�veis a serem utilizados
@author Jackson Patrick Werka
@since 10/09/2014

@param cProduto, Caracter, C�digo do produto
@param cLocDest, Caracter, Local destino para busca de endere�os
@param cEstDest, Caracter, Estrutura destino para busca de endere�os
@param cLoteCtl, Caracter, N�mero do lote. Utilizado quando n�o mistura lotes
@param cNumLote, Caracter, N�mero do sub-lote. Utilizado quando n�o mistura lotes
@param cWmsTpEn, Caracter, Tipo de endere�amento, conforme par�metro MV_WMSTPEN
@param lPriorSA, L�gico, Indica se o produto prioriza endere�amento na zona de armazenagem do produto
@param lZonaPrd, L�gico, Indica que deve fazer a busca apenas pela zona do produto
@param cZonaPrd, Caracter, Zona de armazenagem padr�o do produto.
@param lRadioF, L�gico, Indicador se utiliza radio frequ�ncia

@return Caracter Alias para a consulta j� aberta
/*/
Static Function QryEndEst(cProduto,cLocDest,cEstDest,cLoteCtl,cNumLote,cWmsTpEn,lPriorSA,lZonaPrd,cZonaPrd,lRadioF,aNivEndOri,nCapEstru,cCodNorma)
Local cQuery    := ""
Local cAliasSBE := ""
Local aTamSX3   := {}
Local nTipoEst  := DLTipoEnd(cEstDest)
Local cDBMS     := Upper(TcGetDB())

	cZonaPrd := PadR(cZonaPrd,TamSX3("DCH_CODZON")[1])
	cQuery := "SELECT"
	// Se considera primeiro a zona de armazenagem do produto
	If lPriorSA
		If lZonaPrd
			cQuery += " '00' ZON_ORDEM,"
		Else
			cQuery += " ZON.ZON_ORDEM,"
		EndIf
	Else
		cQuery += " ZON.ZON_ORDEM,"
	EndIf
	// Se foi informado o produto no endere�o ele tem prioridade
	cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 2 ELSE 1 END PRD_ORDEM,"
	// Este campos s�o para compatibilidade com outros tipos de endere�amento
	If cWmsTpEn == "1"
		cQuery += " 99 SLD_ORDEM,"
		cQuery += " 99 MOV_ORDEM,"
		cQuery += " 0  SLD_PRODUT,"
		cQuery += " 0  MOV_PRODUT,"
		cQuery += " 0  SLD_OUTROS,"
		cQuery += " 0  MOV_OUTROS,"
	Else
		cQuery += " CASE WHEN SLD.SLD_ORDEM  IS NOT NULL THEN SLD.SLD_ORDEM  ELSE 99 END SLD_ORDEM,"
		cQuery += " CASE WHEN SLD.MOV_ORDEM  IS NOT NULL THEN SLD.MOV_ORDEM  ELSE 99 END MOV_ORDEM,"
		cQuery += " CASE WHEN SLD.SLD_PRODUT IS NOT NULL THEN SLD.SLD_PRODUT ELSE 0  END SLD_PRODUT,"
		cQuery += " CASE WHEN SLD.MOV_PRODUT IS NOT NULL THEN SLD.MOV_PRODUT ELSE 0  END MOV_PRODUT,"
		cQuery += " CASE WHEN SLD.SLD_OUTROS IS NOT NULL THEN SLD.SLD_OUTROS ELSE 0  END SLD_OUTROS,"
		cQuery += " CASE WHEN SLD.MOV_OUTROS IS NOT NULL THEN SLD.MOV_OUTROS ELSE 0  END MOV_OUTROS,"
	EndIf
	// Carregando as informa��es de endere�o compartilhado via percentual de ocupa��o
	cQuery += " CASE WHEN DCP.DCP_CODPRO IS NULL THEN 0"
	cQuery +=      " WHEN (DCP.DCP_NORMA = '"+cCodNorma+"' AND DCP.DCP_CODPRO = '"+cProduto+"') THEN 1"
	cQuery +=      " WHEN (DCP.DCP_NORMA = '"+cCodNorma+"' AND DCP.DCP_CODPRO = '"+Space(TamSx3("DCP_CODPRO")[1])+"') THEN 2"
	cQuery +=      " ELSE 3"
	cQuery += " END DCP_PEROCP,"
	// Pegando as informa��es do endere�o
	cQuery += " SBE.BE_LOCALIZ, SBE.BE_CODCFG, SBE.R_E_C_N_O_ RECNOSBE,"
	// Calcula um Endereco Alvo com base nos Pesos atribuidos aos Niveis
	cQuery += " ((ABS(SBE.BE_VALNV1-"+Str(Iif(Len(aNivEndOri)>0,aNivEndOri[1,1],0))+")*"+Str(Iif(Len(aNivEndOri)>0,aNivEndOri[1,2],0))+")+"
	cQuery +=  " (ABS(SBE.BE_VALNV2-"+Str(Iif(Len(aNivEndOri)>1,aNivEndOri[2,1],0))+")*"+Str(Iif(Len(aNivEndOri)>1,aNivEndOri[2,2],0))+")+"
	cQuery +=  " (ABS(SBE.BE_VALNV3-"+Str(Iif(Len(aNivEndOri)>2,aNivEndOri[3,1],0))+")*"+Str(Iif(Len(aNivEndOri)>2,aNivEndOri[3,2],0))+")+"
	cQuery +=  " (ABS(SBE.BE_VALNV4-"+Str(Iif(Len(aNivEndOri)>3,aNivEndOri[4,1],0))+")*"+Str(Iif(Len(aNivEndOri)>3,aNivEndOri[4,2],0))+")+"
	cQuery +=  " (ABS(SBE.BE_VALNV5-"+Str(Iif(Len(aNivEndOri)>4,aNivEndOri[5,1],0))+")*"+Str(Iif(Len(aNivEndOri)>4,aNivEndOri[5,2],0))+")+"
	cQuery +=  " (ABS(SBE.BE_VALNV6-"+Str(Iif(Len(aNivEndOri)>5,aNivEndOri[6,1],0))+")*"+Str(Iif(Len(aNivEndOri)>5,aNivEndOri[6,2],0))+")"
	// Inclui o Peso  "LADO"  para  Enderecos  localizados  no  Mesmo  Nivel
	// Primario e Secundario (Ex.:Na mesma Rua e mesmo Predio)
	If Len(aNivEndOri) > 1
		If "MSSQL" $ cDBMS .Or. "POSTGRES" $ cDBMS
			cQuery += "+(CASE WHEN (ABS(SBE.BE_VALNV1-"+Str(aNivEndOri[1,1])+") = 0 AND ( ( SBE.BE_VALNV1-(2*( CAST(SBE.BE_VALNV1/2 AS INTEGER))) ) != ( "+Str(aNivEndOri[2,1])+"-(2*( CAST("+Str(aNivEndOri[2,1])+"/2 AS INTEGER))) ) )) THEN (1*"+Str(aNivEndOri[1,3])+") ELSE 0 END)"
		Else
			cQuery += "+(CASE WHEN (ABS(SBE.BE_VALNV1-"+Str(aNivEndOri[1,1])+") = 0 AND (MOD(SBE.BE_VALNV1,2) != MOD("+Str(aNivEndOri[2,1])+",2))) THEN (1*"+Str(aNivEndOri[1,3])+") ELSE 0 END)"
		EndIf
	EndIf
	cQuery += ") BE_DISTANC"
	cQuery += " FROM "+RetSqlName("SBE")+" SBE"
	// Verifica se j� considera as zonas de armazenagem na query
	If !lPriorSA .Or. (lPriorSA .And. !lZonaPrd)
		cQuery += " INNER JOIN ("
		// Se prioriza a sequencia, vai filtar direto, sen�o junta na query
		If !lPriorSA
			// N�o utiliza do cadastro por que existe um PE que pode alterar, usa a vari�vel
			cQuery += "SELECT '00' ZON_ORDEM, '"+cZonaPrd+"' ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("SB5")
			cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "   AND B5_COD    = '"+cProduto+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery += " UNION ALL "
		EndIf
		cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
		cQuery += "  FROM "+RetSqlName("DCH")
		cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
		cQuery += "   AND DCH_CODPRO = '"+cProduto+"'"
		cQuery += "   AND DCH_CODZON <> '"+cZonaPrd+"'"
		cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
		cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
	EndIf
	// Carrega as informa��es se o endere�o possui percentual de ocupa��o
	cQuery += " LEFT JOIN "+RetSqlName("DCP")+" DCP"
	cQuery +=   " ON DCP.DCP_FILIAL = '"+xFilial("DCP")+"'"
	cQuery +=  " AND DCP.DCP_LOCAL  = SBE.BE_LOCAL"
	cQuery +=  " AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ"
	cQuery +=  " AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS"
	cQuery +=  " AND DCP.D_E_L_E_T_ = ' ' "
	// Carrega os saldos e movimenta��es pendentes para este produto para o endere�o
	If cWmsTpEn != "1"
		// Carregando saldo do endere�o para o produto e/ou lote e outros produtos
		cQuery += "  LEFT JOIN ("
		cQuery += "SELECT SLD_LOCAL, SLD_ENDERE,"
		cQuery +=       " CASE SUM(SLD_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 ELSE 3 END SLD_ORDEM,"
		cQuery +=       " CASE SUM(MOV_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 ELSE 3 END MOV_ORDEM,"
		cQuery +=       " SUM(SLD_PRODUT) SLD_PRODUT, SUM(SLD_OUTROS) SLD_OUTROS,"
		cQuery +=       " SUM(MOV_PRODUT) MOV_PRODUT, SUM(MOV_OUTROS) MOV_OUTROS"
		cQuery += " FROM ("
		// Consultando saldo do produto nos endere�os
		cQuery += "SELECT BF_LOCAL SLD_LOCAL, BF_LOCALIZ SLD_ENDERE,"
		cQuery +=       " 1 SLD_ORDEM,"
		cQuery +=       " 0 MOV_ORDEM,"
		cQuery +=       " SUM(BF_QUANT) SLD_PRODUT, 0 SLD_OUTROS,"
		cQuery +=       " 0 MOV_PRODUT, 0 MOV_OUTROS"
		cQuery += "  FROM "+RetSqlName("SBF")
		cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
		cQuery += "   AND BF_LOCAL   = '"+cLocDest+"'"
		cQuery += "   AND BF_PRODUTO = '"+cProduto+"'"
		cQuery += "   AND BF_ESTFIS  = '"+cEstDest+"'"
		cQuery += "   AND BF_QUANT > 0"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY BF_LOCAL, BF_LOCALIZ"
		// Consultando saldo pendente de entrada do produto para o endere�o
		If lRadioF
			cQuery += " UNION ALL "
			cQuery += "SELECT DB_LOCAL SLD_LOCAL, DB_ENDDES SLD_ENDERE,"
			cQuery +=       " 0 SLD_ORDEM,"
			cQuery +=       " 1 MOV_ORDEM,"
			cQuery +=       " 0 SLD_PRODUT, 0 SLD_OUTROS,"
			cQuery +=       " SUM(DB_QUANT) MOV_PRODUT, 0 MOV_OUTROS"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+cLocDest+"'"
			cQuery += "   AND SDB.DB_PRODUTO = '"+cProduto+"'"
			cQuery += "   AND SDB.DB_ESTDES  = '"+cEstDest+"'"
			cQuery += "   AND SDB.DB_TM     <= '500'"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
															" FROM "+RetSqlName("SDB")+" SDBM"+;
														  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
															 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
															 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
															 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
															 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
															 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
															 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
															 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
															 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
															 " AND SDBM.DB_ESTORNO = ' '"+;
															 " AND SDBM.DB_ATUEST  = 'N'"+;
															 " AND SDBM.DB_STATUS IN ('4','3','2','-')"+;
															 " AND SDBM.D_E_L_E_T_ = ' ' )"
			cQuery += " GROUP BY SDB.DB_LOCAL, SDB.DB_ENDDES"
		EndIf
		// Consultando saldo de outros produtos no endere�o
		cQuery += " UNION ALL "
		cQuery += "SELECT BF_LOCAL SLD_LOCAL, BF_LOCALIZ SLD_ENDERE,"
		cQuery +=       " 3 SLD_ORDEM,"
		cQuery +=       " 0 MOV_ORDEM,"
		cQuery +=       " 0 SLD_PRODUT, SUM(BF_QUANT) SLD_OUTROS,"
		cQuery +=       " 0 MOV_PRODUT, 0 MOV_OUTROS"
		cQuery += "  FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("SBE")+" SBE"
		cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
		cQuery +=   " AND BF_LOCAL   = '"+cLocDest+"'"
		cQuery +=   " AND BF_PRODUTO <> '"+cProduto+"'"
		cQuery +=   " AND BF_ESTFIS  = '"+cEstDest+"'"
		cQuery +=   " AND BF_QUANT > 0"
		cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
		cQuery +=   " AND BE_FILIAL  = '"+xFilial("SBF")+"'"
		cQuery +=   " AND BF_LOCAL   = '"+cLocDest+"'"
		cQuery +=   " AND BE_ESTFIS  = '"+cEstDest+"'"
		cQuery +=   " AND BE_LOCALIZ  = BF_LOCALIZ"
		// Deve filtar os outros produtos somente da mesma zona de armazenagem do produto atual
		If lPriorSA .And. lZonaPrd
			cQuery += " AND BE_CODZON = '"+cZonaPrd+"'"
		Else
			cQuery += " AND BE_CODZON IN ("
			// Se prioriza a sequencia, vai filtar direto, sen�o junta na query
			If !lPriorSA
				// N�o utiliza do cadastro por que existe um PE que pode alterar, usa a vari�vel
				cQuery += "SELECT '"+cZonaPrd+"' ZON_CODZON"
				cQuery += "  FROM "+RetSqlName("SB5")
				cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
				cQuery += "   AND B5_COD    = '"+cProduto+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				cQuery += " UNION ALL "
			EndIf
			cQuery += "SELECT DCH_CODZON ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("DCH")
			cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
			cQuery += "   AND DCH_CODPRO = '"+cProduto+"'"
			cQuery += "   AND DCH_CODZON <> '"+cZonaPrd+"'"
			cQuery += "   AND D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY BF_LOCAL, BF_LOCALIZ"
		// Consultando saldo pendente de entrada de outros produtos para o endere�o
		If lRadioF
			cQuery += " UNION ALL "
			cQuery += "SELECT DB_LOCAL SLD_LOCAL, DB_ENDDES SLD_ENDERE,"
			cQuery +=       " 0 SLD_ORDEM,"
			cQuery +=       " 3 MOV_ORDEM,"
			cQuery +=       " 0 SLD_PRODUT, 0 SLD_OUTROS,"
			cQuery +=       " 0 MOV_PRODUT, SUM(DB_QUANT) MOV_OUTROS"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+cLocDest+"'"
			cQuery += "   AND SDB.DB_PRODUTO <> '"+cProduto+"'"
			cQuery += "   AND SDB.DB_ESTDES  = '"+cEstDest+"'"
			cQuery += "   AND SDB.DB_TM     <= '500'"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
															" FROM "+RetSqlName("SDB")+" SDBM"+;
														  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
															 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
															 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
															 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
															 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
															 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
															 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
															 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
															 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
															 " AND SDBM.DB_ESTORNO = ' '"+;
															 " AND SDBM.DB_ATUEST  = 'N'"+;
															 " AND SDBM.DB_STATUS IN ('4','3','2','-')"+;
															 " AND SDBM.D_E_L_E_T_ = ' ' )"
			cQuery += " GROUP BY SDB.DB_LOCAL, SDB.DB_ENDDES"
		EndIf
		cQuery +=   ") COM "
		cQuery +=   " GROUP BY SLD_LOCAL, SLD_ENDERE"
		cQuery += ") SLD"
		cQuery +=  "  ON SLD.SLD_LOCAL  = SBE.BE_LOCAL"
		cQuery +=  " AND SLD.SLD_ENDERE = SBE.BE_LOCALIZ"
	EndIf
	// Filtros em cima da SBE - Endere�os
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL  = '"+cLocDest+"'"
	cQuery +=   " AND SBE.BE_ESTFIS = '"+cEstDest+"'"
	cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+cProduto+"')"
	cQuery +=   " AND SBE.BE_STATUS <> '3'"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	// Se prioriza a sequencia e est� usando a zona do produto, filtra direto
	If lPriorSA .And. lZonaPrd
		cQuery +=   " AND SBE.BE_CODZON = '"+cZonaPrd+"'"
	EndIf
	// Se somente endere�a em endere�os vazios, n�o considera endere�os saldo ou movimenta��o
	If cWmsTpEn == "1"
		// Desconsiderando endere�os que possuem saldo
		cQuery += " AND NOT EXISTS ("
		cQuery += " SELECT 1 FROM "+RetSqlName('SBF')+" SBF"
		cQuery +=  " WHERE BF_FILIAL  = '"+xFilial('SBF')+"'"
		cQuery +=    " AND BF_LOCAL   = BE_LOCAL"
		cQuery +=    " AND BF_LOCALIZ = BE_LOCALIZ"
		cQuery +=    " AND BF_ESTFIS  = BE_ESTFIS"
		cQuery +=    " AND BF_QUANT   > 0"
		cQuery +=    " AND SBF.D_E_L_E_T_  = ' ')"
		// Desconsiderando movimenta��o para o endere�o
		If lRadioF
			cQuery += " AND NOT EXISTS ("
			cQuery += " SELECT 2 FROM "+RetSqlName('SDB')+" SDB"
			cQuery +=  " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
			cQuery +=    " AND DB_LOCAL   = BE_LOCAL"
			cQuery +=    " AND DB_ENDDES  = BE_LOCALIZ"
			cQuery +=    " AND DB_ESTDES  = BE_ESTFIS"
			cQuery +=    " AND DB_ESTORNO = ' '"
			cQuery +=    " AND DB_ATUEST  = 'N'"
			cQuery +=    " AND DB_STATUS IN ('-','2','3','4')"
			cQuery +=    " AND DB_TM <= '500'"
			cQuery +=    " AND SDB.D_E_L_E_T_  = ' ')"
		EndIf
	EndIf
	// Se n�o � busca de endere�os vazios
	If cWmsTpEn != "1"
		// Se n�o possui percentual de ocupa��o, descarta neste momento os endere�os
		// que est�o com sua capacidade total utilizada
		cQuery += " AND (CASE WHEN DCP.DCP_CODPRO IS NULL THEN "+cValtoChar(nCapEstru)+" ELSE 999999999 END) > "
		cQuery +=    " ((CASE WHEN SLD_PRODUT IS NULL THEN 0 ELSE SLD_PRODUT END) + "
		cQuery +=    "  (CASE WHEN MOV_PRODUT IS NULL THEN 0 ELSE MOV_PRODUT END) + "
		cQuery +=    "  (CASE WHEN SLD_OUTROS IS NULL THEN 0 ELSE SLD_OUTROS END) + "
		cQuery +=    "  (CASE WHEN MOV_OUTROS IS NULL THEN 0 ELSE MOV_OUTROS END)) "
		// Se n�o compartilha endere�o, descarta endere�os com saldo de outros produtos
		If cWmsTpEn $ "2|3"
			cQuery += " AND ((CASE WHEN SLD_OUTROS IS NULL THEN 0 ELSE SLD_OUTROS END) + "
			cQuery +=      " (CASE WHEN MOV_OUTROS IS NULL THEN 0 ELSE MOV_OUTROS END)) <= 0"
		EndIf
	EndIf
	// Deve ordenar de forma diferente para o caso de n�o utilizar m�ltiplos pickings
	If cWmsTpEn != "1" .And. nTipoEst == 2
		// Ordena por - Endere�o Ocupado + Movimenta��o Prevista + Ordem Zona + Ordem Produto + Distancia Total + C�digo Endere�o + Percentual Ocupa��o
		cQuery += " ORDER BY SLD_ORDEM, MOV_ORDEM, ZON_ORDEM, PRD_ORDEM, BE_DISTANC, BE_LOCALIZ, DCP_PEROCP"
	Else
		// Ordena por - Ordem Zona + Ordem Produto + Endere�o Ocupado + Movimenta��o Prevista + Distancia Total + C�digo Endere�o + Percentual Ocupa��o
		cQuery += " ORDER BY ZON_ORDEM, PRD_ORDEM, SLD_ORDEM, MOV_ORDEM, BE_DISTANC, BE_LOCALIZ, DCP_PEROCP"
	EndIf

	cAliasSBE := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
	aTamSX3:=TamSx3('BF_QUANT');
	//-- Ajustando o tamanho dos campos da query
	TcSetField(cAliasSBE,'PRD_ORDEM' ,'N',5 ,0)
	TcSetField(cAliasSBE,'SLD_ORDEM' ,'N',5 ,0)
	TcSetField(cAliasSBE,'MOV_ORDEM' ,'N',5 ,0)
	TcSetField(cAliasSBE,'DCP_PEROCP','N',5 ,0)
	TcSetField(cAliasSBE,'BE_DISTANC','N',10,0)
	TcSetField(cAliasSBE,'SLD_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'MOV_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'SLD_OUTROS','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBE,'MOV_OUTROS','N',aTamSX3[1],aTamSX3[2])

Return cAliasSBE
/*/{Protheus.doc} QryEndSel
Monta a query respons�vel por buscar os saldos do endere�o selecionado
@author Squad WMS Protheus
@since 20/06/2018

@param cProduto, Caracter, C�digo do produto
@param cLocDest, Caracter, Local destino para busca de endere�os
@param cEndereco, Caracter, C�digo do endere�o
@param lRadioF, L�gico, Indicador se utiliza radio frequ�ncia

@return Caracter Alias para a consulta j� aberta
/*/
Static Function QryEndSel(cProduto,cLocDest,cEndereco,lRadioF)
Local cQuery    := ""
Local cAliasSBF := ""
Local aTamSX3   := {}

	cQuery := "SELECT SUM(SLD_PRODUT) SLD_PRODUT,"
	cQuery +=       " SUM(SLD_OUTROS) SLD_OUTROS,"
	cQuery +=       " SUM(MOV_PRODUT) MOV_PRODUT,"
	cQuery +=       " SUM(MOV_OUTROS) MOV_OUTROS"
	cQuery += " FROM ("
	// Consultando saldo do produto nos endere�os
	cQuery += "SELECT SUM(SBF.BF_QUANT) SLD_PRODUT,"
	cQuery +=       " 0 SLD_OUTROS,"
	cQuery +=       " 0 MOV_PRODUT,"
	cQuery +=       " 0 MOV_OUTROS"
	cQuery +=  " FROM "+RetSqlName("SBF")+" SBF"
	cQuery += " WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
	cQuery +=   " AND SBF.BF_LOCAL = '"+cLocDest+"'"
	cQuery +=   " AND SBF.BF_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND SBF.BF_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND SBF.BF_QUANT > 0"
	cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY SBF.BF_LOCAL,"
	cQuery +=          " SBF.BF_LOCALIZ"
	// Consultando saldo pendente de entrada do produto para o endere�o
	If lRadioF
		cQuery += " UNION ALL "
		cQuery += "SELECT 0 SLD_PRODUT,"
		cQuery +=       " 0 SLD_OUTROS,"
		cQuery +=       " SUM(DB_QUANT) MOV_PRODUT,"
		cQuery +=       " 0 MOV_OUTROS"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_LOCAL = '"+cLocDest+"'"
		cQuery +=   " AND SDB.DB_ENDDES = '"+cEndereco+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
		cQuery +=   " AND SDB.DB_TM <= '500'"
		cQuery +=   " AND SDB.DB_STATUS IN ('-','2','3','4')"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST = 'N'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(SDBM.DB_ORDATIV)"
		cQuery +=                           " FROM "+RetSqlName("SDB")+" SDBM"
		cQuery +=                          " WHERE SDBM.DB_FILIAL = SDB.DB_FILIAL"
		cQuery +=                            " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"
		cQuery +=                            " AND SDBM.DB_DOC = SDB.DB_DOC"
		cQuery +=                            " AND SDBM.DB_SERIE = SDB.DB_SERIE"
		cQuery +=                            " AND SDBM.DB_CLIFOR = SDB.DB_CLIFOR
		cQuery +=                            " AND SDBM.DB_LOJA = SDB.DB_LOJA"
		cQuery +=                            " AND SDBM.DB_SERVIC = SDB.DB_SERVIC"
		cQuery +=                            " AND SDBM.DB_TAREFA = SDB.DB_TAREFA"
		cQuery +=                            " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"
		cQuery +=                            " AND SDBM.DB_ESTORNO = ' '"
		cQuery +=                            " AND SDBM.DB_ATUEST = 'N'"
		cQuery +=                            " AND SDBM.DB_STATUS IN ('4','3','2','-')"
		cQuery +=                            " AND SDBM.D_E_L_E_T_ = ' ' )"
		cQuery += " GROUP BY SDB.DB_LOCAL, SDB.DB_ENDDES"
	EndIf
	// Consultando saldo de outros produtos no endere�o
	cQuery += " UNION ALL "
	cQuery += "SELECT 0 SLD_PRODUT,"
	cQuery +=       " SUM(SBF.BF_QUANT) SLD_OUTROS,"
	cQuery +=       " 0 MOV_PRODUT,"
	cQuery +=       " 0 MOV_OUTROS"
	cQuery += "  FROM "+RetSqlName("SBF")+" SBF"
	cQuery += " WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
	cQuery +=   " AND SBF.BF_LOCAL = '"+cLocDest+"'"
	cQuery +=   " AND SBF.BF_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND SBF.BF_PRODUTO <> '"+cProduto+"'"
	cQuery +=   " AND SBF.BF_QUANT > 0"
	cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	// Consultando saldo pendente de entrada de outros produtos para o endere�o
	If lRadioF
		cQuery += " UNION ALL "
		cQuery += "SELECT 0 SLD_PRODUT,"
		cQuery +=       " 0 SLD_OUTROS,"
		cQuery +=       " 0 MOV_PRODUT,"
		cQuery +=       " SUM(SDB.DB_QUANT) MOV_OUTROS"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_LOCAL = '"+cLocDest+"'"
		cQuery +=   " AND SDB.DB_ENDDES = '"+cEndereco+"'"
		cQuery +=   " AND SDB.DB_PRODUTO <> '"+cProduto+"'"
		cQuery +=   " AND SDB.DB_TM <= '500'"
		cQuery +=   " AND SDB.DB_STATUS IN ('-','2','3','4')"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST = 'N'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(SDBM.DB_ORDATIV)"
		cQuery +=                           " FROM "+RetSqlName("SDB")+" SDBM"
		cQuery +=                          " WHERE SDBM.DB_FILIAL = SDB.DB_FILIAL"
		cQuery +=                            " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"
		cQuery +=                            " AND SDBM.DB_DOC = SDB.DB_DOC"
		cQuery +=                            " AND SDBM.DB_SERIE = SDB.DB_SERIE"
		cQuery +=                            " AND SDBM.DB_CLIFOR = SDB.DB_CLIFOR"
		cQuery +=                            " AND SDBM.DB_LOJA = SDB.DB_LOJA"
		cQuery +=                            " AND SDBM.DB_SERVIC = SDB.DB_SERVIC"
		cQuery +=                            " AND SDBM.DB_TAREFA = SDB.DB_TAREFA"
		cQuery +=                            " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"
		cQuery +=                            " AND SDBM.DB_ESTORNO = ' '"
		cQuery +=                            " AND SDBM.DB_ATUEST = 'N'"
		cQuery +=                            " AND SDBM.DB_STATUS IN ('4','3','2','-')"
		cQuery +=                            " AND SDBM.D_E_L_E_T_ = ' ' )"
	EndIf
	cQuery += ") SLD"

	cAliasSBF := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBF,.F.,.T.)
	aTamSX3:=TamSx3('BF_QUANT');
	//-- Ajustando o tamanho dos campos da query
	TcSetField(cAliasSBF,'SLD_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBF,'MOV_PRODUT','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBF,'SLD_OUTROS','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSBF,'MOV_OUTROS','N',aTamSX3[1],aTamSX3[2])

Return cAliasSBF

/*/{Protheus.doc} EndUsaComp
Verifica se o endere�o pode ser usado de forma compartilhada.
@author Jackson Patrick Werka
@since 10/09/2014

@param cProduto, Caracter, C�digo do produto
@param cLocDest, Caracter, Local do endere�o destino
@param cEstDest, Caracter, Estrutura do endere�o destino
@param cEndDest, Caracter, C�digo do endere�o destino
@param cCodNorma, Caracter, C�dido da norma do produto para a estrutura fisica
@param lRadioF, L�gico, Indicador se utiliza radio frequ�ncia

@return L�gico Endere�o pode ser usado de forma compartilhada
/*/
Static Function EndUsaComp(cProduto,cLocDest,cEstDest,cEndDest,cCodNorma,lRadioF)
Local aAreaAnt  := GetArea()
Local aAreaSB5  := SB5->(GetArea())
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lRet      := .T.

	//Carregando saldo do endere�o para outros produtos
	cQuery += "SELECT BF_PRODUTO ARM_PRODUTO"
	cQuery +=  " FROM "+RetSqlName("SBF")
	cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
	cQuery +=   " AND BF_LOCAL   = '"+cLocDest+"'"
	cQuery +=   " AND BF_ESTFIS  = '"+cEstDest+"'"
	cQuery +=   " AND BF_LOCALIZ = '"+cEndDest+"'"
	cQuery +=   " AND BF_PRODUTO <> '"+cProduto+"'" //Somente considera se for produto diferente
	cQuery +=   " AND BF_QUANT   > 0"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY BF_PRODUTO"
	//Carregando movimenta��o para o endere�o para outros produtos
	If lRadioF
		cQuery += " UNION "
		cQuery += "SELECT DB_PRODUTO ARM_PRODUTO"
		cQuery +=  " FROM "+RetSqlName("SDB")
		cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND DB_LOCAL   = '"+cLocDest+"'"
		cQuery +=   " AND DB_ESTDES  = '"+cEstDest+"'"
		cQuery +=   " AND DB_ENDDES  = '"+cEndDest+"'"
		cQuery +=   " AND DB_PRODUTO <> '"+cProduto+"'" //Somente considera se for produto diferente
		cQuery +=   " AND DB_TM     <= '500'"
		cQuery +=   " AND DB_STATUS IN ('-','2','3','4')"
		cQuery +=   " AND DB_ESTORNO = ' '"
		cQuery +=   " AND DB_ATUEST  = 'N'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY DB_PRODUTO"
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	//efetua a an�lise do produto que j� estiver armazenado no endere�o (2o passo abaixo).
	SB5->(DbSetOrder(1))
	//S� analisa o primeiro produto, pois se este permite, os demais foram analisados antes
	If (cAliasQry)->(!Eof())
		If SB5->(MsSeek(xFilial('SB5')+(cAliasQry)->ARM_PRODUTO))
				lRet := PrdCompEnd(cProduto,(cAliasQry)->ARM_PRODUTO,cLocDest,cEstDest,cCodNorma)
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaSB5)
RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} EndUsaComp
Verifica se os produtos s�o compat�veis para compartilhar endere�o.
@author Jackson Patrick Werka
@since 10/09/2014

@param cProdOrig, Caracter, C�digo do produto a ser endere�ado
@param cProdArmz, Caracter, C�digo do produto armazenado no endere�o
@param cLocDest, Caracter, Local do endere�o destino
@param cEstDest, Caracter, Estrutura do endere�o destino
@param cCodNorma, Caracter, C�dido da norma do produto para a estrutura fisica

@return L�gico Produtos podem utilizar endere�os de forma compartilhada
/*/
Static Function PrdCompEnd(cProdOrig,cProdArmz,cLocDest,cEstDest,cCodNorma)
Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local cTipoOrig  := ""
Local cGrupoOrig := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local lRet       := .T.
Local lRetPE     := .T.

	// PE para substituir a valida��o padr�o de cadastro dos
	// produtos no processo de compartilhamento de endere�os
	If lWMSCPEND
		lRetPE := ExecBlock("WMSCPEND",.F.,.F.,{cProdOrig,cProdArmz})
		lRet   := Iif(ValType(lRetPE)=='L',lRetPE,.T.)
	Else
		SB1->(DbSetOrder(1))
		If SB1->B1_COD != cProdOrig
			SB1->(MsSeek(xFilial('SB1')+cProdOrig, .F.))
		EndIf

		cTipoOrig  := SB1->B1_TIPO
		cGrupoOrig := SB1->B1_GRUPO
	
		If SB1->(MsSeek(xFilial('SB1')+cProdArmz, .F.))
			lRet := (cTipoOrig == SB1->B1_TIPO) .And. (cGrupoOrig == SB1->B1_GRUPO)
		EndIf
	EndIf

	If lRet
		//O produto a ser armazenado deve ter no cadastro de Sequ�ncias de Abastecimento(DC3),
		//para o mesmo tipo de estrutura(DC3_TPESTR) do endere�o candidato ao armazenamento,
		//pelo menos um registro com o mesmo c�digo de norma(DC3_CODNOR) que exista para o produto j� alocado
		//Esta estrutura tamb�m deve permitir armazenar de forma compartilhada.
		cQuery := "SELECT DC3_TIPEND"
		cQuery += " FROM "+RetSqlName('DC3')
		cQuery += " WHERE DC3_FILIAL = '"+xFilial('DC3')+"'"
		cQuery +=   " AND DC3_CODPRO = '"+cProdArmz+"'"
		cQuery +=   " AND DC3_LOCAL  = '"+cLocDest+"'"
		cQuery +=   " AND DC3_TPESTR = '"+cEstDest+"'"
		cQuery +=   " AND DC3_CODNOR = '"+cCodNorma+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			lRet := ((cAliasQry)->DC3_TIPEND == "4")
		Else
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} WmsGrvEnd
Gera a movimenta��o para o endere�o de destino considerando a norma.
Caso a tarefa n�o utilize RF j� � executada a movimenta��o do saldo.
@author Jackson Patrick Werka
@since 10/09/2014

@param cProduto, Caracter, C�digo do produto
@param cProdArmz, Caracter, C�digo do produto armazenado no endere�o
@param cLocDest, Caracter, Local do endere�o destino
@param cEstDest, Caracter, Estrutura do endere�o destino
@param cEndDest, Caracter, C�digo do endere�o destino
@param nQtdEnd, Num�rico, Quantidade a ser endere�ada no movimento
@param [lRadioF], L�gico, Indicador se a tarefa utiliza radio frequ�ncia

@return L�gico Gera��o da atividade executada com sucesso
/*/
Static Function WmsGrvEnd(cProduto,cLocDest,cEstDest,cEndDest,nQtdEnd,lRadioF)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cTarefa    := aParam150[10]  //-- Tarefa
Local aParam     := {}

Default lRadioF := (SuperGetMV("MV_RADIOF")=="S")

	//-- Monta o Array aParam para ser utilizado na Execucao das Atividades
	aParam     := aClone(aParam150)
	aParam[06] := nQtdEnd         //-- Quantidade Movimentada
	aParam[07] := dDataBase       //-- Data da Movimentacao
	aParam[08] := Time()          //-- Hora da Movimentacao
	aParam[18] := SDA->DA_LOTECTL //-- Lote
	aParam[19] := SDA->DA_NUMLOTE //-- Sub-Lote
	aParam[25] := cLocDest        //-- Armazem Destino
	aParam[26] := cEndDest        //-- Endereco Destino
	aParam[27] := cEstDest        //-- Estrutura Fisica Destino
	//-- Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
	DLXExecAti(cTarefa, aParam)
	If !lRadioF
		While Len(aParam150) < 34
			AAdd(aParam150,"")
		EndDo
		aParam150[34] := aParam[34]
		//Deve efetuar a movimenta��o de estoque
		lRet := WmsMovEnd(aParam)
	EndIf

RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} WmsMovEnd
Realiza a movimenta��o do saldo para o endere�o de destino.
@author Jackson Patrick Werka
@since 10/09/2014

@param aParam, Array, Parametros da movimenta��o. Vide aParam150

@return L�gico Movimenta��o executada com sucesso
/*/
Static Function WmsMovEnd(aParam)
Local aAreaAnt   := GetArea()
Local aAreaSDA   := SDA->(GetArea())
Local aAreaSDB   := SDB->(GetArea())
Local aAreaSB8   := SB8->(GetArea())
Local aAreaSB2   := SB2->(GetArea())
Local cProduto   := ""
Local cLocOrig   := ""
Local cEstOrig   := ""
Local cEndOrig   := ""
Local cDocto     := ""
Local cSerie     := ""
Local cCliFor    := ""
Local cLoja      := ""
Local cTipoNF    := ""
Local cTm        := '499'
Local cItem      := '01'
Local cOrigLan   := ""
Local cNumSerie  := ""
Local cNumSerPE  := ""
Local cServico   := ""
Local cTarefa    := ""
Local cAtividade := ""
Local cHoraIni   := ""
Local cCarga     := ""
Local cUnitiza   := ""
Local cOrdTar    := ""
Local cOrdAti    := ""
Local cRHumano   := ""
Local cRFisico   := ""
Local cCodNorma  := ""
Local lRet       := .T.
Local nQtdEnd    := 0
Local nQtdSDB    := 0
Local cAliasSDA  := ""
Local cQuery     := ""
Local cIdDCF     := ""
Local cIdMovto   := ""

	cProduto    := aParam[01]
	cLocOrig    := aParam[02]
	cDocto      := aParam[03]
	cSerie      := aParam[04]
	cNumSeq     := aParam[05]
	nQtdEnd     := aParam[06]
	cHoraIni    := aParam[08]
	cServico    := aParam[09]
	cTarefa     := aParam[10]
	cAtividade  := aParam[11]
	cCliFor     := aParam[12] //-- Cliente/Fornecedor
	cLoja       := aParam[13] //-- Loja
	cTipoNF     := aParam[14] //-- Tipo da Nota Fiscal
	cItem       := aParam[15] //-- Item da Nota Fiscal
	cTM         := aParam[16] //-- Tipo de Movimentacao
	cOrigLan    := aParam[17] //-- Origem do Lancamento
	cEndOrig    := aParam[20]
	cEstOrig    := aParam[21]
	cEndDest    := aParam[26]
	cEstDest    := aParam[27]
	cCarga      := aParam[23]
	cUnitiza    := aParam[24]
	cOrdTar     := aParam[28]
	cOrdAti     := aParam[29]
	cRHumano    := aParam[30]
	cRFisico    := aParam[31]
	cIdDCF      := aParam[32]
	cCodNorma   := aParam[33]
	cIdMovto    := aParam[34]
	__cMsgOsPr := "SIGAWMS - OS "+AllTrim(cDocto)+Iif(!Empty(cSerie),"/"+AllTrim(SubStr(cSerie,1,3)),"")+STR0013+AllTrim(cProduto)+CLRF
	//���������������������������������������������������������������������Ŀ
	//� Ponto de Entrada para Alteracao do Status a ser gravado no Endereco �
	//�����������������������������������������������������������������������
	If lDLGRVSTO
		ExecBlock('DLGRVSTO', .F., .F., {cOrigLan,cProduto,cLocOrig,cDocto,cSerie,cCliFor,cLoja,nQtdEnd,cEndDest})
	EndIf
	If lDLGNSERI
		cNumSerPE := ExecBlock('DLGNSERI',.F.,.F.,{cOrigLan,cProduto,cLocOrig,cDocto,cSerie,cCliFor,cLoja,nQtdEnd,cEndDest})
		cNumSerie := If(ValType(cNumSerPE)=='C',cNumSerPE,cNumSerie)
	EndIf
	//-- Busca os saldos a endere�ar com base na DCR do movimento
	SDA->(DbSetOrder(1)) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	cAliasSDA := GetNextAlias()
	cQuery := "SELECT SDA.R_E_C_N_O_ RECNOSDA, DCR.DCR_QUANT, DCR.DCR_IDDCF"
	cQuery +=  " FROM "+RetSqlName('SDA')+" SDA, "+RetSqlName('DCR')+" DCR"
	cQuery += " WHERE SDA.DA_FILIAL  = '"+xFilial('SDA')+"'"
	cQuery +=   " AND SDA.DA_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND SDA.DA_LOCAL   = '"+cLocOrig+"'"
	cQuery +=   " AND SDA.DA_SALDO   > 0"
	cQuery +=   " AND SDA.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery +=   " AND DCR.DCR_IDORI  = '"+cIdDCF+"'"
	cQuery +=   " AND DCR.DCR_IDMOV  = '"+cIdMovto+"'"
	cQuery +=   " AND DCR.DCR_IDOPER = '"+SDB->DB_IDOPERA+"'"
	cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SDA.DA_IDDCF  = DCR.DCR_IDDCF"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDA,.F.,.T.)
	While (cAliasSDA)->(!Eof())
		//-- Posiciona o SDA correto
		SDA->(DbGoTo((cAliasSDA)->RECNOSDA))
		nQtdSDB := Min(SDA->DA_SALDO,(cAliasSDA)->DCR_QUANT)
		//-- Cria o registro de movimenta��o de estoque
		CriaSDB(cProduto,cLocOrig,nQtdSDB,cEndDest,cNumSerie,SDA->DA_DOC,SDA->DA_SERIE,SDA->DA_CLIFOR,SDA->DA_LOJA,cTipoNF,cOrigLan,dDataBase,SDA->DA_LOTECTL,SDA->DA_NUMLOTE,SDA->DA_NUMSEQ,cTm,'E',cItem,.F.,Nil,Nil,Nil,cEstDest,cServico,cTarefa,'','',cEstOrig,cEndOrig,cHoraIni,'S','','',cOrdTar,'',cRHumano,cRFisico,/*cSeqCar*/,(cAliasSDA)->DCR_IDDCF,/*nRecnoSDB*/,cIdMovto)
		//-- Diminui do registro de saldo a endere�ar
		RecLock('SDA', .F.)
		SDA->DA_SALDO   -= SDB->DB_QUANT
		SDA->DA_QTSEGUM -= SDB->DB_QTSEGUM
		SDA->DA_EMPENHO -= SDB->DB_EMPENHO
		SDA->DA_EMP2    -= SDB->DB_EMP2
		SDA->(MsUnlock())
		//-- Se posuir Rastro() diminui do saldo por lote
		If Rastro(SDA->DA_PRODUTO)
			SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
			If SB8->(DbSeek(xFilial('SB8')+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_LOTECTL+(Iif(Rastro(SDA->DA_PRODUTO, 'S'),SDA->DA_NUMLOTE,"")), .F.))
				RecLock('SB8', .F.)
				SB8->B8_QACLASS -= SDB->DB_QUANT
				SB8->B8_QACLAS2 -= SDB->DB_QTSEGUM
				SB8->(MsUnlock())
			EndIf
		EndIf
		//-- Diminui do saldo por produto
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(xFilial('SB2')+SDA->DA_PRODUTO+SDA->DA_LOCAL, .F.))
			RecLock('SB2', .F.)
			SB2->B2_QACLASS -= SDB->DB_QUANT
			SB2->(MsUnlock())
		EndIf
		//-- Cria saldo no SBF baseado enderecamento do SDB
		GravaSBF('SDB')
		nQtdEnd -= nQtdSDB

		(cAliasSDA)->(DbSkip())
	EndDo
	(cAliasSDA)->(DbCloseArea())
	If QtdComp(nQtdEnd) > QtdComp(0)
		cMensagem := __cMsgOsPr
		cMensagem += WmsFmtMsg(STR0012,{{"[VAR01]",Str(nQtdEnd)}}) //"N�o foi poss�vel endere�ar toda a quantidade. Saldo restante ([VAR02])."
		WmsMessage(cMensagem,"WmsMovEnd",1)
		lRet := .F.
	EndIf

RestArea(aAreaSDA)
RestArea(aAreaSDB)
RestArea(aAreaSB8)
RestArea(aAreaSB2)
RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
// Gera as movimenta��es para endere�amento do tipo crossdocking
//-----------------------------------------------------------------------------
Static Function WmsEstCros(cProduto,cLocDest,nQuant,cZonaPrd,lRadioF,cStatRF)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cMensagem  := ""
Local cAliasSBE  := ""
Local nCapEnder  := 0
Local nQtdNorma  := 0
Local nQtdEnd    := 0
Local nQtdMov    := 0
Local cTipoServ  := WmsTipServ(aParam150[09])  //-- Servico
Local cTarefa    := aParam150[10]  //-- Tarefa
Local cEndOrig   := aParam150[20]
Local cEstOrig   := aParam150[21]
Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO
Local xRetPE     := Nil
Local lFoundSBE  := .F.
Local lLogEnd    := Type("aLogEnd") == "A"

	If lLogEnd
		AAdd(aLogEnd,{DCF->DCF_DOCTO,DCF->DCF_SERIE,cProduto,SB1->B1_DESC,SDA->DA_LOTECTL,nQuant,{}})
		AAdd(aLogEnd[Len(aLogEnd),RELDETEST],{WmsFmtMsg(STR0027,{{"[VAR01]",cLocDest}}),"4",{}}) // Armaz�m [VAR01] - Busca de endere�o em estruturas tipo cross-docking
	EndIf

	//-- Carregas as exce��es das atividades, somente da origem
	DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,Nil,Nil,aExcecoesO,Nil)
	//Deve validar o endere�o e gerar os processos de movimenta��o para o endere�amento
	cAliasSBE := QryEndCros(cProduto,cLocDest,cZonaPrd)
	While lRet .And. (cAliasSBE)->(!Eof()) .And. QtdComp(nQuant) > 0

		nCapEnder := DLQtdNorma(cProduto,cLocDest,(cAliasSBE)->BE_ESTFIS,/*cDesUni*/,.T.,(cAliasSBE)->BE_LOCALIZ) //Considerar a qtd pelo nr de unitizadores

		//Ponto de entrada para verificar se o endere�o pode ser utilizado
		If lDLENDEOK
			xRetPE := ExecBlock("DLENDEOK", .F., .F., {cProduto, nQuant, (cAliasSBE)->RECNOSBE})
			If (ValType(xRetPE) == 'N' .And. xRetPE <= 0) .Or.;
				(ValType(xRetPE) == 'L' .And. !xRetPE)
				AddMsgLog((cAliasSBE)->BE_ESTFIS,PadR((cAliasSBE)->ZON_ORDEM,TamSX3("DCH_ORDEM")[1],'0'),StrZero((cAliasSBE)->PRD_ORDEM,2,0),"02","99",(cAliasSBE)->BE_LOCALIZ,nCapEnder,0,0,nQuant,0,STR0020) // Endere�o descartado pelo PE DLENDEOK
				(cAliasSBE)->(DbSkip())
				Loop
			EndIf
		EndIf

		lFoundSBE := .T.
		nQtdNorma := DLQtdNorma(cProduto,cLocDest,(cAliasSBE)->BE_ESTFIS,/*cDesUni*/,.F.,(cAliasSBE)->BE_LOCALIZ) //Considerar somente a norma
		nQtdEnd   := Min(nQuant,nCapEnder)

		AddMsgLog((cAliasSBE)->BE_ESTFIS,;                                   // Estrutura Fisica
					PadR((cAliasSBE)->ZON_ORDEM,TamSX3("DCH_ORDEM")[1],'0'),;   // Ordem Zona Armazenagem
					StrZero((cAliasSBE)->PRD_ORDEM,2,0),;                       // Ordem Produto
					"02",;                                                      // Ordem Saldo
					"99",;                                                      // Ordem Movimento
					(cAliasSBE)->BE_LOCALIZ,;                                   // Endere�o
					nCapEnder,;                                                 // Capacidade
					0,;                                                         // Saldo Endere�o
					0,;                                                         // Saldo RF
					nQuant,;                                                    // Quantidade Total a Endere�ar
					nQtdEnd,;                                                   // Quantidade Endere�ada
					STR0022)                                                    // Endere�o utilizado.

		//-- Verifica se a Atividade utiliza Radio Frequencia
		//-- Carregas as exce��es das atividades no destino
		DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,(cAliasSBE)->BE_ESTFIS,(cAliasSBE)->BE_LOCALIZ,Nil,aExcecoesD)
		//-- Verifica se a tarefa utiliza RF
		lRadioF := DLTarUsaRF(cTipoServ,cTarefa,aExcecoesO,aExcecoesD)
		//Equanto for maior que uma norma, vai endere�ando a quantidade de uma norma
		While lRet .And. QtdComp(nQtdEnd) > 0
			nQtdMov := Min(nQtdEnd,nQtdNorma)
			lRet := WmsGrvEnd(cProduto,cLocDest,(cAliasSBE)->BE_ESTFIS,(cAliasSBE)->BE_LOCALIZ,nQtdMov,lRadioF)
			If lRet
				nQtdEnd -= nQtdMov
				nQuant  -= nQtdMov
			EndIf
		EndDo
		(cAliasSBE)->(DbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())

	If !lFoundSBE
		cMensagem := __cMsgOsPr
		cMensagem += WmsFmtMsg(STR0026,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest}}) //"Produto/Armaz�m [VAR01]/[VAR02] n�o possui estrutura f�sica do tipo cross-docking cadastrada na sequ�ncia de abastecimento cadastrada (DC3)."
		WmsMessage(cMensagem,"WmsEstCros",1)
		lRet := .F.
	Else
		If QtdComp(nQuant) > QtdComp(0)
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0012,{{"[VAR01]",Str(nQuant)}}) //"N�o foi poss�vel endere�ar toda a quantidade. Saldo restante ([VAR02])."
			WmsMessage(cMensagem,"WmsEstCros",1)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Consulta so endere�os do tipo crossdocking para efetuar o endere�amento
//-----------------------------------------------------------------------------
Static Function QryEndCros(cProduto,cLocDest,cZonaPrd)
Local cQuery    := ""
Local cAliasSBE := "SBE"

	cQuery := "SELECT ZON.ZON_ORDEM,"
	//Se foi informado o produto no endere�o ele tem prioridade
	cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 2 ELSE 1 END PRD_ORDEM,"
	cQuery += " SBE.BE_ESTFIS, SBE.BE_LOCALIZ, SBE.R_E_C_N_O_ RECNOSBE"
	cQuery += " FROM "+RetSqlName("SBE")+" SBE"
	//Somente considera as zonas de armazenagem na query
	cQuery += " INNER JOIN ("
	//N�o utiliza do cadastro por que existe um PE que pode alterar, usa a vari�vel
	cQuery += "SELECT '00' ZON_ORDEM, '"+cZonaPrd+"' ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("SB5")
	cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery += "   AND B5_COD    = '"+cProduto+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " UNION ALL "
	cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("DCH")
	cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
	cQuery += "   AND DCH_CODPRO = '"+cProduto+"'"
	cQuery += "   AND DCH_CODZON <> '"+cZonaPrd+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
	cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
	cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=   " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=  " AND DC3.DC3_LOCAL  = SBE.BE_LOCAL"
	cQuery +=  " AND DC3.DC3_TPESTR = SBE.BE_ESTFIS"
	cQuery +=  " AND DC3.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=   " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=  " AND DC8.DC8_CODEST = DC3.DC3_TPESTR"
	cQuery +=  " AND DC8.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL   = '"+cLocDest+"'"
	cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+cProduto+"')"
	cQuery +=   " AND SBE.BE_STATUS <> '3'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND DC8.DC8_TPESTR = '3'"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY ZON_ORDEM, PRD_ORDEM, BE_LOCALIZ"
	cQuery := ChangeQuery(cQuery)
	cAliasSBE := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
Return cAliasSBE

Static Function FindEndSld(cProduto,cLocDest,cEstDest,cZonaPrd,lPriorSA,lZonaPrd,aNivEndOri,lRadioF)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasSBE := GetNextAlias()
	aNivEndOri := {}
	// Se endere�a somente endere�os vazios, deve pesquisar se possui algum endere�o de picking
	// Pois mesmo endere�ando somente em endere�os vazios, deve respeitar os par�metros do picking
	cQuery := "SELECT MIN(BE_LOCALIZ) BE_LOCALIZ"
	cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
	If lPriorSA .And. lZonaPrd
		cQuery += " INNER JOIN "+RetSqlName("DCH")+" DCH"
		cQuery += " ON DCH_FILIAL = '"+xFilial("DCH")+"'"
		cQuery += " AND DCH_CODPRO = '"+cProduto+"'"
		cQuery += " AND DCH.DCH_CODZON = SBE.BE_CODZON"
		cQuery += " AND DCH_CODZON <> '"+cZonaPrd+"'"
		cQuery += " AND DCH.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " WHERE BE_FILIAL = '"+xFilial('SBE')+"'"
	cQuery +=   " AND BE_LOCAL    = '"+cLocDest+"'"
	cQuery +=   " AND BE_ESTFIS   = '"+cEstDest+"' "
	cQuery +=   " AND SBE.D_E_L_E_T_  = ' '"
	If !(lPriorSA .And. lZonaPrd)
		cQuery += " AND SBE.BE_CODZON = '"+cZonaPrd+"'"
	EndIf
	If lRadioF
		cQuery += "AND ( "
	Else
		cQuery += "AND "
	EndIf
	cQuery += "EXISTS (SELECT 1 FROM "+RetSqlName('SBF')+" SBF"
	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial('SBF')+"'"
	cQuery +=   " AND SBF.BF_LOCAL   = BE_LOCAL"
	cQuery +=   " AND SBF.BF_LOCALIZ = BE_LOCALIZ"
	cQuery +=   " AND SBF.BF_ESTFIS  = BE_ESTFIS"
	cQuery +=   " AND SBF.BF_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND SBF.BF_QUANT > 0"
	cQuery +=   " AND SBF.D_E_L_E_T_  = ' ')"
	If lRadioF
		cQuery += "OR EXISTS (SELECT 2 FROM "+RetSqlName('SDB')+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = BE_LOCAL"
		cQuery +=   " AND SDB.DB_ENDDES  = BE_LOCALIZ"
		cQuery +=   " AND SDB.DB_ESTDES  = BE_ESTFIS"
		cQuery +=   " AND SDB.DB_STATUS IN ('-','2','3','4')"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '))"
	EndIf
	cQuery += " ORDER BY BE_LOCALIZ"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
	If (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
		FindNivSBE(cLocDest,(cAliasSBE)->BE_LOCALIZ,aNivEndOri)
	EndIf
	(cAliasSBE)->(DbCloseArea())
RestArea(aAreaAnt)
Return .T.

Static Function FindNivSBE(cLocal,cLocaliz,aNivEndOri)
Local lRet      := .T.
Local cAliasSBE := GetNextAlias()
Local cQuery    := ""
Local nValNv    := 0
	aNivEndOri := {}
	cQuery := "SELECT DC7_SEQUEN, DC7_POSIC, DC7_PESO1, DC7_PESO2, BE_LOCALIZ, BE_LOCALIZ, BE_VALNV1, BE_VALNV2, BE_VALNV3, BE_VALNV4, BE_VALNV5, BE_VALNV6"
	cQuery += "  FROM "+RetSqlName('DC7')+" DC7"
	cQuery += " INNER JOIN "+RetSqlName('SBE')+" SBE"
	cQuery +=    " ON SBE.BE_FILIAL = '"+xFilial('SBE')+"'"
	cQuery +=   " AND SBE.BE_LOCAL = '"+cLocal+"'"
	cQuery +=   " AND SBE.BE_LOCALIZ = '"+cLocaliz+"' "
	cQuery +=   " AND SBE.D_E_L_E_T_  = ' '"
	cQuery += " WHERE DC7.DC7_FILIAL = '"+xFilial('DC7')+"'"
	cQuery += "   AND DC7.DC7_CODCFG = SBE.BE_CODCFG"
	cQuery += "   AND DC7.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DC7_SEQUEN, DC7_POSIC, DC7_PESO1, DC7_PESO2"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
	TcSetField(cAliasSBE,'DC7_PESO1','N',15,0)
	TcSetField(cAliasSBE,'DC7_PESO2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV1','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV3','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV4','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV5','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV6','N',15,0)
	Do While (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
		// Niveis
		nValNv := 0
		If (cAliasSBE)->DC7_SEQUEN == "01"
			nValNv := (cAliasSBE)->BE_VALNV1
		ElseIf (cAliasSBE)->DC7_SEQUEN == "02"
			nValNv := (cAliasSBE)->BE_VALNV2
		ElseIf (cAliasSBE)->DC7_SEQUEN == "03"
			nValNv := (cAliasSBE)->BE_VALNV3
		ElseIf (cAliasSBE)->DC7_SEQUEN == "04"
			nValNv := (cAliasSBE)->BE_VALNV4
		ElseIf (cAliasSBE)->DC7_SEQUEN == "05"
			nValNv := (cAliasSBE)->BE_VALNV5
		ElseIf (cAliasSBE)->DC7_SEQUEN == "06"
			nValNv := (cAliasSBE)->BE_VALNV6
		EndIf
		aAdd(aNivEndOri,{nValNv,(cAliasSBE)->DC7_PESO2,(cAliasSBE)->DC7_PESO1})
		(cAliasSBE)->(dbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())
Return lRet

/*/-----------------------------------------------------------------------------
Adiciona mensagens ao registro de LOG de busca de endere�os.
Formato aLogEnd
	aLogEnd[nX,1] = Documento
	aLogEnd[nX,2] = Serie
	aLogEnd[nX,3] = Produto
	aLogEnd[nX,4] = Descri��o Produto
	aLogEnd[nX,5] = Lote
	aLogEnd[nX,6] = Quantidade Endere�ar
	aLogEnd[nX,7] = Array(2)
		aLogEnd[nX,7,nY,1] = "Busca de endere�os ..."
		aLogEnd[nX,7,nY,2] = Tipo de Endere�amento
		aLogEnd[nX,7,nY,3] = Array(6)
			aLogEnd[nX,7,nY,3,nZ,01] = Estrutura Fisica
			aLogEnd[nX,7,nY,3,nZ,02] = Ordem Zona Armazenagem
			aLogEnd[nX,7,nY,3,nZ,03] = Ordem Produto
			aLogEnd[nX,7,nY,3,nZ,04] = Ordem Saldo
			aLogEnd[nX,7,nY,3,nZ,05] = Ordem Movimento
			aLogEnd[nX,7,nY,3,nZ,06] = Endere�o
			aLogEnd[nX,7,nY,3,nZ,07] = Capacidade
			aLogEnd[nX,7,nY,3,nZ,08] = Saldo Endere�o
			aLogEnd[nX,7,nY,3,nZ,09] = Saldo RF
			aLogEnd[nX,7,nY,3,nZ,10] = Quantidade Total a Endere�ar
			aLogEnd[nX,7,nY,3,nZ,11] = Quantidade Endere�ada
			aLogEnd[nX,7,nY,3,nZ,12] = Mensagem
-----------------------------------------------------------------------------/*/
Static Function AddMsgLog(cEstrtura,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndereco,nCapEnder,nSaldoSBF,nSaldoRF,nTotEnd,nQtdEnd,cMensagem)
Local aLogMsg := Nil

	If Type("aLogEnd") != "A"
		Return Nil
	EndIf

	aLogMsg := aLogEnd[Len(aLogEnd),RELDETEST]
	AAdd(aLogMsg[Len(aLogMsg),3],{cEstrtura,cOrdSeq,cOrdPrd,cOrdSld,cOrdMov,cEndereco,nCapEnder,nSaldoSBF,nSaldoRF,nTotEnd,nQtdEnd,cMensagem})

Return (Nil)

//-----------------------------------------------------------------------------
// Fun��o utilizada em gatilhos do campo D1_COD para preenchimento
// autom�tico do servi�o e endere�o WMS no documento de entrada
//-----------------------------------------------------------------------------
Function WmsGatEnt(cCampo)
Local aAreaAnt := GetArea()
Local aAreaSB5 := SB5->(GetArea())
Local cRet     := ""

	// Somente se for produto com controle de endere�amento
	// e n�o for chamado pela rotina Pr�-nota de Entrada
	If IntWMS(M->D1_COD) .And. !IsInCallStack("MATA140")
		SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
		If SB5->(DbSeek(xFilial("SB5")+M->D1_COD))
			If IsInCallStack("MATA103") .And. cTipo == "D"
				If cCampo == "B5_SERVENT"
					cRet := SB5->B5_SERVDEV
				ElseIf cCampo == "B5_ENDENT"
					cRet := SB5->B5_ENDDEV
				EndIf
			Else
				If cCampo == "B5_SERVENT"
					cRet := SB5->B5_SERVENT
				ElseIf cCampo == "B5_ENDENT"
					cRet := SB5->B5_ENDENT
				EndIf
			EndIf
		EndIf
	EndIf

RestArea(aAreaSB5)
RestArea(aAreaAnt)
Return cRet

//-----------------------------------------------------------------------------
// Retorna a quantidade da segunda unidade de medida do produto
// caso seja uma unidade agrupadora como, por exemplo, Caixa
//-----------------------------------------------------------------------------
Static Function RetQtdCx(cProduto)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial('SB1')+cProduto))
	If SB1->B1_TIPCONV == 'D' .And. !Empty(SB1->B1_CONV)
		Return SB1->B1_CONV
	Else
		Return 0
	EndIf

Return

