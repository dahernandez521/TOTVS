#Include "Rwmake.ch"
#Include "Protheus.ch"
#include "fileio.ch"
#define CRLF chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS01  ºAutor  ³Percy Arias,SISTHEL º Data ³  20/01/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa itens del archivo Excel                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STHWMS07()

	Local _aArea	:= getArea()
	Local aPergs    := {}
	Private aResps  := {}
 
    aAdd(aPergs,{6,"Archivo: ",Space(150),"",'.T.','.T.',80,.F.,"archivos (*.csv) |*.csv"})

	If ParamBox(aPergs,"Parâmetros", @aResps)
    	Processa({|| ProcMovs()})
	EndIf            
		
	Restarea(_aArea)

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
		//cItem := Strzero(nl,tamSx3("DB_ITEM")[1])
		AADD(aCols, Array( nUsado + 1 ) )
	
		nZ++
		N := nZ

		cItem := Strzero(n,tamSx3("DB_ITEM")[1])
	    
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

Static Function xLeArqTxt( cNomArchivo )

	Local cLinha := ""
	Local nX := 1
	Local _aItens := {}
	Local _aDetalle := {}

	FT_FUSE( cNomArchivo )
	   
	While !FT_FEOF()
	
		if nX>=2
		
			cLinha := Alltrim( FT_FREADLN() )
			
			if len(cLinha) > 5
				
				cLinha := replace( cLinha,",",";")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")
				cLinha := replace( cLinha,";;","; ;")

				_aItens := StrTokArr( cLinha, ";" )
				
                Aadd( _aDetalle, _aItens )
				
			endif
			
		endif
		
		FT_FSKIP()
		nX++
	 
	EndDo
	
	FT_FUSE() 

Return( _aDetalle )
