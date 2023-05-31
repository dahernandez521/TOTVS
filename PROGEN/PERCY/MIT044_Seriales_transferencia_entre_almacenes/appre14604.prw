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

    Local n_op := 0
	Local aCores := {}
	Local _aIts := {}
	Local _aOpx := {}
	
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
	
	AAdd ( aCores , { "TRX->ZZ3_ORIGEM='C'" , "ENABLE"		} )
	AAdd ( aCores , { "TRX->ZZ3_ORIGEM='I'" , "BR_AZUL"		} )
	AAdd ( aCores , { "TRX->ZZ3_ORIGEM='R'" , "DISABLE"		} )
	AAdd ( aCores , { "TRX->ZZ3_ORIGEM='D'" , "BR_LARANJA"	} )
	AAdd ( aCores , { "TRX->ZZ3_ORIGEM='E'" , "BR_AMARELO"	} )

	oFont2     := TFont():New( "MS Sans Serif",0,-21,,.F.,0,,400,.F.,.F.,,,,,, )

	xMontaSql()	
	
	AADD( aObjects, { 100, 40, .T., .F. } )
	AADD( aObjects, { 100, 100, .T., .T. } )
	AADD( aObjects, { 100, 10, .T., .F. } )
	
	aPosObj := MsObjSize(aInfo,aObjects)	
	
	oDlg1 := TDialog():New(aSize[7],0,aSize[6],aSize[5],"Modulo de Expedicion",,,,,,,,oMainWnd,.T.)

	oDlg1:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

	oBrw1 := MsSelect():New( "TRX","ZZ3_YOK",,aCampos,.F.,@cMarca,{aSize[7],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,oDlg1,,aCores)
	
	oBrw1:bAval := {||CTTMark(@cMarca)}
	oBrw1:oBrowse:lHasMark := .T.
	oBrw1:oBrowse:lCanAllmark := .F.
	oBrw1:oBrowse:bAllMark  := { || CTTAMark(cMarca)}
	oBrw1:oBrowse:BRCLICKED := { || ModPre() }
	
	oPanel := TPanel():New(aPosObj[3,1],aPosObj[3,2],'',oDlg1,, .T., .T.,, ,(aPosObj[3,4]-10),012,.F.,.F. )
	
	_aIts := xGetFilial("",2)
	_oCmbFormas := TComboBox():New( 002,002, {|u| If(PCount()>0,_cForma:=u,_cForma)},_aIts,100,60,oPanel,,{|| n_op:=0,TRX->(dbCloseArea()),oDlg1:End(),u_clProcessa() /*xFiltraBrw(_cForma)*/ },,,,.T.,,,,,,,,,) 
	_oCmbFormas:Align := CONTROL_ALIGN_LEFT

	oSplitter3 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter3:Align := CONTROL_ALIGN_LEFT

	Aadd( _aOpx, "" )
	Aadd( _aOpx, "Cotizaciones" )
	Aadd( _aOpx, "Insumos Directos" )
	Aadd( _aOpx, "Recomendados" )
	Aadd( _aOpx, "Dosificaciones" )
	Aadd( _aOpx, "Encapsulados" )
	
	_oCmbFormas := TComboBox():New( 002,002, {|u| If(PCount()>0,_cOrigem:=u,_cOrigem)},_aOpx,100,60,oPanel,,{|| n_op:=0,TRX->(dbCloseArea()),oDlg1:End(),u_clProcessa() },,,,.T.,,,,,,,,,) 
	_oCmbFormas:Align := CONTROL_ALIGN_LEFT

	oSplitter4 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter4:Align := CONTROL_ALIGN_LEFT
	
	oGet1 := TGet():New( 002,002,{|u| If(PCount()>0,_cCodDe:=u,_cCodDe)},oPanel,60,018,'@!',{|| n_op:=0,_cCodAte:=_cCodDe },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cCodDe",,)
	oGet1:Align := CONTROL_ALIGN_LEFT

	oSplitter6 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter6:Align := CONTROL_ALIGN_LEFT
	
	oGet2 := TGet():New( 002,002,{|u| If(PCount()>0,_cCodAte:=u,_cCodAte)},oPanel,60,018,'@!',{|| n_op:=0,TRX->(dbCloseArea()),oDlg1:End(),u_clProcessa() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cCodAte",,)
	oGet2:Align := CONTROL_ALIGN_LEFT

	// ---------------------------------------------------------
	
	oTButton1 := TButton():New( 002, 002, "Entregar al Cliente",oPanel,{|| MsgRun( "Aguarde, actualizando stock..." ,, {|| xExpedicion("S") } ) }, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter1 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter1:Align := CONTROL_ALIGN_RIGHT

	oTButton2 := TButton():New( 002, 002, "Salir",oPanel,{|| n_op:=0,oDlg1:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton2:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter2 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter2:Align := CONTROL_ALIGN_RIGHT

	oTButton3 := TButton():New( 002, 002, "Leyenda",oPanel,{|| FU014LEY() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton3:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter3 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter3:Align := CONTROL_ALIGN_RIGHT

	oTButton4 := TButton():New( 002, 002, "Actualizar",oPanel,{|| n_op:=0,_cCodDe:=space(6),_cCodAte:=space(6),/*_cOrigem:="",_cForma:="",*/TRX->(dbCloseArea()),xMontaSql() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton4:Align	:= CONTROL_ALIGN_RIGHT

	oSplitter4 	:= TSplitter():New( 01,01,oPanel,005,01 )
	oSplitter4:Align := CONTROL_ALIGN_RIGHT
	
	oTButton5 := TButton():New( 002, 002, "Transferir a la Sucursal",oPanel,{|| FU016TRS() }, 80,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton5:Align	:= CONTROL_ALIGN_RIGHT

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
	
    local _cFile	  := AllTrim(aResps[1])
    local _aData 	  := xLeArqTxt(_cFile) 
    local nPosLocaliz := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_LOCALIZ" })
    local nPosQtde    := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT" })
    local nPosSerie	  := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_NUMSERI" })
    local nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_ITEM" })
    local nPosData	  := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_DATA" })
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

   	ProcRegua(len(_aData))

	If Right(Alltrim(cPathLog),1)="\"
		cArqTmp := Alltrim(cPathLog)+cNomArq
	Else
		cArqTmp := Alltrim(cPathLog)+"\"+cNomArq
	EndIf

	SBE->(dbSetOrder(1)) 	// BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_

    ntotal := 0

    for nl := 1 to len(_aData)

        ntotal += val(_aData[nl][2])
		cLocalizacion := Padr( alltrim(_aData[nl][1]), tamSx3("DB_LOCALIZ")[1] )

		if SBE->( !( MsSeek( xFilial("SBE")+M->DA_LOCAL+cLocalizacion ) ) )
			cMsgErr += "Local/ubicacion no encontrado: " + M->DA_LOCAL + "/" + cLocalizacion + CRLF
		endif 

    next nl

    if ntotal > M->DA_SALDO
        MsgAlert('¡Cantidad digitada es mayor que la cantidad a distribuir!', 'TOTVS')
        Return
    endif

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

		IncProc( "Importando registro " + alltrim(_aData[nl][1]) )

		alColsAux := {}
		for nX := 1 to nZ
			if ( .not. empty( aCols[nX][nPosLocaliz] ) )
				AADD(alColsAux, aClone(aCols[nX]) )
			endif
		next nX
		
		aCols := {}
		if ( len(alColsAux) > 0 )
			aCols := aClone( alColsAux )
		endif
		
		nZ := len(aCols)
		//if ( nZ == 0 )
		//	cItem := "0000"
		//else
		//	cItem := aCols[nZ,nPosItem]
		//endif
		
		//cItem := Soma1(cItem)
		cItem := Strzero(nl,tamSx3("DB_ITEM")[1])
		AADD(aCols, Array( nUsado + 1 ) )
	
		nZ++
		N := nZ
	    
		for nW := 1 to nUsado
			if (aHeader[nW,2] <> "DB_REC_WT") .And. (aHeader[nW,2] <> "DB_ALI_WT")
				aCols[nZ,nW] := CriaVar(aHeader[nW,2])
			endif
			if aHeader[nW,2] == "DB_REC_WT"
				aCols[nZ,nW] := 0
			endif
		next nW
	
		aCols[nZ,nUsado+1]    := .F.
		aCols[nZ,nPosItem]    := cItem
		aCols[nZ,nPosLocaliz] := _aData[nl][1]
		aCols[nZ,nPosData] 	  := dDatabase
		aCols[nZ,nPosQtde] 	  := val(_aData[nl][2])
		aCols[nZ,nPosSerie]   := _aData[nl][3]

		oGetd:oBrowse:Refresh()
					
    next nl
    
Return




Static Function xMontaSql()

	Local _aArea := getArea()
	Local _xAlias12 := getNextAlias()
	Local _aIts := {}


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

    cQuery := "SELECT F1_FILIAL,F1_HAWB,F1_EMISSAO,F1_SERIE,F1_DOC,D1_COD,D1_LOCAL,D1_QUANT,D1_LOCALIZ,D1_NUMSERI"+CRLF
    cQuery += "  FROM " + RetSqlName("SF1")+" SF1 WITH(NOLOCK)"+CRLF
    cQuery += " INNER JOIN " + RetSqlName("SD1")+" SD1 WITH(NOLOCK)"+CRLF
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
    cQuery += " ORDER BY F1_EMISSAO DESC"+CRLF
		
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), _xAlias12, .F., .T.)
				
	If (_xAlias12)->( !Eof() )
	
		While (_xAlias12)->( !Eof() )

			_aIts := xGetFilial((_xAlias12)->F1_FILIAL,1)
			
	    	TRX->( RecLock("TRX",.t.) )
			TRX->TP_OK      := " "
			TRX->TP_HAWB	:= (_xAlias12)->F1_HAWB
			TRX->TP_EMISSAO	:= STOD((_xAlias12)->F1_EMISSAO)
			TRX->TP_SERIE	:= (_xAlias12)->F1_SERIE
			TRX->TP_DOC     := (_xAlias12)->F1_DOC
			TRX->TP_COD     := (_xAlias12)->D1_COD
			TRX->TP_LOCAL	:= (_xAlias12)->D1_LOCAL
			TRX->TP_QUANT	:= (_xAlias12)->D1_QUANT
			TRX->TP_LOCALIZ	:= (_xAlias12)->D1_LOCALIZ
			TRX->TP_NUMSERI	:= (_xAlias12)->D1_NUMSERI
			TRX->( MsUnLock() )
		
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
