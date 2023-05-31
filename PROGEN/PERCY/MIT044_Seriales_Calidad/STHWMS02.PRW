#Include "RwMake.CH"
#include "tbiconn.ch"
#define CRLF chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS02  ºAutor  ³Percy Arias,SISTHEL º Data ³  16/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa itens del archivo Excel                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STHWMS02()

	Local _aArea	:= getArea()
	Local aPergs    := {}
	Private aResps  := {}
 
    aAdd(aPergs,{6,"Archivo: ",Space(150),"",'.T.','.T.',80,.F.,"archivos (*.csv) |*.csv"})

	If ParamBox(aPergs,"Parâmetros", @aResps)
    	Processa({|| STHWMS21()})
	EndIf            
		
	Restarea(_aArea) 

Return


Static Function STHWMS21()

    local _cFile	  	:= AllTrim(aResps[1])
    local _aData	  	:= xLeArqTxt(_cFile) 
	Local aCabSDA       := {}
	Local aItSDB        := {}
	Local _aItensSDB    := {}
	local cPathLog	  	:= getNewpar("AA_PATHLOG","C:\Temp")
	local cNomArq	  	:= "log_"+dtos(date())+"_"+replace(time(),":","")+".log"
	local cArqTmp	  	:= ""
	local cArqLog	  	:= "\"+cNomArq
	local nl			:= 1
	local cproduto 		:= ""
	local clocal	 	:= ""
	local cnumseq  		:= ""
	local cdoc	 		:= ""
	local cserie   		:= ""
	local cproveedor	:= ""
	local cloja    		:= ""
	local cMsgErr		:= ""
	local _xAlias		:= getNextAlias()
	local _zAlias		:= getNextAlias()
	local aRecsZZZ		:= {}

	Private lMsErroAuto := .F.

   	ProcRegua(len(_aData))

	If Right(Alltrim(cPathLog),1)="\"
		cArqTmp := Alltrim(cPathLog)+cNomArq
	Else
		cArqTmp := Alltrim(cPathLog)+"\"+cNomArq
	EndIf

	SBE->(dbSetOrder(1)) 	// BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_


	sql := "SELECT ZZZ_ID, R_E_C_N_O_ AS RECNO"
	sql += "  FROM " + RetSqlName("ZZZ")
	sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
	sql += "   AND D_E_L_E_T_=' '"
	sql += "   AND ZZZ_STATUS='0'"
	sql += "   AND ZZZ_ARQ='"+_cFile+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

	If (_xAlias)->(!EOF())

		While (_xAlias)->(!EOF())

			_nrec := (_xAlias)->RECNO

			ZZZ->(DbGoTo(_nrec))
			ZZZ->( RecLock("ZZZ",.f.))
			ZZZ->(DBDelete())
			ZZZ->(MsUnlock())

			(_xAlias)->(dbSkip())		
		
		end

	endif

	(_xAlias)->(dbCloseArea())

	SDA->(dbSetOrder(1))
	ZZZ->(dbSetOrder(2))

    for nl := 1 to len(_aData)

		cproduto 	:= padr(alltrim(_aData[nl][1]),tamSX3("DA_PRODUTO")[1])
		clocal	 	:= padr(alltrim(_aData[nl][2]),tamSX3("DA_LOCAL")[1])
		cnumseq  	:= padr(alltrim(_aData[nl][3]),tamSX3("DA_NUMSEQ")[1])
		cdoc	 	:= padr(alltrim(_aData[nl][4]),tamSX3("DA_DOC")[1])
		cserie   	:= padr(alltrim(_aData[nl][5]),tamSX3("DA_SERIE")[1])
		cproveedor	:= padr(alltrim(_aData[nl][6]),tamSX3("DA_CLIFOR")[1])
		cloja    	:= padr(alltrim(_aData[nl][7]),tamSX3("DA_LOJA")[1])
		cubicacion 	:= padr(alltrim(_aData[nl][8]),tamSX3("DB_LOCALIZ")[1])
		nqtde	 	:= VAL(_aData[nl][9])
		cnumserie	:= padr(alltrim(_aData[nl][10]),tamSX3("DB_NUMSERI")[1])

		// ZZZ_FILIAL, ZZZ_PROD, ZZZ_LOCAL, ZZZ_NUMSEQ, ZZZ_DOC, ZZZ_SERIE, ZZZ_CLIFOR, ZZZ_LOJA
		//if ZZZ->( !( MsSeek( xFilial("ZZZ")+cproduto+clocal+cnumseq+cdoc+cserie+cproveedor+cloja+cnumserie ) ) )

		sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"
		sql += "  FROM " + RetSqlName("ZZZ")
		sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
		sql += "   AND ZZZ_STATUS<>'0'"
		sql += "   AND ZZZ_PROD='"+cproduto+"'"
		sql += "   AND ZZZ_LOCAL='"+clocal+"'"
		sql += "   AND ZZZ_NUMSEQ='"+cnumseq+"'"
		sql += "   AND ZZZ_DOC='"+cdoc+"'"
		sql += "   AND ZZZ_SERIE='"+cserie+"'"
		sql += "   AND ZZZ_CLIFOR='"+cproveedor+"'"
		sql += "   AND ZZZ_LOJA='"+cloja+"'"
		sql += "   AND ZZZ_NROSER='"+cnumserie+"'"
		sql += "   AND D_E_L_E_T_=' '"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

		If (_xAlias)->(EOF())

			// DA_FILIAL, DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR, DA_LOJA
			if SDA->( MsSeek( xFilial("SDA")+cproduto+clocal+cnumseq+cdoc+cserie+cproveedor+cloja ) )

				if SDA->DA_SALDO > 0

					if SBE->( !( MsSeek( xFilial("SBE")+clocal+cubicacion ) ) )
					
						cMsgErr += "Local/ubicacion no encontrado: " + clocal + "/" + cubicacion + CRLF
					
					else
					
					
					endif

				else

					cMsgErr += "Producto/Local/ubicacion saldo menor o igual a cero: NUMSEQ("+cnumseq+")"+cproduto+"/"+clocal+"/"+cubicacion+CRLF

				endif

			else
				
				cMsgErr += "¡Producto/Local/ubicacion no encontrado en la tabla SDA!"+CRLF

			endif

		else

			cMsgErr += "¡Producto/Local/ubicacion/Serie YA fue ubicada - SERIE: " +cproduto+"/"+clocal+"/"+cubicacion+"/"+cserie +CRLF

		endif

		(_xAlias)->(dbCloseArea())


		sql := "SELECT COUNT(*) AS QTDE"
		sql += "  FROM " + RetSqlName("SDB")
		sql += " WHERE DB_FILIAL='" + xFilial("SDB") + "'"
		sql += "   AND DB_NUMSERI='"+cnumserie+"'"
		sql += "   AND D_E_L_E_T_=' '"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

		If (_xAlias)->QTDE > 0
			cMsgErr += "¡Nro de Serie " + alltrim(cnumserie) + " ya fue registrada anteriormente!"+CRLF
		Endif

		(_xAlias)->( DBCloseArea() )

    next nl



	if !empty(cMsgErr)

		u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
		u_XGRVLOG( cArqLog,cMsgErr,.T. )
		u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
					
		__CopyFile( cArqLog, cArqTmp )

		shellExecute( "Open", "C:\Windows\System32\notepad.exe", cArqTmp , "C:\", 1 )
        MsgAlert('¡Existem errores, verifique!', 'TOTVS')
        Return
	endif

    for nl := 1 to len(_aData)

		cproduto 	:= padr(alltrim(_aData[nl][1]),tamSX3("DA_PRODUTO")[1])
		clocal	 	:= padr(alltrim(_aData[nl][2]),tamSX3("DA_LOCAL")[1])
		cnumseq  	:= padr(alltrim(_aData[nl][3]),tamSX3("DA_NUMSEQ")[1])
		cdoc	 	:= padr(alltrim(_aData[nl][4]),tamSX3("DA_DOC")[1])
		cserie   	:= padr(alltrim(_aData[nl][5]),tamSX3("DA_SERIE")[1])
		cproveedor	:= padr(alltrim(_aData[nl][6]),tamSX3("DA_CLIFOR")[1])
		cloja    	:= padr(alltrim(_aData[nl][7]),tamSX3("DA_LOJA")[1])
		cubicacion 	:= padr(alltrim(_aData[nl][8]),tamSX3("DB_LOCALIZ")[1])
		nqtde	 	:= VAL(_aData[nl][9])
		cnumserie	:= padr(alltrim(_aData[nl][10]),tamSX3("DB_NUMSERI")[1])

		sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"
		sql += "  FROM " + RetSqlName("ZZZ")
		sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
		sql += "   AND ZZZ_STATUS<>'0'"
		sql += "   AND ZZZ_ARQ='"+_cFile+"'"
		sql += "   AND ZZZ_PROD='"+cproduto+"'"
		sql += "   AND ZZZ_LOCAL='"+clocal+"'"
		sql += "   AND ZZZ_NUMSEQ='"+cnumseq+"'"
		sql += "   AND ZZZ_DOC='"+cdoc+"'"
		sql += "   AND ZZZ_SERIE='"+cserie+"'"
		sql += "   AND ZZZ_CLIFOR='"+cproveedor+"'"
		sql += "   AND ZZZ_LOJA='"+cloja+"'"
		sql += "   AND ZZZ_NROSER='"+cnumserie+"'"
		sql += "   AND D_E_L_E_T_=' '"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

		If (_xAlias)->(EOF())

			ZZZ->( RecLock("ZZZ",.t.) )
			ZZZ->ZZZ_FILIAL	:= xFilial("ZZZ")
			ZZZ->ZZZ_ID		:= somahum()
			ZZZ->ZZZ_PROD	:= cproduto
			ZZZ->ZZZ_LOCAL	:= clocal
			ZZZ->ZZZ_NUMSEQ	:= cnumseq
			ZZZ->ZZZ_DOC	:= cdoc
			ZZZ->ZZZ_SERIE	:= cserie
			ZZZ->ZZZ_CLIFOR	:= cproveedor
			ZZZ->ZZZ_LOJA	:= cloja
			ZZZ->ZZZ_UBICA	:= cubicacion
			ZZZ->ZZZ_QTDE	:= nqtde
			ZZZ->ZZZ_NROSER	:= cnumserie
			ZZZ->ZZZ_ARQ	:= _cFile
			ZZZ->ZZZ_DATA	:= dDataBase
			ZZZ->ZZZ_HORA	:= time()
			ZZZ->ZZZ_USER	:= cUserName
			ZZZ->ZZZ_STATUS	:= "0"
			ZZZ->( MsUnlock() )

		endif

		(_xAlias)->( DBCloseArea() )

	next nl

	cMsgErr := ""

	// sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA,SUM(ZZZ_QTDE) AS QTDE"
	// sql += "  FROM " + RetSqlName("ZZZ")
	// sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
	// sql += "   AND ZZZ_STATUS='0'"
	// sql += "   AND ZZZ_ARQ='"+_cFile+"'"
	// sql += "   AND D_E_L_E_T_=' '"
	// sql += " GROUP BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"
	// sql += " ORDER BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"

	// dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

	// If (_xAlias)->(!EOF())

	// 	SDA->( dbSetOrder(1) )

	// 	While (_xAlias)->(!EOF())

	// 		cproduto 	:= padr(alltrim((_xAlias)->ZZZ_PROD),tamSX3("DA_PRODUTO")[1])
	// 		clocal	 	:= padr(alltrim((_xAlias)->ZZZ_LOCAL),tamSX3("DA_LOCAL")[1])
	// 		cnumseq  	:= padr(alltrim((_xAlias)->ZZZ_NUMSEQ),tamSX3("DA_NUMSEQ")[1])
	// 		cdoc	 	:= padr(alltrim((_xAlias)->ZZZ_DOC),tamSX3("DA_DOC")[1])
	// 		cserie   	:= padr(alltrim((_xAlias)->ZZZ_SERIE),tamSX3("DA_SERIE")[1])
	// 		cproveedor	:= padr(alltrim((_xAlias)->ZZZ_CLIFOR),tamSX3("DA_CLIFOR")[1])
	// 		cloja    	:= padr(alltrim((_xAlias)->ZZZ_LOJA),tamSX3("DA_LOJA")[1])

	// 		if SDA->( MsSeek( xFilial("SDA")+cproduto+clocal+cnumseq+cdoc+cserie+cproveedor+cloja ) )

	// 			if (_xAlias)->QTDE <> SDA->DA_SALDO

	// 				cMsgErr += cproduto+"/"+clocal+"/"+cnumseq+"/"+cdoc+"/"+cserie+"/"+cproveedor+"/"+cloja+" - SALDO INSUFICIENTE"+CRLF
	// 				cMsgErr += "CANT.IMPORTAR---" + transform((_xAlias)->QTDE,"999999.99")+CRLF
	// 				cMsgErr += "CANT.ACTUAL....." + transform(SDA->DA_SALDO,"999999.99")+CRLF

	// 			endif

	// 		endif

	// 		(_xAlias)->(dbSkip())

	// 	end

	// EndIf

	// (_xAlias)->( dbCloseArea() )


	// if !empty(cMsgErr)

	// 	u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
	// 	u_XGRVLOG( cArqLog,cMsgErr,.T. )
	// 	u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
					
	// 	__CopyFile( cArqLog, cArqTmp )

	// 	shellExecute( "Open", "C:\Windows\System32\notepad.exe", cArqTmp , "C:\", 1 )
    //     MsgAlert('¡Existem errores, verifique!', 'TOTVS')
    //     Return
	// endif

	// ------------------------------------- //
	// genera los numeros seriales en la SDB //
	// ------------------------------------- //

	nitem := 1

	sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA,SUM(ZZZ_QTDE) AS QTDE"
	sql += "  FROM " + RetSqlName("ZZZ")
	sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
	sql += "   AND ZZZ_STATUS='0'"
	sql += "   AND ZZZ_ARQ='"+_cFile+"'"
	sql += "   AND D_E_L_E_T_=' '"
	sql += " GROUP BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"
	sql += " ORDER BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

	If (_xAlias)->(!EOF())

		While (_xAlias)->(!EOF())

			cproduto 	:= padr(alltrim((_xAlias)->ZZZ_PROD),tamSX3("DA_PRODUTO")[1])
			clocal	 	:= padr(alltrim((_xAlias)->ZZZ_LOCAL),tamSX3("DA_LOCAL")[1])
			cnumseq  	:= padr(alltrim((_xAlias)->ZZZ_NUMSEQ),tamSX3("DA_NUMSEQ")[1])
			cdoc	 	:= padr(alltrim((_xAlias)->ZZZ_DOC),tamSX3("DA_DOC")[1])
			cserie   	:= padr(alltrim((_xAlias)->ZZZ_SERIE),tamSX3("DA_SERIE")[1])
			cproveedor	:= padr(alltrim((_xAlias)->ZZZ_CLIFOR),tamSX3("DA_CLIFOR")[1])
			cloja    	:= padr(alltrim((_xAlias)->ZZZ_LOJA),tamSX3("DA_LOJA")[1])

			// DB_FILIAL, DB_PRODUTO, DB_LOCAL, DB_NUMSEQ, DB_DOC, DB_SERIE, DB_CLIFOR, DB_LOJA, DB_ITEM
			sql := "SELECT MAX(DB_ITEM) AS ITEM"
			sql += "  FROM " + RetSqlName("SDB")
			sql += " WHERE DB_FILIAL='" + xFilial("SDB") + "'"
			sql += "   AND DB_PRODUTO='"+cproduto+"'"
			sql += "   AND DB_LOCAL='"+clocal+"'"
			sql += "   AND DB_NUMSEQ='"+cnumseq+"'"
			sql += "   AND DB_DOC='"+cdoc+"'"
			sql += "   AND DB_SERIE='"+cserie+"'"
			sql += "   AND DB_CLIFOR='"+cproveedor+"'"
			sql += "   AND DB_LOJA='"+cloja+"'"
			sql += "   AND D_E_L_E_T_=' '"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_zAlias,.T.,.T.) 

			If (_zAlias)->(!EOF())
				nitem := VAL((_zAlias)->ITEM)+1
			Endif

			(_zAlias)->( DBCloseArea() )


			_aItensSDB := {}
			//cproduto   := (_xAlias)->ZZZ_PROD
			//clocal     := (_xAlias)->ZZZ_LOCAL

			aCabSDA	:=	{	{"DA_PRODUTO"	,cproduto				,Nil },;
							{"DA_LOCAL"		,(_xAlias)->ZZZ_LOCAL	,Nil },;
							{"DA_NUMSEQ"	,(_xAlias)->ZZZ_NUMSEQ	,Nil };
						}

			sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA,"
			sql += "	   ZZZ_UBICA,ZZZ_QTDE,ZZZ_NROSER,R_E_C_N_O_ AS ID"
			sql += "  FROM " + RetSqlName("ZZZ")
			sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
			sql += "   AND ZZZ_STATUS='0'"
			sql += "   AND ZZZ_ARQ='"+_cFile+"'"
			sql += "   AND ZZZ_PROD='"+cproduto+"'"
			sql += "   AND ZZZ_LOCAL='"+clocal+"'"
			sql += "   AND D_E_L_E_T_=' '"
			sql += " ORDER BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_zAlias,.T.,.T.) 

			If (_zAlias)->(!EOF())

				While (_zAlias)->(!EOF())

					aAdd( aRecsZZZ,(_zAlias)->ID )

					aItSDB	:= {	{"DB_ITEM"		,strzero(nitem,tamSX3("DB_ITEM")[1])	,Nil	},;
									{"DB_PRODUTO"	,(_zAlias)->ZZZ_PROD					,Nil	},;
									{"DB_LOCAL"		,(_zAlias)->ZZZ_LOCAL					,Nil	},;
									{"DB_LOCALIZ"	,(_zAlias)->ZZZ_UBICA					,Nil	},;
									{"DB_DATA"		,dDataBase								,Nil	},;
									{"DB_QUANT"		,(_zAlias)->ZZZ_QTDE					,Nil	},;
									{"DB_NUMSERI"	,(_zAlias)->ZZZ_NROSER					,Nil	};
								}
				
					aadd(_aItensSDB,aitSDB)
					nitem++

					(_zAlias)->(dbSkip())

				end

			endif

			(_zAlias)->(dbCloseArea())

			MATA265( aCabSDA, _aItensSDB, 3)
			If lMsErroAuto
				MostraErro()
			Else
				if len(aRecsZZZ) > 0

					for nl := 1 to len(aRecsZZZ)

						_nrec := aRecsZZZ[nl]

						ZZZ->(DbGoTo(_nrec))
						ZZZ->(RecLock("ZZZ",.f.))
						ZZZ->ZZZ_STATUS := "2"
						ZZZ->(MsUnlock())

					next nl

				endif

				MsgAlert("Processamento Ok!","TOTVS")
			
			Endif

			(_xAlias)->(dbSkip())

		end

	endif

	(_xAlias)->(dbCloseArea())

Return


Static Function xLeArqTxt( cNomArchivo )

	Local cLinha := ""
	Local nX := 1
	Local _aItens := {}
	Local _aDetalle := {}

	FT_FUSE( cNomArchivo )
	   
	While !FT_FEOF()
	
		if nX>=2
		
			cLinha := Alltrim( FT_FREADLN() )

			if right(alltrim(cLinha),1) <> ";"
				cLinha := alltrim(cLinha) + ";" 
			endif
			
			if len(cLinha) > 5
				
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,",",";")
				_aItens := StrTokArr( cLinha, ";" )

				Aadd( _aDetalle, _aItens )
				
			endif
			
		endif
		
		FT_FSKIP()
		nX++
	 
	EndDo
	
	FT_FUSE() 

Return( _aDetalle )


Static Function somahum()

	Local nNextCode := 1
	Local _cQry := ""
	Local _cAlias := getNextAlias()
	
	_cQry := "SELECT ISNULL(MAX(ZZZ_ID),0) AS XCODE"
	_cQry += "  FROM " + RetSqlName("ZZZ")
	_cQry += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
	_cQry += "   AND D_E_L_E_T_=' '"
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.T.,.T.) 

	If val((_cAlias)->(XCODE)) <= 0
		nNextCode := 1
	Else
		nNextCode := val((_cAlias)->(XCODE)) + 1
	EndIf

	nNextCode := strzero(nNextCode,tamSX3("ZZZ_ID")[1])

	(_cAlias)->( dbCloseArea() )

Return(nNextCode)


