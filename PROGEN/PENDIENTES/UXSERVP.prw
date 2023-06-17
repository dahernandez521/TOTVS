#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "Topconn.ch"

User Function UXSERVP()

    Local oButton1
    Local oButton13
    Local oButton5
    Local oButton9
    Local oGroup1
    Local oGroup2
    Local oGroup3
    Local oSay1
    Local oSay13
    Local oSay5
    Local oSay9
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "PROGEN PARADA DE SERVICIOS PROTEHUS PRODUCCION." FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 007, 005 GROUP oGroup1 TO 240, 239 PROMPT "Utilitario para Reinicio de procesos de Windows.   " OF oDlg COLOR 0, 16777215 PIXEL
    @ 021, 015 GROUP oGroup2 TO 095, 227 PROMPT "Detener Servicios de Windows ...." OF oDlg COLOR 0, 16777215 PIXEL
    @ 105, 015 GROUP oGroup3 TO 192, 227 PROMPT "Iniciar Servicios de Windows..." OF oDlg COLOR 0, 16777215 PIXEL

    //Pantalla de la parada de los servicios

    @ 032, 019 SAY oSay1 PROMPT "Servicio Coletor" SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 087 BUTTON oButton1 PROMPT "Stop Coletor" SIZE 032, 009   ACTION  Processa( {|| USPCOLET() }, "Espere...", "Procesando...",.F.) OF oDlg PIXEL
    @ 032, 135 SAY oSay5 PROMPT "Servicio de ACD" SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 177 BUTTON oButton5 PROMPT "Stop ACD" SIZE 032, 009 ACTION  Processa( {|| USPACD() }, "Espere...", "Procesando...",.F.) OF oDlg PIXEL
    @ 042, 019 SAY oSay2 PROMPT "Servicio de REST" SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 087 BUTTON oButton2 PROMPT "Stop REST" SIZE 032, 009 ACTION Processa( {|| USPREST() }, "Espere...", "Procesando...",.F.) OF oDlg PIXEL
  
   
    //Pantalla de la inicio  de los servicios

    @ 122, 019 SAY oSay9 PROMPT "Servicio Coletor" SIZE 055, 011 OF oDlg COLORS 0, 16777215 PIXEL
    @ 120, 087 BUTTON oButton9 PROMPT "Start Coletor" SIZE 032, 009 ACTION Processa( {|| USICOLET() }, "Espere...", "Procesando...",.F.)  OF oDlg PIXEL
    @ 122, 138 SAY oSay13 PROMPT "Servicio de ACD" SIZE 041, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 120, 177 BUTTON oButton13 PROMPT "Start ACD" SIZE 035, 009 ACTION Processa( {|| USIACD() }, "Espere...", "Procesando...",.F.)  OF oDlg PIXEL
    @ 132, 019 SAY oSay9 PROMPT "Servicio REST" SIZE 055, 011 OF oDlg COLORS 0, 16777215 PIXEL
    @ 130, 087 BUTTON oButton9 PROMPT "Start REST" SIZE 032, 009 ACTION Processa( {|| USIREST() }, "Espere...", "Procesando...",.F.)  OF oDlg PIXEL
   

    ACTIVATE MSDIALOG oDlg CENTERED

Return

//ACD
Static Function USPACD()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "stop_ACD.bat"
    If !WaitRunSrv(cPasta+cCommand,lWait,"C:\")
        Alert("Error al intentar detener el servicio de ACD  de CAL" + Time())
    Else
        Alert("Servicio de ACD detenido en el servidor de CAL" + Time())
    EndIf
RETURN

Static Function USIACD()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "start_ACD.bat"
    If !WaitRunSrv( cPasta + cCommand, lWait , "C:\" )
        Alert("Error al intentar iniciar el servicio de ACD de CAL" + Time())
    Else
        MsgInfo("Servicio de ACD  inciado en el servidor de CAL" + Time())
    EndIf
RETURN


//COLETOR
Static Function USPCOLET()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "stop_Coletor.bat"
    If !WaitRunSrv(cPasta+cCommand,lWait,"C:\")
        Alert("Error al intentar detener el servicio de Coletor de CAL" + Time())
    Else
        Alert("Servicio de Coletor detenido en el servidor de CAL" + Time())
    EndIf
RETURN

Static Function USICOLET()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "start_Coletor.bat"
    If !WaitRunSrv( cPasta + cCommand, lWait , "C:\" )
        Alert("Error al intentar iniciar el servicio de Coletor de CAL" + Time())
    Else
        MsgInfo("Servicio de Coletor inciado en el servidor de CAL" + Time())
    EndIf
RETURN

//rest
Static Function USPREST()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "STOP_rest.bat"
    If !WaitRunSrv(cPasta+cCommand,lWait,"C:\")
        Alert("Error al intentar detener el servicio de REST de CAL" + Time())
    Else
        Alert("Servicio de REST detenido en el servidor de CAL" + Time())
    EndIf
RETURN

Static Function USIREST()
    lWait       := .T.
    cPasta      := "C:\TOTVS\Scripts\"
    cCommand    := "START_rest.bat"
    If !WaitRunSrv( cPasta + cCommand, lWait , "C:\" )
        Alert("Error al intentar iniciar el servicio de REST de CAL" + Time())
    Else
        MsgInfo("Servicio de REST inciado en el servidor de CAL" + Time())
    EndIf
RETURN
