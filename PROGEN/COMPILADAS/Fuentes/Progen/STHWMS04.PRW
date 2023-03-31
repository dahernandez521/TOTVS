#Include "Rwmake.ch"
#Include "Protheus.ch"
#include "fileio.ch"
#define CRLF chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS04  ºAutor  ³Percy Arias,SISTHEL º Data ³  10/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Llena grilla de transferencia multiple a partir de los     º±±
±±º          ³ documentos cargados de importacion.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STHWMS04()

    cPerg    := "STHWMS04"
     
    cValid   := ""
    cF3      := ""
    cPicture := ""
    cDef01   := ""
    cDef02   := ""
    cDef03   := ""
    cDef04   := ""
    cDef05   := ""
     
    u_STHSX101(cPerg, "01", "¿Deposito Orig.?"   ,"MV_PAR01", "MV_CH0", "C", TamSX3('NNR_CODIGO')[1], 0, "G", cValid, "NNR" , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe el deposito origen")
    u_STHSX101(cPerg, "02", "¿Ubicacion Orig.?"  ,"MV_PAR02", "MV_CH1", "C", tamSx3("D1_LOCALIZ")[1], 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe la ubicacion origen")
    u_STHSX101(cPerg, "03", "¿Deposito Dest.?"   ,"MV_PAR03", "MV_CH2", "C", TamSX3('NNR_CODIGO')[1], 0, "G", cValid, "NNR" , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe el deposito destino")
    u_STHSX101(cPerg, "04", "¿Ubicacion Dest.?"  ,"MV_PAR04", "MV_CH3", "C", tamSx3("D1_LOCALIZ")[1], 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe la ubicacion destino")
    u_STHSX101(cPerg, "05", "¿Proceso?"          ,"MV_PAR05", "MV_CH4", "C", TamSX3('F1_HAWB')[1]   , 0, "G", cValid, cF3   , cPicture, cDef01,  cDef02, cDef03, cDef04, cDef05, "Informe el codigo del proceso")

    if Pergunte(cPerg)

      	MsgRun( "Aguarde, leyendo informaciones ..." ,, {|| STHWMS41() } )

    endif

Return


Static Function STHWMS41()

    Local n_op := 0
	Local aCores := {}
	
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
	
	AAdd ( aCores , { "TRX->TP_OK=' '" , "ENABLE"		} )
	AAdd ( aCores , { "TRX->TP_OK='I'" , "BR_AZUL"		} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='R'" , "DISABLE"		} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='D'" , "BR_LARANJA"	} )
	//AAdd ( aCores , { "TRX->TP_ORIGEM='E'" , "BR_AMARELO"	} )

	oFont2     := TFont():New( "MS Sans Serif",0,-21,,.F.,0,,400,.F.,.F.,,,,,, )

	xMontaSql()	
	
	AADD( aObjects, { 100, 40, .T., .F. } )
	AADD( aObjects, { 100, 100, .T., .T. } )
	AADD( aObjects, { 100, 10, .T., .F. } )
	
	aPosObj := MsObjSize(aInfo,aObjects)	
	
	//oDlg1 := TDialog():New(aSize[7],0,aSize[6],aSize[5],"Seleccionar Proceso",,,,,,,,oMainWnd,.T.)
	oDlg1 := TDialog():New(aSize[7]+100,100,aSize[6]-100,aSize[5]-195,"Seleccionar Proceso",,,,,,,,oMainWnd,.T.)

	oDlg1:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

	oBrw1 := MsSelect():New( "TRX","TP_OK",,aCampos,.F.,@cMarca,{aSize[7]+5,aPosObj[2,2],aPosObj[2,3]-120,aPosObj[2,4]-150},,,oDlg1,,aCores)
	
	oBrw1:bAval := {||CTTMark(@cMarca)}
	oBrw1:oBrowse:lHasMark := .T.
	oBrw1:oBrowse:lCanAllmark := .F.
	oBrw1:oBrowse:bAllMark  := { || CTTAMark(cMarca)}
	oBrw1:oBrowse:BRCLICKED := { || ModPre() }
	
	//oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],'',oDlg1,, .T., .T.,, ,(aPosObj[3,4]-10),012,.F.,.F. )
	oPanel := TPanel():New(aPosObj[3,1]-110,aPosObj[3,2]-100,'',oDlg1,, .T., .T.,, ,(aPosObj[3,4]-50),012,.F.,.F. )
	
	oTButton1 := TButton():New( 002, 002, "Confirmar",oPanel,{|| MsgRun( "Aguarde, cargando informacion..." ,, {|| ProcMovs() } ), oDlg1:End() }, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter1 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter1:Align := CONTROL_ALIGN_RIGHT

	oTButton2 := TButton():New( 002, 002, "Salir",oPanel,{|| n_op:=0,oDlg1:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton2:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter2 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter2:Align := CONTROL_ALIGN_RIGHT

	oDlg1:Activate(,,,.T.)
		
	If Select("TRX") > 0  
	   TRX->( dbCloseArea() )
	End   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS01  ºAutor  ³Microsiga           º Data ³  10/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcMovs()
	
    local nPosD3Cod   := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_COD" })
    local nPosD3Loc   := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOCAL" })
    local nPosD3Ubi   := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOCALIZ" })
    //local n2PosD3Cod  := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_COD" })
    //local n2PosD3Loc  := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOCAL" })
    //local n2PosD3Ubi  := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_LOCALIZ" })
    local nPosQtde    := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_QUANT" })
    local nPosSerie	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_NUMSERI" })
    local nPosDescri  := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_DESCRI" })
    local nPosUM      := aScan(aHeader,{|x| AllTrim(x[2]) == "D3_UM" })
	local nZ          := len(aCols)
	local nUsado      := len(aHeader)
	local alColsAux	  := {}
	local nX		  := 0
	local nW		  := 0
	local nl		  := 0
	local ntotal	  := 0
	local cMsgErr	  := ""
	local cPathLog	  := getNewpar("AA_PATHLOG","C:\Temp")
	local cNomArq	  := "log_"+dtos(date())+"_"+replace(time(),":","")+".log"
	local cArqTmp	  := ""
	local cArqLog	  := "\"+cNomArq

   	ProcRegua(TRX->( Reccount() ))

	If Right(Alltrim(cPathLog),1)="\"
		cArqTmp := Alltrim(cPathLog)+cNomArq
	Else
		cArqTmp := Alltrim(cPathLog)+"\"+cNomArq
	EndIf

	SBE->(dbSetOrder(1)) 	// BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_

    TRX->( dbgotop() )
    While (TRX->(!EOF()))

        if !empty(TRX->TP_OK)
        
            IncProc( "leyendo registro " + alltrim(TRX->TP_COD) )

            alColsAux := {}
            for nX := 1 to nZ
                if ( .not. empty( aCols[nX][nPosD3Cod] ) )
                    AADD(alColsAux, aClone(aCols[nX]) )
                endif
            next nX
            
            aCols := {}
            if ( len(alColsAux) > 0 )
                aCols := aClone( alColsAux )
            endif
            
            nZ := len(aCols)
            //cItem := Strzero(nl,tamSx3("DB_ITEM")[1])
            AADD(aCols, Array( nUsado + 1 ) )
        
            nZ++
            N := nZ
            
            for nW := 1 to nUsado
                if (aHeader[nW,2] <> "D3_REC_WT") .And. (aHeader[nW,2] <> "D3_ALI_WT")
                    aCols[nZ,nW] := CriaVar(aHeader[nW,2])
                endif
                if aHeader[nW,2] == "D3_REC_WT"
                    aCols[nZ,nW] := 0
                endif
            next nW
        
            aCols[nZ,nUsado+1]   := .F.
            aCols[nZ,nPosD3Cod]  := TRX->TP_COD
            M->D3_COD            := aCols[nZ,nPosD3Cod]

            If nPosDescri > 0
                If SB1->(dbSeek(xFilial("SB1")+aCols[Len(aCols),nPosD3Cod]))
                    aCols[Len(aCols),nPosDescri] := SB1->B1_DESC
                    aCols[Len(aCols),7] := SB1->B1_DESC
                EndIf
            EndIf

            If nPosUM > 0
                If SB1->(dbSeek(xFilial("SB1")+aCols[Len(aCols),nPosD3Cod]))
                    aCols[Len(aCols),nPosUM] := SB1->B1_UM
                    aCols[Len(aCols),8] := SB1->B1_UM
                EndIf
            EndIf

            //U_EnterCpo("D3_COD",aCols[nZ][nPosD3Cod], nZ)

            A240IniCpo()

            aCols[nZ,nPosD3Loc]  := TRX->TP_LOCAL
            aCols[nZ,nPosD3Ubi]  := TRX->TP_LOCALIZ
            aCols[nZ,6]          := TRX->TP_COD

            aCols[nZ,9]          := MV_PAR03
            aCols[nZ,10]         := MV_PAR04
            aCols[nZ,nPosQtde]   := transform(TRX->TP_QUANT, PesqPict("SD3","D3_QUANT") )
            aCols[nZ,nPosSerie]  := TRX->TP_NUMSERI

            //A093Prod()
            //A241PrdGrd()
            //A241VLDFan(TRX->TP_COD)

            oGet:oBrowse:Refresh()
        
        endif

        TRX->( dbSkip() )
					
    EndDo
    
Return




Static Function xMontaSql()

	Local _aArea := getArea()
	Local _xAlias12 := getNextAlias()
	Local _xAlias05 := getNextAlias()

	aColumns := {}

	AAdd(aColumns,{"TP_OK"      ,"C",02,0})
	AAdd(aColumns,{"TP_HAWB"	,"C",tamSx3("F1_HAWB")[1],0})
	AAdd(aColumns,{"TP_EMISSAO"	,"D",8,0})
	AAdd(aColumns,{"TP_SERIE"	,"C",tamSx3("F1_SERIE")[1],0})
	AAdd(aColumns,{"TP_DOC"	    ,"C",tamSx3("F1_DOC")[1],0})
	AAdd(aColumns,{"TP_COD"    	,"C",tamSx3("D1_COD")[1],0})
	AAdd(aColumns,{"TP_LOCAL"	,"C",tamSx3("D1_LOCAL")[1],0})
	AAdd(aColumns,{"TP_QUANT"  	,"N",15,2})
	AAdd(aColumns,{"TP_LOCALIZ"	,"C",tamSx3("D1_LOCALIZ")[1],0})
	AAdd(aColumns,{"TP_NUMSERI"	,"C",tamSx3("D1_NUMSERI")[1],0})

	cFileTRX := CriaTrab(aColumns) 
	DBCreate(cFileTRX,aColumns)

	DBUseArea(.T.,,cFileTRX,"TRX",.F.,.F.) // Exclusivo

    cQuery := "SELECT F1_FILIAL,F1_HAWB,F1_EMISSAO,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA,D1_COD,D1_LOCAL,D1_QUANT,D1_LOCALIZ,D1_NUMSERI"+CRLF
    cQuery += "  FROM " + RetSqlName("SF1")+" SF1"+CRLF
    cQuery += " INNER JOIN " + RetSqlName("SD1")+" SD1"+CRLF
    cQuery += "    ON F1_DOC = D1_DOC"+CRLF
    cQuery += "   AND F1_SERIE = D1_SERIE"+CRLF
    cQuery += "   AND F1_FORNECE = D1_FORNECE"+CRLF
    cQuery += "   AND F1_LOJA = D1_LOJA"+CRLF
    cQuery += "   AND F1_FILIAL = D1_FILIAL"+CRLF
    cQuery += " WHERE SD1.D_E_L_E_T_ = ''"+CRLF
    cQuery += "   AND SF1.D_E_L_E_T_ = ''"+CRLF
    cQuery += "   AND F1_FILIAL='"+ xFilial("SF1") + "'"+CRLF
    cQuery += "   AND D1_FILIAL='"+ xFilial("SD1") + "'"+CRLF
    cQuery += "   AND F1_HAWB<>''"+CRLF
    cQuery += "   AND F1_TIPO='N'"+CRLF
	cQuery += "   AND SF1.R_E_C_N_O_>0"+CRLF
	cQuery += "   AND SD1.R_E_C_N_O_>0"+CRLF

    if !empty(MV_PAR01)
        cQuery += " AND D1_LOCAL='" + MV_PAR01 +"'" +CRLF
    endif

    if !empty(MV_PAR02)
        //cQuery += " AND D1_LOCALIZ='" + MV_PAR02 +"'" +CRLF
    endif

    if !empty(MV_PAR05)
        cQuery += " AND F1_HAWB='" + MV_PAR05 +"'" +CRLF
    endif

    cQuery += " ORDER BY F1_EMISSAO DESC"+CRLF
		
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), _xAlias12, .F., .T.)
				
	If (_xAlias12)->( !Eof() )
	
		While (_xAlias12)->( !Eof() )

			cProduto := (_xAlias12)->D1_COD
			cLocal   := (_xAlias12)->D1_LOCAL
			cSerie   := (_xAlias12)->F1_SERIE
			cDoc     := (_xAlias12)->F1_DOC
			cClifor  := (_xAlias12)->F1_FORNECE
			cLoja    := (_xAlias12)->F1_LOJA

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
			sql += "   AND DB_PRODUTO='"+cProduto+"'"
			sql += "   AND DB_LOCAL='"+cLocal+"'"
			sql += "   AND DB_SERIE='"+cSerie+"'"
			sql += "   AND DB_DOC='"+cDoc+"'"
			sql += "   AND DB_CLIFOR='"+cClifor+"'"
			sql += "   AND DB_LOJA='"+cLoja+"'"
			sql += "   AND DB_LOCALIZ='"+MV_PAR02+"'"

			dbUseArea(.T., 'TOPCONN', TCGenQry(,,sql), _xAlias05, .F., .T.)

			if (_xAlias05)->(!EOF())

				While (_xAlias05)->(!EOF())

					TRX->( RecLock("TRX",.t.) )
					TRX->TP_OK      := " "
					TRX->TP_HAWB	:= (_xAlias12)->F1_HAWB
					TRX->TP_EMISSAO	:= STOD((_xAlias12)->F1_EMISSAO)
					TRX->TP_SERIE	:= (_xAlias12)->F1_SERIE
					TRX->TP_DOC     := (_xAlias12)->F1_DOC
					TRX->TP_COD     := (_xAlias12)->D1_COD
					TRX->TP_LOCAL	:= (_xAlias12)->D1_LOCAL
					TRX->TP_QUANT	:= (_xAlias05)->DB_QUANT
					TRX->TP_LOCALIZ	:= (_xAlias05)->DB_LOCALIZ
					TRX->TP_NUMSERI	:= (_xAlias05)->DB_NUMSERI
					TRX->( MsUnLock() )
		
					(_xAlias05)->( dbSkip() )

				End

			endif

			(_xAlias05)->( dbCloseArea() )

			(_xAlias12)->( dbSkip() )

		End
	
	EndIf
	
	(_xAlias12)->( dbCloseArea() )

	        
	dbSelectArea("TRX")
	aCampos := {}
	AADD(aCampos,{"TP_OK"		,," "				,})
	AADD(aCampos,{"TP_HAWB"	    ,,"Proceso" 		,})
	AADD(aCampos,{"TP_EMISSAO"	,,"Emision"			,})
	AADD(aCampos,{"TP_SERIE"	,,"Serie"			,})
	AADD(aCampos,{"TP_DOC"	    ,,"Documento"		,})
	AADD(aCampos,{"TP_COD"	    ,,"Producto"		,})
	AADD(aCampos,{"TP_LOCAL"	,,"Almacen" 		,})
	AADD(aCampos,{"TP_QUANT"	,,"Cantidad"		,})
	AADD(aCampos,{"TP_LOCALIZ"	,,"Ubicacion"		,})
	AADD(aCampos,{"TP_NUMSERI"	,,"Num.Serie"		,})
		
	cKey  := "TP_HAWB"
	cFiltro := ""
	cArq := CriaTrab( Nil, .F. )

	IndRegua("TRX",cArq,cKey,,,OemToAnsi("Organizando Archivo..."))
	
	RestArea(_aArea)

Return


Static Function xGetFilial(__dFilial,_nX)

	Local _nRecnoSM0	:= SM0->( Recno() )
	Local _aLstFil		:= {}
	
	Default __dFilial := Nil
    
    If _nX==2
		Aadd( _aLstFil, "" )
	EndIf

	SM0->(dbGoTop())
	
	While SM0->(!Eof())

		If _nX==1
		
			If Alltrim(SM0->M0_CODFIL)==Alltrim(__dFilial)
				Aadd( _aLstFil, Alltrim(SM0->M0_CODFIL) + "-" + SM0->M0_FILIAL )
				Exit
			EndIf
		
		Else
			
			Aadd( _aLstFil, Alltrim(SM0->M0_CODFIL) + "-" + SM0->M0_FILIAL )
					
		EndIf
		
		SM0->( dbSkip() )

	End
	
	SM0->(dbGoTo(_nRecnoSM0))

Return( _aLstFil )


Static Function CTTMark()

	Local lDesMarca := TRX->(IsMark("TP_OK", cMarca))
	
	TRX->( RecLock("TRX", .F.) )
	if lDesmarca
		TRX->TP_OK := " "
	else
		TRX->TP_OK := cMarca
	endif
	TRX->(MsUnlock())
	
	oBrw1:oBrowse:Refresh()
	
Return()


Static Function CTTAMark()

	Local x_aArea  := GetArea()
	Local lMarca := Nil   

	dbSelectArea("TRX")
	TRX->( dbgotop() )
	While TRX->(!Eof())
		If (lMarca == Nil)
			lMarca := (TRX->TP_OK == cMarca)
		EndIf
		RecLock("TRX",.F.)
		TRX->TP_OK := If( lMarca,"",cMarca )
		MsUnLock()
		DbSkip()
	EndDo
  
  	oBrw1:oBrowse:Refresh()
  	
	RestArea(x_aArea)

Return


