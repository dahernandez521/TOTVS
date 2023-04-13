#Include "PROTHEUS.CH"


User Function XCTBR821()

	Local oReport
	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local oReport
	Local xAuxTerc
	Local cAliasQry 	:= GetNextAlias()

	oReport := TReport():New("XCTBR821","Auxiliar por Tercero","XCTBR821", {|oReport| ReportPrint(oReport,cAliasQry,xAuxTerc)},"Auxiliar general por tercero")
	oReport:SetTotalInLine(.F.)

	Pergunte(oReport:uParam,.F.)

	xAuxTerc := TRSection():New(oReport,'Report Aux Terc',{"CT2","CT1","CV0"},/*{Array com as ordens do relatСrio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	xAuxTerc:SetTotalInLine(.F.)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDefine celulas da secao                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRCell():New(xAuxTerc,"FECHA"	  	,/*Tabela*/	,'FECHA',PesqPict("CT2","CT2_DATA")		,15,/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"FECHA_AUX"	  	,/*Tabela*/	,'FECHA_AUX',PesqPict("CT2","CT2_DATA")		,TamSx3("CT2_DATA")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"PREF"	  	,/*Tabela*/	,'PREF',PesqPict("CT2","CT2_AT03CR")		,TamSx3("CT2_AT03CR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"DOCUM"	  	,/*Tabela*/	,'DOCUM',PesqPict("CT2","CT2_AT03CR")		,TamSx3("CT2_AT03CR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"NIIF"	  	,/*Tabela*/	,'NIIF',PesqPict("CT1","CT1_XNIIFS")		,TamSx3("CT1_XNIIFS")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"NOM_NIIF"	  	,/*Tabela*/	,'NOM_NIIF',PesqPict("CT1","CT1_DESC01")		,TamSx3("CT1_DESC01")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"COLGAP"	  	,/*Tabela*/	,'COLGAP',PesqPict("CT2","CT2_CREDIT")		,TamSx3("CT2_CREDIT")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"NOM_COLGAP"	  	,/*Tabela*/	,'NOM_COLGAP',PesqPict("CT1","CT1_DESC01")		,TamSx3("CT1_DESC01")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"HISTORIAL"	  	,/*Tabela*/	,'HISTORIAL',PesqPict("CT2","CT2_HIST")		,TamSx3("CT2_HIST")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"DEBITOS"	  	,/*Tabela*/	,'DEBITOS',PesqPict("CT2","CT2_VALOR")		,TamSx3("CT2_VALOR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
	TRCell():New(xAuxTerc,"CREDITOS"	  	,/*Tabela*/	,'CREDITOS',PesqPict("CT2","CT2_VALOR")		,TamSx3("CT2_VALOR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)

	IF(mv_par07==1)

		TRCell():New(xAuxTerc,"NIT"	  	,/*Tabela*/	,'NIT',PesqPict("CT2","CT2_EC05CR")		,TamSx3("CT2_EC05CR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
		TRCell():New(xAuxTerc,"DV"	  	,/*Tabela*/	,'DV',PesqPict("CT2","CT2_EC05CR")		,TamSx3("CT2_EC05CR")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)
		TRCell():New(xAuxTerc,"NOMBRE"	  	,/*Tabela*/	,'NOMBRE',PesqPict("CV0","CV0_DESC")		,TamSx3("CV0_DESC")	 [1],/*lPixel*/,/*{|| (cAliasQry)->NIT }*/)

	ENDIF



Return(oReport)

Static Function ReportPrint(oReport,cAliasQry,xAuxTerc)


	oReport:Section(1):Cell("FECHA" ):SetBlock({|| cFechaAux})
	oReport:Section(1):Cell("FECHA_AUX" ):SetBlock({|| cFechaAux})
	oReport:Section(1):Cell("PREF" ):SetBlock({|| cPref})
	oReport:Section(1):Cell("DOCUM" ):SetBlock({|| cDocum})
	oReport:Section(1):Cell("NIIF" ):SetBlock({|| (cAliasQry)->NIIF})
	oReport:Section(1):Cell("NOM_NIIF" ):SetBlock({|| (cAliasQry)->NOM_NIIF})
	oReport:Section(1):Cell("COLGAP" ):SetBlock({|| (cAliasQry)->COLGAP})
	oReport:Section(1):Cell("NOM_COLGAP" ):SetBlock({|| (cAliasQry)->NOM_COLGAP})
	oReport:Section(1):Cell("HISTORIAL" ):SetBlock({|| (cAliasQry)->HISTORIAL})
	oReport:Section(1):Cell("DEBITOS" ):SetBlock({|| (cAliasQry)->DEBITOS})
	oReport:Section(1):Cell("CREDITOS" ):SetBlock({|| (cAliasQry)->CREDITOS})

	IF(mv_par07==1)
		oReport:Section(1):Cell("NIT" ):SetBlock({|| (cAliasQry)->NIT})
		oReport:Section(1):Cell("DV" ):SetBlock({|| (cAliasQry)->DV})
		oReport:Section(1):Cell("NOMBRE" ):SetBlock({|| cName})

	ENDIF

	cNum:= ""
	cName:= ""
	cPref:= ""
	cDocum:= ""
	cFechaAux :=""






	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁTransforma parametros Range em expressao SQL                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MakeSqlExpr(oReport:uParam)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFiltragem do relatСrio                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("CT2")
	// dbSetOrder(2)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuery do relatСrio da secao 1                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oReport:Section(1):BeginQuery()
	BeginSql Alias cAliasQry
		SELECT
		DISTINCT
			CT2_SEQUEN,
			CT2_LOTE,
			CT2_SBLOTE,
			CT2_DOC,
			CT2_LINHA,
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
			(SELECT TOP 1 CV0_DESC FROM %Table:CV0% WHERE D_E_L_E_T_<>'*' AND CV0_CODIGO=CT2_EC05CR)NOMBRE
		FROM
			%Table:CT2% CT2
		INNER JOIN %Table:CT1% CT11
		ON CT2.CT2_CREDIT = CT11.CT1_CONTA
			AND CT11.D_E_L_E_T_ = ''
		INNER JOIN %Table:CT1% CT12
		ON CT11.CT1_XNIIFS = CT12.CT1_CONTA
			AND CT12.D_E_L_E_T_ = ''
		INNER JOIN %Table:CV0% CV0
		ON CT2_EC05CR = CV0.CV0_CODIGO
			AND CV0.D_E_L_E_T_ = ''
		WHERE
			CT2.D_E_L_E_T_ = ''
			AND CT2_CREDIT > 0
			AND CT2_CREDIT >= %Exp:mv_par01%
			AND CT2_CREDIT <= %Exp:mv_par02%
			AND CT2_DATA >= %Exp:mv_par03%
			AND CT2_DATA <= %Exp:mv_par04%
			AND CT2_MOEDLC = %Exp:mv_par05%
			AND CT2_TPSALD = %Exp:mv_par06%
			AND CT2_EC05CR >= %Exp:mv_par08%
			AND CT2_EC05CR <= %Exp:mv_par09%
		UNION
		SELECT
		DISTINCT
CT2_SEQUEN,
CT2_LOTE,
CT2_SBLOTE,
CT2_DOC,
CT2_LINHA,
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
			CT2_EC05DB NIT,
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
			(SELECT TOP 1 CV0_DESC FROM %Table:CV0% WHERE D_E_L_E_T_<>'*' AND CV0_CODIGO=CT2_EC05DB)NOMBRE
		FROM
			%Table:CT2% CT2
		INNER JOIN %Table:CT1% CT11
		ON CT2.CT2_DEBITO = CT11.CT1_CONTA
			AND CT11.D_E_L_E_T_ = ''
		INNER JOIN %Table:CT1% CT12
		ON CT11.CT1_XNIIFS = CT12.CT1_CONTA
			AND CT12.D_E_L_E_T_ = ''
		INNER JOIN %Table:CV0% CV0
		ON CT2_EC05DB = CV0.CV0_CODIGO
			AND CV0.D_E_L_E_T_ = ''
		WHERE
			CT2.D_E_L_E_T_ = ''
			AND CT2_DEBITO > 0
			AND CT2_DEBITO >= %Exp:mv_par01%
			AND CT2_DEBITO <= %Exp:mv_par02%
			AND CT2_DATA >= %Exp:mv_par03%
			AND CT2_DATA <= %Exp:mv_par04%
			AND CT2_MOEDLC = %Exp:mv_par05%
			AND CT2_TPSALD = %Exp:mv_par06%
			AND CT2_EC05DB >= %Exp:mv_par08%
			AND CT2_EC05DB <= %Exp:mv_par09%
	EndSql
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMetodo EndQuery ( Classe TRSection )                                    Ё
	//Ё                                                                        Ё
	//ЁPrepara o relatСrio para executar o Embedded SQL.                       Ё
	//Ё                                                                        Ё
	//ЁExpA1 : Array com os parametros do tipo Range                           Ё
	//Ё                                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)



	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicio da impressao do fluxo do relatСrio                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cAliasQry)
	dbGoTop()
	oReport:SetMeter((cAliasQry)->(LastRec()))
	oReport:Section(1):Init()



	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

		cNum 	 := (cAliasQry)->DOCUM

		cNum  := STRTOKARR((cAliasQry)->DOCUM, ' ')
		cPref :=""
		cDocum :=" "
		cFechaAux := (cAliasQry)->FECHA_AUX
		cFechaAux := STOD((cAliasQry)->FECHA_AUX)
		IF len(cNum)>=1
			cPref :=cNum[1]
		endif
		IF len(cNum)>=2
			cDocum :=cNum[2]
		endif

		IF (LEN(ALLTRIM((cAliasQry)->NIT))>1)
			cName 	 := (cAliasQry)->NOMBRE
		ELSE
			cName := ""
		ENDIF

		oReport:Section(1):PrintLine()
		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo
	oReport:Section(1):Finish()




Return


