#include "protheus.ch"
#include "rwmake.ch"

User Function STHWMS06

    local _aArea        := getArea()
    //local nPosProducto  := aScan(aHeader,{|x| Alltrim(x[2])=="D2_COD"})	
    //local cIdProducto   := if(nPosProducto==0,"",aCols[n][nPosProducto])
    local cPerg         := "STH00006"
    local nMv           := 1
    local aMvPar        := {}

    cValid   := ""
    cF3      := ""
    cPicture := ""
    cDef01   := ""
    cDef02   := ""
    cDef03   := ""
    cDef04   := ""
    cDef05   := ""

    For nMv := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
    Next nMv

    u_STHSX101(cPerg, "01", "¿Producto?"            ,"MV_PAR01", "MV_CH0", "C", 25                      , 0, "G", cValid, "SB1" , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe el codigo del producto")
    u_STHSX101(cPerg, "02", "¿Serie?"               ,"MV_PAR02", "MV_CH1", "C", 3                       , 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe la seroe del documento")
    u_STHSX101(cPerg, "03", "¿Documento?"           ,"MV_PAR03", "MV_CH2", "C", 13                      , 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe el nro del documento origem")
    u_STHSX101(cPerg, "04", "¿Proveedor?"           ,"MV_PAR04", "MV_CH3", "C", 15                      , 0, "G", cValid, "SA2" , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe codigo del proveedor")
    u_STHSX101(cPerg, "05", "¿Loja?"                ,"MV_PAR05", "MV_CH4", "C", 2                       , 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe la tienda del proveedor")
    u_STHSX101(cPerg, "06", "¿Archivo?"             ,"MV_PAR06", "MV_CH5", "C", 30                      , 0, "F", cValid, cF3   , cPicture, "56"  ,  cDef02, cDef03, cDef04, cDef05, "Informe el archivo con los seriales a devolver")
    u_STHSX101(cPerg, "07", "¿Traer Marcados?"      ,"MV_PAR07", "MV_CH6", "N", 1                       , 1, "C", cValid, cF3   , cPicture, "Si"  ,  "No"  , cDef03, cDef04, cDef05, "¿Trae seleccionados?")

    if Pergunte(cPerg)
        //if empty(cIdProducto)
        //    MsgAlert("¡Digite el priducto para buscar los seriales!", "TOTVS")
        //else
            //MsgRun( "Aguarde, leyendo seriales ..." ,, {|| STHWMS51(cIdProducto) } )
            MsgRun( "Aguarde, leyendo seriales ..." ,, {|| STHWMS51(MV_PAR01) } )
        //endif
    endif

    For nMv := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
    Next nMv

    restArea(_aArea)

Return 

Static Function STHWMS51(cId)

    //Local aArea     := getArea()
    Local n_op      := 0
	Local aCores    := {}
	
	Private cMarca		:= GetMark()
	Private aSize    	:= MsAdvSize()
	Private aObjects 	:= {}
	Private aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,2}
	Private aPosObj  	:= {}
	Private aPosGet  	:= {}
	Private cCadastro	:= ""
	Private aCampos		:= {}
	Private aColumns	:= {}
	Private oDlg1

	Private _cForma		:= ""
	Private _cOrigem	:= ""
	Private _cCodDe		:= Space(6)
	Private _cCodAte	:= Space(6)
	
	AAdd ( aCores , { "TTX->TP_OK=' '" , "ENABLE"		} )
	AAdd ( aCores , { "TTX->TP_OK='I'" , "BR_AZUL"		} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='R'" , "DISABLE"		} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='D'" , "BR_LARANJA"	} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='E'" , "BR_AMARELO"	} )

	oFont2     := TFont():New( "MS Sans Serif",0,-21,,.F.,0,,400,.F.,.F.,,,,,, )

	xgetSql(cId)	
	
	AADD( aObjects, { 100, 40, .T., .F. } )
	AADD( aObjects, { 100, 100, .T., .T. } )
	AADD( aObjects, { 100, 10, .T., .F. } )
	
	aPosObj := MsObjSize(aInfo,aObjects)	
	
	//oDlg1 := TDialog():New(aSize[7],0,aSize[6],aSize[5],"Seleccionar Proceso",,,,,,,,oMainWnd,.T.)
	oDlg1 := TDialog():New(aSize[7]+100,100,aSize[6]-100,aSize[5]-195,"Seleccionar Seriales del Producto "+cId,,,,,,,,oMainWnd,.T.)

	oDlg1:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

	oBrw1 := MsSelect():New( "TTX","TP_OK",,aCampos,.F.,@cMarca,{aSize[7]+5,aPosObj[2,2],aPosObj[2,3]-120,aPosObj[2,4]-150},,,oDlg1,,aCores)
	
	oBrw1:bAval := {||CTTMark(@cMarca)}
	oBrw1:oBrowse:lHasMark := .T.
	oBrw1:oBrowse:lCanAllmark := .F.
	oBrw1:oBrowse:bAllMark  := { || CTTAMark(cMarca)}
	oBrw1:oBrowse:BRCLICKED := { || ModPre() }
	
	//oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],'',oDlg1,, .T., .T.,, ,(aPosObj[3,4]-10),012,.F.,.F. )
	oPanel := TPanel():New(aPosObj[3,1]-110,aPosObj[3,2]-100,'',oDlg1,, .T., .T.,, ,(aPosObj[3,4]-50),012,.F.,.F. )
	
	oTButton1 := TButton():New( 002, 002, "Confirmar",oPanel,{|| MsgRun( "Aguarde, cargando seriales..." ,, {|| ExecSeriales(cId) } ), oDlg1:End() }, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter1 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter1:Align := CONTROL_ALIGN_RIGHT

	oTButton2 := TButton():New( 002, 002, "Salir",oPanel,{|| n_op:=0,oDlg1:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton2:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter2 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter2:Align := CONTROL_ALIGN_RIGHT

	oDlg1:Activate(,,,.T.)
		
	If Select("TTX") > 0  
	   TRX->( dbCloseArea() )
	End

    //restArea(aArea)

Return


Static Function xgetSql(cId)

    local _xAlias05 := getNextAlias()
    local sql       := ""
    local aSeriales := leeSeriales()
    
    aColumns  := {}
    aCampos   := {}

    if Select("TTX") > 0
        TTX->( dbCloseArea() )
    endif

	AAdd(aColumns,{"TP_OK"      ,"C",02,0})
	AAdd(aColumns,{"TP_DOC"	    ,"C",tamSx3("DA_DOC")[1],0})
	AAdd(aColumns,{"TP_SERIE"	,"C",tamSx3("DA_SERIE")[1],0})
	AAdd(aColumns,{"TP_DATA"	,"D",8,0})
	AAdd(aColumns,{"TP_LOCAL"   ,"C",tamSx3("DB_LOCAL")[1],0})
	AAdd(aColumns,{"TP_LOCALIZ"	,"C",tamSx3("DB_LOCALIZ")[1],0})
	AAdd(aColumns,{"TP_NUMSERI" ,"C",tamSx3("DB_NUMSERI")[1],0})
	AAdd(aColumns,{"TP_QUANT"  	,"N",15,2})
	AAdd(aColumns,{"TP_NUMSEQ"  ,"C",tamSx3("DA_NUMSEQ")[1],0})

	cFileTRX := CriaTrab(aColumns) 
	DBCreate(cFileTRX,aColumns)

	DBUseArea(.T.,,cFileTRX,"TTX",.F.,.F.) // Exclusivo

    sql := "SELECT DA_PRODUTO,DA_LOCAL,DA_DOC,DA_SERIE,DA_QTDORI,DA_SALDO,DA_DATA,DA_NUMSEQ,"
    sql += "       DB_ITEM,DB_LOCAL,DB_LOCALIZ,DB_QUANT,DB_NUMSERI"
    sql += "  FROM "+RetSqlName("SDA")+" SDA"
    sql += " INNER JOIN "+RetSqlName("SDB")+" SDB"  
    sql += "    ON DA_FILIAL=DB_FILIAL"  
    sql += "   AND DA_PRODUTO=DB_PRODUTO"  
    sql += "   AND DA_LOCAL=DB_LOCAL"  
    sql += "   AND DA_DOC=DB_DOC"  
    sql += "   AND DA_SERIE=DB_SERIE"  
    sql += "   AND DA_NUMSEQ=DB_NUMSEQ"  
    sql += " WHERE DA_FILIAL='"+xFilial("SDA")+"'"  
    sql += "   AND DB_FILIAL='"+xFilial("SDB")+"'"  
    sql += "   AND SDA.D_E_L_E_T_=''"  
    sql += "   AND SDB.D_E_L_E_T_=''"  
    sql += "   AND DB_PRODUTO='"+cId+"'"
    sql += "   AND DB_SERIE='"+MV_PAR02+"'"
    sql += "   AND DB_DOC='"+MV_PAR03+"'"
    sql += "   AND DB_CLIFOR='"+MV_PAR04+"'"
    sql += "   AND DB_LOJA='"+MV_PAR05+"'"

    dbUseArea(.T., 'TOPCONN', TCGenQry(,,sql), _xAlias05, .F., .T.)

    if (_xAlias05)->(!EOF())

        While (_xAlias05)->(!EOF())

	    	TTX->( RecLock("TTX",.t.) )

            if len(aSeriales) > 0
                if aScan( aSeriales, alltrim((_xAlias05)->DB_NUMSERI) ) > 0
                    TTX->TP_OK := cMarca
                else
                    TTX->TP_OK := " "
                endif
            else
                TTX->TP_OK := if(MV_PAR07==1,cMarca," ")
            endif

			TTX->TP_DOC	    := (_xAlias05)->DA_DOC
			TTX->TP_SERIE	:= (_xAlias05)->DA_SERIE
			TTX->TP_DATA	:= STOD((_xAlias05)->DA_DATA)
			TTX->TP_LOCAL	:= (_xAlias05)->DB_LOCAL
			TTX->TP_LOCALIZ	:= (_xAlias05)->DB_LOCALIZ
			TTX->TP_NUMSERI := (_xAlias05)->DB_NUMSERI
			TTX->TP_QUANT	:= (_xAlias05)->DB_QUANT
			TTX->TP_NUMSEQ	:= (_xAlias05)->DA_NUMSEQ
			TTX->( MsUnLock() )

            (_xAlias05)->(dbSkip())

        end

    endif

    (_xAlias05)->(DBCloseArea())

	dbSelectArea("TTX")
	aCampos := {}
	AADD(aCampos,{"TP_OK"		,," "				,})
	AADD(aCampos,{"TP_DOC"	    ,,"Documento" 		,})
	AADD(aCampos,{"TP_SERIE"	,,"Serie"			,})
	AADD(aCampos,{"TP_DATA  "	,,"Emision"			,})
	AADD(aCampos,{"TP_LOCAL"	,,"Bodega"	    	,})
	AADD(aCampos,{"TP_LOCALIZ"	,,"Ubicacion"		,})
	AADD(aCampos,{"TP_NUMSERI"	,,"Num.Serie"		,})
	AADD(aCampos,{"TP_QUANT"	,,"Cantidad"		,})
	AADD(aCampos,{"TP_NUMSEQ"	,,"Num.Seq."		,})
		
	cKey  := "TP_DOC"
	cFiltro := ""
	cArq := CriaTrab( Nil, .F. )

	IndRegua("TTX",cArq,cKey,,,OemToAnsi("Organizando Archivo..."))

Return

Static Function CTTMark()

	Local lDesMarca := TTX->(IsMark("TP_OK", cMarca))
	
	TTX->( RecLock("TTX", .F.) )
	if lDesmarca
		TTX->TP_OK := " "
	else
		TTX->TP_OK := cMarca
	endif
	TTX->(MsUnlock())
	
	oBrw1:oBrowse:Refresh()
	
Return()


Static Function CTTAMark()

	Local x_aArea  := GetArea()
	Local lMarca := Nil   

	dbSelectArea("TTX")
	TTX->( dbgotop() )
	While TTX->(!Eof())
		If (lMarca == Nil)
			lMarca := (TTX->TP_OK == cMarca)
		EndIf
		RecLock("TTX",.F.)
		TTX->TP_OK := If( lMarca,"",cMarca )
		MsUnLock()
		DbSkip()
	EndDo
  
  	oBrw1:oBrowse:Refresh()
  	
	RestArea(x_aArea)

Return


Static Function leeSeriales()

	Local cLinha := ""
	Local aDatos := {}

    if !empty(MV_PAR06)

        FT_FUSE( alltrim( MV_PAR06 ) )
        
        While !FT_FEOF()
        
            cLinha := Alltrim( FT_FREADLN() )
            Aadd( aDatos, cLinha )
                            
            FT_FSKIP()
        
        EndDo
        
        FT_FUSE() 
    
    endif

Return(aDatos)





Static Function ExecSeriales(cIdProducto)

    local nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM" })
    local nPosProd	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD" })
    local nPosLocal	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_LOCAL" })
    local nPosQtde    := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT" })
    local nPosUbica	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_LOCALIZ" })
    local nPosSerie	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NUMSERI" })
    local nPosNFOrig  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NFORI" })
    local nPosSerOrig := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_SERIORI" })
    local nPosCCusto  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CCUSTO" })
    local nPosPrecio  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN" })
    local nPosGrupo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_GRUPO" })
    local nPosTES     := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES" })
    local nPosSTSERV  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_STSERV" })
	local nZ          := 1  //len(aCols)
	local nUsado      := len(aHeader)
    local nX          := 0
    local nW          := 0
    local cCosto      := getNewpar("ST_CCOSTO","VT01")
    local cD2_STSERV  := getNewpar("ST_STSERV","1")

    TTX->(dbgotop())
    SD1->( DbSetOrder(1) )
    SF4->( DbSetOrder(1) )

    while TTX->(!Eof())

        if !empty(TTX->TP_OK)

            if nZ > 1

                AADD(aCols, Array( nUsado + 1 ) )

                for nW := 1 to nUsado
                    if (aHeader[nW,2] <> "D2_REC_WT") .And. (aHeader[nW,2] <> "D2_ALI_WT")
                        aCols[nZ,nW] := CriaVar(aHeader[nW,2])
                    endif
                    if aHeader[nW,2] == "D2_REC_WT"
                        aCols[nZ,nW] := 0
                    endif
                next nW

            endif

            n := nZ
            nPrecioVenta := 0
            cTesDevolucion := ""

            if SD1->( MsSeek( xFilial("SD1")+TTX->TP_DOC+TTX->TP_SERIE+M->F2_CLIENTE+M->F2_LOJA+cIdProducto ) )
                cCosto := SD1->D1_CC
                nPrecioVenta := SD1->D1_VUNIT
                if SF4->( MsSeek( xFilial("SF4")+SD1->D1_TES ) )
                    cTesDevolucion := SF4->F4_TESDV
                endif
                
            endif

            aCols[nZ,nUsado+1]  := .F.
            aCols[nZ,nPosItem]  := strzero(n,2)
            aCols[nZ,nPosProd]  := cIdProducto
            M->D2_COD           := cIdProducto

            U_EnterCpo("D2_COD",M->D2_COD, nZ)
            //U_EnterCpo("D2_COD",aCols[nZ][nPosProd], n)
            //RunTrigger(2,n,nil,,"D2_COD") 

            aCols[nZ,nPosQtde] 	  := TTX->TP_QUANT
            M->D2_QUANT           := TTX->TP_QUANT

            U_EnterCpo("D2_QUANT",M->D2_QUANT, nZ)

            aCols[nZ,nPosPrecio]  := nPrecioVenta
            M->D2_PRCVEN          := nPrecioVenta

            U_EnterCpo("D2_PRCVEN",M->D2_PRCVEN, nZ)


            aCols[nZ,nPosLocal]   := TTX->TP_LOCAL
            M->D2_LOCAL           := TTX->TP_LOCAL
            aCols[nZ,nPosTES]     := cTesDevolucion
            M->D2_TES             := cTesDevolucion
            aCols[nZ,nPosCCusto]  := cCosto
            M->D2_CCUSTO          := cCosto
            aCols[nZ,nPosUbica]   := TTX->TP_LOCALIZ
            M->D2_LOCALIZ         := TTX->TP_LOCALIZ
            aCols[nZ,nPosSerie]   := TTX->TP_NUMSERI
            M->D2_NUMSERI         := TTX->TP_NUMSERI

            aCols[nZ,nPosNFOrig]  := TTX->TP_DOC
            M->D2_NFORI           := TTX->TP_DOC

            U_EnterCpo("D2_NFORI",M->D2_NFORI, nZ)

            aCols[nZ,nPosSerOrig] := TTX->TP_SERIE
            M->D2_SERIORI         := TTX->TP_SERIE

            aCols[nZ,nPosSTSERV]  := cD2_STSERV
            M->D2_STSERV          := cD2_STSERV

            nZ++

            //oGetDados:oBrowse:Refresh()

            //Sleep(5)


        endif

        TTX->( dbSkip() )

    end

 	For nX := 1 to len(aCols)
		//aCols[nX][nPosItem]    := StrZero(nX,2)
		//aCols[nX][nPosNFOrig]  := MV_PAR02
		//aCols[nX][nPosSerOrig] := MV_PAR03
		aCols[nX][nPosGrupo] := Posicione("SB1",1,xFilial("SB1")+M->D2_COD,"B1_GRUPO")
        aCols[nX][nPosTES]   := cTesDevolucion
	Next
 
    //ADel(aCols,1)
    //oGetDados:oBrowse:Refresh()

    //MaColsToFis(aHeader,aCols,,"MT100",.T.,,,.T.)


Return
