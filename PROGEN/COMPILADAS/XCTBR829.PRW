// #INCLUDE "MATR620.CH"
#Include "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MATR620  � Autor � Marco Bianchi         � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao Vendas por Produto                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
user Function XCTBR829()

	Local oReport

	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()


Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�                                                                        �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport := TReport():New("XCTBR829","Aux Tercero","MTR620", {|oReport| ReportPrint(oReport,cAliasQry,oVenProd)},"Descripci�n")	// "Relacao de Pedidos por Produto"###"Este relatorio ira emitir a relacao de Vendas por"###"ordem de Produto."
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

	//������������������������������������������������������������������������Ŀ
	//�Criacao da secao utilizada pelo relatorio                               �
	//�                                                                        �
	//�TRSection():New                                                         �
	//�ExpO1 : Objeto TReport que a secao pertence                             �
	//�ExpC2 : Descricao da se�ao                                              �
	//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
	//�        sera considerada como principal para a se��o.                   �
	//�ExpA4 : Array com as Ordens do relat�rio                                �
	//�ExpL5 : Carrega campos do SX3 como celulas                              �
	//�        Default : False                                                 �
	//�ExpL6 : Carrega ordens do Sindex                                        �
	//�        Default : False                                                 �
	//�                                                                        �
	//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//�Criacao da celulas da secao do relatorio                                �
	//�                                                                        �
	//�TRCell():New                                                            �
	//�ExpO1 : Objeto TSection que a secao pertence                            �
	//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
	//�ExpC3 : Nome da tabela de referencia da celula                          �
	//�ExpC4 : Titulo da celula                                                �
	//�        Default : X3Titulo()                                            �
	//�ExpC5 : Picture                                                         �
	//�        Default : X3_PICTURE                                            �
	//�ExpC6 : Tamanho                                                         �
	//�        Default : X3_TAMANHO                                            �
	//�ExpL7 : Informe se o tamanho esta em pixel                              �
	//�        Default : False                                                 �
	//�ExpB8 : Bloco de c�digo para impressao.                                 �
	//�        Default : ExpC2                                                 �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oVenProd := TRSection():New(oReport,"REGISTRO CONTABLE",{"CT2","CT1","CV0"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)		// "Relacao de Pedidos por Produto"
	oVenProd:SetTotalInLine(.F.)


	//������������������������������������������������������������������������Ŀ
	//�Define celulas da secao                                                 �
	//��������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Marco Bianchi         � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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


	//������������������������������������������������������������������������Ŀ
	//�Metodo TrPosition()                                                     �
	//�                                                                        �
	//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
	//�realizado antes da impressao de cada linha do relat�rio.                �
	//�                                                                        �
	//�                                                                        �
	//�ExpO1 : Objeto Report da Secao                                          �
	//�ExpC2 : Alias da Tabela                                                 �
	//�ExpX3 : Ordem ou NickName de pesquisa                                   �
	//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
	//�        cutada.                                                         �
	//�                                                                        �
	//��������������������������������������������������������������������������

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)

	//������������������������������������������������������������������������Ŀ
	//�Filtragem do relat�rio                                                  �
	//��������������������������������������������������������������������������
	dbSelectArea("CT2")		// Itens do Pedido de Vendas
	// dbSetOrder(2)				// Produto,Numero
	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
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
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�                                                                        �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)



	//������������������������������������������������������������������������Ŀ
	//�Inicio da impressao do fluxo do relat�rio                               �
	//��������������������������������������������������������������������������
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
