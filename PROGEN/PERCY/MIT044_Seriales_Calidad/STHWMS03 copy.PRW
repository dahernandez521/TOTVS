#Include "Rwmake.ch"
#Include "Protheus.ch"
#define CRLF chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS03  ºAutor  ³Percy Arias,SISTHEL º Data ³  18/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa itens del archivo Excel                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STHWMS03()

	local aArrayF4	:= {}
    local _xAlias   := getNextAlias()

    private oQual
	
    sql := "SELECT DISTINCT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_SERIE,ZZZ_DOC,ZZZ_ARQ,SUM(ZZZ_QTDE) AS QTDE"
	sql += "  FROM " + RetSqlName("ZZZ")
	sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
    sql += "   AND ZZZ_STATUS='2'"
    sql += "   AND D_E_L_E_T_=' '"
    sql += " GROUP BY ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_SERIE,ZZZ_DOC,ZZZ_ARQ"
    //sql += " ORDER BY ZZZ_ID DESC"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

	If (_xAlias)->(!EOF())

	    While (_xAlias)->(!EOF())

            Aadd( aArrayF4, {;
                (_xAlias)->ZZZ_PROD,;
                (_xAlias)->ZZZ_LOCAL,;
                (_xAlias)->ZZZ_NUMSEQ,;
                (_xAlias)->ZZZ_SERIE,;
                (_xAlias)->ZZZ_DOC,;
                (_xAlias)->ZZZ_ARQ,;
                Transform((_xAlias)->QTDE,"999,999.99");
            } )

	    	(_xAlias)->(dbSkip())

    	EndDo

    Endif

    (_xAlias)->( DBCloseArea() )

	If Len(aArrayF4) > 0
	
		nOpcA := 0
		cCadastro := "Cargas Realizadas"
			
		DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 40,110 OF oMainWnd		
		@ 0.5,  0 TO 15, 54.0 OF oDlg
		@ 1,.7 LISTBOX oQual VAR cVar Fields HEADER "Producto","Local","Numseq","Archivo","Cantidad" SIZE 420,180 ON DBLCLICK (nList:= oQual:nAt, nOpca := 1,oDlg:End())
		oQual:SetArray(aArrayF4)
		oQual:bLine := { ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2],;
				aArrayF4[oQual:nAT,3],aArrayF4[oQual:nAT,6],;
				aArrayF4[oQual:nAT,7]}}
		   
		DEFINE SBUTTON FROM 215, 375  TYPE 1 ACTION (nList:= oQual:nAt, nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 215, 405  TYPE 2 ACTION (nList:= oQual:nAt, oDlg:End()) ENABLE OF oDlg
			
		ACTIVATE MSDIALOG oDlg

		If nOpca == 1
            Processa({|| ExecIems( aArrayF4[nList,1],aArrayF4[nList,2],;
				        aArrayF4[nList,3],aArrayF4[nList,6],;
				        aArrayF4[nList,7];
                    );
            })
		EndIf

	Else
		Help(" ",1,"NO-LOTE")
	Endif

Return



Static Function ExecIems(cproducto,clocal,cnumseq,carchivo,nqtde)
 	
    //local nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SEQ" })
    local nPosTipo	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_TIPO" })
    local nPosQtde    := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_QTDE" })
    //local nPosSaldo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SALDO" })
    local nPosLocaDes := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_LOCDEST" })
    local nPosUbica	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_LOCALIZ" })
    local nPosSerie	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_NUMSERI" })
	local nZ          := len(aCols)
	local nUsado      := len(aHeader)
	local alColsAux	  := {}
	local nX		  := 0
	local nW		  := 0
	local cMsgErr	  := ""
    local _xAlias     := getNextAlias()
    local cNomArq	  := "log_"+dtos(date())+"_"+replace(time(),":","")+".log"
    local cArqLog	  := "\"+cNomArq
    local cArqTmp	  := ""

	sql := "SELECT ZZZ_PROD,ZZZ_LOCAL,ZZZ_NUMSEQ,ZZZ_DOC,ZZZ_SERIE,ZZZ_CLIFOR,ZZZ_LOJA,ZZZ_UBICA,ZZZ_QTDE,ZZZ_NROSER,ZZZ_STATUS"
	sql += "  FROM " + RetSqlName("ZZZ")
	sql += " WHERE ZZZ_FILIAL='" + xFilial("ZZZ") + "'"
	sql += "   AND ZZZ_STATUS='2'"
	sql += "   AND ZZZ_ARQ='"+carchivo+"'"
	sql += "   AND ZZZ_PROD='"+cproducto+"'"
	sql += "   AND ZZZ_LOCAL='"+clocal+"'"
	sql += "   AND ZZZ_NUMSEQ='"+cnumseq+"'"
	sql += "   AND D_E_L_E_T_=' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_xAlias,.T.,.T.) 

	If (_xAlias)->(!EOF())

    	SBE->(dbSetOrder(1))
    	SB1->(dbSetOrder(1))
        
        While (_xAlias)->(!EOF())

    		cLocalizacion := Padr( alltrim((_xAlias)->ZZZ_UBICA), tamSx3("DB_LOCALIZ")[1] )
    		cproducto := Padr( alltrim((_xAlias)->ZZZ_PROD), tamSx3("B1_COD")[1] )
    		clocal := Padr( alltrim((_xAlias)->ZZZ_LOCAL), tamSx3("B1_LOCPAD")[1] )

            //if (_xAlias)->ZZZ_STATUS == "3"
                if SB1->( ( MsSeek( xFilial("SB1")+cproducto ) ) )
                    clocal := SB1->B1_LOCPAD
                endif
            //endif

            if SBE->( !( MsSeek( xFilial("SBE")+clocal+cLocalizacion ) ) )
                cMsgErr += "Local/ubicacion no encontrado: " + clocal + "/" + cLocalizacion + CRLF
            endif 

    		IncProc( "Leyendo registro " + alltrim((_xAlias)->ZZZ_NUMSEQ) )

    		alColsAux := {}
            for nX := 1 to nZ
                //if ( .not. empty( aCols[nX][nPosTipo] ) )
                    AADD(alColsAux, aClone(aCols[nX]) )
                //endif
            next nX
		
            
            if ( len(alColsAux) > 0 )
                aCols := {}
                aCols := aClone( alColsAux )
            endif
		
    		nZ := len(aCols)
            nZ++
            N := nZ
    		cItem := Strzero(nZ,tamSx3("D7_SEQ")[1])
	    	AADD(aCols, Array( nUsado + 1 ) )
            
            for nW := 1 to nUsado
                if (aHeader[nW,2] <> "D7_REC_WT") .And. (aHeader[nW,2] <> "D7_ALI_WT")
                    aCols[nZ,nW] := CriaVar(aHeader[nW,2])
                endif
                if aHeader[nW,2] == "D7_REC_WT"
                    aCols[nZ,nW] := 0
                endif
            next nW

            aCols[nZ,nUsado+1]    := .F.
            //aCols[nZ,nPosItem]    := cItem
            aCols[nZ,nPosTipo]    := 1

            U_EnterCpo("D7_TIPO",aCols[nZ][nPosTipo], nZ)

            aCols[nZ,nPosQtde] 	  := (_xAlias)->ZZZ_QTDE

            U_EnterCpo("D7_QTDE",aCols[nZ][nPosQtde], nZ)

            Sleep(10)

            aCols[nZ,nPosLocaDes] := clocal
            aCols[nZ,nPosUbica]   := (_xAlias)->ZZZ_UBICA
            aCols[nZ,nPosSerie]   := (_xAlias)->ZZZ_NROSER

            //GETDREFRESH()
            //A175LinOk()
            oGet:oBrowse:Refresh()

            (_xAlias)->( dbSkip() )

        end

		//Acerta sequencia da coluna D7_SEQ
		For nX := 1 to len(aCols)
            Sleep(10)
			If Empty(aCols[nX][1])
				aCols[nX][1] := StrZero(nX,3)
			EndIf
		Next

    endif

    (_xAlias)->( DBCloseArea() )

	if !empty(cMsgErr)

		u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
		u_XGRVLOG( cArqLog,cMsgErr,.T. )
		u_XGRVLOG( cArqLog,"----------------------------------------------------",.T. )
					
		__CopyFile( cArqLog, cArqTmp )

		shellExecute( "Open", "C:\Windows\System32\notepad.exe", cArqTmp , "C:\", 1 )
        MsgAlert('¡Existem errores, verifique!', 'TOTVS')
        Return
	endif

Return


