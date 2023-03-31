#include 'Protheus.ch'
#Include "TBIconn.Ch"
#Include "FileIO.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBORRA_MIG บAutor  ณAndres Demarziani   บFecha ณ  02/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcion para eliminar todos los registros de las tablas de บฑฑ
ฑฑบ          ณ movimientos del sistema.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BORRA_MIG

Local cFileLog		:= ""	
Local cDirLog		:= "" 
Local cPath			:= ""
Local lIsJob		:= !(Type('cEmpAnt') == 'C')
Local oImpoTab
Local oCheckBox2
Local oCheckBox3
Local UserActua:=RetCodUsr()
Private	nOpc		:= 0
Private lDel		:= .F.
Private lImpoTab	:= .F.
Private lCheckBox2	:= .F.
Private lCheckBox3	:= .F.
Private oDlg
Private oMainWnd    

// if UserActua<>"000016"
// 	Return
// EndIF
If lIsJob
	RpcSetType(3)
	RpcSetEnv('00','00',,,'CFG')
EndIf

DEFINE MSDIALOG oDlg TITLE "Limpieza de datos" FROM C(249),C(410) TO C(539),C(784) PIXEL

	@ C(002),C(004) TO C(142),C(183) LABEL " Limpieza de datos " PIXEL OF oDlg

	@ C(012),C(012) Say "Este programa tiene el objetivo de borrar los movimientos de" 	Size C(200),C(008) COLOR CLR_BLACK 	PIXEL OF oDlg
	@ C(022),C(012) Say "todo el sistema. Puede usar la opcion 'Importa Tablas'" 		Size C(200),C(008) COLOR CLR_BLACK 	PIXEL OF oDlg
	@ C(032),C(012) Say "si desea levantar desde un archivo, las tablas a eliminar."	Size C(200),C(008) COLOR CLR_BLACK 	PIXEL OF oDlg
	
	@ C(050),C(012) CheckBox oImpoTab 		Var lImpoTab 	Prompt "Importa Tablas" Size C(048),C(008) PIXEL OF oDlg
	@ C(062),C(012) CheckBox oCheckBox2 	Var lCheckBox2 	Prompt "CheckBox2" 		Size C(048),C(008) PIXEL OF oDlg
	@ C(074),C(012) CheckBox oCheckBox3 	Var lCheckBox3 	Prompt "CheckBox3" 		Size C(048),C(008) PIXEL OF oDlg

	DEFINE SBUTTON oBtnOk FROM C(121),C(137) TYPE 1 ACTION ( nOpc := 1, oDlg:End() )	ENABLE OF oDlg PIXEL	

ACTIVATE MSDIALOG oDlg CENTERED 

If nOpc == 1

	AutoGrLog( "Fecha Inicio.......: " + DToC(MsDate()) )
	AutoGrLog( "Hora Inicio........: " + Time() )
	AutoGrLog( "Environment........: " + GetEnvServer() )
	AutoGrLog( " " )

	Processa( {|| fLimpiaDatos() }, 'Limpiando Tablas...'   , 'Aguarde Por Favor... ' )

	AutoGrLog( " " )
	AutoGrLog( "Fecha Fin...........: " + Dtoc(MsDate()) )
	AutoGrLog( "Hora Fin............: " + Time() )
			
	cFileLog := NomeAutoLog()
	
	If cFileLog <> ""
		nX := 1
		While .T.
			If File( Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) ) // El directorio debe estar creado en el servidor bajo DATA
				nX++
				If nX == 999
					Exit
				EndIf
				Loop
			Else
				Exit
			EndIf
		EndDo
		__CopyFile( cPath + Alltrim( cFileLog ), Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) )
		MostraErro(cPath,cFileLog)
		FErase( cFileLog )
	EndIf
EndIf

If lIsJob
	RpcClearEnv()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBORRA_MIG บAutor  ณMicrosiga           บFecha ณ  02/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLimpiaDatos()

Local cFileLog	:= ""	
Local cQuery	:= ""
Local cDirLog	:= "" 
Local cPath		:= ""
Local nRegDEL	:= 0
Local aTablas 	:= {	'SB2','SB7','SB8','SBC','SBF','SBJ','SBK','SC1','SC2','SC5','SC6','SC7','SC8','SC9',;
						'SCR','SD1','SD2','SD3','SD4','SD5','SF1','SF2','SF3','SE1','SE2','SE5','SEK','SFE',;
						'SEL','ADA','ADB','CT2','CT6','CT7','SE8','SEF','SC3','SL1','SL2','SL4','SB9','SCP',;
						'SCQ','SDA','SDD','SW0','SW1','SW2','SW3','SW4','SW5','SW6','SW7','SW8','SW9','SWN',;
						'SWD','SWW','SEU','QEK','QER','QEU','QET','QEL','QPK','QPM','QQG','QPT','QPU','QPL',;
						'SC2','SH6','SBC','SCJ','SCK','SCL','DAI','DAK','SW2','CN9','CNA','CNB','CNC','CNN',;
						'DBM','CQ1','CQ2','CQ3','CQ4','CQ5','CQ7','CQ8','CQ6','CTJ','CV4','CV0','CVY','CVX',;
						'SEA','FK1','FK2','FK3','FK4','FK5','FK6','FK7','FK8','FK9','FKA','STA','TP1','TP2',;
						'TP3','TP4','SI3','ST3','STC','STI','STJ','STK','STL','STN','STO','CBF','CZJ',;
						'STP','STQ','STR','STS','STT','STU','STV','STW','STX','STY','STZ','TAF','TCJ','TP0',;
						'TP6','TP7','TP8','TPD','TPI','TPL','TPN','TPO','TPP','TPQ','TPT','TPU','TPV','TPW',;
						'TPX','TPZ','TQ0','TQ1','TQ2','TQ4','TQ5','TQ6','TQ9','TQA','TQB','TQC','TQD','TQE',;
						'TQF','TQG','TQH','TQI','TQJ','TQK','TQL','TQM','TQN','TQO','TQP','TQQ','TQS','TQT',;
						'TQU','TQV','TQX','TQZ','TR1','TR2','TR3','TR4','TR5','TR6','TR7','TR8','TR9','TRA',;
						'TRC','TRF','TRG','TRH','TRI','TRJ','TRK','TRL','TRM','TRN','TRO','TRP','TRQ','TRR',;
						'TRS','TRT','TRU','TRV','TRW','TRX','TRZ','TS0','TS1','TS2','TS3','TS4','TS5','TS6',;
						'TS7','TS8','TSA','TSB','TSC','TSD','TSE','TSF','TSG','TSH','TSI','TSJ','TSK','TSL',;
						'TSM','TSN','TSO','TSP','TSQ','TSR','TSS','TST','TSV','TSW','TSX','TSY','TSZ','TT0',;
						'TT1','TT2','TT3','TT4','TT5','TT7','TTA','TTC','TTD','TTE','TTF','TTG','TTH','TTI',;
						'TTK','TTL','TTO','TTP','TTQ','TTS','TTT','TTV','TTX','TTY','TU0','TU1','TU4','TUA',;
						'TUB','TZE','TZF','TZG','TZI','CTK','CV3','CT3','CT4','CT6','CT7','DA0','DA1','CB7','CB8',;
						'CTI','CTC','CTV','CTW','CTX','CTY','DB4','ZZZ','SDB','SDC','SBG','SBH','SCT','ZZ5','ZZ6',;
						'QEK','QEL','QEM','QEN','QEP','QEQ','QER','QES','QET','QEU','QEV','QEW','QEY','QPK','QPL','QPM',;
						'QPQ','QPR','QPS','QPT','QPU','QM7','QM8','QMD','QME','QMG','QML','QMZ','SC2','SD4','SH6','SH8','SBC',;
						'SC4','SCP','SCQ','SD7','SD5','SDD','HW2','HW3','HW9','HWA','HWE','HWB','HWC','HWG','HWM','HWD','HWX',;
						'HWY','T4J','TAS','TAN','T4Q','T4M','T4T','T4U','T4V','T4O','SMM','SME','SMH','SMV','SM2','CTH',;
						'SCY','SCS','DBA','DBB','DBC', 'SB3','SHF','SHC',;
						'NNT','NNS'}

//Local aTablas 	:= {'ZC5','ZC6'}
If lImpoTab
	aTablas := aClone(fCargaTablasArchivo())
EndIf

#IFDEF TOP
	For nX := 1 To Len(aTablas)
		cQuery := 'DELETE FROM ' + RetSqlName(aTablas[nX])
		TCSqlExec(cQuery)
		AutoGrLog("Tabla "+aTablas[nX])
		nRegDEL++
	Next
#ELSE
	For nX := 1 To Len(aTablas)
		DbSelectArea( aTablas[nX] )
		__DbZap()
		AutoGrLog("Tabla "+aTablas[nX])
		nRegDEL++
	Next
#ENDIF

CloseOpen(aTablas,aTablas)		

AutoGrLog( "Tablas borradas: "+cValToChar(nRegDEL))

Return

/****************************************************************************/
Static Function C(nRet)
Return nRet
/****************************************************************************/ 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBORRA_MIG บAutor  ณMicrosiga           บFecha ณ  02/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCargaTablasArchivo()

Local cFile 		:= ""
Local cLinea		:= ""
Local cTitulo1  	:= "Seleccione Archivo"
Local cExtens   	:= "Archivo | *.*"
Local aRet 			:= {}

cFile := cGetFile(cExtens,cTitulo1,,,.T.)

If File( cFile )

	FT_FUse( cFile )
	FT_FGotop()

	dbSelectArea("SX2")
	dbSetOrder(1)

	While !FT_FEof()
		cLinea	:= SubStr(FT_FREADLN(),01,03)
		If SX2->(dbSeek(cLinea))
			aAdd(aRet,cLinea)		
		Else
			AutoGrLog("La tabla "+cLinea+" No existe!")
		EndIf
		FT_FSkip()
	EndDo
EndIf

Return aRet
