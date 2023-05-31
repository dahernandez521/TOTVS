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

	Local _aArea	:= getArea()
	Local aPergs    := {}
    local nMv       := 1

	Private aResps  := {}
	Private aMvPar  := {}

    For nMv := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
    Next nMv

    aAdd(aPergs,{6,"Archivo: ",Space(150),"",'.T.','.T.',80,.F.,"archivos (*.csv) |*.csv"})

	If ParamBox(aPergs,"Parâmetros", @aResps)
    	Processa({|| STHWMS31()})
	EndIf

    For nMv := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
    Next nMv

	Restarea(_aArea)

Return

Static Function STHWMS31

    local _cFile	:= AllTrim(aResps[1])
    local _aData	:= xLeArqTxt(_cFile) 

	If Len(_aData) > 0
        Processa({|| ExecIems( _aData )})
	Else
		Help(" ",1,"NO-DATA")
	Endif

Return


Static Function ExecIems(aArray)
 	
    local nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SEQ" })
    local nPosTipo	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_TIPO" })
    local nPosQtde    := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_QTDE" })
    //local nPosSaldo   := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SALDO" })
    local nPosLocaDes := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_LOCDEST" })
    local nPosUbica	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_LOCALIZ" })
    local nPosSerie	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_NUMSERI" })
    local nPosMotivo  := aScan(aHeader,{|x| AllTrim(x[2]) == "D7_MOTREJE" })
	local nZ          := len(aCols)
	local nUsado      := len(aHeader)
	local alColsAux	  := {}
	local nX		  := 0
	local nW		  := 0
	local nn		  := 0
	local cMsgErr	  := ""
    local cNomArq	  := "log_"+dtos(date())+"_"+replace(time(),":","")+".log"
    local cArqLog	  := "\"+cNomArq
    local cArqTmp	  := ""

   	SBE->(dbSetOrder(1))
   	SB1->(dbSetOrder(1))
        
    for nn := 1 to len(aArray)

        cLocalizacion := Padr( alltrim(aArray[nn][3]), tamSx3("DB_LOCALIZ")[1] )
    	clocal := Padr( alltrim(aArray[nn][2]), tamSx3("B1_LOCPAD")[1] )
    	cnroserie := Padr( alltrim(aArray[nn][5]), tamSx3("D7_NUMSERI")[1] )
    	cmotivo := Padr( alltrim(aArray[nn][6]), tamSx3("D7_MOTREJE")[1] )

        if SBE->( !( MsSeek( xFilial("SBE")+clocal+cLocalizacion ) ) )
            cMsgErr += "Local/ubicacion no encontrado: " + clocal + "/" + cLocalizacion + CRLF
        endif 

    	alColsAux := {}
        for nX := 1 to nZ
            AADD(alColsAux, aClone(aCols[nX]) )
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
        aCols[nZ,nPosItem]    := cItem
        aCols[nZ,nPosTipo]    := val(aArray[nn][1])

        U_EnterCpo("D7_TIPO",aCols[nZ][nPosTipo], nZ)

        aCols[nZ,nPosQtde] 	  := val(aArray[nn][4])

        U_EnterCpo("D7_QTDE",aCols[nZ][nPosQtde], nZ)

        aCols[nZ,nPosLocaDes] := clocal
        aCols[nZ,nPosUbica]   := cLocalizacion
        aCols[nZ,nPosSerie]   := cnroserie
        aCols[nZ,nPosMotivo]  := cmotivo

        oGet:oBrowse:Refresh()

    next


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



Static Function xLeArqTxt( cNomArchivo )

	Local cLinha := ""
	Local nX := 1
	Local _aItens := {}
	Local _aDetalle := {}

	FT_FUSE( cNomArchivo )
	   
	While !FT_FEOF()
	
		if nX>=2
		
			cLinha := Alltrim( FT_FREADLN() )
            
            _aItens := Separa(cLinha,';',.T.)
			
			Aadd( _aDetalle, _aItens )
			
		endif
		
		FT_FSKIP()
		nX++
	 
	EndDo
	
	FT_FUSE() 

Return( _aDetalle )
