#INCLUDE 'MATA261.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE LINHAS 999

Static __lIntWMS

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA261  � Autor � Marcelo Pimentel      � Data � 28/01/98  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Transferencias Mod II                           ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void Mata261(ExpA1,ExpN1)                                   ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com dados da rotina automatica                ���
���          � ExpN1 = Numero da opcao selecionada (rotina automatica)     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function Mata261(aAutoItens, nOpcAuto)
Local aCores		:= A240aCores()
Local aMemUser
Local lAcesso		:= .T.
Local cFiltro		:= ""
Local lRet 			:= .T.
Local nRet			:= 0
Local cFiltraSD3    := '' 

Private cCadastro	:= OemToAnsi(STR0001) 		//-- Transfer�ncia Mod. II
Private lMA261D3	:= (ExistBlock('MA261D3'))	//-- Ponto de entrada na gravacao
Private lMA261Cpo	:= (ExistBlock('MA261CPO')) //-- Ponto de entrada para adicionar campos no aHeader
Private lMA261Exc	:= (ExistBlock('MA261EXC')) //-- Ponto de entrada na gravacao do estorno
Private lMA261Est	:= (ExistBlock('MA261EST')) //-- Ponto de entrada para verificar se estorno eh possivel
Private lM261D3O	:= (ExistBlock('M261D3O'))	//-- Ponto de entrada para verificar se estorno eh possivel
Private lLogMov		:= GetMV("MV_IMPMOV")
//��������������������������������������������������������������Ŀ
//� Pega a variavel que identifica se o calculo do custo � :     �
//�               O = On-Line ou M = Mensal                      �
//����������������������������������������������������������������
Private cCusMed		:= GetMV('MV_CUSMED')
Private nTotal		:= 0
Private nHdlPrv		:= 0
Private cLoteEst	:= ''
Private cArquivo	:= ''
Private lCriaHeade	:= .T.
Private aRegSD3		:= {}
Private aMemos		:= {}
Private aRegPgSD3	:= {}

//��������������������������������������������������������������Ŀ
//� Estas variaveis indicam para as funcoes de validacao qual    �
//� programa as est� chamando                                    �
//����������������������������������������������������������������
Private l240:=.F.,l241 := .F.,l242:=.F.,l250:= .F.,l261:= .T.,l185:=.F.

//��������������������������������������������������������������Ŀ
//� Variavel utilizada para indicar se utiliza rotina automatica �
//� ------> NAO DEVE SER REMOVIDA <----------------------------- �
//����������������������������������������������������������������
Private lAutoma261	:= Valtype(aAutoItens) == "A"
Private nFCICalc    := SuperGetMV("MV_FCICALC",.F.,0)
Private aLogSld   	:= {}
Private aCtbDia		:= {}

__lIntWMS := FindFunction("IntWMS")

If ExistBlock("MT261ACS")
	lAcesso := ExecBlock("MT261ACS",.F.,.F.)
	If ValType(lAcesso) == "L" .And. !lAcesso
		Return
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Ponto de entrada para adicao de campos memo do usuario       �
//����������������������������������������������������������������
If ExistBlock( "MT261MEM" )
	aMemUser := ExecBlock( "MT261MEM", .F., .F. )
	If ValType( aMemUser ) == "A"
		AEval( aMemUser, { |x| AAdd( aMemos, x ) } )
	EndIf
EndIf

//����������������������������������������������������������������Ŀ
//� mv_par01 - Se mostra e permite digitar lancamentos contabeis   �
//� mv_par02 - Se deve aglutinar os lancamentos contabeis          �
//� mv_par03 - Subtrai Saldo Terc. N.Poder ? SIM/NAO               �
//� mv_par04 - Quanto ao Estorno ? DOCUMENTO/ITEM                  �
//������������������������������������������������������������������
Pergunte("MTA260",.F.)

//��������������������������������������������������������������Ŀ
//� Verifica se o custo medio e' calculado On-Line               �
//����������������������������������������������������������������
If cCusMed == 'O'
	//��������������������������������������������������������������Ŀ
	//� Inicializa perguntas deste programa                          �
	//����������������������������������������������������������������
	lDigita    := Iif(mv_par01 == 1,.T.,.F.)
	lAglutina  := Iif(mv_par02 == 1,.T.,.F.)
	nTotal     := 0   //-- Total dos lancamentos contabeis
	nHdlPrv    := 0   //-- Endereco do arquivo de contra prova dos lanctos cont.
	cLoteEst   := ''  //-- Numero do lote para lancamentos do estoque
	cArquivo   := ''  //-- Nome do arquivo contra prova
	lCriaHeade := .T. //-- Para criar o header do arquivo Contra Prova

	//��������������������������������������������������������������Ŀ
	//� Posiciona numero do Lote para Lancamentos do Faturamento     �
	//����������������������������������������������������������������
	cLoteEst := If(SX5->(dbSeek(xFilial('SX5')+'09EST',.F.)),AllTrim(X5Descri()),'EST')
EndIf

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Utiliza a funcao automatica para inclusao                    �
//����������������������������������������������������������������
If lAutoma261
	lMsHelpAuto:=.T.
	If nOpcAuto == Nil .Or. nOpcAuto == 3
		nRet := A261Inclui("SD3",SD3->(Recno()),3,aAutoItens)
	Else
		nRet := A261Estorn("SD3",SD3->(Recno()),6,aAutoItens)
	EndIf
	if nRet == 0
		lRet:=.F.
		If IsInCallStack('MATA311') .OR. IsInCallStack('ACDV150')
			lMsErroAuto:=.T.
		EndIf
	EndIf
	lMsHelpAuto:=.F.
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	//����������������������������������������������������������������Ŀ
	//� Ativa tecla F12 para acionar perguntas                         �
	//������������������������������������������������������������������
	SetKey( VK_F12, {|| Pergunte("MTA260")})

	//Ponto de entrada para filtragem com regra ADVPL
	If ExistBlock("MT261FIL")
		cFiltraSD3 := ExecBlock("MT261FIL",.F.,.F.)
		If Valtype(cFiltraSD3) <> "C"
			cFiltraSD3 := Nil
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Ponto de entrada para verificacao de filtros na Mbrowse      �
	//����������������������������������������������������������������
	If  ExistBlock("M261FILB")
		cFiltro := ExecBlock("M261FILB",.F.,.F.)
		If Valtype(cFiltro) <> "C"
			cFiltro := ""
		EndIf
	EndIf

	mBrowse( 6, 1,22,75,"SD3",,,,,,aCores,,,,,,,, IF(!Empty(cFiltro),cFiltro, NIL),,,,cFiltraSD3)
	//����������������������������������������������������������������Ŀ
	//� Desativa tecla que aciona perguntas                            �
	//������������������������������������������������������������������
	Set Key VK_F12 To
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a261Visual� Autor � Marcelo Pimentel      � Data � 04/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de visualizacao de uma Transfer�ncia Mod. II      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void a261Visual(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaEst                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function a261Visual(cAlias,nReg,nOpcX)

Local oDlg
Local aArea      := GetArea()
Local aSB1Area   := SB1->(GetArea())
Local aSD3Area   := SD3->(GetArea())
Local aTam       := {}
Local cSeek      := ''
Local cNumSeq    := ''
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosDOri	:= 2	//Descricao do Produto Origem
Local nPosUMOri	:= 3	//Unidade de Medida Origem
Local nPosLOCOri 	:= 4	//Armazem Origem
Local nPosLcZOri 	:= 5	//Localizacao Origem
Local nPosCODDes 	:= 6 	//Codigo do Produto Destino
Local nPosDDes	:= 7	//Descricao do Produto Destino
Local nPosUMDes	:= 8	//Unidade de Medida Destino
Local nPosLOCDes	:= 9	//Armazem Destino
Local nPosLcZDes	:= 10	//Localizacao Destino
Local nPosNSer	:= 11	//Numero de Serie
Local nPosLoTCTL 	:= 12	//Lote de Controle
Local nPosNLOTE	:= 13	//Numero do Lote
Local nPosDTVAL	:= 14	//Data Valida
Local nPosPotenc 	:= 15	//Potencia do Lote
Local nPosQUANT	:= 16	//Quantidade
Local nPosQTSEG	:= 17	//Quantidade na 2a. Unidade de Medida
Local nPosEstor	:= 18	//Estornado
Local nPosNumSeq	:= 19	//Sequencia
Local nPosLotDes	:= 20	//Lote Destino
Local nPosDtVldD	:= 21	//Data Valida de Destino
Local nPosPerImp	:= 0
Local nPosCAT83O	:= 0   //Cod.CAT 83 Prod.Origem
Local nPosCAT83D	:= 0   //Cod.CAT 83 Prod.Destino
Local nPosServic	:= 0
Local aBut261		:= {}
Local lContinua	:= .T.
Local lCAT83		:= .F.
Local cMemo
Local cDescMemo
Local nMem
Local nPItem      := 0
Local nPosCODOri  := 1
Local oSize
Local lMA261In	:= (ExistBlock('MA261IN'))	//-- Atribui valores nos campos de usuario


Private aCols      := {}
Private aHeader    := {}
Private cDocumento := SD3->D3_DOC
Private dA261Data  := SD3->D3_EMISSAO

//������������������Ŀ
//� Portaria CAT83   |
//��������������������
If V240CAT83()
    lCAT83:=.T.
EndIf

//-- Verifica se est� na filial correta
If xFilial("SD3") # SD3->D3_FILIAL
	Help(' ',1,'A000FI')
	lContinua := .F.
EndIf

//-- S� Trabalha com Movimenta��es RE4/DE4
If lContinua .And. !SD3->D3_CF $ 'RE4�DE4'
	Help(' ',1,'A260NAO')
	lContinua := .F.
EndIf
//����������������������������������������������������������������������Ŀ
//� Inicializa variaveis para campos Memos Virtuais						 �
//������������������������������������������������������������������������
If Type("aMemos")=="A" .And. Len(aMemos) > 0
	For nMem := 1 to Len(aMemos)
		cMemo := aMemos[nMem][2]
		cDescMemo := aMemos[nMem][3]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next i
EndIf

//��������������������������������������Ŀ
//� Montagem do AHeader (Visualiza��o)   �
//����������������������������������������
If lContinua
	aHeader := {}
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0006, 'D3_COD'    , PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A261VldCod(1)', USADO, 'C', 'SD3', ''}) // 'Prod.Orig.'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0007, 'D3_DESCRI' , PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Desc.Orig.'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0008, 'D3_UM'     , PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''            , USADO, 'C', 'SD3', ''}) // 'UM Orig.'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0009, 'D3_LOCAL'  , PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(1)' , USADO, 'C', 'SD3', ''}) // 'Almox Orig.'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0010, 'D3_LOCALIZ', PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(1)', USADO, 'C', 'SD3', ''}) // 'Localiz.Orig.'
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0011, 'D3_COD'    , PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A261VldCod(2)', USADO, 'C', 'SD3', ''}) // 'Prod.Destino'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0012, 'D3_DESCRI' , PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Desc.Destino'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0013, 'D3_UM'     , PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''            , USADO, 'C', 'SD3', ''}) // 'UM Destino'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0014, 'D3_LOCAL'  , PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(2)' , USADO, 'C', 'SD3', ''}) // 'Almox Destino'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0015, 'D3_LOCALIZ', PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(2)', USADO, 'C', 'SD3', ''}) // 'Localiz.Destino'
	aTam := TamSX3('D3_NUMSERI'); Aadd(aHeader, {STR0016, 'D3_NUMSERI', PesqPict('SD3', 'D3_NUMSERI', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'N�mero Serie'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0018, 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1]         ), aTam[1], aTam[2], 'A261Lote()'   , USADO, 'C', 'SD3', ''}) // 'Lote'
	aTam := TamSX3('D3_NUMLOTE'); Aadd(aHeader, {STR0017, 'D3_NUMLOTE', PesqPict('SD3', 'D3_NUMLOTE', aTam[1]         ), aTam[1], aTam[2], 'A261Lote()'   , USADO, 'C', 'SD3', ''}) // 'Sub-Lote'
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0019, 'D3_DTVALID', PesqPict('SD3', 'D3_DTVALID', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'D', 'SD3', ''}) // 'Validade'
	aTam := TamSX3('D3_POTENCI'); Aadd(aHeader, {STR0039, 'D3_POTENCI', PesqPict('SD3', 'D3_POTENCI', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'N', 'SD3', ''}) // 'Potencia'
	aTam := TamSX3('D3_QUANT'  ); Aadd(aHeader, {STR0020, 'D3_QUANT'  , PesqPict('SD3', 'D3_QUANT'    			        ), aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Quantidade'
	aTam := TamSX3('D3_QTSEGUM'); Aadd(aHeader, {STR0021, 'D3_QTSEGUM', PesqPict('SD3', 'D3_QTSEGUM',         			), aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Qt 2aUM'
	aTam := TamSX3('D3_ESTORNO'); Aadd(aHeader, {STR0022, 'D3_ESTORNO', PesqPict('SD3', 'D3_ESTORNO', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Estornado'
	aTam := TamSX3('D3_NUMSEQ' ); Aadd(aHeader, {STR0028, 'D3_NUMSEQ' , PesqPict('SD3', 'D3_NUMSEQ' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Sequencia'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0044, 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1]         ), aTam[1], aTam[2], ''   , USADO, 'C', 'SD3', ''})
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0046, 'D3_DTVALID', PesqPict('SD3', 'D3_DTVALID', aTam[1]         ), aTam[1], aTam[2], 'A261DtPot(3)' , USADO, 'D', 'SD3', ''}) // 'Validade Destino'
	//-- Tratamento dos campos para utilizacao do SIGAWMS
	If	a261IntWMS()
		aTam := TamSX3('D3_SERVIC'); Aadd(aHeader, {RetTitle('D3_SERVIC'), 'D3_SERVIC', PesqPict('SD3', 'D3_SERVIC', aTam[1]      ), aTam[1], aTam[2], ''  , USADO, 'C', 'SD3', ''})
		nPosServic := aScan(aHeader,{|x| Alltrim(x[2])=="D3_SERVIC"})
	EndIf
	aTam := TamSX3('D3_ITEMGRD' ); Aadd(aHeader, {STR0055, 'D3_ITEMGRD' , PesqPict('SD3', 'D3_ITEMGRD'  , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Sequencia'
	If Type("aMemos")=="A" .And. Len(aMemos) > 0
		aTam := TamSX3(cMemo);Aadd(aHeader, {cDescMemo, cMemo, PesqPict('SD3', cMemo, aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'M', 'SD3', ''})	// CAMPOS MEMO
	EndIf

	//������������������Ŀ
	//� Portaria CAT83   |
	//��������������������
	If lCAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0065,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // Cod.CAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0066,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // Cod.CAT83
		nPosCAT83O  := aScan(aheader,{|x| Alltrim(x[2])=="D3_CODLAN"})
		nPosCAT83D  := IIF(nPosCAT83O>0,nPosCAT83O+1,0)
	EndIf

	//������������������Ŀ
	//� Percentual FCI   |
	//��������������������
	If nFCICalc == 1
		aTam := TamSX3('D3_PERIMP'  ); Aadd(aHeader, {"Per. Imp.", 'D3_PERIMP'  	, PesqPict('SD3', 'D3_PERIMP'), aTam[1], aTam[2], 'A250VlPImp()', USADO, 'N', 'SD3', ''}) // 'Percentual Importacao'
		nPosPerImp  := aScan(aheader,{|x| Alltrim(x[2])=="D3_PERIMP"})    //Percental Importacao
	EndIf

	//-- ExecBlock para incluir campos no aHeader
	If lMA261Cpo
		ExecBlock('MA261CPO',.F.,.F.)
	EndIf

	ADHeadRec("SD3",aHeader)

	//-- Posicionamento das Ordens utilizadas na fun��o
	SB1->(dbSetOrder(1))
	SD3->(dbSetOrder(8))

	//��������������������������������������Ŀ
	//� Montagem do ACols (Visualiza��o)     �
	//����������������������������������������
	aCols   := {}
	cNumSeq := If(Empty(SD3->D3_DOC),SD3->D3_NUMSEQ,'�')
	nPItem:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_ITEMGRD"})

	cSeek := If(Empty(SD3->D3_DOC),xFilial('SD3')+cDocumento+cNumseq,xFilial('SD3')+cDocumento)	

	If !SD3->(dbSeek( cSeek,.F.))
		Help(' ',1,'A260NAO')
		lContinua := .F.
	EndIf
EndIf
Do While lContinua .And. !SD3->(Eof()) .And. cSeek == SD3->D3_FILIAL+SD3->D3_DOC+If(Empty(SD3->D3_DOC),SD3->D3_NUMSEQ,"")

	If SD3->D3_CF $ 'RE4�DE4'
		aAdd(aCols, Array(Len(aHeader)))
		cNumSeq := SD3->D3_NUMSEQ
	Else
		SD3->(dbSkip())
		Loop
	EndIf

	Do While !SD3->(Eof()) .And. cNumSeq == SD3->D3_NUMSEQ

		If SD3->D3_CF $ 'RE4'

			//-- Posiciona o Arquivo de Produtos (SB1)
			If !SB1->(dbSeek(xFilial('SB1')+SD3->D3_COD,.F.))
				Help(' ', 1, 'REGNOIS')
				lContinua := .F.
				Exit
			EndIf
			aCols[Len(aCols),nPosCODOri]   	:= SD3->D3_COD
			aCols[Len(aCols),nPosDOri]     	:= SB1->B1_DESC
			aCols[Len(aCols),nPosUMOri]    	:= SD3->D3_UM
			aCols[Len(aCols),nPosLOCOri]   	:= SD3->D3_LOCAL
			aCols[Len(aCols),nPosQUANT]    	:= SD3->D3_QUANT
			aCols[Len(aCols),nPosQTSEG]    	:= SD3->D3_QTSEGUM
			aCols[Len(aCols),nPosEstor]    	:= SD3->D3_ESTORNO
			aCols[Len(aCols),nPosNumSeq]   	:= cNumSeq
			aCols[Len(aCols),nPItem]       	:= SD3->D3_ITEMGRD
			aCols[Len(aCols),nPosLcZOri]	:= SD3->D3_LOCALIZ
			aCols[Len(aCols),nPosNSer]  	:= SD3->D3_NUMSERI
			aCols[Len(aCols),nPosLoTCTL]	:= SD3->D3_LOTECTL
			aCols[Len(aCols),nPosNLOTE] 	:= SD3->D3_NUMLOTE
			aCols[Len(aCols),nPosDTVAL] 	:= SD3->D3_DTVALID
			aCols[Len(aCols),nPosPotenc]	:= SD3->D3_POTENCI

			If nPosCAT83O>0
				aCols[Len(aCols),nPosCAT83O]:= SD3->D3_CODLAN
			EndIf

		ElseIf SD3->D3_CF $ 'DE4'
			//-- Posiciona o Arquivo de Produtos (SB1)
			If !SB1->(dbSeek(xFilial('SB1')+SD3->D3_COD,.F.))
				Help(' ', 1, 'REGNOIS')
				lContinua := .F.
				Exit
			EndIf
			aCols[Len(aCols),nPosCODDes]	:= SD3->D3_COD
			aCols[Len(aCols),nPosDDes]		:= SB1->B1_DESC
			aCols[Len(aCols),nPosUMDes]		:= SD3->D3_UM
			aCols[Len(aCols),nPosLOCDes]	:= SD3->D3_LOCAL
			aCols[Len(aCols),nPosLcZDes]	:= SD3->D3_LOCALIZ
			aCols[Len(aCols),nPosLotDes]	:= SD3->D3_LOTECTL
			aCols[Len(aCols),nPosDtVldD]	:= SD3->D3_DTVALID
			If	nPosServic > 0
				aCols[Len(aCols),nPosServic] := SD3->D3_SERVIC
			EndIf

			If nPosCAT83D>0
				aCols[Len(aCols),nPosCAT83D]:= SD3->D3_CODLAN
			EndIf
			If nFCICalc == 1
				aCols[Len(aCols),nPosPerImp]:= SD3->D3_PERIMP
			EndIf
		EndIf

		aCols[Len(aCols)][Len(aHeader)-1] := "SD3"
		aCols[Len(aCols)][Len(aHeader)]	  := SD3->(RecNo())

		SD3->(dbSkip())
		If !Empty(aCols[Len(aCols),nPosCODOri]) .And. !Empty(aCols[Len(aCols),nPosCODDes])
			Exit
		EndIf
	EndDo
	If !lContinua
		Exit
	EndIf
	If Empty(aCols[Len(aCols),nPosCODOri]) .Or. Empty(aCols[Len(aCols),nPosCODDes])
		Help(' ',1,'A260NAO')
		lContinua := .F.
		Exit
	EndIf
	//-- ExecBlock para atribuir valores nos campos de usuario
	If lMA261In
		ExecBlock('MA261IN',.F.,.F.)
	EndIf
EndDo

If lContinua .And. Len(aCols) == 0
	Help(' ',1,'A240ESTORN')
	lContinua := .F.
EndIf

If lContinua
	//��������������������������������������������������������������Ŀ
	//� Calcula dimens�es                                            �
	//����������������������������������������������������������������
	oSize := FwDefSize():New()

	oSize:AddObject( "CIMA"  ,  100,  5, .T., .T.) // Nao dimensiona Y
	oSize:AddObject( "BAIXO",  100, 95, .T., .T.) // Totalmente dimensionavel

	oSize:lProp := .T. // Proporcional
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() // Dispara os calculos
	//��������������������������������������������������������������Ŀ
	//� Executa ponto de entrada para montar array com botoes a      �
	//� serem apresentados na tela                                   �
	//����������������������������������������������������������������
	If (ExistBlock("M261BCHOI"))
		aBut261:=ExecBlock("M261BCHOI",.F.,.F.)
		If ValType(aBut261) # "A"
			aBut261:={}
		EndIf
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Monta Dialog                                                 �
	//����������������������������������������������������������������
	DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"Transferencia Mod2"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	//��������������������������������������������������������������Ŀ
	//� Adiciona Panel                                               �
	//����������������������������������������������������������������
	oPanel1:= tPanel():New(oSize:GetDimension("CIMA","LININI"),oSize:GetDimension("CIMA","COLINI"),,oDlg,,,,,,oSize:GetDimension("CIMA","XSIZE"),oSize:GetDimension("CIMA","YSIZE"),,)
	oPanel2:= tPanel():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),,oDlg,,,,,,oSize:GetDimension("BAIXO","XSIZE"),oSize:GetDimension("BAIXO","YSIZE"),,)

	@ 0,0 SAY   OemToAnsi(STR0023) OF oPanel1 PIXEL // 'N�mero Documento'
	@ 0,50 MSGET cDocumento When .F. SIZE 70,08 OF oPanel1 PIXEL
	@ 0,125 SAY   OemToAnsi(STR0024) OF oPanel1 PIXEL // 'Emiss�o'
	@ 0,150 MSGET dA261Data When .F. SIZE 40,08 OF oPanel1 PIXEL

	//��������������������������������������������������������������Ŀ
	//�Ponto de Entrada que disponibiliza o Objeto da Dialog        �
	//����������������������������������������������������������������
	If (ExistBlock( "MT261CAB" ))
		ExecBlock("MT261CAB",.F.,.F.,{@oPanel1,0,nOpcx})
	EndIf

	oGet := MSGetDados():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),oSize:GetDimension("BAIXO","LINEND"),oSize:GetDimension("BAIXO","COLEND"),;
							nOpcX,'AllwaysTrue','AllwaysTrue','',;
							.F.,{"D3_QUANT","D3_QTSEGUM"},NIL,NIL,;
							LINHAS,,,,,,,,,oPanel2)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End(),If(oGet:TudoOK(),nOpca:=1,nOpca:=0)},{||oDlg:End()},,aBut261)
EndIf
//-- Retorna a integridade do Sistema
RestArea(aSB1Area)
RestArea(aSD3Area)
RestArea(aArea)
Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a261Inclui� Autor � Marcelo Pimentel      � Data � 29/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Transferencia Mod. II                          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void a261Inclui(ExpC1,ExpN1,ExpN2,ExpA1)                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
���          � ExpA1 = Array com dados da rotina automatica               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function a261Inclui(cAlias,nReg,nOpcX,aAutoItens)

Local aArea      := GetArea()
Local aAreaDH1	 := {}
Local aSB1Area   := SB1->(GetArea())
Local aSD3Area   := SD3->(GetArea())
Local nOpcao     := 3
Local dDataFec   := MVUlmes()
Local aAlter     := {}
Local nSavReg    := 0
Local cLocCQ     := GetMvNNR('MV_CQ','98')
Local cStrErr    := ""
Local lQualyCQ   := .F.
Local lOkAutoma  := .T.
Local lCAT83  	 := .F.
Local oDlg
Local nx,nz
Local cDescMemo
Local cMemo
Local nMem
Local cCampo     := ""
Local nPosCODDes := 6	//Codigo do Produto Destino
Local nPosLOCDes := 9	//Armazem Destino
Local cTextoAutoma:=STR0038
Local nw
Local aBut261		:= {}
Local lContinua		:= .T.
Local lChangeDoc	:= .F.
Local nPosHeader	:= 0
Local aHeaderBKP	:= {}
Local oSize
Local aRecSD3 		:= {}
Local lMA261TRD3	:= ExistBlock("MA261TRD3")
Local cDocWMS    := ""
Local lIntegDef		:= FWHasEAI("MATA261",.T.,,.T.)
Local lWmsNew	 := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lMA261In	:= (ExistBlock('MA261IN'))	//-- Atribui valores nos campos de usuario
Local lDocto	:= IIf( GetSx3Cache("D3_DOC","X3_VISUAL") == "V", .F., IIf( Empty( GetSx3Cache( "D3_DOC", "X3_WHEN" ) ), .T.,&( GetSx3Cache( "D3_DOC", "X3_WHEN" ) ) ) )

Private cDocumento := CriaVar('D3_DOC')
Private dA261Data  := dDataBase
Private nOpca      := 0
Private nPosNSer   := 11
Private nPosLotCTL := 12
Private nPosLote   := 13
Private nPosDValid := 14
Private nPos261Loc := 05
Private nPos261Qtd := 16
Private nPosLotDes := 20	//Lote Destino
Private nPos261Pot := 15	//Potencia
Private nPosDtVldD := 21	//Data Valida de Destino
Private aCols      := {}
Private aHeader    := {}

//-- Variaveis utilizadas pela funcao wmsexedcf
Private aLibSDB    := {}
Private aWmsAviso  := {}

INCLUI := .T. //Vari�vel criada pois quando a fun��o incluir � acionada por MsExecAuto a mesma n�o � criada
ALTERA := .F. //Vari�vel criada pois quando a fun��o incluir � acionada por MsExecAuto a mesma n�o � criada

//Tratamento para Carregar os parametros do Pergunte
Pergunte("MTA260",.F.)

//������������������Ŀ
//� Portaria CAT83   |
//��������������������
If V240CAT83()
    lCAT83:=.T.
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica a Existencia do ponto de entrada e seta valor       �
//� da variavel que define se edita o documento ou nao           �
//����������������������������������������������������������������
If ExistBlock("MTA261DOC")
	lDocto := ExecBlock("MTA261DOC",.F.,.F.)
	lDocto := If(Valtype(lDocto)#"L",.T.,lDocto)
EndIf

//-- Verificar data do ultimo fechamento em SX6
If dDataFec >= dDataBase
	Help (' ', 1, 'FECHTO')
	lContinua := .F.
EndIf

//����������������������������������������������������������������������Ŀ
//� Inicializa variaveis para campos Memos Virtuais                  	 �
//������������������������������������������������������������������������
If Type("aMemos")=="A" .And. Len(aMemos) > 0
	For nMem :=1 To Len(aMemos)
		cMemo := aMemos[nMem][2]
		cDescMemo := aMemos[nMem][3]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next nMem
EndIf
If lContinua
	//-- Verificar integracao com rotina automatica
	If lAutoma261
		cDocumento:=If(ValType(aAutoItens[1,1])=="C",aAutoItens[1,1],"")
		dA261Data:=If(ValType(aAutoItens[1,2])=="D",aAutoItens[1,2],dDataBase)
	EndIf

	//-- Inicializa o numero do Documento com o ultimo + 1
	dbSelectArea(cAlias)
	nSavReg		:= RecNo()
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	// Busca proximo documento na tabela auxiliar (DH1) quando controla novo WMS
	If !lAutoma261 .And. lWmsNew
		aAreaDH1 := GetArea()
		dbSelectArea("DH1")
		DH1->(dbSetOrder(2))
		If DH1->(dbSeek(xFilial("DH1")+cDocumento))
			cDocWms	:= NextNumero("DH1",2,"DH1_DOC",.T.)
			cDocumento := cDocWms
		EndIf
		RestArea(aAreaDH1)
	EndIf
	cDocumento := A261RetINV(cDocumento)
	dbSetOrder(2)
	dbSeek(xFilial()+cDocumento)
	cMay := "SD3"+Alltrim(xFilial())+cDocumento
	While D3_FILIAL+D3_DOC==xFilial()+cDocumento.Or.!MayIUseCode(cMay)
		If D3_ESTORNO # "S"
			cDocumento := Soma1(cDocumento)
			cMay := "SD3"+Alltrim(xFilial())+cDocumento
		EndIf
		dbSkip()
	EndDo
	dbSetOrder(1)
	dbGoTo(nSavReg)

	//-- Monta o array com os campos que poder�o ser alterados
	Aadd(aAlter, 'D3_COD')
	Aadd(aAlter, 'D3_LOCAL')
	Aadd(aAlter, 'D3_QUANT')
	Aadd(aAlter, 'D3_LOCALIZ')
	Aadd(aAlter, 'D3_NUMSERI')
	Aadd(aAlter, 'D3_NUMLOTE')
	Aadd(aAlter, 'D3_LOTECTL')
	Aadd(aAlter, 'D3_DTVALID')
	Aadd(aAlter, 'D3_POTENCI')
	Aadd(aAlter, 'D3_QTSEGUM')

	//��������������������������������������Ŀ
	//� Montagem do AHeader (Inclus�o)       �
	//����������������������������������������
	aHeader := {}
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0006, 'D3_COD'    	, PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A093Prod().And.A261PrdGrd().And.A261VldCod(1)', USADO, 'C', 'SD3', ''})	// 'Prod.Orig.'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0007, 'D3_DESCRI' 	, PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''})	// 'Desc.Orig.'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0008, 'D3_UM'     	, PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''})	// 'UM Orig.'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0009, 'D3_LOCAL'  	, PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(1)' , USADO, 'C', 'SD3', ''})	// 'Almox Orig.'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0010, 'D3_LOCALIZ'	, PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(1)', USADO, 'C', 'SD3', ''})	// 'Localiz.Orig.'
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0011, 'D3_COD'    	, PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A093Prod().And.A261PrdGrd().And.A261VldCod(2)', USADO, 'C', 'SD3', ''}) // 'Prod.Destino'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0012, 'D3_DESCRI' 	, PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Desc.Destino'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0013, 'D3_UM'     	, PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'UM Destino'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0014, 'D3_LOCAL'  	, PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(2)' , USADO, 'C', 'SD3', ''}) // 'Almox Destino'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0015,'D3_LOCALIZ'	, PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(2)', USADO, 'C', 'SD3', ''}) // 'Localiz.Destino'
	aTam := TamSX3('D3_NUMSERI'); Aadd(aHeader, {STR0016,'D3_NUMSERI'	, PesqPict('SD3', 'D3_NUMSERI', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'N�mero Serie'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0018,'D3_LOTECTL'	, PesqPict('SD3', 'D3_LOTECTL', aTam[1]     )	, aTam[1], aTam[2], 'A261Lote(1)'  , USADO, 'C', 'SD3', ''}) // 'Lote'
	aTam := TamSX3('D3_NUMLOTE'); Aadd(aHeader, {STR0017,'D3_NUMLOTE'	, PesqPict('SD3', 'D3_NUMLOTE', aTam[1]     )	, aTam[1], aTam[2], 'A261Lote(1)'  , USADO, 'C', 'SD3', ''}) // 'Sub-Lote'
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0019,'D3_DTVALID'	, PesqPict('SD3', 'D3_DTVALID', aTam[1]     )	, aTam[1], aTam[2], 'A261DtPot(1)' , USADO, 'D', 'SD3', ''}) // 'Validade'
	aTam := TamSX3('D3_POTENCI'); Aadd(aHeader, {STR0039,'D3_POTENCI'	, PesqPict('SD3', 'D3_POTENCI', aTam[1]     )	, aTam[1], aTam[2], 'A261DtPot(2)' , USADO, 'N', 'SD3', ''}) // 'Potencia'
	aTam := TamSX3('D3_QUANT'  ); Aadd(aHeader, {STR0020, 'D3_QUANT'  	, PesqPict('SD3', 'D3_QUANT'   			         ), aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Quantidade'
	aTam := TamSX3('D3_QTSEGUM'); Aadd(aHeader, {STR0021, 'D3_QTSEGUM'	, PesqPict('SD3', 'D3_QTSEGUM'	         		 ), aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Qt 2aUM'
	aTam := TamSX3('D3_ESTORNO'); Aadd(aHeader, {STR0022, 'D3_ESTORNO'	, PesqPict('SD3', 'D3_ESTORNO', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Estornado'
	aTam := TamSX3('D3_NUMSEQ' ); Aadd(aHeader, {STR0028, 'D3_NUMSEQ' 	, PesqPict('SD3', 'D3_NUMSEQ' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Sequencia'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0044, 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1]      ), aTam[1], aTam[2], 'A261Lote(2)'  , USADO, 'C', 'SD3', ''})
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0046,'D3_DTVALID'	, PesqPict('SD3', 'D3_DTVALID', aTam[1]     ), aTam[1], aTam[2], 'A261DtPot(3)' , USADO, 'D', 'SD3', ''}) // 'Validade Destino'
	//-- Tratamento dos campos para utilizacao do SIGAWMS
	If	a261IntWMS()
		aTam := TamSX3('D3_SERVIC'); Aadd(aHeader, {RetTitle('D3_SERVIC'), 'D3_SERVIC', PesqPict('SD3', 'D3_SERVIC', aTam[1]      ), aTam[1], aTam[2], ''  , USADO, 'C', 'SD3', ''})
	EndIf
	aTam := TamSX3('D3_ITEMGRD'); Aadd(aHeader, {STR0055,'D3_ITEMGRD'	, PesqPict('SD3', 'D3_ITEMGRD', aTam[1]         ), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // 'Validade Destino'

	//������������������Ŀ
	//� Portaria CAT83   |
	//��������������������
	If lCAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0065,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], "Vazio() .Or. ExistCpo('CDZ')" , USADO, 'C', 'SD3', ''}) // Cod.CAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0066,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], "Vazio() .Or. ExistCpo('CDZ')" , USADO, 'C', 'SD3', ''}) // Cod.CAT83
	EndIf
	//������������������Ŀ
	//� Percentual FCI   |
	//��������������������
	If nFCICalc == 1
		aTam := TamSX3('D3_PERIMP'  ); Aadd(aHeader, {RetTitle('D3_PERIMP'), 'D3_PERIMP'  	, PesqPict('SD3', 'D3_PERIMP'), aTam[1], aTam[2], 'A250VlPImp()', USADO, 'N', 'SD3', ''}) // 'Percentual Importacao'
	EndIf

	If Type("aMemos")=="A" .And. Len(aMemos) > 0
		aTam := TamSX3(cMemo);Aadd(aHeader, {cDescMemo, cMemo, PesqPict('SD3', cMemo, aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'M', 'SD3', ''})	// CAMPOS MEMO
	EndIf

	If SD3->(FieldPos("D3_IDDCF"))>0 .And. a261IntWMS()
		aTam := TamSX3('D3_IDDCF'); Aadd(aHeader, {RetTitle('D3_IDDCF'),'D3_IDDCF', PesqPict('SD3','D3_IDDCF', aTam[1]), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // Id DCF
	EndIf
	if lAutoma261
		aTam := TamSX3('D3_OBSERVA'); Aadd(aHeader, {RetTitle('D3_OBSERVA'), 'D3_OBSERVA', PesqPict('SD3', 'D3_OBSERVA', aTam[1] ), aTam[1], aTam[2], , USADO, 'C', 'SD3', ''})
	Endif

	//������������������������������������������������������������������Ŀ
	//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
	//��������������������������������������������������������������������

	//-- ExecBlock para incluir campos no aHeader
	If lMA261Cpo
		ExecBlock('MA261CPO',.F.,.F.)
	EndIf

	aCols := {}
	//-- Verificar integracao com rotina automatica
	If lAutoma261
		// Varre o array consistindo se os valores passados pelo usuario estao corretos
		// com relacao ao seu tipo
		// O item 1 do array contem o cabecalho para a rotina, nao deve ser considerado
		For nz:=2 to Len(aAutoItens)
			If ValType(aAutoItens[nz,Len(aAutoItens[nz])])#"D" .And. Len(aAutoItens[nz]) < 21
				Aadd(aAutoItens[nz], If(ValType(aAutoItens[nz,14])=="D",aAutoItens[nz,14],If(Empty(aAutoItens[nz,12]),CTOD(''),dDataBase)) )
			EndIf
			If Len(aAutoItens[nz,1]) == 3
				aAdd(aCols, Array(Len(aHeader)+1))
				aHeaderBKP := aClone(aHeader)
				For nX := 1 To Len(aAutoItens[nz])
					nPosHeader:=	aScan(aHeaderBKP,{|x| Alltrim(x[2])==aAutoItens[nz,nX,1]})
					If !Empty(nPosHeader)
						aCols[Len(aCols),nPosHeader]:=aAutoItens[nz,nX,2]
						aHeaderBKP[nPosHeader,2]:= "X"
					EndIf
				Next nX
				aCols[Len(aCols),Len(aHeader)+1] := .F.
			ElseIf Len(aAutoItens[nz]) # Len(aHeader)
				cTextoAutoma:=STR0040+chr(13)+chr(10)
				cTextoAutoma+=STR0041+chr(13)+chr(10)
				cTextoAutoma+=STR0042+chr(13)+chr(10)
				cTextoAutoma+="---------- ---------- ---- ------- -------"+chr(13)+chr(10)
				For nw:= 1 to len(aHeader)
					cTextoAutoma+=Padr(aHeader[nw,1],10)+" "+padr(aHeader[nw,2],10)+"  "+aHeader[nw,8]+"   "+Str(aHeader[nw,4],7)+" "+Str(aHeader[nw,5],7)+chr(13)+chr(10)
				Next
				lOkAutoma:=.F.
				Exit
			Else
				aAdd(aCols, Array(Len(aHeader)+1))
				For nX := 1 To Len(aHeader)
					If !ValType(aAutoItens[nz,nx]) == aHeader[nX,8]
						lOkAutoma:=.F.
						cStrErr  :=" "+Str(nx)
						cTextoAutoma+=cStrErr
					Else
						aCols[Len(aCols),nx]:=aAutoItens[nz,nx]
					EndIf
				Next nX
				aCols[Len(aCols),Len(aHeader)+1] := .F.
			EndIf
		Next nz
	Else

		ADHeadRec(cAlias,aHeader)

		//��������������������������������������Ŀ
		//� Montagem do ACols (Visualiza��o)     �
		//����������������������������������������
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 To Len(aHeader)
			cCampo:=Alltrim(aHeader[nX,2])
			If IsHeadRec(aHeader[nX][2])
				aCols[1][nX] := 0
			ElseIf IsHeadAlias(aHeader[nX][2])
				aCols[1][nX] := cAlias
			ElseIf aHeader[nX,8] == 'C'
				aCols[1,nX] := Space(aHeader[nX,4])
			ElseIf aHeader[nX,8] == 'N'
				aCols[1,nX] := 0
			ElseIf aHeader[nX,8] == "D" .And. cCampo != "D3_DTVALID"
				aCols[1][nX] := dDataBase
			ElseIf aHeader[nX,8] == "D" .And. cCampo == "D3_DTVALID"
				aCols[1][nX] := CriaVar("D3_DTVALID")
			ElseIf aHeader[nX,8] == 'M'
				aCols[1,nX] := ''
			Else
				aCols[1,nX] := .F.
			EndIf
		Next nX
		aCols[1,Len(aHeader)+1] := .F.
	EndIf

	//-- ExecBlock para atribuir valores nos campos de usuario
	If lMA261In
		ExecBlock('MA261IN',.F.,.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Calcula dimens�es                                            �
	//����������������������������������������������������������������
	oSize := FwDefSize():New()

	oSize:AddObject( "CIMA"  ,  100,  5, .T., .T.) // Nao dimensiona Y
	oSize:AddObject( "BAIXO",  100, 95, .T., .T.) // Totalmente dimensionavel

	oSize:lProp := .T. // Proporcional
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() // Dispara os calculos

	If lAutoma261
		//���������������������������������������Ŀ
		//� Valida o cabecalho passado pela rotina�
		//� automatica, a integridade do tipo de  �
		//� dado alimentado no array da rotina    �
		//� automatica e valida a getdados como se�
		//� os dados tivessem sido digitados.     �
		//�����������������������������������������
		If lOkAutoma
			lOkAutoma:=lOkAutoma .And. (dDataFec < dA261Data) .And. A240Doc()
			For nw:=1 to Len(aCols)
				If !lOkAutoma
					Exit
				EndIf
				N := nw //-- Inicializa a variavel "N" utilizada para definir a linha atual do aCols
				lOkAutoma:=A261Linok(nil,nw) .And. A261Tudook(nil,nw)
			Next nw
			If lOkAutoma
				nOpcA := 1
			EndIf
		Else
			Help(" ",1,STR0037,STR0037,cTextoAutoma,05,01)
		EndIf
	Else
		//��������������������������������������������������������������Ŀ
		//� Executa ponto de entrada para montar array com botoes a      �
		//� serem apresentados na tela                                   �
		//����������������������������������������������������������������
		If (ExistBlock("M261BCHOI"))
			aBut261:=ExecBlock("M261BCHOI",.F.,.F.)
			If ValType(aBut261) # "A"
				aBut261:={}
			EndIf
		EndIf

		Set Key VK_F4 TO ShowF4()


		//��������������������������������������������������������������Ŀ
		//� Monta Dialog                                                 �
		//����������������������������������������������������������������
		DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"Transferencia Mod2"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		//��������������������������������������������������������������Ŀ
		//� Adiciona Panel                                               �
		//����������������������������������������������������������������
		oPanel1:= tPanel():New(oSize:GetDimension("CIMA","LININI"),oSize:GetDimension("CIMA","COLINI"),,oDlg,,,,,,oSize:GetDimension("CIMA","XSIZE"),oSize:GetDimension("CIMA","YSIZE"),,)
		oPanel2:= tPanel():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),,oDlg,,,,,,oSize:GetDimension("BAIXO","XSIZE"),oSize:GetDimension("BAIXO","YSIZE"),,)

		@ 0 ,0  SAY   OemToAnsi(STR0023) OF oPanel1 PIXEL // 'N�mero Documento'
		@ 0 ,50 MSGET cDocumento Picture PesqPict('SD3','D3_DOC') Valid A240Doc() WHEN lDocto SIZE 70,08  OF oPanel1 PIXEL
		@ 0 ,125 SAY   OemToAnsi(STR0024) OF oPanel1 PIXEL // 'Emiss�o'
		@ 0 ,150 MSGET dA261Data Valid Ma261VldDt(dDataFec, dA261Data) WHEN If(GetSx3Cache("D3_EMISSAO","X3_VISUAL") == "V",.F.,&(GetSx3Cache("D3_EMISSAO","X3_WHEN"))) SIZE 40,08  OF oPanel1 PIXEL

		//��������������������������������������������������������������Ŀ
		//�Ponto de Entrada que disponibiliza o Objeto da Dialog        �
		//����������������������������������������������������������������
		If (ExistBlock( "MT261CAB" ))
			ExecBlock("MT261CAB",.F.,.F.,{@oPanel1,0,nOpcx})
		EndIf

		oGet := MSGetDados():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),oSize:GetDimension("BAIXO","LINEND"),oSize:GetDimension("BAIXO","COLEND"),;
								nOpcX,'A261LINOK','A261TUDOOK','',;
								.T.,NIL,NIL,NIL,;
								LINHAS,,,,,,,,,oPanel2)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIf(oGet:TudoOK(),(oDlg:End(),nOpca:=1),nOpca := 0)},{||oDlg:End()},,aBut261)
		Set Key VK_F4 to
	EndIf
	If nOpcA == 1
		//-- Verifica se algum produto utiliza CQ Celerina
		lQualyCQ := .F.
		For nX := 1 to Len(aCols)
			If SB1->(dbSeek(xFilial('SB1') + aCols[nX, nPosCODDes], .F.)) .And. ;
					RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q' .And. aCols[nX, nPosLOCDes] == cLocCQ
				lQualyCQ := .T.
				dbSelectArea("QE6")
				QE6->(dbSetOrder(3))
				If !QE6->(dbSeek(xFilial("QE6")+SB1->B1_COD))
					HELP(" ",1,"QIPXFATIPCQ")
					Return NIL
				Endif
				QE6->(dbCloseArea())
				Exit
			EndIf
		Next nX

		Begin Transaction
			a261Grava(cAlias,nOpcao,@lChangeDoc,@aRecSD3,aAutoItens)
			// Processa Gatilhos
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			EndIf
			//-- Integra��o Mensagem �nica
			If lIntegDef
				FwIntegDef("MATA261",,,,"MATA261")
			EndIf
			aRegPgSD3 := aClone(aRegSD3)
			aRegSD3 := {}
		End Transaction

		If lMA261TRD3
			ExecBlock("MA261TRD3",.F.,.F.,{aRecSD3})
		EndIf

		If lChangeDoc .And. !lAutoma261
			Help("",1,"A240DOC",,cDocumento,4,30)
		EndIf

		If lLogMov .And. Len(aLogSld) > 0
			//��������������������������������������������������������������������Ŀ
			//� Imprimir Relatorio de Movimentos nao realizados por falta de saldo �
			//����������������������������������������������������������������������
			RelLogMov(aLogSld)
		EndIf
		aSD3Area[3] := SD3->(Recno())
		//-- Integrado ao wms devera avaliar as regras para convocacao do servico e disponibilizar os
		//-- registros do SDB para convocacao, ou exibir as mensagens de erro WMS caso necess�rio
		If IntWMS()
			WmsAvalSD3("2","SD3")
		EndIf
	Else
		If __lSX8
			RollBackSX8()
		EndIf
		//��������������������������������������������������������������Ŀ
		//�Executa P.E. ao sair sem gravar 				                 �
		//����������������������������������������������������������������
		If (ExistBlock("MTA261CAN"))
			ExecBlock("MTA261CAN",.F.,.F.,{nOpcx})
		EndIf
	EndIf
EndIf
//-- Retorna a integridade do Sistema
RestArea(aSB1Area)
RestArea(aSD3Area)
RestArea(aArea)

If !lAutoma261 .And. Len(aRegPgSD3) > 0
	SD3->(DbGoTo(aRegPgSD3[Len(aRegPgSD3)]))
EndIf

Return nOpcA

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Estorn� Autor � Marcelo Pimentel      � Data � 02/02/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de transferencias Mod. II             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261Estorn(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Sigaest                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261Estorn(cAlias,nReg,nOpcX, aAutoItens)
LOCAL dDataFec   := MVUlmes()
Local aArea      := GetArea()
Local aArea2 	:= {}
Local aAreaSD3	:= {}
Local aSB1Area   := SB1->(GetArea())
Local aSD3Area   := SD3->(GetArea())
Local aSD7Area   := SD7->(GetArea())
Local aAlter     := {"D3_QUANT","D3_QTSEGUM"}
Local nX         := 0
Local nY         := 0
Local cSeek      := ''
Local cNumSeq    := ''
Local cCFAnt     := ''
Local aRecnos    := {}
Local aDelSD7    := {}
Local nDelSD7    := 0
Local cLocCQ     := GetMvNNR('MV_CQ','98')
Local lEstQualy  := .F.
Local oDLG
Local cDescMemo
Local cMemo
Local nMem
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosEstor  	:= 1	//Estornado
Local nPosCODOri 	:= 2 	//Codigo do Produto Origem
Local nPosDOri	:= 3	//Descricao do Produto Origem
Local nPosUMOri	:= 4	//Unidade de Medida Origem
Local nPosLOCOri	:= 5	//Armazem Origem
Local nPosLcZOri	:= 6	//Localizacao Origem
Local nPosCODDes	:= 7	//Codigo do Produto Destino
Local nPosDDes	:= 8	//Descricao do Produto Destino
Local nPosUMDes	:= 9	//Unidade de Medida Destino
Local nPosLOCDes	:= 10	//Armazem Destino
Local nPosLcZDes	:= 11	//Localizacao Destino
Local nPosNSer	:= 12	//Numero de Serie
Local nPosLoTCTL	:= 13	//Lote de Controle
Local nPosNLOTE	:= 14	//Numero do Lote
Local nPosDTVAL	:= 15	//Data Valida
Local nPosPotenc	:= 16	//Potencia
Local nPosQUANT	:= 17	//Quantidade
Local nPosQTSEG	:= 18	//Quantidade na 2a. Unidade de Medida
Local nPosNumSeq	:= 19	//Sequencia
Local nPosLotDes	:= 20	//Lote Destino
Local nPosDtVldD	:= 21	//Data Validade Destino
Local nPosCAT83O	:= 0	//Cod.CAT 83 Prod.Origem
Local nPosCAT83D	:= 0   //Cod.CAT 83 Prod.Destino
Local nPosServic	:= 0
Local nPosPerImp	:= 0

Local oSize
Local cLotCtlQie	:= ''
Local cNumLotQie	:= ''
Local lVldEst		:= .F.
Local lCAT83		:= .F.
Local aBut261		:= {}
Local aLockSB2		:= {}
Local aLockSD3		:= {}
Local lContinua		:= .T.
Local cServico		:= ''
Local aCtbDia		:= {}
Local cAliasSBC		:= ""
Local cNrlote		:= ''
Local lMT261TRV		:= ExistBlock("MT261TRV")
Local lTravaReg		:= .T.
Local lExecSD3		:= If(!(Type('lExecWms')=='U'), lExecWms, .F.)
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lMA261In		:= (ExistBlock('MA261IN'))	//-- Atribui valores nos campos de usuario
Local lEstornaIt    := .F.
Local cMvPar        := "mv_par04"
Local xMvParBkp

Private cDocumento := SD3->D3_DOC
Private dA261Data  := SD3->D3_EMISSAO
Private aCols      := {}
Private aHeader    := {}
Private nOpcA      := 0

INCLUI := .F. //Vari�vel criada pois quando a fun��o � acionada por MsExecAuto a mesma n�o � criada
ALTERA := .F. //Vari�vel criada pois quando a fun��o � acionada por MsExecAuto a mesma n�o � criada


//������������������Ŀ
//� Portaria CAT83   |
//��������������������
If V240CAT83()
    lCAT83:=.T.
EndIf

//-- Verifica se est� na filial correta
If xFilial("SD3") # SD3->D3_FILIAL
	Help(' ',1,'A000FI')
	lContinua := .F.
EndIf

//-- S� Trabalha com Movimenta��es RE4/DE4
If lContinua .And. !SD3->D3_CF $ 'RE4�DE4'
	Help(' ',1,'A260NAO')
	lContinua := .F.
EndIf

If lContinua .And. SD3->D3_CF $ 'RE4�DE4'
	If SuperGetMV("MV_INTACD",.F.,"0") == "1" .and. USACB0('01')
		CB0->(dbsetorder(4))
		CB0->(Dbseek(xfilial('CB0')+'01'+SD3->D3_LOCAL+SD3->D3_COD))
		While CB0->(!EOF()) .and. CB0->CB0_FILIAL+'01'+CB0->CB0_LOCAL+CB0->CB0_CODPRO = xfilial('CB0')+'01'+SD3->D3_LOCAL+SD3->D3_COD
			If CB0->CB0_NUMSEQ == SD3->D3_NUMSEQ
			   Help(' ',1,'A260NAO')
				lContinua := .F.
				Exit
			EndiF
			CB0->(Dbskip())
		End do
	EndIf
EndIf

If lContinua

	cQuery 	:= "SELECT BC_FILIAL, BC_SEQSD3"
	cQuery 	+= " FROM " + RetSqlName("SBC") + " SBC "
	cQuery 	+= " WHERE BC_FILIAL = '"+xFilial("SD3")+"'"
	cQuery 	+= " AND BC_SEQSD3 = '"+SD3->D3_NUMSEQ+"'"
	cQuery 	+= " AND SBC.D_E_L_E_T_ = ' '"
	cAliasSBC 	:= CriaTrab(,.F.)
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBC,.T.,.T.)
	If !Empty((cAliasSBC)->BC_SEQSD3) .And. SD3->D3_CHAVE == "E0"
		lContinua := .F.
	Endif

	If !lContinua
		Help(' ',1,'A260NAO')
	EndIf

Endif

//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If dDataFec >= dDataBase .Or.;
		dDataFec >= SD3->D3_EMISSAO
	Help ( " ", 1, "FECHTO" )
	SetCursor(0)
	lContinua := .F.
EndIf

//�������������������������������������������������Ŀ
//�Verifica se o usuario tem permissao de exclusao. �
//���������������������������������������������������
aArea2 := GetArea()
aAreaSD3 := SD3->(GetArea())
SD3->(DbSetorder(2))
SD3->(dbSeek(xFilial("SD3")+cDocumento))
While !SD3->(Eof()) .And. lContinua .And. SD3->D3_DOC == cDocumento
	lContinua := MaAvalPerm(1,{SD3->D3_COD,"MTA260",5})
	SD3->(dbSkip())
End
RestArea(aAreaSD3)
RestArea(aArea2)
If !lContinua
	Help(,,1,'SEMPERM')
EndIf

//���������������������������������������������������������������Ŀ
//� Verifica calend�rio cont�bil                �
//�����������������������������������������������������������������
If lContinua
	lContinua := (CtbValiDt(Nil,SD3->D3_EMISSAO,,Nil ,Nil ,{"EST001"}))
EndIf

If lContinua
	//����������������������������������������������������������������������Ŀ
	//� Inicializa variaveis para campos Memos Virtuais                  	 �
	//������������������������������������������������������������������������
	If Type("aMemos")=="A" .And. Len(aMemos) > 0
		For nMem :=1 To Len(aMemos)
			cMemo := aMemos[nMem][2]
			cDescMemo := aMemos[nMem][3]
			If ExistIni(cMemo)
				&cMemo := InitPad(SX3->X3_RELACAO)
			Else
				&cMemo := ""
			EndIf
		Next nMem
	EndIf
	//-- Campo que pode ser alterado na GetDados
	aAdd(aAlter, 'D3_ESTORNO')

	//��������������������������������������Ŀ
	//� Montagem do AHeader (Estorno)        �
	//����������������������������������������
	aHeader := {}
	aTam := TamSX3('D3_ESTORNO'); Aadd(aHeader, {STR0022, 'D3_ESTORNO', PesqPict('SD3', 'D3_ESTORNO', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Estornado'
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0006, 'D3_COD'    , PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A261VldCod(1)', USADO, 'C', 'SD3', ''}) // 'Prod.Orig.'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0007, 'D3_DESCRI' , PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Desc.Orig.'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0008, 'D3_UM'     , PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'UM Orig.'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0009, 'D3_LOCAL'  , PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(1)' , USADO, 'C', 'SD3', ''}) // 'Almox Orig.'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0010, 'D3_LOCALIZ', PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(1)', USADO, 'C', 'SD3', ''}) // 'Localiz.Orig.'
	aTam := TamSX3('D3_COD'    ); Aadd(aHeader, {STR0011, 'D3_COD'    , PesqPict('SD3', 'D3_COD'    , aTam[1]         ), aTam[1], aTam[2], 'A261VldCod(2)', USADO, 'C', 'SD3', ''}) // 'Prod.Destino'
	aTam := TamSX3('D3_DESCRI' ); Aadd(aHeader, {STR0012, 'D3_DESCRI' , PesqPict('SD3', 'D3_DESCRI' , aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Desc.Destino'
	aTam := TamSX3('D3_UM'     ); Aadd(aHeader, {STR0013, 'D3_UM'     , PesqPict('SD3', 'D3_UM'     , aTam[1], aTam[1]), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'UM Destino'
	aTam := TamSX3('D3_LOCAL'  ); Aadd(aHeader, {STR0014, 'D3_LOCAL'  , PesqPict('SD3', 'D3_LOCAL'  , aTam[1]         ), aTam[1], aTam[2], 'A261Almox(2)' , USADO, 'C', 'SD3', ''}) // 'Almox Destino'
	aTam := TamSX3('D3_LOCALIZ'); Aadd(aHeader, {STR0015, 'D3_LOCALIZ', PesqPict('SD3', 'D3_LOCALIZ', aTam[1]         ), aTam[1], aTam[2], 'A261Locali(2)', USADO, 'C', 'SD3', ''}) // 'Localiz.Destino'
	aTam := TamSX3('D3_NUMSERI'); Aadd(aHeader, {STR0016, 'D3_NUMSERI', PesqPict('SD3', 'D3_NUMSERI', aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'N�mero Serie'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0018, 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1]     )	, aTam[1], aTam[2], 'A261Lote(1)'  , USADO, 'C', 'SD3', ''}) // 'Lote'
	aTam := TamSX3('D3_NUMLOTE'); Aadd(aHeader, {STR0017, 'D3_NUMLOTE', PesqPict('SD3', 'D3_NUMLOTE', aTam[1]     )	, aTam[1], aTam[2], 'A261Lote(1)'  , USADO, 'C', 'SD3', ''}) // 'Sub-Lote'
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0019, 'D3_DTVALID', PesqPict('SD3', 'D3_DTVALID', aTam[1]     )	, aTam[1], aTam[2], ''             , USADO, 'D', 'SD3', ''}) // 'Validade'
	aTam := TamSX3('D3_POTENCI'); Aadd(aHeader, {STR0039, 'D3_POTENCI', PesqPict('SD3', 'D3_POTENCI', aTam[1]     )	, aTam[1], aTam[2], ''             , USADO, 'N', 'SD3', ''}) // 'Potencia'
	aTam := TamSX3('D3_QUANT'  ); Aadd(aHeader, {STR0020, 'D3_QUANT'  , PesqPict('SD3', 'D3_QUANT'  		            )	, aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Quantidade'
	aTam := TamSX3('D3_QTSEGUM'); Aadd(aHeader, {STR0021, 'D3_QTSEGUM', PesqPict('SD3', 'D3_QTSEGUM'			        )	, aTam[1], aTam[2], 'A261Quant(.T.)'  , USADO, 'N', 'SD3', ''}) // 'Qt 2aUM'
	aTam := TamSX3('D3_NUMSEQ' ); Aadd(aHeader, {STR0028, 'D3_NUMSEQ' , PesqPict('SD3', 'D3_NUMSEQ' , aTam[1]         )	, aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Sequencia'
	aTam := TamSX3('D3_LOTECTL'); Aadd(aHeader, {STR0044, 'D3_LOTECTL', PesqPict('SD3', 'D3_LOTECTL', aTam[1]     )	, aTam[1], aTam[2], ''   , USADO, 'C', 'SD3', ''})
	aTam := TamSX3('D3_DTVALID'); Aadd(aHeader, {STR0046,'D3_DTVALID'	, PesqPict('SD3', 'D3_DTVALID', aTam[1]    )	, aTam[1], aTam[2], 'A261DtPot(3)' , USADO, 'D', 'SD3', ''}) // 'Validade Destino'
	//-- Tratamento dos campos para utilizacao do SIGAWMS
	If	a261IntWMS()
		aTam := TamSX3('D3_SERVIC'); Aadd(aHeader, {RetTitle('D3_SERVIC'), 'D3_SERVIC', PesqPict('SD3', 'D3_SERVIC', aTam[1]      ), aTam[1], aTam[2], ''  , USADO, 'C', 'SD3', ''})
		nPosServic := aScan(aheader,{|x| Alltrim(x[2])=="D3_SERVIC"})
	EndIf
	aTam := TamSX3('D3_ITEMGRD' ); Aadd(aHeader, {STR0055, 'D3_ITEMGRD' , PesqPict('SD3', 'D3_ITEMGRD' , aTam[1]      )	, aTam[1], aTam[2], ''             , USADO, 'C', 'SD3', ''}) // 'Sequencia'
	nPosGrade := ascan(aheader,{|x| Alltrim(x[2])=="D3_ITEMGRD"})

	//������������������Ŀ
	//� Portaria CAT83   |
	//��������������������
	If lCAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0065,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // Cod.CAT83
		aTam := TamSX3('D3_CODLAN'); Aadd(aHeader, {STR0066,'D3_CODLAN', PesqPict('SD3','D3_CODLAN', aTam[1]), aTam[1], aTam[2], '' , USADO, 'C', 'SD3', ''}) // Cod.CAT83
		nPosCAT83O  := aScan(aheader,{|x| Alltrim(x[2])=="D3_CODLAN"})
		nPosCAT83D  := IIF(nPosCAT83O>0,nPosCAT83O+1,0)
	EndIf

	//������������������Ŀ
	//� Percentual FCI   |
	//��������������������
	If nFCICalc == 1
		aTam := TamSX3('D3_PERIMP'  ); Aadd(aHeader, {"Per. Imp.", 'D3_PERIMP'  	, PesqPict('SD3', 'D3_PERIMP'), aTam[1], aTam[2], 'A250VlPImp()', USADO, 'N', 'SD3', ''}) // 'Percentual Importacao'
		nPosPerImp  := aScan(aheader,{|x| Alltrim(x[2])=="D3_PERIMP"})    //Percental Importacao
	EndIf

	If Type("aMemos")=="A" .And. Len(aMemos) > 0
		aTam := TamSX3(cMemo);Aadd(aHeader, {cDescMemo, cMemo, PesqPict('SD3', cMemo, aTam[1]         ), aTam[1], aTam[2], ''             , USADO, 'M', 'SD3', ''})	// CAMPOS MEMO
	EndIf
	//-- ExecBlock para incluir campos no aHeader
	If lMA261Cpo
		ExecBlock('MA261CPO',.F.,.F.)
	EndIf

	ADHeadRec(cAlias,aHeader)

	//-- Posicionamento das Ordens utilizadas na fun��o
	SB1->(dbSetOrder(1))
	SD3->(dbSetOrder(8))

	// Pergunta cadastrada a partir do release 12.1.2210 (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
	If cPaisLoc == "ANG" .Or. cPaisLoc == "EQU" .Or. cPaisLoc == "HAI" .Or. cPaisLoc == "PTG"
		cMvPar := "mv_par05"
	EndIf
	xMvParBkp := &cMvPar
	&cMvPar := ""
	Pergunte("MTA260",.F.)
	If !Empty(&cMvPar)
		lEstornaIt := (&cMvPar == 2)
	Else
		&cMvPar := xMvParBkp
	EndIf

	//��������������������������������������Ŀ
	//� Montagem do ACols (Estorno)          �
	//����������������������������������������
	aCols   := {}
	aRecnos := {}
	cNumSeq := If(lEstornaIt .Or. Empty(SD3->D3_DOC),SD3->D3_NUMSEQ,'�')

	cSeek := If(lEstornaIt .Or. Empty(SD3->D3_DOC),xFilial('SD3')+cDocumento+cNumseq,xFilial('SD3')+cDocumento)

	If !SD3->(dbSeek( cSeek,.F.))
		Help(' ',1,'A260NAO')
		lContinua := .F.
	EndIf
EndIf
Do While lContinua .And. !SD3->(Eof()) .And. cSeek == SD3->D3_FILIAL+SD3->D3_DOC+If(lEstornaIt .Or. Empty(SD3->D3_DOC),SD3->D3_NUMSEQ,"")
	If Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'RE4�DE4' 
		aAdd(aCols, Array(Len(aHeader)))
		cNumSeq := SD3->D3_NUMSEQ
	Else
		SD3->(dbSkip())
		Loop
	EndIf
	Do While !SD3->(Eof()) .And. cNumSeq == SD3->D3_NUMSEQ
		If Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'RE4'
			//��������������������������������������������������������������������������Ŀ
			//� AvalMovDiv - Funcao utilizada para avaliar possiveis divergencias de     |
			//|              saldo no estorno do movimento selecionado.                  �
			//����������������������������������������������������������������������������
			If AvalMovDiv(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,SD3->D3_NUMSEQ)
				Return
			EndIf
			//-- Posiciona o Arquivo de Produtos (SB1)
			If !SB1->(dbSeek(xFilial('SB1')+SD3->D3_COD,.F.))
				Help(' ', 1, 'REGNOIS')
				lContinua := .F.
				Exit
			EndIf
			cCFAnt := SD3->D3_CF
			Aadd(aRecnos,{ SD3->(Recno()),Len(aCols) })
			aCols[Len(aCols),nPosEstor]     := 'S'
			aCols[Len(aCols),nPosCODOri]    := SD3->D3_COD
			aCols[Len(aCols),nPosDOri]      := SB1->B1_DESC
			aCols[Len(aCols),nPosUMOri]     := SD3->D3_UM
			aCols[Len(aCols),nPosLOCOri]    := SD3->D3_LOCAL
			aCols[Len(aCols),nPosQUANT]     := SD3->D3_QUANT
			aCols[Len(aCols),nPosQTSEG]     := SD3->D3_QTSEGUM
			aCols[Len(aCols),nPosNumSeq]    := cNumSeq
			aCols[Len(aCols),nPosGrade]     := SD3->D3_ITEMGRD
			aCols[Len(aCols),nPosLcZOri]:= SD3->D3_LOCALIZ
			aCols[Len(aCols),nPosNSer]  := SD3->D3_NUMSERI
			aCols[Len(aCols),nPosLoTCTL]:= SD3->D3_LOTECTL
			aCols[Len(aCols),nPosNLOTE] := SD3->D3_NUMLOTE
			aCols[Len(aCols),nPosDTVAL] := SD3->D3_DTVALID
			aCols[Len(aCols),nPosPotenc]:= SD3->D3_POTENCI
			If	nPosServic > 0
				aCols[Len(aCols),nPosServic] := SD3->D3_SERVIC
			EndIf

			If nPosCAT83O>0
				aCols[Len(aCols),nPosCAT83O]:= SD3->D3_CODLAN
			EndIf

			//������������������������������������������������������������������������Ŀ
			//� Tratamento para Dead-Lock                                              �
			//��������������������������������������������������������������������������
			If aScan(aLockSD3,SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)==0
				Aadd(aLockSD3,SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)
			EndIf
			If aScan(aLockSB2,SD3->D3_COD+SD3->D3_LOCAL)==0
				aadd(aLockSB2,SD3->D3_COD+SD3->D3_LOCAL)
			EndIf
		ElseIf Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF $ 'DE4'
			//-- Posiciona o Arquivo de Produtos (SB1)
			If !SB1->(dbSeek(xFilial('SB1')+SD3->D3_COD,.F.))
				Help(' ', 1, 'REGNOIS')
				lContinua := .F.
				Exit
			EndIf
			//-- Verifica se o saldo do armz esta bloqueado
			If !SldBlqSB2(SD3->D3_COD,SD3->D3_LOCAL)
				lContinua := .F.
				Exit
			EndIf
			Aadd(aRecnos,{ SD3->(Recno()),Len(aCols) })
			aCols[Len(aCols),nPosCODDes]		:= SD3->D3_COD
			aCols[Len(aCols),nPosDDes]			:= SB1->B1_DESC
			aCols[Len(aCols),nPosUMDes]			:= SD3->D3_UM
			aCols[Len(aCols),nPosLOCDes]		:= SD3->D3_LOCAL
			aCols[Len(aCols),nPosLcZDes]	:= SD3->D3_LOCALIZ
			aCols[Len(aCols),nPosLotDes]	:= SD3->D3_LOTECTL
			aCols[Len(aCols),nPosDtVldD]	:= SD3->D3_DTVALID
			If	nPosServic > 0
				aCols[Len(aCols),nPosServic] := SD3->D3_SERVIC
			EndIf

			If nPosCAT83D>0
				aCols[Len(aCols),nPosCAT83D]:= SD3->D3_CODLAN
			EndIf
			If nFCICalc == 1
				aCols[Len(aCols),nPosPerImp]:= SD3->D3_PERIMP
			EndIf
            If Rastro(SD3->D3_COD,'S')
	            cNumLotRE4 := SD3->D3_NUMLOTE
	        Else
	        	cNumLotRE4 := Nil
	        EndIf
			//������������������������������������������������������������������������Ŀ
			//� Tratamento para Dead-Lock                                              �
			//��������������������������������������������������������������������������
			If aScan(aLockSD3,SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)==0
				Aadd(aLockSD3,SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)
			EndIf
			If aScan(aLockSB2,SD3->D3_COD+SD3->D3_LOCAL)==0
				aadd(aLockSB2,SD3->D3_COD+SD3->D3_LOCAL)
			EndIf
		EndIf

		//���������������������������������������������������������Ŀ
		//� Verificando Data de origem do lote                      �
		//�����������������������������������������������������������


		aCols[Len(aCols)][Len(aHeader)-1] := "SD3"
		aCols[Len(aCols)][Len(aHeader)]	  := SD3->(RecNo())

		SD3->(dbSkip())
		If !Empty(aCols[Len(aCols),nPosCODOri]) .And. !Empty(aCols[Len(aCols),nPosCODDes])
			Exit
		EndIf
	EndDo
	If !lContinua
		Exit
	EndIf
	If Empty(aCols[Len(aCols),nPosCODOri]) .Or. Empty(aCols[Len(aCols),nPosCODDes])
		Help(' ',1,'A260NAO')
		lContinua := .F.
		Exit
	EndIf
	//���������������������������������������������������������Ŀ
	//� Validacao WMS.                                          �
	//�����������������������������������������������������������
	If	lContinua .And. a261IntWMS(aCols[Len(aCols),nPosCODDes])
		If !lWmsNew
			//-- Validar Servico WMS de transferencia quando informado.
			If	nPosServic > 0 .And. !Empty(cServico := aCols[Len(aCols),nPosServic])
				//A ordem de servi�o WMS � gerada para o local destino
				If WmsChkDCF('SD3',,,cServico,'3',,cDocumento,,,,aCols[Len(aCols),nPosLOCDes],aCols[Len(aCols),nPosCODDes],,,cNumSeq)
					lContinua := WmsAvalDCF('2')
				EndIf
			EndIf
			If lContinua .And. (SuperGetMV('MV_WMSVLDT',.F.,.T.)==.T.)
				//No estorno o destino deve ser assumido como a origem
				If !WmsVldDest(aCols[Len(aCols),nPosCODOri],aCols[Len(aCols),nPosLOCOri],aCols[Len(aCols),nPosLcZOri],aCols[Len(aCols),nPosLoTCTL],aCols[Len(aCols),nPosNLOTE],aCols[Len(aCols),nPosNSer],aCols[Len(aCols),nPosQUANT])
					lContinua := .F.
				EndIf
			EndIf
		ElseIf !lExecSD3
			// Valida��o [NOVO WMS]
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
			If oOrdSerDel:LoadData()
				If !oOrdSerDel:CanDelete()
					Help( ,1,"SIGAWMS",,oOrdSerDel:GetErro(),1,0)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	//-- ExecBlock para atribuir valores nos campos de usuario
	If lMA261In
		ExecBlock('MA261IN',.F.,.F.)
	EndIf
EndDo

If lContinua .And. Len(aCols) == 0
	Help(' ',1,'A240ESTORN')
	lContinua := .F.
EndIf

If lContinua
	SD3->(dbSetOrder(2))

	//�����������������������������������������������������Ŀ
	//� Verifica se algum produto est� sendo inventariado.  �
	//�������������������������������������������������������
	For nX := 1 to Len(aCols)
		If BlqInvent(aCols[nX,nPosCODOri],aCols[nX,nPosUMOri],,aCols[nX,nPosLcZOri])
			Help(' ',1,'BLQINVENT',,aCols[nX,nPosCODOri]+STR0054+aCols[nX,nPosUMOri],1,11) //' Almox: '
			lContinua := .F.
			Exit
		EndIf
		If lContinua .And. BlqInvent(aCols[nX,nPosCODDes],aCols[nX,nPosLOCDes],,aCols[nX,nPosLcZDes])
			Help(' ',1,'BLQINVENT',,aCols[nX,nPosCODDes]+STR0054+aCols[nX,nPosLOCDes],1,11) //' Almox: '
			lContinua := .F.
			Exit
		EndIf
		//�����������������������������������������������������Ŀ
		//� Analisa se o tipo do armazem permite a movimentacao |
		//�������������������������������������������������������
		If lContinua .And. AvalBlqLoc(aCols[nX,nPosCODOri],aCols[nX,nPosLOCOri],Nil,,aCols[nX,nPosCODDes],aCols[nX,nPosLOCDes])
			lContinua := .F.
			Exit
		EndIf
		//�����������������������������������������������������Ŀ
		//� Verifica se o produto destino tem saldo p/ estornar �
		//�������������������������������������������������������
		SD3->(Dbgoto(aCols[nx,len(acols[nx])]))         //posiciona no SD3 em foco para pegar o numlote correto.
		cNrlote:=SD3->D3_NUMLOTE
		If !MatVldEst(aCols[nx,nPosCODDes],;
			aCols[nx,nPosLOCDes],;
			aCols[nx,nPosLoTDes],;
			cNrlote,;
			If(Empty(cServico),aCols[nx,nPosLcZDes],""),;
				aCols[nx,nPosNSer],;
				aCols[nx,nPosNumSeq],;
				cDocumento,;
				aCols[nx,nPosQUANT])
			lContinua := .F.
			Exit
		EndIf
	Next nX
EndIf

If lContinua
	If ! lAutoma261
		//��������������������������������������������������������������Ŀ
		//� Calcula dimens�es                                            �
		//����������������������������������������������������������������
		oSize := FwDefSize():New()

		oSize:AddObject( "CIMA"  ,  100,  5, .T., .T.) // Nao dimensiona Y
		oSize:AddObject( "BAIXO",  100, 95, .T., .T.) // Totalmente dimensionavel

		oSize:lProp := .T. // Proporcional
		oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() // Dispara os calculos

       nOpcX := 5
		nOpcA := 0
		//��������������������������������������������������������������Ŀ
		//� Executa ponto de entrada para montar array com botoes a      �
		//� serem apresentados na tela                                   �
		//����������������������������������������������������������������
		If (ExistBlock("M261BCHOI"))
			aBut261:=ExecBlock("M261BCHOI",.F.,.F.)
			If ValType(aBut261) # "A"
				aBut261:={}
			EndIf
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Monta Dialog                                                 �
		//����������������������������������������������������������������
		DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"Transferencia Mod2"
							FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		//��������������������������������������������������������������Ŀ
		//� Adiciona Panel                                               �
		//����������������������������������������������������������������
		oPanel1:= tPanel():New(oSize:GetDimension("CIMA","LININI"),oSize:GetDimension("CIMA","COLINI"),,oDlg,,,,,,oSize:GetDimension("CIMA","XSIZE"),oSize:GetDimension("CIMA","YSIZE"),,)
		oPanel2:= tPanel():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),,oDlg,,,,,,oSize:GetDimension("BAIXO","XSIZE"),oSize:GetDimension("BAIXO","YSIZE"),,)

		@ 0,0 SAY   OemToAnsi(STR0023) OF oPanel1 PIXEL // 'N�mero Documento'
		@ 0,50 MSGET cDocumento When .F. SIZE 70,08 OF oPanel1 PIXEL
		@ 0,125 SAY   OemToAnsi(STR0024) OF oPanel1 PIXEL // 'Emiss�o'
		@ 0,150 MSGET dA261Data When .F. SIZE 40,08 OF oPanel1 PIXEL

		//��������������������������������������������������������������Ŀ
		//�Ponto de Entrada que disponibiliza o Objeto da Dialog        �
		//����������������������������������������������������������������
		If (ExistBlock( "MT261CAB" ))
			ExecBlock("MT261CAB",.F.,.F.,{@oPanel1,0,nOpcx})
		EndIf

		oGet := MSGetDados():New(oSize:GetDimension("BAIXO","LININI"),oSize:GetDimension("BAIXO","COLINI"),oSize:GetDimension("BAIXO","LINEND"),oSize:GetDimension("BAIXO","COLEND"),;
								nOpcX,'AllwaysTrue','AllwaysTrue','',;
								,aAlter,NIL,NIL,;
								LINHAS,,,,,,,,,oPanel2)


		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End(),If(oGet:TudoOK(),nOpcA:=2,nOpcA := 0)},{||oDlg:End()},,aBut261)
	Else
		nOpcA := 2
	EndIf
	For nX := 1 to Len(aCols)
		SD3->(Dbgoto(aCols[nx,len(acols[nx])]))   //posiciona no SD3 em foco para pegar o numlote correto.
		cNrlote:=SD3->D3_NUMLOTE
		lVldEst := MatVldEst(aCols[nx,nPosCODDes],aCols[nx,nPosLOCDes],aCols[nx,nPosLoTDes],cNrlote,If(Empty(cServico),aCols[nx,nPosLcZDes],""),aCols[nx,nPosNSer],aCols[nx,nPosNumSeq],cDocumento,aCols[nx,nPosQUANT])
		If !lVldEst
			Exit
		EndIf
	Next

	If nOpcA == 2 .And. lVldEst
		aDelSD7 := {}
		If A261EstrOK(cDocumento,@aDelSD7)
			//������������������������������������������������������������������������Ŀ
			//� Tratamento para Dead-Lock                                              �
			//��������������������������������������������������������������������������
			If lMT261TRV
				lTravaReg := ExecBlock("MT261TRV",.F.,.F.,{aLockSB2,aLockSD3})
				If ValType(lTravaReg) # "L"
					lTravaReg := .T.
				EndIf
			EndIf
			If If(lTravaReg, MultLock("SB2",aLockSB2,1) .And. MultLock("SD3",aLockSD3,3), .T.)


				For nX := 1 to Len(aRecnos)
					If aCols[aRecnos[nX,2],nPosEstor] == 'S'
						dbSelectArea('SD3')
						SD3->(dbGoTo(aRecnos[nX,1]))
						aSD3Area[3] := SD3->(Recno())

						//-- Verifica se algum produto utiliza CQ Celerina
						lEstQualy := .F.
						For nY := 1 to Len(aCols)
							If SB1->(dbSeek(xFilial('SB1') + aCols[nY, nPosCODDes], .F.)) .And. ;
									RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q' .And. aCols[nY, nPosLOCDes] == cLocCQ
								lEstQualy := .T.
								Exit
							EndIf
						Next nY

						Begin Transaction
							RecLock('SD3',.F.)
							A261DesAtu()
							SD3->(MsUnlock())
						End Transaction

					EndIf
				Next nX
				nDelSD7 := 0
				For nX := 1 to Len(aDelSD7)
					SD7->(dbGoto(aDelSD7[nX]))

					lEstQualy := (SB1->(dbSeek(xFilial('SB1')+SD7->D7_PRODUTO, .F.)) .And.;
						(RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=="Q"))

					If lEstQualy

						//��������������������������������������������������������������Ŀ
						//� Exclus�o do CQ no SigaQIE                                    �
						//����������������������������������������������������������������

						//��������������������������������������������������������������Ŀ
						//�Posiciona o registro no SD5 para que o LOTECTL+NUMLOTE seja en�
						//�viado para qAtuMatQie()										 �
						//����������������������������������������������������������������
						If Rastro(SD7->D7_PRODUTO,"L") .Or. Rastro(SD7->D7_PRODUTO,"S")
							aAreaSD5 := SD5->(GetArea())
							SD5->(dbSetOrder(3))
							If SD5->(dbSeek(xFilial('SD5')+SD7->D7_NUMSEQ+SD7->D7_PRODUTO+SD7->D7_LOCAL+SD7->D7_LOTECTL, .F.))
								cLotCtlQie := SD5->D5_LOTECTL
								cNumLotQie := SD5->D5_NUMLOTE
							EndIf
							SD5->(dbSetOrder(aAreaSD5[2]))
							SD5->(dbGoto(aAreaSD5[3]))
						EndIf

						aEnvCele := {SD7->D7_DOC			,; //Numero da Nota Fiscal
							SD7->D7_SERIE					,; //Serie da Nota Fiscal
							"N"								,; //Tipo da Nota Fiscal
							SD7->D7_DATA					,; //Data de Emissao da Nota Fiscal
							SD7->D7_DATA					,; //Data de Entrada da Nota Fiscal
							"NF"							,; //Tipo de Documento
							Space(TamSX3("D1_ITEM")[1])		,; //Item da Nota Fiscal
							Space(TamSX3("D1_REMITO")[1])	,; //Numero do Remito (Localizacoes)
							Space(TamSX3("D1_PEDIDO")[1])	,; //Numero do Pedido de Compra
							Space(TamSX3("D1_ITEMPC")[1])	,; //Item do Pedido de Compra
							SD7->D7_FORNECE					,; //Codigo Fornecedor/Cliente
							SD7->D7_LOJA					,; //Loja Fornecedor/Cliente
							SD7->D7_LOTECTL					,; //Numero do Lote do Fornecedor
							Space(TamSX3("QEK_SOLIC")[1])	,; //Codigo do Solicitante
							SD7->D7_PRODUTO					,; //Codigo do Produto
							SD7->D7_LOCAL					,; //Local Origem
							cLotCtlQie						,; //Numero do Lote
							cNumLotQie						,; //Sequencia do Sub-Lote
							SD7->D7_NUMSEQ					,; //Numero Sequencial
							SD7->D7_NUMERO					,; //Numero do CQ
							SD7->D7_SALDO					,; //Quantidade
							0								,; //Preco
							0								,; //Dias de atraso
							" "								,; //TES
							AllTrim(FunName())				,; //Origem
							" "								,; //Origem TXT
							PadR(0,15)}				           //Tamanho do lote original

						//��������������������������������������������������������������Ŀ
						//� Realiza a exclusao do material enviado para Inspecao	     �
						//����������������������������������������������������������������
						aRecCele := qAtuMatQie(aEnvCele,2)

					EndIf

					SD7->(dbGoto(aDelSD7[nX]))
					RecLock('SD7', .F.)
					dbDelete()
					MsUnlock()
					nDelSD7 ++
				Next nX
			Else
				ConOut("WARNING: DEADLOCK CONTROL IS ON")
			EndIf
			If nDelSD7 > 0
				SD7->(WriteSX2('SD7', nDelSD7))
			EndIf
		EndIf
	EndIf

	If cCusMed == 'O' .And. nTotal <> 0
		If !lCriaHeade
			//��������������������������������������������������������������Ŀ
			//� Se ele criou o arquivo de prova ele deve gravar o rodape'    �
			//����������������������������������������������������������������
			//����������������������������������������������������������������Ŀ
			//� mv_par01 - Se mostra e permite digitar lancamentos contabeis   �
			//� mv_par02 - Se deve aglutinar os lancamentos contabeis          �
			//������������������������������������������������������������������
			n := 1
			RodaProva(nHdlPrv,nTotal)
			If !Empty(aCtbDia)
				cCodDiario := CtbaVerdia()
				For nX := 1 to Len(aCtbDia)
					aCtbDia[nX][3] := cCodDiario
				Next nX
			EndIf
			cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,lAglutina,,,,,,aCtbDia)
			lCriaHeade := .T.
		EndIf
	EndIf
EndIf
If nOpca == 0 .And. (ExistBlock("MTA261CAN"))
	//��������������������������������������������������������������Ŀ
	//�Executa P.E. ao sair sem gravar 				                 �
	//����������������������������������������������������������������
	ExecBlock("MTA261CAN",.F.,.F.,{nOpcx})
EndIf
//-- Retorna a integridade do Sistema
RestArea(aSB1Area)
RestArea(aSD3Area)
RestArea(aSD7Area)
RestArea(aArea)

Return nOpcA

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                                                                       ���
���                                                                       ���
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
���                                                                       ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a261TudOk � Autor � Marcelo Pimentel      � Data �30/01/98  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a Transferencia est� Ok.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261TudOK(ExpO1,ExpN1) 		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto a ser verificado.                           ���
���          � ExpN1 = numero do registro			                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function a261TudoOk(o,nLinha)
Static lPontoEntr := NIL
Local lRet        := .T.
Local nX		  := 0
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri	:= 1 	//Codigo do Produto Origem
Local nPosLOCOri	:= 4	//Armazem Origem
Local nPosLcZOri	:= 5	//Localizacao Origem
Local nPosCODDes	:= 6	//Codigo do Produto Destino
Local nPosLOCDes	:= 9	//Armazem Destino
Local nPosLcZDes	:= 10	//Localizacao Destino
Local nPosNSer	:= 11	//Numero de Serie
Local nPosLoTCTL	:= 12	//Lote de Controle
Local nPosNLOTE	:= 13	//Numero do Lote
Local nPosQUANT	:= 16	//Quantidade
Local nPosCTLDes	:= 20	//Lote de Controle Destino
Default nLinha 	:= n

//��������������������������������������������������������������Ŀ
//� Verifica se existe ponto de entrada para validacao           �
//����������������������������������������������������������������
If (lPontoEntr == NIL)
	lPontoEntr := ExistBlock("A261TOK")
EndIf

If !aCols[nLinha,Len(aCols[nLinha])]
	If Empty(aCols[nLinha,nPosCODOri]) .Or. Empty(aCols[nLinha,nPosLOCOri]) .Or. ;
			Empty(aCols[nLinha,nPosCODDes]) .Or. Empty(aCols[nLinha,nPosLOCDes]) .Or. Empty(aCols[nLinha,nPosQUANT])
		Help(' ',1,'MA260OBR')
		lRet := .F.
	EndIf
	If lRet
		For nX := 1 To Len(aCols)
			If nX # nLinha .And. !aCols[nx,Len(aCols[nx])] .And. aCols[nLinha,nPosCODOri]+aCols[nLinha,nPosLOCOri]+aCols[nLinha,nPosCODDes]+aCols[nLinha,nPosLOCDes]+aCols[nLinha,nPosNSer]+aCols[nLinha,nPosNLOTE]+aCols[nLinha,nPosLoTCTL]+aCols[nLinha,nPosLcZOri]+aCols[nLinha,nPosLcZDes]+aCols[nLinha,nPosCTLDes] == aCols[nX,nPosCODOri]+aCols[nX,nPosLOCOri]+aCols[nX,nPosCODDes]+aCols[nX,nPosLOCDes]+aCols[nX,nPosNSer]+aCols[nX,nPosNLOTE]+aCols[nX,nPosLoTCTL]+aCols[nX,nPosLcZOri]+aCols[nX,nPosLcZDes]+aCols[nX,nPosCTLDes]
				Help(' ',1,'A242JACAD')
				lRet := .F.
			EndIf

			//�����������������������������������������������������Ŀ
			//� Validacao do Custo FIFO On-Line                     |
			//�������������������������������������������������������
			If IsFifoOnLine()
				If SaldoSBD("SD3",aCols[nLinha,nPosCODOri],aCols[nLinha,nPosLOCOri],dDataBase,.F.)[1] < aCols[nLinha,nPosQUANT]
					Help(" ",1,"DIVFIFO2")
					lRet := .F.
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Executa ponto de entrada para validacao                      �
//����������������������������������������������������������������
If lRet .And. lPontoEntr
	lRet := ExecBlock("A261TOK",.F.,.F.)
	lRet := If(ValType(lRet)#"L",.T.,lRet)
EndIf

//���������������������������������������������������������������Ŀ
//� Verifica calend�rio cont�bil                �
//�����������������������������������������������������������������
If lRet
	lRet := (CtbValiDt(Nil,DA261DATA,,Nil ,Nil ,{"EST001"}))
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a261Grava � Autor � Marcelo Pimentel      � Data �05/02/98  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar os dados no arquivo                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261Grava(ExpC1,ExpN1)		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero da opcao selecionada                        ���
���          � ExpL1 = Valida se o no. do documento sera alterado         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Mata261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function a261Grava(cAlias,nOpcao,lChangeDoc,aRecSD3,aAutoItens)
Static lMA260NFQ := NIL

Local aArea      := GetArea()
Local aSD3Area   := SD3->(GetArea())
Local aSD7Area   := SD7->(GetArea())
Local aSX6Area   := SX6->(GetArea())
Local aAreaSD5   := SD5->(GetArea())
Local aCTBEnt	   := CTBEntArr()
Local nMaxArray  := 0
Local cNumSeq    := ''
Local cLocCQ     := GetMvNNR('MV_CQ','98')
Local lRet       := .T.
Local lQualyCQ   := .F.
Local nAtraso    := 0
Local aMov       := {}
Local aEnvCele   := {}
Local aRecCele   := {}
Local cForNFO    := ''
Local cLojNFO    := ''
Local cPedNFO    := ''
Local cDocNFO    := ''
Local cSerNFO    := ''
Local cTipNFO    := ''
Local cIPCNFO    := ''
Local cMay       := ''
Local nX		:= 0
Local nY		:= 0
Local nW		:= 0

//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri 	:= 1 	//Codigo do Produto Origem
Local nPosDOri		:= 2	//Descricao do Produto Origem
Local nPosUMOri		:= 3	//Unidade de Medida Origem
Local nPosLOCOri 	:= 4	//Armazem Origem
Local nPosLcZOri 	:= 5	//Localizacao Origem
Local nPosCODDes 	:= 6	//Codigo do Produto Destino
Local nPosUMDes		:= 8	//Unidade de Medida Destino
Local nPosLOCDes 	:= 9	//Armazem Destino
Local nPosLcZDes 	:= 10	//Localizacao Destino
Local nPosNSer		:= 11	//Numero de Serie
Local nPosLoTCTL	:= 12	//Lote de Controle
Local nPosNLOTE		:= 13	//Numero do Lote
Local nPosDTVAL		:= 14	//Data Valida
Local nPosPotenc 	:= 15	//Potencia do Lote
Local nPosQUANT		:= 16	//Quantidade
Local nPosQTSEG		:= 17	//Quantidade na 2a. Unidade de Medida
Local nPosDtVldD 	:= 21	//Data Valida de Destino
Local nPosServic 	:= aScan(aheader,{|x| Alltrim(x[2])=="D3_SERVIC"})
Local nPosCAT83O	:= aScan(aheader,{|x| Alltrim(x[2])=="D3_CODLAN"})    //Cod.CAT 83 Prod.Origem
Local nPosCAT83D	:= IIF(nPosCAT83O>0,nPosCAT83O+1,0)					 //Cod.CAT 83 Prod.Destino
Local nPosPerImp	:= aScan(aheader,{|x| Alltrim(x[2])=="D3_PERIMP"})    //Percental Importacao
Local nPosIDDCF		:= aScan(aheader,{|x| Alltrim(x[2])=="D3_IDDCF"})
Local nPosNumSeq	:= Iif(!__lPyme,19,16)	//Sequencia
Local nQtdOri		:= 0
Local cItemNF		:= " "
Local cDocEnt		:= ''
Local dNotFis		:= cTOD('')
Local nPreco		:= 0
Local lQtdRep		:= If(GetMV("MV_QTRFREP")=="S",.T.,.F.)  // variavel desnecessaria para integra��o QIExEST
Local cCodEIC		:= SubStr(GetMv('MV_PRODIMP'),1,Len(SB1->B1_COD))
Local cLotCtlQie	:= ''
Local cNumLotQie	:= ''
Local cServico		:= ''
Local cNumDesp		:= ''
Local cLoteFor		:= ''
Local nLoop 		:= 0
Local aLockSB2		:= {}
Local aItenSD3		:= {{}}
Local cMemo
Local nMem
Local lFirstNum		:= .T.
Local lCAT83		:= .F.
Local lMtNLote 		:= If(SuperGetMV("MV_MTNLOTE",,"N")=="S",.T.,.F.)
Local lMantemLot	:= .F.
Local lMA261TRD3 	:= ExistBlock("MA261TRD3")
Local lExecSD3		:= If(!(Type('lExecWms')=='U'), lExecWms, .F.)
Local lWmsNew		:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lValLote		:= .T.
Local cDocWMS		:= ""
Local lMT260NLOT	:= ExistBlock('MT260NLOT')	//-- Op��o para o tipo de SubLote
Local lAtuEti		:= .F.
Local cLotVenc 	  	:= SuperGetMv("MV_LOTVENC",.F.,"S")
Local lLtVcCQ		:= NIL
Local lRastroL		:= .F.
Local lRastroS 		:= .F.

If Type('N')=='U'
	Private N := 0
EndIf

DEFAULT lChangeDoc := .F.
DEFAULT aRecSD3    := {}

lRastroL  := Rastro(aCols[n,nPosCODOri],'L')
lRastroS  := Rastro(aCols[n,nPosCODOri],'S')

//������������������Ŀ
//� Portaria CAT83   |
//��������������������
If V240CAT83()
    lCAT83:=.T.
EndIf

lMA260NFQ := If(lMA260NFQ==NIL,ExistBlock("MA260NFQ"),lMA260NFQ)
//��������������������������������������������������������������Ŀ
//� Verifica se o ultimo elemento do array esta em branco        �
//����������������������������������������������������������������
nMaxArray := Len(aCols)
For nY := 1 to Len(aHeader)
	If Empty(aCols[nMaxArray, nY])
		If Upper(AllTrim(aHeader[nY,2])) == 'D3_QUANT'
			nMaxArray--
			Exit
		EndIf
	EndIf
Next nY
//����������������������������������������������������������������������Ŀ
//� Inicializa variaveis para campos Memos Virtuais         			 �
//������������������������������������������������������������������������
If Type("aMemos")=="A" .And. Len(aMemos) > 0
	For nMem :=1 To Len(aMemos)
		cMemo := aMemos[nMem][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next nMem
EndIf

//-- Verificar integracao com rotina automatica
If lAutoma261 .And. lWmsNew .And. lExecSD3
	cDocumento := Iif(!Empty(aAutoItens[1,1]),aAutoItens[1,1],cDocumento)
Else
	//��������������������������������������������������������������Ŀ
	//� Verifica se durante a digitacao n�o foi incluido um documento�
	//� com o mesmo numero por outro usu�rio.                        �
	//����������������������������������������������������������������
	dbSelectArea('SD3')
	dbSetOrder(2)
	dbSeek(xFilial()+cDocumento)
	cMay := "SD3"+Alltrim(xFilial())+cDocumento
	lFirstNum := .T.
	While D3_FILIAL+D3_DOC==xFilial()+cDocumento.Or.!MayIUseCode(cMay)
		If D3_ESTORNO # "S"
			If lFirstNum
				cDocumento := NextNumero("SD3",2,"D3_DOC",.T.)
				cDocumento := A261RetINV(cDocumento)
				lFirstNum := .F.
			Else
				cDocumento := Soma1(cDocumento)
			EndIf
			lChangeDoc := .T.
			cMay := "SD3"+Alltrim(xFilial())+cDocumento
		EndIf
		dbSkip()
	EndDo

	If lWmsNew
		dbSelectArea("DH1")
		DH1->(dbSetOrder(2))
		If DH1->(dbSeek(xFilial("DH1")+cDocumento))
			cDocWms	:= NextNumero("DH1",2,"DH1_DOC",.T.)
			cDocumento := cDocWms
			cMay := "SD3"+Alltrim(xFilial())+cDocumento
		EndIf
	EndIf

EndIf

//Utilizado na mensagem unica
If Type('cDocIntMU') <> "U"
	cDocIntMU	:= cDocumento
Endif
RestArea(aSD3Area)

//������������������������������������������������������������������������Ŀ
//� Tratamento para Dead-Lock                                              �
//��������������������������������������������������������������������������
For nX:=1 to Len(aCols)
	If aScan(aLockSB2,aCols[nX][nPosCODOri]+aCols[nX][nPosLOCOri])==0
		aadd(aLockSB2,aCols[nX][nPosCODOri]+aCols[nX][nPosLOCOri]) //Produto+Local
	EndIf
	If aScan(aLockSB2,aCols[nX][nPosCODDes]+aCols[nX][nPosLOCDes])==0
		aadd(aLockSB2,aCols[nX][nPosCODDes]+aCols[nX][nPosLOCDes]) //Produto+Local
	EndIf
Next nX
//������������������������������������������������������������������������Ŀ
//� Tratamento para Dead-Lock                                              �
//��������������������������������������������������������������������������
If MultLock("SB2",aLockSB2,1)
	// Verifica se � proveniente de integracao com ACD
	lAtuEti := IsTelnet() .And. UsaCb0("01") .And. Type("aLista") == "A"

	For nLoop := 1 to nMaxArray
		n := nLoop
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5")+aCols[n,nPosCODOri]))

		//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
		If !SB2->(dbSeek(xFilial('SB2')+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri],.F.))
			CriaSB2(aCols[n,nPosCODOri],aCols[n,nPosLOCOri])
		EndIf
		//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
		If !SB2->(dbSeek(xFilial('SB2')+aCols[n,nPosCODDes]+aCols[n,nPosLOCDes],.F.))
			CriaSB2(aCols[n,nPosCODDes],aCols[n,nPosLOCDes])
		EndIf

		If !lWmsNew
			lValLote := .T.
		Else
			If IntWMS(aCols[n,nPosCODOri])
				lValLote := .F.
				lMantemLot := .T.
			EndIf
		EndIf

		//�������������������������������������������������������Ŀ
		//� Ponto de Entrada para escolher o tipo de sub-lote     �
		//���������������������������������������������������������
		If lValLote
			If lMT260NLOT
				lMantemLot := ExecBlock("MT260NLOT",.F.,.F.,{aCols[n,nPosCODOri],aCols[n,nPosCODDes],aCols[n,nPosLoTCTL],aCols[n,nPosLotDes]})
				If ValType(lMtNLote) <> "L"
					lMantemLot := .F.
				EndIf
			ElseIf lMtNLote
			//���������������������������������������������������������������������������������Ŀ
			//� Transferencia entre produtos ou lotes diferentes necess�rio alterar o sub-lote  �
			//�����������������������������������������������������������������������������������
				If (aCols[n,nPosLoTCTL]!= aCols[n,nPosLotDes] .And. !Empty(aCols[n,nPosLotDes])) .Or. aCols[n,nPosCODOri] != aCols[n,nPosCODDes]
					lMantemLot := .F.
				Else
					lMantemLot := .T.
				EndIf
			EndIf
		EndIf

		If a261IntWMS(aCols[n,nPosCODOri]) .And. lWmsNew .And. !lExecSD3
			//-- Posiciona no Arquivo de Produtos (SB1)
			If !SB1->(dbSeek(xFilial('SB1')+aCols[n,nPosCODOri],.F.))
				Help(' ',1,'NOFOUNDSB1')
				Loop
			EndIf


			//����������������������������������������������������Ŀ
			//� Pega o proximo numero sequencial de movimento      �
			//������������������������������������������������������
			cNumSeq := ProxNum()

			//Utilizado na mensagem unica
			If Type('cNSeqIntMU') <> "U"
				cNSeqIntMU := cNumSeq
			Endif

			For nW:= 1 To 2
			 // Gerar a movimentacao de REQUISICAO = 1 / DEVOLUCAO = 2
				AADD(aItenSD3[Len(aItenSD3)],xFilial('SD3'))																			//-- D3_FILIAL
				AADD(aItenSD3[Len(aItenSD3)],IIf(nW = 1,"999","499") )																//-- D3_TM
				AADD(aItenSD3[Len(aItenSD3)],dA261Data)																				//-- D3_EMISSAO
				AADD(aItenSD3[Len(aItenSD3)],cNumSeq)																					//-- D3_NUMSEQ
				AADD(aItenSD3[Len(aItenSD3)],IIf(nW = 1,aCols[n,nPosCODOri],aCols[n,nPosCODDes]))								//-- D3_COD
				If	nW == 1
					AADD(aItenSD3[Len(aItenSD3)],If(Rastro(aCols[n,nPosCODOri]),aCols[n,nPosLoTCTL],CriaVar('D3_LOTECTL')))	//-- D3_LOTECTL
				Else
					cLoteDes:=If(Empty(aCols[n,nPosLotDes]),aCols[n,nPosLoTCTL],aCols[n,nPosLotDes])
					AADD(aItenSD3[Len(aItenSD3)],If(Rastro(aCols[n,nPosCODDes]),cLoteDes,CriaVar('D3_LOTECTL')))
				EndIf
				AADD(aItenSD3[Len(aItenSD3)],IIf(nW = 1,aCols[n,nPosLOCOri],aCols[n,nPosLOCDes]))								//-- D3_LOCAL
				AADD(aItenSD3[Len(aItenSD3)],IIf(nW = 1,aCols[n,nPosLcZOri],aCols[n,nPosLcZDes]))								//-- D3_LOCALIZ
				AADD(aItenSD3[Len(aItenSD3)],aCols[n,nPosQUANT])																		//-- D3_Quant
				AADD(aItenSD3[Len(aItenSD3)],ConvUm(aCols[n,nPosCODOri],aCols[n,nPosQUANT],aCols[n,nPosQTSEG],2))				//-- D3_QTSEGUM
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_TRT
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_PROJPMS
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_TASKPMS
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_CLVL
				aAdd(aItenSD3[Len(aItenSD3)],aCols[n,nPosServic])																	//-- D3_SERVIC
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_CC
				AADD(aItenSD3[Len(aItenSD3)],SB1->B1_CONTA)																			//-- D3_CONTA
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_ITEMCTA
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_STATUS
				AADD(aItenSD3[Len(aItenSD3)],"")																						//-- D3_OP
				If SD3->(FieldPos("D3_NUMSA")) > 0
					AADD(aItenSD3[Len(aItenSD3)],"")																					//-- D3_NUMSA
				Else
					AADD(aItenSD3[Len(aItenSD3)],""	)																					//-- D3_NUMSA
				EndIf
				If SD3->(FieldPos("D3_ITEMSA")) > 0
					AADD(aItenSD3[Len(aItenSD3)],"")																					//-- D3_ITEMSA
				Else
					AADD(aItenSD3[Len(aItenSD3)],""	)																					//-- D3_ITEMSA
				EndIf
				AADD(aItenSD3[Len(aItenSD3)],cDocumento)																				//-- D3_DOC
				AADD(aItenSD3[Len(aItenSD3)],IIf(nW = 1,"RE4","DE4"))																//-- D3_CF
				If nW == 1
					AADD(aItenSD3[Len(aItenSD3)],If(Rastro(aCols[n,nPosCODOri],'S'),aCols[n,nPosNLOTE],CriaVar('D3_NUMLOTE')))	//-- D3_NUMLOTE
				Else
					AADD(aItenSD3[Len(aItenSD3)],If(lMantemLot,aCols[n,nPosNLOTE],CriaVar("D3_NUMLOTE")))							//-- D3_NUMLOTE
				EndIf

				AADD(aItenSD3[Len(aItenSD3)],aCols[n,nPosNSer])																		//-- D3_NUMSERI

				 // Funcao que grava a DH1 gera servico WMS e efetua a movimentacoao de lote
				EspDH1Wms(aItenSD3,"MATA261",,IIF(nW = 1,"2","1"),@oOrdServ)
				ADEL(aItenSD3[1],1)
				ASIZE(aItenSD3[1],1)
				aItenSD3[1] := {}
			Next nW
		Else
			If !aCols[n][Len(aCols[n])] .And. A261Quant(.F.) //--  verifica se nao esta deletado (DEL)
				If lMA261TRD3
					AADD(aRecSD3,{})
				EndIf
				cNumSeq := IIf(!lExecSD3,ProxNum(),aCols[n,nPosNumSeq]) //-- Pega o proximo numero sequencial de movimento

				//Utilizado na mensagem unica
				If Type('cNSeqIntMU') <> "U"
					cNSeqIntMU := cNumSeq
				Endif
				//������������������������������������������������������Ŀ
				//� Gera as Movimenta��es no SD3.                        �
				//��������������������������������������������������������

				//-- Verifica se o Produto Destino vai para o CQ Celerina
				cForNFO := ''
				cLojNFO := ''
				cPedNFO := ''
				cDocNFO := ''
				cSerNFO := ''
				cTipNFO := ''
				cIPCNFO := ''
				nQtdOri := 0
				cItemNF := ''
				cDocEnt := ''
				dNotFis := cTOD('')
				nPreco  := 0
				If (lQualyCQ:=SB1->(dbSeek(xFilial('SB1')+aCols[n,nPosCODDes], .F.)) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ")=='Q'.And.aCols[n,nPosLOCDes]==cLocCQ.And.cLocCQ#aCols[n,nPosLOCOri])
					//������������������������������������������������������������������������Ŀ
					//� Verifica se a existencia do P.E. MA260NFQ, para que nao seja exibida   �
					//� a tela para selecao de materiais a serem transferidos para o CQ, quan- �
					//� do houver integracao com o Quality.									   �
					//��������������������������������������������������������������������������
					If lMA260NFQ
						lQualyCQ := Execblock("MA260NFQ",.F.,.F.)
						lQualyCQ := If(ValType(lQualyCQ)#"L",.T.,lQualyCQ)
					Else
						If !a260NFOrig(aCols[n,nPosCODOri],aCols[n,nPosLOCOri],aCols[n,nPosLoTCTL],aCols[n,nPosNLOTE],.T.,aCols[n,nPosLocDes])
							If Aviso(STR0029,STR0033 + AllTrim(aCols[n,nPosCODOri]) + STR0034,{STR0035,STR0036}) == 1 // 'Siga Quality'###'Envia o Produto '###' somente para CQ Materiais?'###'Sim'###'Aborta'
								lQualyCQ := .F.
							Else
								lRet	:= .F.
								Exit
							EndIf
						EndIf
					EndIf

					If lQualyCQ
						If Alias() == 'SWN'
							cForNFO := SWN->WN_FORNECE
							cLojNFO := SWN->WN_LOJA
							cDocNFO := SWN->WN_DOC
							cSerNFO := SWN->WN_SERIE
							cTipNFO := SWN->WN_TIPO_NF
							nQtdOri := SWN->WN_QUANT
							cItemNF := StrZero(Val(SWN->WN_ITEM),2)
							nPreco  := SWN->WN_VALOR

							SD1->(dbSetOrder(1))
							If SD1->(dbSeek(xFilial('SD1')+cDocNFO+cSerNFO+cForNFO+cLojNFO+cCodEIC))
								cPedNFO := SD1->D1_PEDIDO
								cIPCNFO := SD1->D1_ITEMPC
								cDocEnt := SD1->D1_LOTEFOR
								dNotFis := SD1->D1_EMISSAO
							EndIf
						Else
							cForNFO := SD1->D1_FORNECE
							cLojNFO := SD1->D1_LOJA
							cPedNFO := SD1->D1_PEDIDO
							cDocNFO := SD1->D1_DOC
							cSerNFO := SD1->D1_SERIE
							cTipNFO := SD1->D1_TIPO
							cIPCNFO := SD1->D1_ITEMPC
							nQtdOri := SD1->D1_QUANT
							cItemNF := SD1->D1_ITEM
							cDocEnt := SD1->D1_LOTEFOR
							dNotFis := SD1->D1_EMISSAO
							nPreco  := SD1->D1_VUNIT
						EndIf
					EndIf
				EndIf
				//-- Posiciona no Arquivo de Produtos (SB1)
				If !SB1->(dbSeek(xFilial('SB1')+aCols[n,nPosCODOri],.F.))
					Help(' ',1,'NOFOUNDSB1')
					Loop
				EndIf

				//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
				If !SB2->(dbSeek(xFilial('SB2')+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri],.F.))
					CriaSB2(aCols[n,nPosCODOri],aCols[n,nPosLOCOri])
				EndIf

				RecLock('SD3', .T.) //-- Origem
				SD3->D3_FILIAL  := xFilial('SD3')
				SD3->D3_COD     := aCols[n,nPosCODOri]
				SD3->D3_QUANT   := aCols[n,nPosQUANT]
				SD3->D3_CF      := 'RE4'
				SD3->D3_CHAVE   := 'E0'
				SD3->D3_LOCAL   := aCols[n,nPosLOCOri]
				SD3->D3_DOC     := cDocumento
				SD3->D3_EMISSAO := dA261Data
				SD3->D3_UM      := aCols[n,nPosUMOri]
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,aCols[n,nPosQUANT],aCols[n,nPosQTSEG],2)
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_TM      := '999'
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_CONTA   := SB1->B1_CONTA
				For nX := 1 To Len(aCTBEnt)
					SD3->&("D3_EC"+aCTBEnt[nX]+"CR") := SB1->&("B1_EC"+aCTBEnt[nX]+"CR")
					SD3->&("D3_EC"+aCTBEnt[nX]+"DB") := SB1->&("B1_EC"+aCTBEnt[nX]+"DB")
				Next nX
				SD3->D3_USUARIO := CUSERNAME
				SD3->D3_LOTECTL := If(Rastro(aCols[n,nPosCODOri]),aCols[n,nPosLoTCTL],CriaVar('D3_LOTECTL'))
				SD3->D3_NUMLOTE := If(Rastro(aCols[n,nPosCODOri],'S'),aCols[n,nPosNLOTE],CriaVar('D3_NUMLOTE'))
				SD3->D3_DTVALID := If(Rastro(aCols[n,nPosCODOri]),aCols[n,nPosDTVAL],CriaVar('D3_DTVALID'))
				SD3->D3_POTENCI := If(Rastro(aCols[n,nPosCODOri]),aCols[n,nPosPotenc],CriaVar('D3_POTENCI'))
				SD3->D3_LOCALIZ := aCols[n,nPosLcZOri]
				SD3->D3_NUMSERI := aCols[n,nPosNSer]

				If Type("cNumSeqP3") == "C" .And. cNumSeqP3 <> Nil
					SD3->D3_IDENT := cNumSeqP3
				EndIf

				//������������������Ŀ
				//� Portaria CAT83   |
				//��������������������
				If lCAT83 .And. nPosCAT83O>0 .And. aCols[n,nPosCODOri] != aCols[n,nPosCODDes]
					Replace D3_CODLAN With If(Empty(aCols[n,nPosCAT83O]),A240CAT83(),aCols[n,nPosCAT83O])
				EndIf
				If lAutoma261 .And. nPosIDDCF > 0
					SD3->D3_IDDCF:= aCols[n,nPosIDDCF]
				EndIf
				IF Ascan(AHEADER,{ |x| x[2] == 'D3_OBSERVA'}) > 0
					SD3->D3_OBSERVA := aCols[n,Ascan(AHEADER,{ |x| x[2] == 'D3_OBSERVA'})]
				Endif
				MsUnlock()

				If lMA261TRD3
					AADD(aRecSD3[Len(aRecSD3)],SD3->(Recno()))
				EndIf

				//�������������������������������������������������������������������Ŀ
				//�Grava os campos Memos Virtuais					 				  �
				//���������������������������������������������������������������������
				If Type("aMemos") == "A"   .And. Len(aMemos) > 0
					For nMem := 1 to Len(aMemos)
						cVar := aMemos[nMem][2]
						MSMM(,TamSx3(aMemos[nMem][2])[1],,&cVar,1,,,"SD3",aMemos[nMem][1])
					Next nMem
				EndIf
				aAdd(aRegSD3,SD3->(Recno()))

				//��������������������������������������������Ŀ
				//� Pega os 15 custos medios atuais            �
				//����������������������������������������������
				aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
				//��������������������������������������������Ŀ
				//� Grava o custo da movimentacao              �
				//����������������������������������������������
				aCusto := GravaCusD3(aCM)

				//��������������������������������������������Ŀ
				//� Grava Lote do Fornecedor e Num. Despacho   �
				//����������������������������������������������
				dbSelectArea('SB8')
				dbSetOrder(3)
				If SB8->(dbSeek(xFilial('SB8')+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri]+aCols[n,nPosLoTCTL],.F.))
					cLoteFor:= SB8->B8_LOTEFOR
					cNumDesp:= SB8->B8_NUMDESP
				EndIf

				//�������������������������������������������������������Ŀ
				//� Atualiza o saldo atual (VATU) com os dados do SD3     �
				//���������������������������������������������������������
				If (lRastroL .or. lRastroS) .and. cLotVenc == 'N' .and. aCols[n,nPosDTVAL] < dA261Data .and. aCols[n,nPosLOCDes] == cLocCQ
					lLtVcCQ := .T.
				EndIf
				If !B2AtuComD3(aCusto,NIL,NIL,NIL,NIL,.T.,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cLoteFor,cNumDesp,NIL,NIL,NIL,NIL,NIL,NIL,lLtVcCQ)
					//�������������������������������������������������������Ŀ
					//� Ponto de entrada para gravar no mov. de Origem         �
					//���������������������������������������������������������

					If lM261D3O
						ExecBlock('M261D3O',.F.,.F.,n)
					EndIf
					//-- Verifica se o custo medio � calculado On-Line e, se necessario, cria o
					//-- cabecalho do arquivo de Prova
					If cCusMed == 'O' .And. lCriaHeade
						lCriaHeade := .F.
						nHdlPrv := HeadProva(cLoteEst,'MATA261',Subs(cUsuario,7,6),@cArquivo)
					EndIf

					//�������������������������������������������������������Ŀ
					//� Verifica se o custo medio e' calculado On-Line        �
					//���������������������������������������������������������
					If cCusMed == 'O'
						//�������������������������������������������������Ŀ
						//� Gera o lancamento no arquivo de prova           �
						//���������������������������������������������������
						nTotal += DetProva(nHdlPrv,'670','MATA261',cLoteEst)
						If ( UsaSeqCor() ) .AND. Type("aCtbDia") == "A"
							aAdd(aCtbDia,{"SD3",SD3->(RECNO()),"","D3_NODIA","D3_DIACTB"})
						Else
							aCtbDia := {}
						EndIF
					EndIf

					//-- Posiciona no Arquivo de Produtos (SB1)
					If aCols[n,nPosCODOri] # aCols[n,nPosCODDes] .And. ;
							!SB1->(dbSeek(xFilial('SB1')+aCols[n,nPosCODDes],.F.))
						Help(' ',1,'NOFOUNDSB1')
						Loop
					EndIf

					RecLock('SD3',.T.) //-- Destino
					SD3->D3_FILIAL  := xFilial('SD3')
					SD3->D3_COD     := aCols[n,nPosCODDes]
					SD3->D3_QUANT   := aCols[n,nPosQUANT]
					SD3->D3_CF      := 'DE4'
					SD3->D3_CHAVE   := 'E9'
					SD3->D3_LOCAL   := aCols[n,nPosLOCDes]
					SD3->D3_DOC     := cDocumento
					SD3->D3_EMISSAO := dA261Data
					SD3->D3_UM      := aCols[n,nPosUMDes]
					SD3->D3_GRUPO   := SB1->B1_GRUPO
					SD3->D3_NUMSEQ  := cNumSeq
					SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,aCols[n,nPosQUANT],aCols[n,nPosQTSEG],2)
					SD3->D3_SEGUM   := SB1->B1_SEGUM
					SD3->D3_TM      := '499'
					SD3->D3_TIPO    := SB1->B1_TIPO
					SD3->D3_CONTA   := SB1->B1_CONTA
					For nX := 1 To Len(aCTBEnt)
						SD3->&("D3_EC"+aCTBEnt[nX]+"CR") := SB1->&("B1_EC"+aCTBEnt[nX]+"CR")
						SD3->&("D3_EC"+aCTBEnt[nX]+"DB") := SB1->&("B1_EC"+aCTBEnt[nX]+"DB")
					Next nX
		   			SD3->D3_USUARIO := CUSERNAME
					cLoteDes:=If(Empty(aCols[n,nPosLotDes]),aCols[n,nPosLoTCTL],aCols[n,nPosLotDes])
					SD3->D3_LOTECTL := If(Rastro(aCols[n,nPosCODDes]),cLoteDes,CriaVar('D3_LOTECTL'))
					SD3->D3_NUMLOTE := If(lMantemLot,aCols[n,nPosNLOTE],CriaVar("D3_NUMLOTE"))
					SD3->D3_DTVALID := If(Rastro(aCols[n,nPosCODDes]),aCols[n,nPosDtVldD],CriaVar('D3_DTVALID'))
					SD3->D3_POTENCI := If(Rastro(aCols[n,nPosCODDes]),aCols[n,nPosPotenc],CriaVar('D3_POTENCI'))
					SD3->D3_LOCALIZ := aCols[n,nPosLcZDes]
					SD3->D3_NUMSERI := aCols[n,nPosNSer]

					If Type("cNumSeqP3") == "C" .And. cNumSeqP3 <> Nil
						SD3->D3_IDENT := cNumSeqP3
					EndIf
					If lAutoma261 .And. nPosIDDCF > 0
						SD3->D3_IDDCF:= aCols[n,nPosIDDCF]
					EndIf
					//-- Usado somente para SIGAWMS
					If nPosServic > 0 .And. !Empty(cServico := aCols[n,nPosServic])
						SD3->D3_SERVIC := cServico
					EndIf

					//������������������Ŀ
					//� Portaria CAT83   |
					//��������������������
					If lCAT83 .And. nPosCAT83D>0 .And. aCols[n,nPosCODOri] != aCols[n,nPosCODDes]
						Replace D3_CODLAN With If(Empty(aCols[n,nPosCAT83D]),A240CAT83(),aCols[n,nPosCAT83D])
					EndIf

					//������������������Ŀ
					//� Percentual FCI   |
					//��������������������
					If nFCICalc == 1
						Replace D3_PERIMP With aCols[n,nPosPerImp]
					EndIf

					if Ascan(AHEADER,{ |x| x[2] == 'D3_OBSERVA'}) > 0
						SD3->D3_OBSERVA := aCols[n,Ascan(AHEADER,{ |x| x[2] == 'D3_OBSERVA'})]
					Endif
					MsUnlock()

					If lMA261TRD3
						AADD(aRecSD3[Len(aRecSD3)],SD3->(Recno()))
					EndIf

					aAdd(aRegSD3,SD3->(Recno()))

					//��������������������������������������������Ŀ
					//� Grava o custo da movimentacao              �
					//����������������������������������������������
					aCusto := GravaCusD3(aCM,,,"261")

					//�������������������������������������������������������Ŀ
					//� Atualiza o saldo atual (VATU) com os dados do SD3     �
					//���������������������������������������������������������
					B2AtuComD3(aCusto,NIL,NIL,NIL,NIL,.T.,NIL,NIL,cServico,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cLoteFor,cNumDesp)

					/* Atualiza etiquetas lidas pelo ACD */
					If lAtuEti .AND. CBProdUnit(SD3->D3_COD) .And. Len(aLista[n]) >= 10
						For nY := 1 To Len(aLista[n,10])
							aEtiqueta := CBRetEti(aLista[n,10,nY,1],'01')

							//--- Atualiza loga da etiqueta com a troca do local/endereco
							CBLog("02",{CB0->CB0_CODPRO,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_LOCAL,CB0->CB0_LOCALI,SD3->D3_LOCAL,SD3->D3_LOCALIZ,CB0->CB0_CODETI})

							aEtiqueta[10] := SD3->D3_LOCAL
							aEtiqueta[09] := SD3->D3_LOCALIZ
							aEtiqueta[12] := SD3->D3_NUMSEQ
							aEtiqueta[17] := SD3->D3_NUMLOTE
							aEtiqueta[24] := "SD3"
							CBGrvEti("01",aEtiqueta,CB0->CB0_CODETI)
						Next nY
					EndIf

					//-- Inclui o Produto Destino no CQ
					If AllTrim(cLocCQ) == AllTrim(aCols[n,nPosLOCDes]) .And. AllTrim(cLocCQ) # AllTrim(aCols[n,nPosLOCOri])
						fGeraCQ0('SD3', SD3->D3_COD, 'TR', aCols[n,nPosLOCOri])
						//�������������������������������������������������������Ŀ
						//� Atualiza o CQ do modulo SigaQuality                   �
						//���������������������������������������������������������
						If lQualyCQ
							SB1->(dbSetOrder(1))
							lQualyCQ := SB1->(dbSeek(xFilial("SB1")+SD3->D3_COD)) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q"
						EndIf

						If lQualyCQ

							nAtraso    := 0
							nSC7OrdAnt := SC7->(IndexOrd())
							nSC7RecAnt := SC7->(Recno())
							SC7->(dbSetOrder(1))
							If SC7->(dbSeek(xFilial('SC7')+cPedNFO+cIPCNFO, .F.))
								nAtraso := SD3->D3_DTVALID-SC7->C7_DATPRF
							EndIf

							SC7->(dbSetOrder(nSC7OrdAnt))
							SC7->(dbGoto(nSC7RecAnt))
							//��������������������������������������������������������������Ŀ
							//�Posiciona o Registro do SD5, para envio do LOTECTL+NUMLOTE a  �
							//� qAtuMatQie().												 �
							//����������������������������������������������������������������
							cLotCtlQie := ''
							cNumLotQie := ''
							If Rastro(SD3->D3_COD,"L") .Or. Rastro(SD3->D3_COD,"S")
								aAreaSD5 := SD5->(GetArea())
								SD5->(dbSetOrder(3))
								If SD5->(dbSeek(xFilial('SD5')+SD3->D3_NUMSEQ+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_LOTECTL,.F.))
									cLotCtlQie := SD5->D5_LOTECTL
									cNumLotQie := SD5->D5_NUMLOTE
								EndIf
								SD5->(dbSetOrder(aAreaSD5[2]))
								SD5->(dbGoto(aAreaSD5[3]))
							EndIf

							//��������������������������������������������������������������Ŀ
							//� Passa LOTECTL+NUMLOTE p/ser gravado nos campos de Lote do QIE�
							//����������������������������������������������������������������
							nSC7OrdAnt := SC7->(IndexOrd())
							nSC7RecAnt := SC7->(Recno())
							SC7->(dbSetOrder(1))
							If SC7->(dbSeek(xFilial('SC7')+cPedNFO+cIPCNFO, .F.))
								nAtraso := SD3->D3_DTVALID-SC7->C7_DATPRF
							Else
								nAtraso := 0
							EndIf

							SC7->(dbSetOrder(nSC7OrdAnt))
							SC7->(dbGoto(nSC7RecAnt))
							//��������������������������������������������������������������Ŀ
							//� Grava os dados referentes ao Inspecao de Entradas (SIGAQIE)  �
							//����������������������������������������������������������������

							//Grava a quantidade original do item rejeitado
							If !lQtdRep
								cItemNF := ''
								cDocEnt := SD3->D3_DOC
								dNotFis := SD3->D3_EMISSAO
								nPreco  := SD3->D3_CUSTO1
							EndIf

							aEnvCele := {cDocNFO				,; //Numero da Nota Fiscal
								cSerNFO							,; //Serie da Nota Fiscal
								cTipNFO 						,; //Tipo da Nota Fiscal
								dNotFis							,; //Data de Emissao da Nota Fiscal
								SD3->D3_EMISSAO					,; //Data de Entrada da Nota Fiscal
								"TR"							,; //Tipo de Documento
								cItemNF							,; //Item da Nota Fiscal
								Space(TamSX3("D1_REMITO")[1])	,; //Numero do Remito (Localizacoes)
								cPedNFO							,; //Numero do Pedido de Compra
								Space(TamSX3("D1_ITEMPC")[1])	,; //Item do Pedido de Compra
								cForNFO							,; //Codigo Fornecedor/Cliente
								cLojNFO							,; //Loja Fornecedor/Cliente
								cDocEnt							,; //Numero do Lote do Fornecedor
								Space(6)						,; //Codigo do Solicitante
								SD3->D3_COD						,; //Codigo do Produto
								SD3->D3_LOCAL					,; //Local Origem
								cLotCtlQie						,; //Numero do Lote
								cNumLotQie						,; //Sequencia do Sub-Lote
								SD3->D3_NUMSEQ					,; //Numero Sequencial
								SD7->D7_NUMERO					,; //Numero do CQ
								SD3->D3_QUANT					,; //Quantidade
								nPreco							,; //Preco
								nAtraso							,; //Dias de atraso
								" "								,; //TES
								AllTrim(FunName())				,; //Origem
								" "								,; //Origem TXT
								PadR(nQtdOri,15)}				   //Tamanho do lote original

							//��������������������������������������������������������������Ŀ
							//� Realiza a integracao Materiais x Inspecao de Entradas		 �
							//����������������������������������������������������������������
							aRecCele := qAtuMatQie(aEnvCele,1)

							//��������������������������������������������������������������Ŀ
							//� Libera��o Automatica (FREE-PASS) - Parametrizada no SigaQIE  �
							//����������������������������������������������������������������
							If aRecCele[1] == 'C' .or. aRecCele[1] =='L'
								//-- Liberar totalmente a movimenta��o no SD7 com Free-Pass
								aMov := {}
								aAdd(aMov, {})
								aAdd(aMov[Len(aMov)], 1)
								aAdd(aMov[Len(aMov)], SD7->D7_SALDO)
								aAdd(aMov[Len(aMov)], SD7->D7_LOCDEST)
								aAdd(aMov[Len(aMov)], SD7->D7_DATA)
								aAdd(aMov[Len(aMov)], '')
								aAdd(aMov[Len(aMov)], '')
								aAdd(aMov[Len(aMov)], aRecCele[2])
								aAdd(aMov[Len(aMov)], SD7->D7_QTSEGUM)
								fGravaCQ(SD7->D7_PRODUTO, SD7->D7_NUMERO, .F., aMov, PegaCMD3())
							EndIf

						EndIf
					EndIf


					//��������������������������������������������������������������Ŀ
					//� ExecBlock apos gravacao do SD3                               �
					//����������������������������������������������������������������
					If lMA261D3
						ExecBlock('MA261D3',.F.,.F.,n)
					EndIf

					//��������������������������������������������������������������Ŀ
					//� Verifica se o custo medio e' calculado On-Line               �
					//����������������������������������������������������������������
					If cCusMed == 'O'
						//�������������������������������������������������Ŀ
						//� Gera o lancamento no arquivo de prova           �
						//���������������������������������������������������
						nTotal += DetProva(nHdlPrv,'672','MATA261',cLoteEst)
					EndIf
				EndIf
			Else
				//��������������������������������������������������������������Ŀ
				//� Cria array com os movimentos dos Produtos sem saldos         �
				//����������������������������������������������������������������
				If lLogMov
					LogSaldo(aCols[n,nPosCODOri],aCols[n,nPosDOri],aCols[n,nPosUMOri],aCols[n,nPosLOCOri],aCols[n,nPosQUANT],;
						aCols[n,nPosLoTCTL],aCols[n,nPosNLOTE],aCols[n,nPosDTVAL],aCols[n,nPosLcZOri],aCols[n,nPosNSer],;
						@aLogSld,cDocumento,dA261Data)
				EndIf
			EndIf
		EndIf
	Next nLoop

	//���������������������������������������������������������������?
	// Telemetria - Uso da classe FwCustomMetrics                   //
	// Metrica - setAverageMetric                                   //
	// Grava a media de itens de um movimento multiplo incluido     //
	//?��������������������������������������������������������������?
	If FWLibVersion() >= "20210517"
		FWCustomMetrics():setAverageMetric(	"MATA261"/*cSubRoutine*/,;
											"estoque-protheus_transferencia-multipla-media-mensal-qtd-itens_seconds" /*cIdMetric*/,;
											nMaxArray /*nValue*/,;
											/*dDateSend*/,/*nLapTime*/)
	EndIf

	If lRet .And. cCusMed == 'O' .And. nTotal <> 0
		If !lCriaHeade
			//��������������������������������������������������������������Ŀ
			//� Se ele criou o arquivo de prova ele deve gravar o rodape'    �
			//����������������������������������������������������������������
			//����������������������������������������������������������������Ŀ
			//� mv_par01 - Se mostra e permite digitar lancamentos contabeis   �
			//� mv_par02 - Se deve aglutinar os lancamentos contabeis          �
			//������������������������������������������������������������������
			n := 1
			RodaProva(nHdlPrv,nTotal)
			If !Empty(aCtbDia)
				cCodDiario := CtbaVerdia()
				For nX := 1 to Len(aCtbDia)
					aCtbDia[nX][3] := cCodDiario
				Next nX
			EndIf
			If cA100Incl(cArquivo,nHdlPrv,3,cLoteEst,lDigita,lAglutina,,,,,,aCtbDia)
				lCriaHeade := .T.
				//�����������������������������������������������������������Ŀ
				//� Grava a data de Contabilizacao do campo D3_DTLANC         �
				//�������������������������������������������������������������
				For nX := 1 To Len(aRegSD3)
					SD3->(dbGoTo(aRegSD3[nX]))
					RecLock("SD3",.F.)
					Replace D3_DTLANC With dDataBase
					MsUnLock()
				Next nX
			EndIf
		EndIf
	EndIf

Else
	ConOut("WARNING: DEADLOCK CONTROL IS ON")
EndIf

FreeUsedCode(.T.)

//��������������������������������������������������Ŀ
//� Ponto de Entrada apos a gravacao da transferencia�
//����������������������������������������������������
If ExistBlock("MT261TDOK")
	ExecBlock("MT261TDOK",.F.,.F.)
EndIf

//-- Restaura a Integridade do Sistema
RestArea(aSD3Area)
RestArea(aSD7Area)
RestArea(aSX6Area)
RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261LinOk � Autor � Marcelo Pimentel      � Data � 30/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa que faz consistencias apos a digitacao da tela    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261LinOk(ExpO1,ExpN1)		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto a ser verificado.                           ���
���          � ExpN1 = numero do registro			                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261LinOk(o,nLinha)
Local aArea      := GetArea()
Local lRet       := .T.
Local aAreaSBE   := { 'SBE', SBE->(IndexOrd()),SBE->(Recno()) }
Local nX		 := 0
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri 	:= 1	//Codigo do Produto Origem
Local nPosUmOrig 	:= 3	//Unidade de Medida Origem
Local nPosLOCOri 	:= 4	//Armazem Origem
Local nPosLcZOri 	:= 5	//Localizacao Origem
Local nPosCODDes 	:= 6	//Codigo do Produto Destino
Local nPosLOCDes 	:= 9	//Armazem Destino
Local nPosUmDest 	:= 8 	//Unidade de Medida Destino
Local nPosLcZDes 	:= 10	//Localizacao Destino
Local nPosNSer		:= 11	//Numero de Serie
Local nPosLoTCTL 	:= 12	//Lote de Controle
Local nPosNLOTE		:= 13  	//Numero do Lote
Local nPosVLdLot    := 14	// Dt Validade do Lote
Local nPosQUANT  	:= 16	//Quantidade
Local nPosCTLDes 	:= 20  	//Lote de Controle Destino
Local nPosDLtOri	:= 14	//Data de Validade Origem
Local nPosDLtDes	:= 21	//Data de Validade Destino
Local nPosServic := aScan(aheader,{|x| Alltrim(x[2])=="D3_SERVIC"})
Local cCodOrig   := ""
Local cCodDest   := ""
Local cLocOrig   := ""
Local cLocDest   := ""
Local cLoclzOrig := ""
Local cLoclzDest := ""
Local cNumSerie  := ""
Local cLoteDigi  := ""
Local cNumLote   := ""
Local cServico   := ""
Local nQuant261  := 0
Local cProdRef   := " "
Local cLocCQ     := GetMvNNR('MV_CQ','98')
Local cOriNSer   := ""
Local lWmsSD3    := If(!(Type('lExecWms')=='U'), lExecWms, .F.)
Local lWmsNew	 := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS  := Iif(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local oMovimento := Nil
Local cLoteDest  := ""
Local nPosSX3	 := 1
Local lCampObrig := .F.
Local lEmptyObrg := .F.
Local cLotVenc 	 := SuperGetMv("MV_LOTVENC",.F.,"S")
Local lLVEmp	 := Nil
Local lRastroL   := .F.
Local lRastroS   := .F.

Static lFnWMSValT

Default nLinha   := n

lRastroL  := Rastro(aCols[n,nPosCODOri],'L')
lRastroS  := Rastro(aCols[n,nPosCODOri],'S')

If lFnWMSValT == NIL
	lFnWMSValT := FindFunction('WMSValTPOD')
EndIf

If !aCols[nLinha,Len(aCols[nLinha])]
	cProdRef:= aCols[nLinha,nPosCODOri]
	If Empty(aCols[nLinha,nPosCODOri]) .Or. Empty(aCols[nLinha,nPosLOCOri]) .Or. ;
			Empty(aCols[nLinha,nPosCODDes]) .Or. Empty(aCols[nLinha,nPosLOCDes]) .Or. Empty(aCols[nLinha,nPosQUANT])
		Help(' ',1,'MA260OBR')
		lRet := .F.
	EndIf

	//����������������������������������Ŀ
	//� Valida preenchimento de campos   �
	//� obrigat�rios durante Execauto    �
	//������������������������������������
	If lAutoma261
		For nPosSX3 := 1 to Len(aCols[nLinha])-1
			lCampObrig := X3Obrigat(aHeader[nPosSX3][2], .F.)
			If lCampObrig 
				lEmptyObrg := Empty(aCols[nLinha][nPosSX3])
				If lEmptyObrg
					lRet := .F.
					//Grava arquivo de LOG do erro da Execauto (necess�rio para tratamento na ACDV150)
					AutoGRLog("Campo obrigat�rio vazio: " + aHeader[nPosSX3][2]) //Grava arquivo de LOG
					Exit
				EndIf
			EndIf	
		Next nPosSX3
	EndIf

	//����������������������������������Ŀ
	//� Verifica a permissao do armazem. �
	//������������������������������������
	If lRet
		lRet := MaAvalPerm(3,{aCols[nLinha][nPosLocOri],aCols[n][nPosCodOri]}) .And. MaAvalPerm(3,{aCols[nLinha][nPosLocDes],aCols[n][nPosCodDes]})
	EndIf
	//�����������������������������������������������������Ŀ
	//� Verifica o local de origem e destino informados     �
	//�������������������������������������������������������
	If lRet .And. (!A261Almox(1,aCols[nLinha,nPosLOCOri]) .Or. !A261Almox(2,aCols[nLinha,nPosLOCDes]))
		lRet := .F.
	EndIf

	//�����������������������������������������������������Ŀ
	//� Verifica se o produto est� sendo inventariado.      �
	//�������������������������������������������������������
	If lRet
		If BlqInvent(aCols[nLinha,nPosCODOri],aCols[nLinha,nPosLOCOri],,aCols[nLinha,nPosLcZOri])
			Help(' ',1,'BLQINVENT',,aCols[nLinha,nPosCODOri]+STR0054+aCols[nLinha,nPosLOCOri],1,11) //' Almox: '
			lRet:=.F.
		EndIf
		If BlqInvent(aCols[nLinha,nPosCODDes],aCols[nLinha,nPosLOCDes],,aCols[nLinha,nPosLcZDes])
			Help(' ',1,'BLQINVENT',,aCols[nLinha,nPosCODDes]+STR0054+aCols[nLinha,nPosLOCDes],1,11) //' Almox: '
			lRet:=.F.
		EndIf
		//�����������������������������������������������������Ŀ
		//� Analisa se o tipo do armazem permite a movimentacao |
		//�������������������������������������������������������
		If lRet .And. AvalBlqLoc(aCols[nLinha,nPosCODOri],aCols[nLinha,nPosLOCOri],Nil,,aCols[nLinha,nPosCODDes],aCols[nLinha,nPosLOCDes])
			lRet := .F.
		EndIf
	EndIf

	//�����������������������������������������������������Ŀ
	//� Verifica se os Produtos tem saldo bloqueado         �
	//�������������������������������������������������������
	If lRet //Origem
		lRet := SldBlqSB2(aCols[nLInha,nPosCODOri],aCols[nLinha,nPosLOCOri])
	EndIf
	If lRet //Destino
		lRet := SldBlqSB2(aCols[nLInha,nPosCODDes],aCols[nLinha,nPosLOCDes])
	EndIf

	//�����������������������������������������������������Ŀ
	//� Verifica se os Produtos possuem Localizacao         �
	//�������������������������������������������������������
	If lRet .And. Localiza(aCols[nLinha,nPosCODOri],.T.)
		If ValType(aCols[nLinha,nPosNSer]) == "U"
			cOriNSer := aCols[nLinha,nPosLcZOri]
		Else
			cOriNSer := aCols[nLinha,nPosLcZOri]+aCols[nLinha,nPosNSer]
		EndIf

		If  Empty(cOriNSer)
			Help(' ',1,'MA260OBR')
			lRet := .F.
		EndIf
		If ( cLocCQ == aCols[nLinha,nPosLOCDes] .And. Localiza(aCols[nLinha,nPosCODDes],.T.) .And. ( Empty(aCols[nLinha,nPosLcZDes]) .Or. Empty(aCols[nLinha,nPosLcZDes]+aCols[nLinha,nPosNSer] ) ) )
			Help(' ',1,'MA260OBR')
			lRet := .F.
		EndIf
		If !(lWmsNew .And. a261IntWMS(aCols[nLinha,nPosCODOri]))
			If (lRastroL .or. lRastroS) .and. cLotVenc == 'N' .and. aCols[n,nPosVLdLot] < dA261Data .and. aCols[n,nPosLOCDes] == cLocCQ
				lLVEmp := .T.
			EndIf
			If QtdComp(SaldoSBF(aCols[nLinha,nPosLOCOri],aCols[nLinha,nPosLcZOri],aCols[nLinha,nPosCODOri],aCols[nLinha,nPosNSer],aCols[nLinha,nPosLoTCTL],aCols[nLinha,nPosNLOTE],lLVEmp)) < QtdComp(aCols[nLinha,nPosQUANT])
				Help(" ",1,"SALDOLOCLZ")
				lRet:=.F.
			EndIf
		Else
			If !lWmsSD3 .And. QtdComp(oSaldoWMS:GetSldWMS(aCols[nLinha,nPosCODOri],aCols[nLinha,nPosLOCOri],aCols[nLinha,nPosLcZOri],aCols[nLinha,nPosLoTCTL],aCols[nLinha,nPosNLOTE],aCols[nLinha,nPosNSer])) < QtdComp(aCols[nLinha,nPosQUANT])
			 	Help(' ', 1, 'SALDOLOCLZ')
			 	lRet := .F.
			EndIf
		EndIf
		If lRet .And. !a261IntWMS(aCols[nLinha,nPosCODOri])
			dbSelectArea('SBE')
			aAreaSBE := GetArea()
			dbSetOrder(1)
			If dbSeek(xFilial('SBE')+aCols[nLinha,nPosLOCDes]+aCols[nLinha,nPosLcZDes], .F.)
				If SBE->(!Eof()) .And. SBE->BE_CAPACID > 0 .And. QtdComp(aCols[nLinha,nPosQUANT]+QuantSBF(aCols[nLinha,nPosLOCDes],aCols[nLinha,nPosLcZDes],aCols[nLinha,nPosCODDes])) > QtdComp(SBE->BE_CAPACID)
					Help(' ',1,'MA265CAPAC')
					lRet:=.F.
				EndIf
			EndIf
			dbSetOrder(aAreaSBE[2])
			dbGoto(aAreaSBE[3])
		EndIf
	EndIf
	//�����������������������������������������������������Ŀ
	//� Verifica se o produto possui Rastro.                �
	//�������������������������������������������������������
	If lRet .And. (Rastro(aCols[nLinha,nPosCODOri]) .And. Empty(aCols[nLinha,nPosLoTCTL]) .Or. ;
			Rastro(aCols[nLinha,nPosCODOri],'S') .And. Empty(aCols[nLinha,nPosNLOTE]))
		Help(' ',1,'MA260LOTE')
		lRet := .F.
	Else
		If ( lRet )
			dbSelectArea( 'SB8' )
			//Validacao Data de Validade Origem
			SB8->( dbSetOrder( 3 ) ) //"B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)"
			If SB8->( dbSeek( FWxFilial( 'SB8' ) + Padr( aCols[ nLinha ][ nPosCODOri ], TamSx3( 'B8_PRODUTO' )[ 1 ] ) + Padr( aCols[ nLinha ][ nPosLOCOri ], TamSx3( 'B8_LOCAL' )[ 1 ] ) + Padr( aCols[ nLinha ][ nPosLoTCTL ], TamSx3( 'B8_LOTECTL' )[ 1 ] ) + Padr( aCols[ nLinha ][ nPosNLOTE  ], TamSx3( 'B8_NUMLOTE' )[ 1 ] ) ) )
				Do Case
				Case ( Empty( SB8->B8_DTVALID ) )
					lRet := .T.
				Case !( Empty( SB8->B8_DTVALID ) ) .And. ( Empty( aCols[ nLinha ][ nPosDLtOri ] ) )
					aCols[ nLinha ][ nPosDLtOri ] := SB8->B8_DTVALID
					lRet := .T.
				Case !( Empty( SB8->B8_DTVALID ) ) .And. !( Empty( aCols[ nLinha ][ nPosDLtOri ] ) )
					If !( SB8->B8_DTVALID == aCols[ nLinha ][ nPosDLtOri ] )
						Help(" ",1,"A240DTVALI")
						lRet := .F.
					EndIf
				EndCase
			EndIf

			cLoteDest := aCols[nLinha][nPosCTLDes]
			If Empty(cLoteDest) .And. !Empty(aCols[nLinha][nPosLoTCTL])
				cLoteDest := aCols[nLinha][nPosLoTCTL]
			EndIf

			If ( lRet )
				//Validacao Data de Validade Destino
				SB8->( dbSetOrder( 3 ) ) //"B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)"
				If SB8->( dbSeek( FWxFilial( 'SB8' ) + Padr( aCols[ nLinha ][ nPosCODDes ], TamSx3( 'B8_PRODUTO' )[ 1 ] ) + Padr( aCols[ nLinha ][ nPosLOCDes ], TamSx3( 'B8_LOCAL' )[ 1 ] ) + Padr(cLoteDest, TamSx3( 'B8_LOTECTL' )[ 1 ] ) + Padr( aCols[ nLinha ][ nPosNLOTE  ], TamSx3( 'B8_NUMLOTE' )[ 1 ] ) ) )
					Do Case
					Case ( Empty( SB8->B8_DTVALID ) )
						lRet := .T.
					Case !( Empty( SB8->B8_DTVALID ) ) .And. ( Empty( aCols[ nLinha ][ nPosDLtDes ] ) )
						aCols[ nLinha ][ nPosDLtDes ] := SB8->B8_DTVALID
						lRet := .T.
					Case !( Empty( SB8->B8_DTVALID ) ) .And. !( Empty( aCols[ nLinha ][ nPosDLtDes ] ) )
						If !( SB8->B8_DTVALID == aCols[ nLinha ][ nPosDLtDes ] )
							aCols[ nLinha ][ nPosDLtDes ] := SB8->B8_DTVALID
							If !lAutoma261
								Help(" ",1,"A240DTVALI")
							EndIf
						EndIf
					EndCase
				EndIf

			EndIf
		EndIf
	EndIf

	//���������������������������������������������������������Ŀ
	//� Verifica se o produto origem e destino sao diferentes.  �
	//�����������������������������������������������������������
	If lRet
		If aCols[nLinha,nPosCODOri]+aCols[nLinha,nPosUmOrig]+aCols[nLinha,nPosLOCOri]+aCols[nLinha,nPosLcZOri]+aCols[nLinha,nPosLotCTL] == aCols[nLinha,nPosCODDes]+aCols[nLinha,nPosUmDest]+aCols[nLinha,nPosLOCDes]+aCols[nLinha,nPosLcZDes]+If(!Empty(aCols[nLinha,nPosCTLDes]),aCols[nLinha,nPosCTLDes],aCols[nLinha,nPosLotCTL])
			Help(" ",1,"MA260IGUAL")
			lRet := .F.
		EndIf
	EndIf

	//���������������������������������������������������������Ŀ
	//� Validacao WMS.                                          �
	//�����������������������������������������������������������
	If lRet .And. !lWmsSD3

		//Retorna falso caso um produto integre com WMS e o outro n�o
		If lFnWMSValT
			lRet := WMSValTPOD(aCols[nLinha,nPosCODOri], aCols[nLinha,nPosCODDes])
		EndIf

		If lRet .And. IntWMS(aCols[nLinha,nPosCODDes])
			cCodOrig   := aCols[nLinha,nPosCODOri]
			cLocOrig   := aCols[nLinha,nPosLOCOri]
			cLoclzOrig := aCols[nLinha,nPosLcZOri]
			cCodDest   := aCols[nLinha,nPosCODDes]
			cLocDest   := aCols[nLinha,nPosLOCDes]
			cLoclzDest := aCols[nLinha,nPosLcZDes]
			cNumSerie  := aCols[nLinha,nPosNSer]
			cLoteDigi  := aCols[nLinha,nPosLoTCTL]
			cNumLote   := aCols[nLinha,nPosNLOTE]
			nQuant261  := aCols[nLinha,nPosQUANT]
			cServico   := aCols[nLinha,nPosServic]
			If !lWmsNew
				lRet := WMSVldTran(cDocumento,cServico,cCodOrig, cLocOrig, cLoclzOrig, cCodDest, cLocDest, cLoclzDest, cLoteDigi, cNumLote, cNumSerie, nQuant261)
			Else
				If !Empty(cLoclzDest)
					oMovimento := WMSBCCTransferencia():New()
					// Endereco Origem
					oMovimento:oMovEndOri:SetArmazem(cLocOrig)
					oMovimento:oMovEndOri:SetEnder(cLoclzOrig)
					// Endereco Destino
					oMovimento:oMovEndDes:SetArmazem(cLocDest)
					oMovimento:oMovEndDes:SetEnder(cLoclzDest)
					// Produto
					oMovimento:oMovPrdLot:SetArmazem(cLocDest)
					oMovimento:oMovPrdLot:SetProduto(cCodOrig)
					oMovimento:oMovPrdLot:SetLoteCtl(cLoteDigi)
					oMovimento:oMovPrdLot:SetNumLote(cNumLote)
					oMovimento:oMovPrdLot:SetNumSer(cNumSerie)
					// Servi�o
					oMovimento:oMovServic:SetServico(cServico)
					oMovimento:oOrdServ:SetDocto(cDocumento)
					oMovimento:oMovPrdLot:SetPrdOri(cCodOrig)
					// Dados Endere�o Origem
					oMovimento:oMovEndOri:SetArmazem(cLocOrig)
					oMovimento:oMovEndOri:SetEnder(cLoclzOrig)
					// Dados Endere�o Destino
					oMovimento:oMovEndDes:SetArmazem(cLocDest)
					oMovimento:oMovEndDes:SetEnder(cLoclzDest)
					oMovimento:SetQuant(nQuant261)
					If !oMovimento:VldGeracao()
						WmsMessagem(oMovimento:GetErro(),"SIGAWMS",5/*MSG_HELP*/)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		For nX := 1 To Len(aCols)
			If nX # nLinha .And. !aCols[nx,Len(aCols[nx])] .And. aCols[nLinha,nPosCODOri]+aCols[nLinha,nPosLOCOri]+aCols[nLinha,nPosCODDes]+aCols[nLinha,nPosLOCDes]+aCols[nLinha,nPosNSer]+aCols[nLinha,nPosNLOTE]+aCols[nLinha,nPosLoTCTL]+aCols[nLinha,nPosLcZOri]+aCols[nLinha,nPosLcZDes]+aCols[nLinha,nPosCTLDes] == aCols[nX,nPosCODOri]+aCols[nX,nPosLOCOri]+aCols[nX,nPosCODDes]+aCols[nX,nPosLOCDes]+aCols[nX,nPosNSer]+aCols[nX,nPosNLOTE]+aCols[nX,nPosLoTCTL]+aCols[nX,nPosLcZOri]+aCols[nX,nPosLcZDes]+aCols[nX,nPosCTLDes]
				Help(' ',1,'A242JACAD')
				lRet := .F.
			EndIf
		Next nX
	EndIf

	If lret
		If aCols[nLinha,nPosLOcOri] == aCols[nLinha,nPosLocDes] .and. aCols[nLinha,nPosLOcOri] == cLocCQ .and. aCols[nLinha,nPosLoTCTL] <> cLoteDest
			Help(' ',1,'A260LOCCQ')
			lRet := .F.
		EndIf
	EndIf	
	If lRet .And. lAutoma261
		lRet := A261Quant(.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� ExecBlock para validar transferencias.                       �
	//����������������������������������������������������������������

	If lRet .And. ExistBlock("MA261LIN")
		lRet := Execblock("MA261LIN",.f.,.f.,{nLinha})
		lRet := If(ValType(LRet)#"L",.T.,lRet)
	EndIf
EndIf

If lRet //Origem
	lRet := a241vldfan(aCols[n][nPosCODOri])
EndIf
If lRet //Destino
	lRet := a241vldfan(aCols[n][nPosCODDes])
EndIf

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261VldCod� Autor � Marcelo Pimentel      � Data � 29/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina p/ iniciar campos a partir do produto informado.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261VldCod(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = 1 - inicializa campos do codigo origem             ���
���          �         2 - inicializa campos do codigo destino            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261VldCod(nOrigDest)

Local aArea       := { Alias(),IndexOrd(),Recno() }
Local aSB1Area    := { 'SB1', SB1->(IndexOrd()),SB1->(Recno()) }
Local aSB2Area    := { 'SB2', SB2->(IndexOrd()),SB2->(Recno()) }
Local aSB8Area    := { 'SB8', SB8->(IndexOrd()),SB8->(Recno()) }
Local cVar        := &(ReadVar())
Local cProdRef	  := ''
Local lRet        := .T.
Local lContinua	  := .T.
Local lRastroO    := .F.
Local lRastroD    := .F.
Local lLocalizO   := .F.
Local lLocalizD   := .F.
Local lCAT83      := .F.
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri  := 1 	//Codigo do Produto Origem
Local nPosDOri    := 2	//Descricao do Produto Origem
Local nPosUMOri   := 3	//Unidade de Medida Origem
Local nPosLOCOri  := 4	//Armazem Origem
Local nPosLcZOri  := 5	//Localizacao Origem
Local nPosCODDes  := 6	//Codigo do Produto Destino
Local nPosDDes    := 7	//Descricao do Produto Destino
Local nPosUMDes   := 8	//Unidade de Medida Destino
Local nPosLOCDes  := 9	//Armazem Destino
Local nPosLcZDes  := 10	//Localizacao Destino
Local nPosLoTCTL  := 12	//Lote de Controle
Local nPosNLOTE   := 13 //Numero do Lote
Local nPosDTVAL   := 14	//Data Valida
Local nPosPotenc  := 15	//Potencia do Lote
Local nPosDTVALD  := 21	//Data Validade de Destino
Local nPosQUANT	  := 16	//Quantidade
Local nPosQTSEG	  := 17	//Quantidade na 2a. Unidade de Medida
Local lExistBlock := ExistBlock("A261PROD")
Local lReferencia := .F.
Local lGrade      := MaGrade()
Local lWmsNew	  := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lExecSD3	  := If(!(Type('lExecWms')=='U'), lExecWms, .F.)
Local cProdAux    := ""

If ReadVar() # 'M->D3_COD'
	//-- Retorna Integridade do Sistema
	dbSelectArea(aSB1Area[1]); dbSetOrder(aSB1Area[2]); dbGoto(aSB1Area[3])
	dbSelectArea(aSB2Area[1]); dbSetOrder(aSB2Area[2]); dbGoto(aSB2Area[3])
	dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])

	lContinua := .F.
	cProdAux := aCols[n,nPosCODOri]
Else
	cProdAux := M->D3_COD
EndIf

IF lGrade
	cProdRef    := cVar
	lReferencia := MatGrdPrrf(@cProdRef)
Endif

//������������������Ŀ
//� Portaria CAT83   |
//��������������������
If V240CAT83()
    lCAT83:=.T.
EndIf

//��������������������������������������������������������������Ŀ
//� Executa PE na digitacao do campo                             �
//����������������������������������������������������������������
If lContinua .And. lRet .And. ExistBlock("A261INI")
	lRet := Execblock("A261INI",.F.,.F.,{cVar,nOrigDest})
	lRet := If(ValType(lRet) != "L", .T., lRet)
	lContinua := lRet
EndIf

//�������������������������������������������������Ŀ
//�Verifica se o usuario tem permissao de inclusao. �
//���������������������������������������������������
If lRet .And. INCLUI
	If nOrigDest == 1
		lRet := MaAvalPerm(1,{M->D3_COD,"MTA260",3})
	Else
		lRet := MaAvalPerm(1,{aCols[n][nPosCodDes],"MTA260",3})
	EndIf
	If !lRet
		Help(,,1,'SEMPERM')
	EndIf
EndIf

If lContinua
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If M->D3_COD <> cVar
		Help(' ',1,'NOFOUNDSB1')
		//-- Retorna Integridade do Sistema
		dbSelectArea(aSB1Area[1]); dbSetOrder(aSB1Area[2]); dbGoto(aSB1Area[3])
		dbSelectArea(aSB2Area[1]); dbSetOrder(aSB2Area[2]); dbGoto(aSB2Area[3])
		dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])
		lContinua	:= .F.
		lRet		:= .F.
	EndIf
EndIf

// Utilizado para verificar se quando o produdo for WMS novo n�o efetuar transferencias
If lRet .And. lWmsNew .And. IntWMS(M->D3_COD) .And. !lExecSD3
	Help(" ",1,"A260WMS",,'Produto informado controlado por WMS n�o � possivel efetuar a transfer�ncia! Utilize o monitor de transfer�ncia WMS!',1,0)
	lRet:= .F.
	lContinua	:= .F.
EndIf

If lContinua
	//-- Preenche Campos do aCols
	SB2->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	If nOrigDest == 1 .And. SB1->(dbSeek(xFilial('SB1')+M->D3_COD, .F.))
		aCols[n,nPosCODOri]		:= PAD(cVar,len(SD3->D3_COD))
		aCols[n,nPosDOri]		:= IIF(AllTrim(aCols[n,nPosCODOri]) == "","", SB1->B1_DESC)
		aCols[n,nPosUMOri]		:= IIF(AllTrim(aCols[n,nPosCODOri]) == "","", SB1->B1_UM)
		aCols[n,nPosLOCOri]		:= If(SB2->(dbSeek(xFilial('SB2')+cVar+RetFldProd(SB1->B1_COD,"B1_LOCPAD"),.F.)),RetFldProd(SB1->B1_COD,"B1_LOCPAD"),Space(Len(aCols[n,nPosLOCOri])))
		If Empty(aCols[n,nPosCODDes]) .or. aCols[n,nPosCODDes] <> aCols[n,nPosCODOri]
			aCols[n,nPosCODDes]		:= PADR(cVar,Len(SD3->D3_COD))
			aCols[n,nPosDDes]		:= SB1->B1_DESC
			aCols[n,nPosUMDes]		:= SB1->B1_UM
		EndIf
		aCols[n,nPosLcZOri]		:= Space(Len(aCols[n,nPosLcZOri]))
		aCols[n,nPosLoTCTL]		:= Space(Len(aCols[n,nPosLoTCTL]))
		aCols[n,nPosNLOTE]		:= Space(Len(aCols[n,nPosNLOTE]))
	ElseIf nOrigDest == 2 .And. SB1->(dbSeek(xFilial('SB1')+M->D3_COD, .F.))
		aCols[n,nPosCODDes]		:= PAD(cVar,len(SD3->D3_COD))
		aCols[n,nPosDDes]		:= SB1->B1_DESC
		aCols[n,nPosUMDes]		:= SB1->B1_UM
		aCols[n,nPosLOCDes]		:= Space(Len(aCols[n,nPosLOCDes]))
		aCols[n,nPosLcZDes]		:= Space(Len(aCols[n,nPosLcZDes]))
	EndIf
	aCols[n,nPosQTSEG] := ConvUm(cVar,aCols[n,nPosQUANT],aCols[n,nPosQTSEG],2)

	//-- Consiste Igualdade da Origem X Destino
	lRastroO   := Rastro(aCols[n,nPosCODOri])
	lRastroD   := Rastro(aCols[n,nPosCODDes])
	lLocalizO  := Localiza(aCols[n,nPosCODOri],.T.)
	lLocalizD  := Localiza(aCols[n,nPosCODDes],.T.)

	If (!lRastroO .And. !lRastroD) .And. (!lLocalizO .And. lLocalizD)
		If nOrigDest == 1 .And. ;
				(!Empty(aCols[n,nPosLOCOri]) .And. !Empty(aCols[n,nPosCODDes]) .And. !Empty(aCols[n,nPosLOCDes]) .And. ;
				cVar + aCols[n,nPosLOCOri] == aCols[n,nPosCODDes] + aCols[n,nPosLOCDes]) .Or. ;
				nOrigDest == 2 .And. ;
				(!Empty(aCols[n,nPosCODOri]) .And. !Empty(aCols[n,nPosLOCOri]) .And. !Empty(aCols[n,nPosLOCDes]) .And. ;
				aCols[n,nPosCODOri] + aCols[n,nPosLOCOri] == cVar + aCols[n,nPosLOCDes])
			Help(' ',1,'MA260IGUAL')
			//-- Retorna Integridade do Sistema
			dbSelectArea(aSB1Area[1]); dbSetOrder(aSB1Area[2]); dbGoto(aSB1Area[3])
			dbSelectArea(aSB2Area[1]); dbSetOrder(aSB2Area[2]); dbGoto(aSB2Area[3])
			dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])

			lRet 		:= .F.
			lContinua 	:= .F.
		EndIf
	EndIf
EndIf
If lContinua
	If !lRastroO
		aCols[n,nPosDTVAL]	:= CriaVar("D3_DTVALID")
		aCols[n,nPosPotenc]	:= CriaVar("D3_POTENCI")
	EndIf
	If lRastroD
		If Empty(aCols[n,nPosLoTCTL])
			aCols[n,nPosDTVALD]	:= dDataBase
		EndIf
	Else
		aCols[n,nPosDTVALD]	:= CriaVar("D3_DTVALID")
	EndIf
	If lExistBlock
		ExecBlock("A261PROD",.F.,.F.,{cVar,nOrigDest})
	EndIf
EndIf

//-- Retorna Integridade do Sistema
dbSelectArea(aSB1Area[1]); dbSetOrder(aSB1Area[2]); dbGoto(aSB1Area[3])
dbSelectArea(aSB2Area[1]); dbSetOrder(aSB2Area[2]); dbGoto(aSB2Area[3])
dbSelectArea(aSB8Area[1]); dbSetOrder(aSB8Area[2]); dbGoto(aSB8Area[3])
dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])
Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Quant � Autor � Marcelo Pimentel      � Data � 29/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina p/ iniciar campos a partir da Quantidade Informada. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A260Quant(ExpN1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = Flag indicando se valida pela digitacao ou nao     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261Quant(lDigita)

Local aArea       := GetArea()
Local aSB2Area    := { 'SB2', SB2->(IndexOrd()),SB2->(Recno()) }
Local aSB8Area    := { 'SB8', SB8->(IndexOrd()),SB8->(Recno()) }
Local aSBEArea    := { 'SBE', SBE->(IndexOrd()),SBE->(Recno()) }
Local lRet        := .T.
Local lContinua	  := .T.
Local cReadVar    := AllTrim(Upper(ReadVar()))
Local cLocDest    := ""
Local cLoclzDest  := ""
Local nQuant      := 0
Local nQuant2UM   := 0
Local nSaldo      := 0
Local lPermNegat  := GetMV('MV_ESTNEG') == 'S'
Local lRastroL    := .F.
Local lRastroS    := .F.
Local lLocalizO   := .F.
Local lLocalizD   := .F.
Local lValidPE
Local lMT261UM    	:= ExistBlock("MT261UM")
Local nX		  		:= 0
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri 	:= 1 	//Codigo do Produto Origem
Local nPosLOCOri 	:= 4	//Armazem Origem
Local nPosLcZOri 	:= 5	//Localizacao Origem
Local nPosCODDes 	:= 6	//Codigo do Produto Destino
Local nPosLOCDes 	:= 9	//Armazem Destino
Local nPosLcZDes 	:= 10	//Localizacao Destino
Local nPosNSer		:= 11	//Numero de Serie
Local nPosLoTCTL 	:= 12	//Lote de Controle
Local nPosNLOTE		:= 13 	//Numero do Lote
Local nPosVLdLot    := 14	// Dt Validade do Lote
Local nPosQUANT		:= 16	//Quantidade
Local nPosQTSEG		:= 17	//Quantidade na 2a. Unidade de Medida
Local cHelp      	:= ""
Local cLocCQ     	:= GetMvNNR('MV_CQ','98')
Local lEmpPrev   	:= If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local lGrade     	:= MaGrade()
Local lReferencia	:= .F.
Local lSaldoSemR 	:= Nil
Local lWmsNew	  := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS   := Iif(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local lWmsSD3     := If(!(Type('lExecWms')=='U'), lExecWms, .F.)
Local cLotVenc 	  := SuperGetMv("MV_LOTVENC",.F.,"S")
Local lLVEmp	  := Nil	

SB2->(dbSetOrder(1))

cLocDest   := aCols[Len(aCols),nPosLOCDes]
cLoclzDest := aCols[Len(aCols),nPosLcZDes]

//-- Verifica se produto eh referencia de grade
If lGrade
	cVar:=aCols[n,nPosCODOri]
	lReferencia := MatGrdPrrf(@cVar)
Endif

If !lReferencia
	If lDigita .And. cReadVar # 'M->D3d_QUANT' .And. cReadVar # 'M->D3_QTSEGUM'
		lContinua := .F.
	EndIf

	If lContinua .And. lDigita .And. Empty(&(ReadVar()))
		Help(' ',1,'NVAZIO')
		lRet		:= .F.
		lContinua	:= .F.
	EndIf

	If lContinua .And. lDigita .And. QtdComp(&(ReadVar())) < QtdComp(0)
		Help(' ',1,'POSIT')
		lRet		:= .F.
		lContinua	:= .F.
	EndIf

	If lContinua
		If lDigita
			If cReadVar == 'M->D3_QUANT'
				nQuant    := &(ReadVar())
				nQuant2UM := ConvUm(aCols[n,nPosCODOri],&(ReadVar()),aCols[n,nPosQTSEG],2)
			Else
				nQuant    := ConvUm(aCols[n,nPosCODOri],aCols[n,nPosQUANT],&(ReadVar()),1)
				nQuant2UM := &(ReadVar())
			EndIf
		Else
			nQuant    := aCols[n,nPosQUANT]
			nQuant2UM := aCols[n,nPosQTSEG]
		EndIf
		If Empty(aCols[n,nPosCODOri]) .Or. Empty(aCols[n,nPosCODDes])
			Help(' ',1,'MA260OBR')
			lRet		:= .F.
			lContinua	:= .F.
		EndIf
	EndIf

	If lContinua
		lRastroL  := Rastro(aCols[n,nPosCODOri],'L')
		lRastroS  := Rastro(aCols[n,nPosCODOri],'S')
		lLocalizO := Localiza(aCols[n,nPosCODOri],.T.)
		lLocalizD := Localiza(aCols[n,nPosCODDes],.T.)

		//-- Produtos com Rastro ou Localizacao ou integracao com WMS
		//-- Negativo - Impede Movimentacoes que causem Saldo Negativo no SB2
		If !lPermNegat .or. (lRastroL .Or. lRastroS) .or. lLocalizO .Or. a261IntWMS(aCols[n,nPosCODOri])
			SB2->(DbSetOrder(1))
			If !SB2->(dbSeek(xFilial('SB277')+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri], .F.))
				Help(' ',1,'A260Local')
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
			If lContinua
				//-- Subtrai a Reserva do Saldo a ser Retornado?
				If a261IntWMS(aCols[n,nPosCODOri]) .And. lLocalizO .And. aCols[n,nPosCODOri]==aCols[n,nPosCODDes] .And. aCols[n,nPosLOCOri]==aCols[n,nPosLOCDes] .And. aCols[n,nPosLcZOri]#aCols[n,nPosLcZDes]
					lSaldoSemR := .F.
				EndIf
				If cLotVenc == 'N' .and. aCols[n,nPosVLdLot] < dA261Data .and. aCols[n,nPosLOCDes] == cLocCQ
					lLVEmp := .F.
				EndIf





















				 Daaate :=Type("dA261Data")
				 xPrue := Date()
  				Type( "xPrue" )
				 Xtupi := Type( "xPrue" )
				nSaldo := SaldoMov(Nil,IIf (!lLVEmp,lLVEmp,Nil),Nil,If(mv_par03==1,.F.,Nil),Nil,Nil, lSaldoSemR, If(Type("dA261Data") == "D",dA261Data,dDataBase))
				For nX := If(!lDigita,n+1,1) to Len(aCols)
					If nX # n
						If !aCols[nX,Len(aCols[nX])].And.(If(lRastroL,aCols[n,nPosLoTCTL]==aCols[nX,nPosLoTCTL],.T.).And.If(lRastroS,aCols[n,nPosNLOTE]==aCols[nX,nPosNLOTE],.T.))
							If aCols[n,nPosCODOri] + aCols[n,nPosLOCOri] == aCols[nX,nPosCODOri] + aCols[nX,nPosLOCOri]
								nSaldo -= aCols[nX,nPosQUANT]
							ElseIf aCols[n,nPosCODOri] + aCols[n,nPosLOCOri] == aCols[nX,nPosCODDes] + aCols[nX,nPosLOCDes]
								nSaldo += aCols[nX,nPosQUANT]
							EndIf
						EndIf
					EndIf
				Next nX
				If QtdComp(nSaldo) < QtdComp(nQuant)
					Help(' ',1,'MA240NEGAT',,Iif(len(Acols) > 0,STR0009+ aCols[n,4],' '),3,0)
					lRet		:= .F.
					lContinua	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Produto Origem com Localizacao - Impede Movimentacoes com
	//-- Quantidades maiores que o Saldo no SBF
	If lContinua .And. !lWmsSD3
		If lLocalizO
			If !Empty(aCols[n,nPosLcZDes]).And. (!SBE->(dbSeek(xFilial('SBE')+aCols[n,nPosLOCDes]+aCols[n,nPosLcZDes]))) .AND. lAutoma261
				Help(' ',1,'MA260LOC')
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
			If Empty(aCols[n,nPosLcZOri]+aCols[n,nPosNSer]) .Or. ;
					(!Empty(aCols[n,nPosLcZOri]) .And. !SBE->(dbSeek(xFilial('SBE')+aCols[n,nPosLOCOri]+aCols[n,nPosLcZOri],.F.))) .AND. lContinua
				Help(' ',1,'MA260OBR')
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
			If lContinua
				If (lRastroL .Or. lRastroS) .and. cLotVenc == 'N' .and. aCols[n,nPosVLdLot] < dA261Data .and. aCols[n,nPosLOCDes] == cLocCQ
					lLVEmp := .T.
				EndIf
				If !(lWmsNew .And. a261IntWMS(aCols[n,nPosCODOri]))
					nSaldo := SaldoSBF(aCols[n,nPosLOCOri],aCols[n,nPosLcZOri],aCols[n,nPosCODOri],aCols[n,nPosNSer],aCols[n,nPosLoTCTL],aCols[n,nPosNLOTE],lLVEmp)
				Else
					nSaldo := oSaldoWMS:GetSldWMS(aCols[n,nPosCODOri],aCols[n,nPosLOCOri],aCols[n,nPosLcZOri],aCols[n,nPosLoTCTL],aCols[n,nPosNLOTE],aCols[n,nPosNSer])
				EndIf
				For nX := If(!lDigita,n+1,1) to Len(aCols)
					If nX # n
						If !aCols[nX,Len(aCols[nX])].And.(If(lRastroL,aCols[n,nPosLoTCTL]==aCols[nX,nPosLoTCTL],.T.).And.If(lRastroS,aCols[n,nPosNLOTE]==aCols[nX,nPosNLOTE],.T.))
							If aCols[n,nPosCODOri] + aCols[n,nPosLOCOri] + aCols[n,nPosCODDes] + aCols[n,nPosNSer] == aCols[nX,nPosCODOri] + aCols[nX,nPosLcZOri] + aCols[nX,nPosLcZOri] + aCols[nX,nPosNSer]
								nSaldo -= aCols[nX,nPosQUANT]
							ElseIf aCols[n,nPosCODOri] + aCols[n,nPosLOCOri]  + aCols[n,nPosLcZOri] + aCols[n,nPosNSer] == aCols[nX,nPosCODDes] + aCols[nX,nPosLOCDes] + aCols[nX,nPosLcZDes] + aCols[nX,nPosNSer]
								nSaldo += aCols[nX,nPosQUANT]
							EndIf
						EndIf
					EndIf
				Next nX
				If QtdComp(nSaldo) < QtdComp(nQuant)
					Help(' ',1,'SALDOLOCLZ')
					lRet		:= .F.
					lContinua	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Produto Destino com Localizacao - Impede Movimentacoes com
	//-- Quantidades superiores a Capacidade no SBE
	If lContinua .And. lLocalizD .And. !lWmsSD3
		If !Empty(aCols[n,nPosLcZDes]) .And. !SBE->(dbSeek(xFilial('SBE')+aCols[n,nPosLOCDes]+aCols[n,nPosLcZDes])) .AND. lAutoma261
			Help(' ',1,'MA260LOC')
			lRet		:= .F.
			lContinua	:= .F.
		EndIf
		If (aCols[n,nPosLOCDes] == cLocCQ .And. Empty(aCols[n,nPosLcZDes]+aCols[n,nPosNSer])) .Or. ;
				(!Empty(aCols[n,nPosLcZDes]) .And. !SBE->(dbSeek(xFilial('SBE')+aCols[n,nPosLOCDes]+aCols[n,nPosLcZDes],.F.))) .AND. lContinua
			Help(' ',1,'MA260OBR')
			lRet		:= .F.
			lContinua	:= .F.
		EndIf
		If lContinua
			If !(lWmsNew .And. a261IntWMS(aCols[n,nPosCODOri]))
				nSaldo := QuantSBF(aCols[n,nPosLOCDes],aCols[n,nPosLcZDes],aCols[n,nPosCODDes])
			Else
				nSaldo := oSaldoWMS:GetSldWMS(aCols[n,nPosCODDes],aCols[n,nPosLOCDes],aCols[n,nPosLcZDes])
			EndIf
			For nX := If(!lDigita,n+1,1) to Len(aCols)
				If nX # n
					If !aCols[nX,Len(aCols[nX])].And.(If(lRastroL,aCols[n,nPosLoTCTL]==aCols[nX,nPosLoTCTL],.T.).And.If(lRastroS,aCols[n,nPosNLOTE]==aCols[nX,nPosNLOTE],.T.))
						If	aCols[n,nPosCODDes] + aCols[n,nPosLOCDes] + aCols[n,nPosLcZDes] == aCols[nX,nPosCODOri] + aCols[nX,nPosLOCOri] + aCols[nX,nPosLcZOri]
							nSaldo -= aCols[nX,nPosQUANT]
						ElseIf aCols[n,nPosCODDes] + aCols[n,nPosLOCDes] + aCols[n,nPosLcZDes] == aCols[nX,nPosCODDes] + aCols[nX,nPosLOCDes] + aCols[nX,nPosLcZDes]
							nSaldo += aCols[nX,nPosQUANT]
						EndIf
					EndIf
				EndIf
			Next nX
			If SBE->(!Eof()) .And. QtdComp(SBE->BE_CAPACID)>QtdComp(0) .And. (QtdComp(SBE->BE_CAPACID)<QtdComp(nQuant+QuantSBF(cLocDest, cLoclzDest))) .And. !a261IntWMS(aCols[n,nPosCODDes])
				Help(' ',1,'MA265CAPAC')
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
		EndIf
	EndIf

	//-- Produto Origem com Rastro - Impede Movimentacoes com Quantidades
	//-- maiores que as existentes no Lote/SubLote de Origem
	If lContinua .And. (lRastroL .Or. lRastroS)
		If lRastroL
			dbSelectArea("SB8")
			SB8->(dbSetOrder(3))
			If !SB8->(dbSeek(xFilial('SB8')+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri]+aCols[n,nPosLoTCTL],.F.))
				Help(' ', 1, 'A240LOTERR')
				lRet		:= .F.
				lContinua	:= .F.
			Else
				If cLotVenc == 'N' .and. aCols[n,nPosVLdLot] < dA261Data .and. aCols[n,nPosLOCDes] == cLocCQ
					nSaldo := SaldoLote(aCols[n,nPosCODOri],aCols[n,nPosLOCOri],aCols[n,nPosLoTCTL],NIL,NIL,NIL,NIL,aCols[n,nPosVLdLot],,.T.)
				Else 
				    nSaldo := SaldoLote(aCols[n,nPosCODOri],aCols[n,nPosLOCOri],aCols[n,nPosLoTCTL],NIL,NIL,NIL,NIL,dA261Data)
			    EndIf
			EndIf
		ElseIf lRastroS
			SB8->(dbSetOrder(2))
			If !SB8->(dbSeek(xFilial('SB8')+aCols[n,nPosNLOTE]+aCols[n,nPosLoTCTL]+aCols[n,nPosCODOri]+aCols[n,nPosLOCOri],.F.))
				Help(' ', 1, 'A240LOTERR')
				lRet		:= .F.
				lContinua	:= .F.
			Else
				nSaldo := SB8Saldo(nil,.T.,nil,nil,nil,lEmpPrev,nil,dA261Data)
			EndIf
		EndIf
		If lContinua
			For nX := If(!lDigita,n+1,1) to Len(aCols)
				If nX # n
					If !aCols[nX,Len(aCols[nX])].And.(If(lRastroL,aCols[n,nPosLoTCTL]==aCols[nX,nPosLoTCTL],.T.).And.If(lRastroS,aCols[n,nPosNLOTE]==aCols[nX,nPosNLOTE],.T.))
						If aCols[n,nPosCODOri] + aCols[n,nPosLOCOri] + aCols[n,nPosLoTCTL] + If(lRastroS,aCols[n,nPosNLOTE],'') == aCols[nX,nPosCODOri] + aCols[nX,nPosLOCOri] + aCols[nX,nPosLoTCTL] + If(lRastroS,aCols[nX,nPosNLOTE],'')
							nSaldo -= aCols[nX,nPosQUANT]
						EndIf
					EndIf
				EndIf
			Next nX
			If QtdComp(nSaldo) < QtdComp(nQuant)
				cHelp:=Substr(STR0006,1,4)+" "+aCols[n,nPosCODOri]+Substr(STR0018,1,4)+" "+aCols[n,nPosLoTCTL]
				Help(" ",1,"MA240NEGAT",,cHelp,4,1)
				lRet		:= .F.
				lContinua	:= .F.
			EndIf
		EndIf
	EndIf
	If lContinua
		aCols[n,nPosQUANT] := nQuant
		aCols[n,nPosQTSEG] := nQuant2UM
	EndIf
	//-- Retorna Integridade do Sistema
	SB2->(dbSelectArea(aSB2Area[1])); SB2->(dbSetOrder(aSB2Area[2])); SB2->(dbGoto(aSB2Area[3]))
	SB8->(dbSelectArea(aSB8Area[1])); SB8->(dbSetOrder(aSB8Area[2])); SB8->(dbGoto(aSB8Area[3]))
	SBE->(dbSelectArea(aSBEArea[1])); SBE->(dbSetOrder(aSBEArea[2])); SBE->(dbGoto(aSBEArea[3]))
	RestArea(aArea)
Endif
If lMT261UM
	lValidPE := ExecBlock("MT261UM",.F.,.F.,{nQuant,nQuant2UM,lRet})
	If ValType(lValidPE) == "L"
		lRet := lValidPE
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Locali� Autor � Marcelo Pimentel      � Data � 30/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida as Localizacoes da transferencia                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261Locali(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Indica se e Origem / Destino                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261Locali(nOrigDest)
Local aArea      := { Alias()	, IndexOrd() , Recno() }
Local aSBEArea   := { 'SBE'	, SBE->(IndexOrd()) , SBE->(Recno()) }
Local lRet       := .T.
Local lContinua	 := .T.
Local cLocaliz   := &(ReadVar())

nOrigDest := If(nOrigDest==NIL,1,nOrigDest)

If ReadVar() # 'M->D3_LOCALIZ'
	lContinua := .F.
EndIf
If lContinua
	If nOrigDest == 1
		If Empty(aCols[n,1]) .Or. Empty(aCols[n,4])
			Help(' ',1,'MA260OBR')
			lRet:=.F.
		EndIf
		If lRet
			lRet:=ExistCpo('SBE',aCols[n,4]+cLocaliz)
		EndIf
		If lRet .And. !Localiza(aCols[n,1],.T.)
			&(ReadVar()) := Space(Len(&(ReadVar())))
		EndIf
	Else
		If Empty(aCols[n,6]) .Or. Empty(aCols[n,9])
			Help(' ',1,'MA260OBR')
			lRet:=.F.
		EndIf

		If lRet .And. Localiza(aCols[n,6],.T.)
			lRet:=ExistCpo('SBE',aCols[n,9]+cLocaliz)
			If lRet
				lRet:=ProdLocali(aCols[n,6],aCols[n,9],cLocaliz)
			EndIf
		Else
			&(ReadVar()) := Space(Len(&(ReadVar())))
		EndIf
	EndIf
EndIf
//-- Retorna Integridade do Sistema
dbSelectArea(aSBEArea[1]); dbSetOrder(aSBEArea[2]); dbGoto(aSBEArea[3])
dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])
Return lRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Almox  � Autor � Fernando Joly Siquini � Data � 04/03/99 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do campo Local                                    ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261Almox(ExpN1)                                            ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Indica se e Origem / Destino                        ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function A261Almox(nOrigDest,cLocOrig)
Static l261Local  := NIL
Local aArea       := { Alias()	, IndexOrd() , Recno() }
Local aSB2Area    := { 'SB2'	, SB2->(IndexOrd()) , SB2->(Recno()) }
Local lRet        := .T.
Local lContinua	  := .T.
Local lRastroO    := .F.
Local lRastroD    := .F.
Local lLocalizO   := .F.
Local lLocalizD   := .F.
Local cLocal      := IIF (lAutoma261,cLocOrig , &(ReadVar()))
Local cLocCQ      := GetMvNNR('MV_CQ','98')
Local cLocProc	:= GetMvNNR('MV_LOCPROC','99')
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosCODOri  := 1	//Codigo do Produto Origem
Local nPosLOCOri  := 4	//Armazem Origem
Local nPosCODDes  := 6	//Codigo do Produto Destino
Local nPosLOCDes  := 9	//Armazem Destino
Local lGrade      := MaGrade()
Local cVar        :=" "
Local lReferencia := .F.

Default cLocOrig := ''

cLocal    := If(Empty(cLocOrig),&(ReadVar()),cLocOrig)
l261Local := If(l261Local==NIL,ExistBlock("A261LOC"),l261Local)
nOrigDest := If(nOrigDest==NIL,1,nOrigDest)

If Empty(cLocOrig) .And. ReadVar() # 'M->D3_LOCAL'
	lContinua := .F.
EndIf

If lContinua .And. Empty(cLocal)
	if lAutoma261
		Help(' ',1,'A261VZNNR',,'N�o informado dep�sito origem',1,1)
	Else
		Help(' ',1,'NVAZIO')
	Endif
	lContinua 	:= .F.
	lRet		:= .F.
EndIf

If lContinua
	SB2->(dbSetOrder(1))

	If nOrigDest == 1

		If Empty(aCols[n,nPosCODOri])
			Help(' ',1,'MA260OBR')
			lContinua	:= .F.
			lRet		:= .F.
		EndIf

		If lContinua
			lRastroO  := Rastro(aCols[n,nPosCODOri])
			lLocalizO := Localiza(aCols[n,nPosCODOri],.T.)

			If !lAutoma261 .and. cLocal == cLocCQ .and. !lLocalizO
				Help(' ',1,'A260LOCCQ')
				lContinua	:= .F.
				lRet		:= .F.
			ElseIf !lAutoma261 .and. cLocal == cLocProc .And. If(Empty(aCols[n,nPosCODOri]).Or.!FindFunction('A260ApropI'),.T.,A260ApropI(aCols[n,nPosCODOri]))	//-- Soh impede transferencia do Armazem de Processo se o Produto for de "Apropriacao Indireta"
				If Aviso(STR0026,STR0052,{STR0050,STR0051}) == 2
					lRet:=.F.
					lContinua	:= .F.
				EndIf
			EndIf
		EndIf
		If lContinua .And. l261Local
			ExecBlock("A261LOC",.F.,.F., {aCols[n,nPosCODOri],cLocal,nOrigDest})
		EndIf

		If lContinua
			If lGrade
				cVar:=aCols[n,nPosCODOri]
				lReferencia := MatGrdPrrf(@cVar)
			Endif
			If !lReferencia
				dbSelectArea("SB2")
				dbSetOrder(1)
				If !SB2->(dbSeek(xFilial('SB2')+aCols[n,nPosCODOri]+cLocal,.F.))
					Help(' ',1,'A260Local')
					lContinua	:= .F.
					lRet		:= .F.
				EndIf
				If !ExistCpo("NNR",cLocal)//verifica se a versao suporta a tabela NNR
				    lContinua := .F.
				    lRet		:= .F.
				Endif
			EndIf
		EndIf
		If lContinua .And. !Empty(aCols[n,nPosCODDes]) .And. !Empty(aCols[n,nPosLOCDes])
			lRastroD  := Rastro(aCols[n,nPosCODDes])
			lLocalizD := Localiza(aCols[n,nPosCODDes],.T.)
			If (!lRastroO .And. !lRastroD) .And. (!lLocalizO .And. !lLocalizD) .And. ;
					aCols[n,nPosCODOri]+cLocal == aCols[n,nPosCODDes]+aCols[n,nPosLOCDes]
				Help(' ',1,'MA260IGUAL')
				lContinua	:= .F.
				lRet		:= .F.
			EndIf
		EndIf

	Else

		If Empty(aCols[n,nPosCODDes])
			Help(' ',1,'MA260OBR')
			lContinua	:= .F.
			lRet		:= .F.
		EndIf

		If lContinua
			lRastroD  := Rastro(aCols[n,nPosCODDes])
			lLocalizD := Localiza(aCols[n,nPosCODDes],.T.)

			If l261Local
				ExecBlock("A261LOC",.F.,.F., {aCols[n,nPosCODDes],cLocal,nOrigDest})
			EndIf
			If lGrade
				cVar:=aCols[n,nPosCODDes]
				lReferencia := MatGrdPrrf(@cVar)
			Endif

			If !lReferencia
				If !SB2->(dbSeek(xFilial('SB2')+aCols[n,nPosCODDes]+cLocal,.F.)) .And. GetMV('MV_VLDALMO') == 'S'
					Help(' ',1,'A260Local')
					lContinua	:= .F.
					lRet		:= .F.
				EndIf
				If !ExistCpo("NNR",cLocal)//Verifica se a versao suporta a tabela NNR
				    lContinua := .F.
				    lRet		:= .F.
				Endif
			Endif
			If lContinua
				If aCols[Len(aCols),nPosLOCOri] == cLocCq .AND. cLocal != cLocCq
					Help(' ',1,'A260LOCCQ')
					lContinua	:= .F.
					lRet		:= .F.
				EndIf
			EndIf
			If lContinua .And. cLocal == cLocProc .And. If(Empty(aCols[n,nPosCODDes]),.T.,A260ApropI(aCols[n,nPosCODDes]))	//-- Soh impede transferencia do Armazem de Processo se o Produto for de "Apropriacao Indireta"
				If !lAutoma261 .and. lContinua .And. cLocal == cLocProc .And. If(Empty(aCols[n,nPosCODDes]).Or.!FindFunction('A260ApropI'),.T.,A260ApropI(aCols[n,nPosCODDes]))	//-- Soh impede transferencia do Armazem de Processo se o Produto for de "Apropriacao Indireta"
					If Aviso(STR0026,STR0053,{STR0050,STR0051}) == 2
						lRet:=.F.
						lContinua	:= .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If lContinua .And. !Empty(aCols[n,nPosCODOri]) .And. !Empty(aCols[n,nPosLOCOri])
			lRastroO  := Rastro(aCols[n,nPosCODOri])
			lLocalizO := Localiza(aCols[n,nPosCODOri],.T.)
			If (!lRastroO .And. !lRastroD) .And. ;
					(!lLocalizO .And. !lLocalizD) .And. ;
					aCols[n,nPosCODOri]+aCols[n,nPosLOCOri] == aCols[n,nPosCODDes]+cLocal
				Help(' ',1,'MA260IGUAL')
				lContinua	:= .F.
				lRet		:= .F.
			EndIf
		EndIf
	EndIf
EndIf
//-- Retorna Integridade do Sistema
dbSelectArea(aSB2Area[1]); dbSetOrder(aSB2Area[2]); dbGoto(aSB2Area[3])
dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Data  � Autor � Marcelo Pimentel      � Data � 30/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do campo Data de Emissao                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261Data()

Local dData
Local dDataFec := MVUlmes()
Local lRet := .T.

dData:= &(ReadVar())
//��������������������������������������������������������������Ŀ
//� Verificar data do ultimo fechamento em SX6.                  �
//����������������������������������������������������������������
If dDataFec >= dData
	Help ( ' ', 1, 'FECHTO' )
	lRet := .F.
EndIf

Return lRet



/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a261DesAtu� Autor � Marcelo Pimentel      � Data �05/02/98  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Estorno                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function a261Desatu()

Local aArea      := { Alias()	, IndexOrd() , Recno() }
Local bCampo     := {|nCPO| Field(nCPO) }
Local aCusto     := {}
Local lRet       := .T.
Local lContinua	 := .T.
Local cServico   := ""
Local nX         := 0
Local cMemo
Local cVar
Local nMem
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local ld3kLimp	:= Findfunction('MatLimpD3K')

//����������������������������������������������������������������������Ŀ
//� Inicializa variaveis para campos Memos Virtuais             		 �
//������������������������������������������������������������������������
If Type("aMemos")=="A"  .And. Len(aMemos) > 0
	For nMem :=1 To Len(aMemos)
		cMemo := aMemos[nMem][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(SX3->X3_RELACAO)
		Else
			&cMemo := ""
		EndIf
	Next nMem
EndIf

//-- Verifica se o custo medio � calculado On-Line e, se necessario, cria o
//-- cabecalho do arquivo de Prova
If cCusMed == 'O' .And. lCriaHeade
	lCriaHeade := .F.
	If (nHdlPrv := HeadProva(cLoteEst,'MATA261',Subs(cUsuario,7,6),@cArquivo)) <= 0
		//-- Retorna Integridade do Sistema
		dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//-- Estorna a Movimenta��o Atual
	RecLock('SD3',.F.)
	Replace SD3->D3_ESTORNO With 'S'
	MsUnlock()

	//-- Salva o Conteudo dos campos da Movimenta��o Atual
	For nX := 1 to SD3->(fCount())
		M->&(Eval(bCampo,nX)) := SD3->(FieldGet(nX))
	Next nX

	//-- Cria o registro de estorno com mesmos dados do original
	RecLock('SD3',.T.)
	For nX := 1 to SD3->(fCount())
		SD3->(FieldPut(nX,M->&(Eval(bCampo,nX))))
	Next nX
	Replace SD3->D3_CF  With If(Left(SD3->D3_CF,1)=='D','R','D')+Subs(SD3->D3_CF,2,2),;
		SD3->D3_TM      With If(Left(SD3->D3_CF,1)=='D','499','999'),;
		SD3->D3_CHAVE   With 'E'+If(Left(SD3->D3_CF,1)=='D','9','0'),;
		SD3->D3_USUARIO With CUSERNAME,;
		SD3->D3_SERVIC  With ''
	//�������������������������������������������������������������������Ŀ
	//�Estorna os campos Memos Virtuais					 				  �
	//���������������������������������������������������������������������
	If Type("aMemos") == "A"  .And.  Len(aMemos) > 0
		For nMem := 1 to Len(aMemos)
			cVar := aMemos[nMem][2]
			MSMM(,TamSx3(aMemos[nMem][2])[1],,&cVar,1,,,"SD3",aMemos[nMem][1])
		Next nMem
	EndIf
	MsUnlock()
	If ld3kLimp
		MatLimpD3K(SD3->D3_COD,SD3->D3_NUMSEQ)
	EndIf

	aAdd(aRegSD3,SD3->(Recno()))
	//-- Ponto de Entrada apos a gravacao do estorno
	If lMA261Exc
		ExecBlock('MA261EXC',.F.,.F.)
	EndIf
	//-- Pega o custo da movimentacao
	aCusto := PegaCusD3()

	//-- Atualiza o saldo atual (VATU) com os dados do SD3
	B2AtuComD3(aCusto,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cServico)
	aRegSD3:={}
	//-- Verifica se o custo medio � calculado On-Line
	If cCusMed == 'O'
		//�������������������������������������������������Ŀ
		//� Gera o lancamento no arquivo de prova           �
		//���������������������������������������������������
		If SD3->D3_TM <= "500"
			nTotal+=DetProva(nHdlPrv,"672","MATA261",cLoteEst)
		Else
			nTotal+=DetProva(nHdlPrv,"670","MATA261",cLoteEst)
		EndIf
		If ( UsaSeqCor() ) .AND. Type("aCtbDia") == "A"
			aAdd(aCtbDia,{"SD3",SD3->(RECNO()),"","D3_NODIA","D3_DIACTB"})
		Else
			aCtbDia := {}
		EndIF
	EndIf

	//-- Integracao SIGAWMS - Realiza o Estorno do Servico
	If a261IntWMS(SD3->D3_COD) .And. !Empty(SD3->D3_SERVIC)
		If !lWmsNew
			cServico := SD3->D3_SERVIC
			WmsDelDCF('1','SD3')
		Else
			// Estorno [NOVO WMS]
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
			If oOrdSerDel:LoadData()
				If !oOrdSerDel:DeleteDCF()
					Help( ,1,"SIGAWMS",,oOrdSerDel:GetErro(),1,0)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ShowF4   � Autor � Fernando Joly Siquini � Data � 13/04/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada da funcao F4                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum/nao utilizados									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum		                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ShowF4(a,b,c)
Local nHdl := GetFocus()
If AllTrim(Upper(ReadVar())) $ 'M->D3_COD�M->D3_QUANT'
	MaViewSB2(aCols[n,1])
ElseIf AllTrim(Upper(ReadVar())) $ 'M->D3_NUMLOTE�M->D3_LOTECTL'
	If oGet:oBrowse:nColPos == 20
		F4Lote(,,,   'A261',aCols[n,6],aCols[n,9],NIL,aCols[n,10],2,,,.F.)
	Else
		F4Lote(,,,   'A261',aCols[n,1],aCols[n,4],NIL,aCols[n,5],2)
	EndIf
ElseIf AllTrim(Upper(ReadVar())) == 'M->D3_LOCALIZ' .Or. AllTrim(Upper(ReadVar())) == 'M->D3_NUMSERI'
	If oGet:oBrowse:nColPos == 10
		F4Localiz(,,,   'A261', aCols[n,6], aCols[n,9],, ReadVar(),.F.,,(AllTrim(Upper(ReadVar()))=='M->D3_NUMSERI') )
	Else
		F4Localiz(,,,   'A261', aCols[n,1], aCols[n,4],, ReadVar(),,,(AllTrim(Upper(ReadVar()))=='M->D3_NUMSERI') )
	EndIf
EndIf
SetFocus(nHdl)
Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A261Lote   � Autor � Fernando Joly Siquini � Data � 24/02/99 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o referente aos campos de Lote e Sub-Lote           ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261Lote(ExpN1)                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Indica validacao 1 - Data de Validade/Potencia 	   ���
���          �         2 - Data de Validade de Destino                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                   ���
��������������������������������������������������������������������������Ĵ��
���Uso       � MATA261                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function A261Lote(nTipo)
Local nPos       := 0
Local aArea      := GetArea()
Local aSB8Area   := SB8->( GetArea() )
Local lRet       := .T.
Local lContinua	 := .T.
Local cVar	     := Upper(ReadVar())
Local cCont      := &(ReadVar())
Local cCodProd   := If((nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_COD'    }))>0,aCols[n, nPos],'')
Local cLocOrig   := If((nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_LOCAL'  }))>0,aCols[n, nPos],'')
Local cLoteCTL   := If((nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_LOTECTL'}))>0,aCols[n, nPos],'')
Local cNumLote   := If((nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_NUMLOTE'}))>0,aCols[n, nPos],'')
Local cCodDest	 := If((nPos := aScan(aHeader, {|x| x[1] == STR0011 }))>0,aCols[n, nPos],'')
Local cLocDest   := If((nPos := aScan(aHeader, {|x| x[1] == STR0014 }))>0,aCols[n, nPos],'')

Local nPosDtVldD := aScan(aHeader, {|x| x[1]==STR0046 })
Local lRastroL   := Rastro(cCodProd, 'L')
Local lRastroS   := Rastro(cCodProd, 'S')
Default nTipo	 := 1

//-- S� Permite Lote ou SubLote
If cVar # 'M->D3_LOTECTL' .And. cVar # 'M->D3_NUMLOTE'
	lContinua := .F.
Else
	cLoteCTL := If(cVar=='M->D3_LOTECTL',cCont,cLoteCTL)
	cNumLote := If(cVar=='M->D3_NUMLOTE',cCont,cNumLote)
EndIf
If lContinua
	If nTipo == 1
		//-- O campo Lote sempre deve estar preenchido
		If (lRastroL .Or. lRastroS) .And. Empty(cLoteCTL)
			Help(' ',1,'MA260LOTE')
			lContinua	:= .F.
			lRet		:= .F.
		EndIf

		//-- Se o Controle for Lote o campo Sub-Lote nao pode ser preenchido
		If lContinua .And. lRastroL .And. cVar == 'M->D3_NUMLOTE' .And. !Empty(cNumLote)
			&(ReadVar()) := Space(Len(&(ReadVar())))
			lContinua	:= .F.
			lRet		:= .F.
		EndIf

		//-- Se o Sub-Lote nao estiver preenchido, Valida somente o Lote.
		If lContinua .And. lRastroS .And. cVar == 'M->D3_LOTECTL' .And. Empty(cNumLote)
			lRastroL := .T.
			lRastroS := .F.
		EndIf

		If lContinua
			If lRastroL //-- Validacao de Lote
				SB8->(dbSetOrder(3))
				If SB8->(dbSeek(xFilial('SB8') + cCodProd + cLocOrig + cLoteCTL, .F.)) .AND. (dA261Data >= SB8->B8_DATA)
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_DTVALID'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_DTVALID
					EndIf
					nPos := aScan(aHeader, {|x| x[1]==STR0046})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_DTVALID
					EndIf
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_POTENCI'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_POTENCI
					EndIf
					If Rastro(cCodProd, 'S')
						nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_NUMLOTE'})
						If nPos > 0
							aCols[n,nPos] := SB8->B8_NUMLOTE
						EndIf
					EndIf
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_LOTECTL'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_LOTECTL
					EndIf
					nSB8Recno     := SB8->(Recno())
				Else
					If		!SB8->(FOUND())
						Help(' ', 1, 'A240LOTERR')
					Endif
					lContinua	:= .F.
					lRet		:= .F.
				EndIf
			ElseIf lRastroS //-- Validacao de Lote e Sub-Lote
				SB8->(dbSetOrder(2))
				If SB8->(dbSeek(xFilial('SB8') + cNumLote + cLoteCTL + cCodProd + cLocOrig, .F.))
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_DTVALID'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_DTVALID
					EndIf
					nPos := aScan(aHeader, {|x| x[1]==STR0046})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_DTVALID
					EndIf
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_POTENCI'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_POTENCI
					EndIf
					If Rastro(cCodProd, 'S')
						nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_NUMLOTE'})
						If nPos > 0
							aCols[n,nPos] := SB8->B8_NUMLOTE
						EndIf
					EndIf
					nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_LOTECTL'})
					If nPos > 0
						aCols[n,nPos] := SB8->B8_LOTECTL
					EndIf
					nSB8Recno     := SB8->(Recno())
				Else
					Help(' ', 1, 'A240LOTERR')
					lContinua	:= .F.
					lRet		:= .F.
				EndIf
			Else
				&(ReadVar()) := Space(Len(&(ReadVar())))
				lContinua	:= .F.
				lRet		:= .T.
			EndIf
		EndIf
	ElseIf nTipo == 2
		If Rastro(cCodDest) .And. !Empty(cCont)
			dbSelectArea("SB8")
			dbSetOrder(3)
			If dbSeek(xFilial("SB8")+cCodDest+cLocDest+cCont) .And. SB8->B8_DTVALID # aCols[n,nPosDtVldD]
				If !lAutoma261 .And. !Empty(aCols[n,nPosDtVldD])
					Help(" ",1,"A240DTVALI")
				EndIf
				aCols[n,nPosDtVldD] := SB8->B8_DTVALID

			ElseIf Empty(aCols[n,nPosDtVldD])
				aCols[n,nPosDtVldD] := dDataBase
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

//-- Retorna Integridade do Sistema
RestArea( aSB8Area )
RestArea( aArea )
Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261EstrOk� Autor � Fernando Joly Siquini � Data � 01/03/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser efetuado o estorno                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261EstrOk(ExpC1,ExpA1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - documento									      ���
���          � ExpA1 - registros relacionados do CQ (SD7)    			  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261EstrOk(cDocumento, aDelSD7)

Local aArea      := { Alias(), IndexOrd(), Recno() }
Local aSD3Area   := { 'SD3', SD3->(IndexOrd()), SD3->(Recno()) }
Local aSD7Area   := { 'SD7', SD7->(IndexOrd()), SD7->(Recno()) }
Local aSDAArea   := { 'SDA', SDA->(IndexOrd()), SDA->(Recno()) }
Local lRet       := .T.
Local nRecCQ     := 0
Local cSeek      := ''
Local nX	     := 0
//������������������������������������������������������������������Ŀ
//� Atribui valores as variaveis de Posicao utilizado no Siga Pyme   �
//��������������������������������������������������������������������
Local nPosEstor := 1		//'Estornado'
Local nPosCODDes:= 7		//Codigo do Produto Destino
Local nPosLOCDes:= 10	//Armazem Destino
Local nPosNumSeq:= 19	//'Sequencia'

aDelSD7    := If(aDelSD7==NIL,{},aDelSD7)
cDocumento := If(cDocumento==NIL,'',cDocumento)

For nX := 1 to Len(aCols)
	If aCols[nX, nPosEstor] == 'S'

		//-- Posiciona SD3
		SD3->(dbSetOrder(2))
		If !SD3->(dbSeek(xFilial('SD3')+cDocumento+aCols[nX,nPosCODDes], .F.))
			Help(' ',1,'A260ESTORN')
			lRet := .F.
			Exit
		EndIf

		//-- Localiza��o - n�o estorna Produto Destino j� distribuido
		SDA->(dbSetOrder(1))
		If Localiza(aCols[nX, nPosCODDes]) .And. ;
				SDA->(dbSeek(xFilial('SDA')+aCols[nX,nPosCODDes]+aCols[nX,nPosLOCDes]+aCols[nX,nPosNumSeq],.F.)) .And. ;
				SDA->DA_QTDORI # SDA->DA_SALDO
			Help(' ',1,'SDAJADISTR')
			lRet := .F.
			Exit
		EndIf

		//-- CQ - n�o estorna Produto Destino com Movim. no CQ
		SD7->(dbSetorder(3))
		If SD7->(dbSeek(xFilial('SD7') + aCols[nX, nPosCODDes] + aCols[nX, nPosNumSeq], .F.))
			cSeek := xFilial('SD7') + SD7->D7_NUMERO + aCols[nX, nPosCODDes]
			SD7->(dbSetOrder(2))
			If SD7->(dbSeek(cSeek, .F.))
				Do While !SD7->(Eof()) .And. ;
						cSeek == SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO
					nRecCQ += If(SD7->D7_TIPO>0.And.Empty(SD7->D7_ESTORNO),1,0)
					If (SD7->D7_TIPO == 0 .Or. (SD7->D7_TIPO > 0 .And. SD7->D7_ESTORNO == 'S')) .And. ;
							aScan(aDelSD7,SD7->(Recno())) == 0
						aAdd(aDelSD7, SD7->(Recno()))
					EndIf
					SD7->(dbSkip())
				EndDo
				If nRecCQ > 0
					Help(' ',1,'A261MOVICQ')
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf

	EndIf
	//-- Ponto de Entrada para o usuario validar o estorno
	If lMA261EST
		lRet := Execblock('MA261EST',.f.,.f.,{nX})
		lRet := If(ValType(LRet)#"L",.T.,lRet)
		If !lRet
			Exit
		EndIf
	EndIf
Next nX

//-- Retorna Integridade do Sistema
dbSelectArea(aSD3Area[1]); dbSetOrder(aSD3Area[2]); dbGoto(aSD3Area[3])
dbSelectArea(aSD7Area[1]); dbSetOrder(aSD7Area[2]); dbGoto(aSD7Area[3])
dbSelectArea(aSDAArea[1]); dbSetOrder(aSDAArea[2]); dbGoto(aSDAArea[3])
dbSelectArea(aArea[1]); dbSetOrder(aArea[2]); dbGoto(aArea[3])

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A261RetINV� Autor � Fernando Joly Siquini � Data � 01/03/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retira INVEN do numero do Documento e retorna o novo numero���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC1 := A261RetINV(ExpC2)	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC2 - documento "INVEN" ou "SK"						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 - novo numero documento                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA261                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function A261RetINV(cDoc)
Local aAreaAnt := GetArea()
Local aAreaSD3 := SD3->(GetArea())
Local cFilSD3  := xFilial('SD3')
Local cRet	   := cDoc
Local lContinua:= .T.
Local lWmsDocSD3 := FindFunction('WmsDocSD3')

	If IntWMs() .And. lWmsDocSD3
		cRet := WmsDocSD3(cDoc)
	Else
		If Upper(SubStr(cDoc,1,5)) == 'INVEN'
			dbSelectArea('SD3')
			dbSetOrder(2)
			dbSeek(cFilSD3+'z', .T.)
			If !Eof() .And. D3_FILIAL == cFilSD3 .And. !(Upper(SubStr(D3_DOC,1,5))=='INVEN')
				cDoc 		:= D3_DOC
				cRet 		:= Soma1(cDoc)
				lContinua 	:= .F.
			EndIf
			If lContinua
				dbSeek(cFilSD3+'INVEN')
				dbSkip(-1)
				If !Bof() .And. D3_FILIAL == cFilSD3
					cDoc 		:= D3_DOC
					cRet 		:= Soma1(cDoc)
					lContinua 	:= .F.
				EndIf
			EndIf
			If lContinua
				cRet := StrZero(1,TamSx3("D3_DOC")[1])
			EndIf
		ElseIf Upper(SubStr(cDoc,1,2)) == 'SK'
			dbSelectArea('SD3')
			dbSetOrder(2)
			dbSeek(cFilSD3+'z', .T.)
			If !Eof() .And. D3_FILIAL == cFilSD3 .And. !(Upper(SubStr(D3_DOC,1,2))=='SK')
				cDoc 		:= D3_DOC
				cRet 		:= Soma1(cDoc)
				lContinua 	:= .F.
			EndIf
			If lContinua
				dbSeek(cFilSD3+'SK')
				dbSkip(-1)
				If Upper(SubStr(D3_DOC,1,5)) == 'INVEN'
					dbSeek(cFilSD3+'INVEN')
					dbSkip(-1)
				EndIf
				If !Bof() .And. D3_FILIAL == cFilSD3
					cDoc 		:= D3_DOC
					cRet 		:= Soma1(cDoc)
					lContinua 	:= .F.
				EndIf
			EndIf
			If lContinua
				cRet := StrZero(1,TamSx3("D3_DOC")[1])
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSD3)
	RestArea(aAreaAnt)
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A261DtPot   �Autor�Rodrigo de A. Sartorio� Data � 19/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao para digitar a validade e potencia do Lote       ���
���          � corretamente                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A261DtPot(ExpN1)				                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Indica se valida 1 - Data de Validade 2 - Potencia ���
���          �         3 - Data de Validade de Destino                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .T.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A261DtPot(nTipo)
LOCAL lRet      := .T.
LOCAL cCod		:= aCols[n,1]
LOCAL cLocal    := aCols[n,4]
LOCAL cLoteCtl  := aCols[n,12]	//Lote de Controle
LOCAL cLote     := aCols[n,13]	//Numero do Lote
LOCAL dDtValid  := If(nTipo==1,&(ReadVar()),aCols[n,14])
LOCAL nPosDtvld := 0
LOCAL nPotencia := If(nTipo==2,&(ReadVar()),aCols[n,15])
LOCAL cCodDest	:= aCols[n,AsCan(aHeader,{|x| x[1]==STR0011})]
LOCAL cLoteDest	:= aCols[n,AsCan(aHeader,{|x| x[1]==STR0014})]
LOCAL cLoteCtlD	:= aCols[n,AsCan(aHeader,{|x| x[1]==STR0044})]
LOCAL dDtVldDest:= If(nTipo==3,&(ReadVar()),aCols[n,AsCan(aHeader,{|x| x[1]==STR0046})])
LOCAL aAreaSB8  := SB8->(GetArea())
LOCAL cAlias    := Alias()

If nTipo == 3
	If !Rastro(cCodDest)
		Help(" ",1,"NAORASTRO")
		lRet:=.F.
	ElseIf !lAutoma261
		If !Rastro(cCod)
			If !Empty(cLoteCtlD)
				// Verifica se a data de validade pode ser utilizada
				dbSelectArea("SB8")
				dbSetOrder(3)
				If dbSeek(xFilial("SB8")+cCodDest+cLoteDest+cLoteCtlD) .And. SB8->B8_DTVALID # dDtVldDest
					Help(" ",1,"A240DTVALI")
					&(ReadVar()):=SB8->B8_DTVALID
				EndIf
				RestArea(aAreaSB8)
			EndIf
		Else
			If (!Empty(cLoteCtl) .Or. !Empty(cLote)) .And.  dDtVldDest < dDtValid
				ApMsgAlert('STR0069')
				&(ReadVar()):= dDtValid
			EndIf
		EndIf
	EndIf
Else
	If !Rastro(cCod)
		Help(" ",1,"NAORASTRO")
		lRet:=.F.

	Else
		If !Empty(cLoteCtl) .Or. !Empty(cLote)
			// Verifica se a data de validade pode ser utilizada
			dbSelectArea("SB8")
			dbSetOrder(3)
			dbSeek(xFilial()+cCod+cLocal+cLoteCtl+If(Rastro(cCod,"S"),+cLote,""))
		EndIf
		If nTipo == 1
			If !lAutoma261 .And. !(SB8->(Eof())) .And. (!Empty(cLoteCtl) .Or. !Empty(cLote)) .And. IIF(!Empty(dDtValid),dDtValid # SB8->B8_DTVALID,.T.)
				Help(" ",1,"A240DTVALI")
				&(ReadVar()):=SB8->B8_DTVALID
			EndIf
			If !Empty(&(ReadVar()))
				If &(ReadVar())# dDtVldDest
					nPosDtvld := aScan(aHeader,{|x| Alltrim(x[2])=="D3_DTVALID"})
			   		aCols[n,nPosDtvld] := &(ReadVar())
				EndIf
			EndIf

		ElseIf nTipo == 2
			If !PotencLote(cCod)
				Help(" ",1,"NAOCPOTENC")
				lRet:=.F.
			EndIf
			If !(SB8->(Eof())) .And. (!Empty(cLoteCtl) .Or. !Empty(cLote)) .And. nPotencia # SB8->B8_POTENCI
				Help(" ",1,"POTENCORI")
				&(ReadVar()):=SB8->B8_POTENCI
			EndIf
		ElseIf nTipo == 3 .And. !lAutoma261
			If  (!Empty(cLoteCtl) .Or. !Empty(cLote)) .And.  dDtVldDest < dDtValid
				ApMsgAlert('STR0069')
				&(ReadVar()):= SB8->B8_DTVALID
			EndIf
		EndIf
		RestArea(aAreaSB8)
	EndIf
EndIf
dbSelectArea(cAlias)
Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �04/10/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Private aRotina	:=  {	{STR0002,"AxPesqui"   , 0, 1, 0, .F.},; // 'Pesquisar'
						{STR0003,"A261Visual" , 0, 2, 0, nil},; // 'Visualizar'
						{STR0004,"A261Inclui" , 0, 3, 0, nil},; // 'Incluir'
						{STR0005,"A261Estorn" , 0, 6, 0, nil},; // 'Estornar'
						{STR0045,"A240Legenda", 0, 2, 0, .F.},; // 'Legenda'
    					{STR0067,"CTBC662"    , 0, 7, 0, .F.} } // "Tracker Cont�bil"

If ExistBlock ("MTA261MNU")
	ExecBlock ("MTA261MNU",.F.,.F.)
Endif
Return (aRotina)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A261PrdGrd�Autor  �Rodrigo de T. Silva    � Data �14/12/2009 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Interface de Grade de Produtos - Transf. Mod (Mod2)  	   ���
���          � Substitui a antiga funcao A261Produto(cProduto)             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. se Valido ou .F. se Invalido                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Getdados do MATA261.PRX disparada pelo X3_VALID do D3_COD    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
User Function A261PrdGrd()
Local aArea        := GetArea()
Local cNewItem     := ""
Local cPrdOrig     := ""
Local cCpoName     := StrTran(ReadVar(),"M->","")
Local cSaveReadVar := __READVAR
Local lGrade       := MaGrade()
Local lReferencia  := .F.
Local lAadd        := .F.
Local lQtdZero     := .F.
Local lRet         := .T.
Local nSaveN
Local nNewItem
Local nPosProd
Local nPLocal
Local nPosQuant
Local nPosCusto1
Local nPosQtSegum
Local nLinX        := 0
Local nColY        := 0
Local nY           := 0
Local nOpca        := 0
Local oDlg

//���������������������������������������������������������������������������������������������������������������������������Ŀ
//�Verifica se a grade esta ativa e se o produto digitado e uma referencia e Monta o AcolsGrade e o AheadGrade para este item �
//�����������������������������������������������������������������������������������������������������������������������������
cProdRef    := &(ReadVar())
lReferencia := MatGrdPrrf(@cProdRef)
If lReferencia .And. lGrade .And. !Empty(&(ReadVar()))
	nSaveN       	:= N
	nNewItem     	:= Len(aCols)
	nPosProd     	:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_COD"})
	nPLocal			:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_LOCAL"})
	nPosQuant    	:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_QUANT"})
	nPosCusto1		:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_CUSTO1"})
	nPosQtSegum  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D3_QTSEGUM"})
  	PRIVATE oGrade  := MsMatGrade():New('oGrade', , 'D3_QUANT', , 'A261VldGrd()', {{VK_F4, { || ShowF4() } }},;
	{{"D3_QUANT"    ,.T., {{"D3_QTSEGUM", {|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) }}} },;
   	{"D3_QTSEGUM"  ,NIL, {{"D3_QUANT"  , {|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} },;
   	{"D3_LOCAL"    ,NIL, NIL},;
   	{"D3_CUSTO1"   ,NIL, NIL};
 	})
	//��������������������������������������������������������������Ŀ
	//� So aceita a entrada de dados via interface de grade se o usr �
	//� estiver posicionado na ultima linha da MsGetdados (NewLine). �
	//����������������������������������������������������������������
	If N >= Len(aCols) .And. Empty(aCols[Len(aCols)][nPosProd])
		oGrade:MontaGrade(1,cProdRef,.T.,,lReferencia,.T.)
		oGrade:nPosLinO     := 1
		oGrade:cProdRef	    := cProdRef
		oGrade:lShowMsgDiff := .F. // Desliga apresentacao do "A410QTDDIF"

		nNewItem := Len(aCols)
		lAadd    := .F.

		DEFINE MSDIALOG oDlg TITLE STR0060 OF oMainWnd PIXEL FROM 000,000 TO 220,520  //"Interface para Grade de Produtos"

		@ 035,010 BUTTON STR0020 SIZE 70,15 FONT oDlg:oFont ACTION ;
		{|| __READVAR:='M->D3_QUANT'  ,M->D3_QUANT   := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Quantidade"
		@ 055,010 BUTTON STR0021 SIZE 70,15 FONT oDlg:oFont ACTION ;
		{|| __READVAR:='M->D3_QTSEGUM',M->D3_QTSEGUM := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Segunda Und Medida"

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End(), nOpca:=1},{||oDlg:End(), nOpca:=0}) CENTERED

		//��������������������������������������������������������������������������������������������������Ŀ
		//� Somente realiza a carga do item para o aCols se pelo menos uma celula do D3_QUANT contiver valor.�
		//����������������������������������������������������������������������������������������������������
		If nOpca == 1
			If If(lQtdZero,oGrade:SomaGrade("D3_QTSEGUM",oGrade:nPosLinO,oGrade:nQtdInformada) <> 0,oGrade:SomaGrade("D3_QUANT",oGrade:nPosLinO,oGrade:nQtdInformada) > 0)
				For nLinX := 1 To Len(oGrade:aColsGrade[1])
					For nColY := 2 To Len(oGrade:aHeadGrade[1])
						If oGrade:aColsFieldByName("D3_QUANT",1,nLinX,nColY)  > 0
							//��������������������������������������������������������������Ŀ
							//� Faz a montagem de uma nova linha em branco no aCols para     �
							//� adicionar novos itens vindos das celulas da Grade.           �
							//����������������������������������������������������������������
							If lAadd
								aadd(aCols,Array(Len(aHeader)+1))
								N := nNewItem
								nNewItem := Len(aCols)
 								cNewItem := StrZero(nNewItem,Len(SD1->D1_ITEM))
								For nY := 1 to Len(aHeader)
									If Trim(aHeader[nY][2]) == "D3_COD"
										aCols[nNewItem][nY] := PadR(oGrade:GetNameProd(cProdRef,nLinX,nColY),Len(SD1->D1_COD))
									ElseIf IsHeadRec(aHeader[nY][2])
										aCols[nNewItem][nY] := 0
									ElseIf IsHeadAlias(aHeader[nY][2])
										aCols[nNewItem][nY] := "SD3"
									Else
										aCols[nNewItem][nY] := CriaVar(aHeader[nY][2])
									EndIf
									aCols[nNewItem][Len(aHeader)+1] := .F.
								Next nY
							EndIf
							//�������������������������������������������������������������������������Ŀ
							//�Efetua a carga dos itens digitados no grid para o aCols                  �
							//�Executa as validacoes necessarias para se carregar corretamente os dados �
							//���������������������������������������������������������������������������
							aCols[nNewItem][nPosProd]:= PadR(oGrade:GetNameProd(cProdRef,nLinX,nColY),Len(SD1->D1_COD))
							DbSelectArea("SB1")
							If dbSeek(xFilial()+alltrim(aCols[nNewItem][nPosProd]),.T.)
								M->D3_COD := aCols[nNewItem][nPosProd]
								aCols[nNewItem][nPosQuant]:= oGrade:aColsFieldByName("D3_QUANT",1,nLinX,nColY)
								M->D3_QUANT   := oGrade:aColsFieldByName("D3_QUANT",1,nLinX,nColY)
								aCols[nNewItem][nPosQtSegum]:= oGrade:aColsFieldByName("D3_QTSEGUM",1,nLinX,nColY)
								M->D3_QTSEGUM := oGrade:aColsFieldByName("D3_QTSEGUM",1,nLinX,nColY)
								AQtdGrade()  //-- Deve ser executada somente neste momento pois o objeto oGrade esta ativo
								aCols[nNewItem,2] := SB1->B1_DESC
								aCols[nNewItem,3] := SB1->B1_UM
								aCols[nNewItem,4] := SB1->B1_LOCPAD
								aCols[nNewItem,6] := aCols[nNewItem,1]
								aCols[nNewItem,7] := aCols[nNewItem,2]
								aCols[nNewItem,8] := aCols[nNewItem,3]
								If !lAadd
									cPrdOrig := aCols[nNewItem][nPosProd]
									lAadd 	 := .T.
								EndIf
							EndIf
						EndIf
					Next nColY
				Next nLinX
			Else
				lRet := .F.
			EndIf
		EndIf
		//�����������������������������������������������������������������Ŀ
		//�Restaura os valores originais do N da GetDados, e da Public      �
		//�__READVAR que fora manipulada pela interface de grade.           �
		//�������������������������������������������������������������������
		N         := nSaveN
		__READVAR := cSaveReadVar
		M->D3_COD := cPrdOrig
	Else
		//������������������������������������������������������������������Ŀ
		//�Para incluir um produto com referencia de grade e necessario estar�
		//�em uma nova linha do movimento interno.                           �
		//��������������������������������������������������������������������
		Help(" ",1,"A241PRDGRD")
		lRet := .F.
	EndIf
Else
	//���������������������������������������������������������������������Ŀ
	//� Se o Produto nao for um produto de grade executa a validacao no SB1 �
	//� e inicializa os campos na getdados.                                 �
	//�����������������������������������������������������������������������
	dbSelectArea("SB1")
	dbSetOrder(1)
	lRet := ExistCpo("SB1")
EndIf
RestArea(aArea)
Return(lRet)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A261VldGrd�Autor  �Rodrigo de T. Silva	� Data �14/12/2009 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Validacao dos itens do Grid na grade de produtos            ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � .T. se Valido e .F. se Invalido                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Objeto de Grade do MATA261                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
User Function A261VldGrd()
Local lValido := .F.

//���������������������������������������������������������������������Ŀ
//� Se Houver necessidade de novas validacoes na entrada de dados nas   �
//� celulas do Grid elas deverao ser inseridas nessa funcao.            �
//�����������������������������������������������������������������������
If Positivo()
	lValido := .T.
EndIf

Return lValido

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� User Function  � IntegDef � Autor � Flavio San Miguel    � Data �  17/12/13   ���
����������������������������������������������������������������������������͹��
��� Descricao � Funcao de tratamento para a mensagem unica de transferencia  ���
���           � de Armazem Modelo II (TRANSFERWAREHOUSELOT)                  ���
����������������������������������������������������������������������������͹��
��� Uso       � MATA261                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function IntegDef(cXML,nTypeTrans,cTypeMessage)
Return MATI261(cXml,nTypeTrans,cTypeMessage)

/*----------------------------------------------------
 Suavizar a nova verifica��o de integra��o com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If __lIntWMS
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� User Function  �Ma261VldDt� Autor � Lucas Crevilari      � Data �  13/07/17   ���
����������������������������������������������������������������������������͹��
��� Descricao � Funcao para valida��o da data de fechamento                  ���
����������������������������������������������������������������������������͹��
��� Uso       � MATA261                                                      ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

User Function Ma261VldDt( dDataFec, dA261Data)
Local lRet	:= .T.

Default dDataFec  := dDataBase
Default dA261Data := dDataBase

If (dDataFec >= dA261Data)
	Help (' ', 1, 'FECHTO')
	lRet := .F.
Endif

If lRet .And. !VldUser('D3_EMISSAO')
	lRet := .F.
Endif

Return lRet
