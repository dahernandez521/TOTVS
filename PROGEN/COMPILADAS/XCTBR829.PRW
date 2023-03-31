// #INCLUDE "MATR620.CH"
#Include "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR620  ³ Autor ³ Marco Bianchi         ³ Data ³ 11/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao Vendas por Produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user Function XCTBR829()

	Local oReport

	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³ 11/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

	Local oReport
	Local oVenProd
	Local cAliasQry 	:= GetNextAlias()
	// Local cProd			:= ""
	Local Ct2Doc 	:= 0
	Local Ct2Debito 	:= 0
	Local Ct2Credito 	:= 0
	// Local nTotFat 		:= 0
	// Local cUM 			:= ""
	// Local nTotDesc 		:= 0
	// Local nTotVal 		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New("XCTBR829","Aux Tercero","MTR620", {|oReport| ReportPrint(oReport,cAliasQry,oVenProd)},"Descripción")	// "Relacao de Pedidos por Produto"###"Este relatorio ira emitir a relacao de Vendas por"###"ordem de Produto."
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVenProd := TRSection():New(oReport,"REGISTRO CONTABLE",{"CT2","CT1","CV0"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)		// "Relacao de Pedidos por Produto"
	oVenProd:SetTotalInLine(.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define celulas da secao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// TRCell():New(oVenProd,"CPROD"	  	,/*Tabela*/	,'Fecha',PesqPict("SB1","B1_COD")		,TamSx3("B1_COD")	 [1],/*lPixel*/,{|| cProd })			    // "Produto"
	// TRCell():New(oVenProd,"B1_DESC"		,"SB1"		,'Fecha Aux',"nombre raro"		,TamSx3("B1_DESC")	 [1],/*lPixel*/,{|| cProd })	    // "Denominacao"
	// TRCell():New(oVenProd,"Ct2Doc"	,/*Tabela*/	,'Tipo Doc',PesqPict("CT2","CT2_DOC",19)	,TamSx3("NIT") [1],/*lPixel*/,{|| Ct2Doc }) 		    // "Qtd.Vendida"
	TRCell():New(oVenProd,"Ct2Debito"	,/*Tabela*/	,'Debito',PesqPict("CT2","CT2_DEBITO",19)	,TamSx3("DEBITOS") [1],/*lPixel*/,{|| Ct2Debito }) 		    // "Qtd.Vendida"
	TRCell():New(oVenProd,"Ct2Credito"	,/*Tabela*/	,'Credito',PesqPict("CT2","CT2_CREDIT",19)	,TamSx3("CREDITOS") [1],/*lPixel*/,{|| Ct2Credito }) 		    // "Qtd.Vendida"

	// TRCell():New(oVenProd,"NTOTQUANT2"	,/*Tabela*/	,'Num Doc',PesqPict("SC6","C6_UNSVEN",19)	,TamSx3("C6_QTDVEN") [1],/*lPixel*/,{|| Ct2Doc })		    // "Qtd.Vendida"
	// TRCell():New(oVenProd,"NTOTFAT1"	,/*Tabela*/	,'Cuenta Niif',PesqPict("SC6","C6_QTDVEN",19)	,TamSx3("C6_QTDVEN") [1],/*lPixel*/,{|| nTotFat })			    // "Qtd.Faturada"
	// TRCell():New(oVenProd,"NTOTFAT2"	,/*Tabela*/	,'Nom Cuenta',PesqPict("SC6","C6_UNSVEN",19)	,TamSx3("C6_QTDVEN") [1],/*lPixel*/,{|| nTotFat })			    // "Qtd.Faturada"
	// TRCell():New(oVenProd,"CUM"			,/*Tabela*/	,'Cuenta Local',PesqPict("SB1","B1_UM")	    ,TamSx3("B1_UM")	 [1],/*lPixel*/,{|| cUM })				    // "UM"
	// TRCell():New(oVenProd,"NTOTFAT2"	,/*Tabela*/	,'Nom Cuenta',PesqPict("SC6","C6_UNSVEN",19)	,TamSx3("C6_QTDVEN") [1],/*lPixel*/,{|| nTotFat })			    // "Qtd.Faturada"
	// TRCell():New(oVenProd,"NTOTDESC"	,/*Tabela*/	,'Concepto',PesqPict("SC6","C6_PRUNIT",19)	,TamSx3("C6_PRUNIT") [1],/*lPixel*/,{|| nTotDesc },,,"RIGHT")	// "Desconto"
	// TRCell():New(oVenProd,"NTOTVAL"		,/*Tabela*/	,'Debitos',PesqPict("SC6","C6_VALOR",19)	,TamSx3("C6_VALOR")	 [1],/*lPixel*/,{|| nTotVal },,,"RIGHT")	// "Valor Total"
	// TRCell():New(oVenProd,"NTOTVAL"		,/*Tabela*/	,'Creditos',PesqPict("SC6","C6_VALOR",19)	,TamSx3("C6_VALOR")	 [1],/*lPixel*/,{|| nTotVal },,,"RIGHT")	// "Valor Total"


Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³ Marco Bianchi         ³ Data ³ 11/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasQry,oVenProd)


	cProd		:= ""
	Ct2Doc	:= 0
	Ct2Debito 	:= 0
	Ct2Credito 	:= 0
	nTotFat		:= 0
	cUM			:= ""
	nTotDesc	:= 0
	nTotVal		:= 0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo TrPosition()                                                     ³
	//³                                                                        ³
	//³Posiciona em um registro de uma outra tabela. O posicionamento será     ³
	//³realizado antes da impressao de cada linha do relatório.                ³
	//³                                                                        ³
	//³                                                                        ³
	//³ExpO1 : Objeto Report da Secao                                          ³
	//³ExpC2 : Alias da Tabela                                                 ³
	//³ExpX3 : Ordem ou NickName de pesquisa                                   ³
	//³ExpX4 : String ou Bloco de código para pesquisa. A string será macroexe-³
	//³        cutada.                                                         ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtragem do relatório                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CT2")		// Itens do Pedido de Vendas
	// dbSetOrder(2)				// Produto,Numero
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()
	BeginSql Alias cAliasQry
		SELECT
			CT2_DATA FECHA,
			CT2_DATA FECHA_AUX,
			CASE
				CT2_AT03CR
				WHEN ''
					THEN CT2_AT03DB
				ELSE CT2_AT03CR
			END DOCUM,
			CT11.CT1_XNIIFS NIIF,
			CT12.CT1_DESC01 NOM_NIIF,
			CT2_CREDIT COLGAP,
			CT11.CT1_DESC01 NOM_COLGAP,
			CT2_HIST HISTORIAL,
			'' DEBITOS,
			CT2_VALOR CREDITOS,
			CT2_EC05CR NIT,
			CASE
				CT2_EC05CR
				WHEN ''
					THEN ''
				ELSE (
					CASE
						CV0_TIPO01
						WHEN '13'
							THEN ''
						ELSE substring(CT2_EC05CR,(len(CT2_EC05CR)), len(CT2_EC05CR))
					END
				)
			END DV,
			CV0_DESC NOMBRE
		FROM
			CT2010 CT2
		INNER JOIN CT1010 CT11
		ON CT2.CT2_CREDIT = CT11.CT1_CONTA
			AND CT11.D_E_L_E_T_ = ''
		INNER JOIN CT1010 CT12
		ON CT11.CT1_XNIIFS = CT12.CT1_CONTA
			AND CT12.D_E_L_E_T_ = ''
		INNER JOIN CV0010 CV0
		ON CT2_EC05CR = CV0.CV0_CODIGO
			AND CV0.D_E_L_E_T_ = ''
		WHERE
			CT2.D_E_L_E_T_ = ''
			AND CT2_CREDIT > 0
			AND CT2_DATA >= '20220201'
			AND CT2_DATA <= '20220201'
			AND CT2_TPSALD = '1'
			AND CT2_MOEDLC = '01'
		UNION
		SELECT
			CT2_DATA FECHA,
			CT2_DATA FECHA_AUX,
			CASE
				CT2_AT03CR
				WHEN ''
					THEN CT2_AT03DB
				ELSE CT2_AT03CR
			END DOCUM,
			CT11.CT1_XNIIFS NIIF,
			CT12.CT1_DESC01 NOM_NIIF,
			CT2_DEBITO COLGAP,
			CT11.CT1_DESC01 NOM_COLGAP,
			CT2_HIST HISTORIAL,
			CT2_VALOR DEBITOS,
			'' CREDITOS,
			CASE
				CT2_EC05DB
				WHEN ''
					THEN CT2_EC05CR
				ELSE CT2_EC05DB NIT,
				CASE
					CT2_EC05DB
					WHEN ''
						THEN ''
					ELSE (
						CASE
							CV0_TIPO01
							WHEN '13'
								THEN ''
							ELSE substring(CT2_EC05DB,(len(CT2_EC05DB)), len(CT2_EC05DB))
						END
					)
				END DV,
				CV0_DESC NOMBRE
				FROM
					CT2010 CT2
				INNER JOIN CT1010 CT11
				ON CT2.CT2_DEBITO = CT11.CT1_CONTA
					AND CT11.D_E_L_E_T_ = ''
				INNER JOIN CT1010 CT12
				ON CT11.CT1_XNIIFS = CT12.CT1_CONTA
					AND CT12.D_E_L_E_T_ = ''
				INNER JOIN CV0010 CV0
				ON CT2_EC05DB = CV0.CV0_CODIGO
					AND CV0.D_E_L_E_T_ = ''
				WHERE
					CT2.D_E_L_E_T_ = ''
					AND CT2_DEBITO > 0
					AND CT2_DATA >= '20220201'
					AND CT2_DATA <= '20220201'
					AND CT2_TPSALD = '1'
					AND CT2_MOEDLC = '01' // AND CT2_DOC='000002'
					// AND C6_PRODUTO >= %Exp:mv_par03% AND C6_PRODUTO <= %Exp:mv_par04%
					// AND SC6.%NotDel%
					// ORDER BY C6_PRODUTO
	EndSql
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasQry)
	dbGoTop()
	oReport:SetMeter((cAliasQry)->(LastRec()))
	oReport:Section(1):Init()



	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())



		oReport:Section(1):PrintLine()


		dbSelectArea(cAliasQry)
	EndDo
	oReport:Section(1):Finish()



Return
