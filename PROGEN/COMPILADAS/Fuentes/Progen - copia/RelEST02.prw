#INCLUDE "rwmake.ch"
#include "totvs.ch"
#include "protheus.ch"
#include 'topconn.ch'
#INCLUDE "TbiConn.ch"
#include 'parmtype.ch'

#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#INCLUDE "COLORS.CH"
#include "report.ch"


/* **********************************************************

         _.-'~~~~~~'-._            | Funcion:  			RelEST02()
        /      ||      \           |
       /       ||       \          | Descripcion: 	 	Impresión transferencia
      |        ||        |         |
      | _______||_______ |         |
      |/ ----- \/ ----- \|         | Parametros:
     /  (     )  (     )  \        |
    / \  ----- () -----  / \       |
   /   \      /||\      /   \      | Retorno:
  /     \    /||||\    /     \     |
 /       \  /||||||\  /       \    |
/_        \o========o/        _\   | Autor: Victor Limaco                                        
  '--...__|'-._  _.-'|__...--'     |
          |    ''    |             |
************************************************************** */

/*
Tabela de cores
CLR_BLACK         // RGB( 0, 0, 0 )
CLR_BLUE           // RGB( 0, 0, 128 )
CLR_GREEN        // RGB( 0, 128, 0 )
CLR_CYAN          // RGB( 0, 128, 128 )
CLR_RED            // RGB( 128, 0, 0 )
CLR_MAGENTA    // RGB( 128, 0, 128 )
CLR_BROWN       // RGB( 128, 128, 0 )
CLR_HGRAY        // RGB( 192, 192, 192 )
CLR_LIGHTGRAY // RGB( 192, 192, 192 )
CLR_GRAY          // RGB( 128, 128, 128 )
CLR_HBLUE        // RGB( 0, 0, 255 )
CLR_HGREEN      // RGB( 0, 255, 0 )
CLR_HCYAN        // RGB( 0, 255, 255 )
CLR_HRED          // RGB( 255, 0, 0 )
CLR_HMAGENTA  // RGB( 255, 0, 255 )
CLR_YELLOW      // RGB( 255, 255, 0 )
CLR_WHITE        // RGB( 255, 255, 255 )

*/



user function RelEST02(cDoc)
    //msginfo(cvaltochar(cDoc))
    Private cNroTran := cDoc
    //Private cDestino := NNT->NNT_LOCDL
    //msginfo(cvaltochar(cDestino))
    Processa( {|| relpdf() }, "Espere...", "Generando reporte...",.F.)


    //SF2 ESPECIE RTS
    // UNIDADES SEGUNDA UNIDAD DE MEDIDA
    // PESO PRIMERA UNIDAD DE MEDIDA
    //DESCRIPCION := LOTE + DESCRIPCION PRODUCTO
Return

Static Function relpdf()
    //MsgInfo("Informe en PDF","title")
    Local lAdjustToLegacy := .F.
    Local lDisableSetup  := .T.
    Local cLocal          := "c:\tmp\"
    Local cFilePrint := ""

    PRIVATE oPrinter
    PRIVATE oFont1 := TFont():New('Courier new',,-18,.T.)


    IF !ExistDir( "c:\tmp\")
        MakeDir( "c:\tmp\" )
    ENDIF

    oPrinter := FWMSPrinter():New('SolTransferencia.PD_', IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
    //oPrinter := TMSPrinter():New(OemToAnsi('Reporte especial proyectos'))
    //oPrinter:Say(10,10,"Teste")

    pdf()
    cFilePrint := cLocal+"SolTransferencia.PD_"
    File2Printer( cFilePrint, "PDF" )
    oPrinter:cPathPDF:= cLocal
    oPrinter:Preview()

Return

Static function pdf()
    //Local aDatos := {}
    //Local aDet := {}
    //Local aDatZZF := {}
    Local iy := 0
    Local nRegs := 0
    //Local nLinha := 0
    //Local cFech := ''
    //Local cUsr := ''
    //Local nTotc := 0 , nTotp := 0



    // ( <nRed> + ( <nGreen> * 256 ) + ( <nBlue> * 65536 ) )
    PRIVATE oBrushA := TBrush():New( , 11206656 ) //RGB (azul: RGB 0/51/171)
    PRIVATE oBrushN := TBrush():New( , 39423 ) //RGB (naranja: 255/153/0)
    PRIVATE oBrushV := TBrush():New( , 9437096 )
    PRIVATE oBrushR := TBrush():New( , 9027071 )
    PRIVATE oBrushG := TBrush():New( , 12107714 ) //RGB (gris: 194/191/184)

    PRIVATE oBrushNE := TBrush():New( , 52479 ) //RGB (naranja: 255/204/0)
    PRIVATE oBrushVE := TBrush():New( , 4697456 ) //RGB (VERDE: 112/173/71)
    PRIVATE oBrushRE := TBrush():New( , 5263615 ) //RGB (ROJO: 255/80/80)
    PRIVATE oBrushND := TBrush():New( , 13434879 ) //RGB (naranja: 255/255/204)
    PRIVATE oBrushVD := TBrush():New( , 13434828 ) //RGB (VERDE: 204/255/204)
    PRIVATE oBrushRD := TBrush():New( , 13421823 ) //RGB (ROJO: 255/204/204)



    Private oFont06 := TFont():New("Courier New",,-6,.T.)
    Private oFont07 := TFont():New("Courier New",,-7,.T.)
    Private oFont08 := TFont():New("Courier New",,-8,.T.)
    Private oFont10 := TFont():New("Courier New",,-10,.T.)
    Private oFont12 := TFont():New("Courier New",,-12,.T.)
    Private oFont14 := TFont():New("Courier New",,-14,.T.)

    Private oFont08b := TFont():New("Courier New",,-8,.T.,.T.)
    Private oFont10b := TFont():New("Courier New",,-10,.T.,.T.)
    Private oFont12b := TFont():New("Courier New",,-12,.T.,.T.)
    Private oFont14b := TFont():New("Courier New",,-14,.T.,.T.)

    Private cFileLogo	:= GetSrvProfString('Startpath','') + 'LGMID' + '.png'
    Private cFileLog2	:= GetSrvProfString('Startpath','') + 'LGMID' + '.png'

    oPrinter:SetLandscape()
    // oPrinter:SetPortrait()

    //PRIMERA PAGINA
    Private aDat := consdat()
    Private aDet := consdet()
    Private nPagatu := 0
    Private nPag := 1
    for iy := 1 to len(aDet)
        nRegs += 1
        if nRegs > 17
            nPag += 1
            nRegs := 0
        endif
    next

    Encab()
    detalle(1,len(aDet))
    // Pie()


Return

Static function Encab()
    oPrinter:StartPage()
    nPagatu += 1


    oPrinter:Box( 0035, 0030, 0110, 0150, "-4") //Espacio logo izquierda
    oPrinter:SayBitmap(40,31,cFileLogo,117,067) //LOGO IZQUIERDA

    oPrinter:Box( 0040, 0150, 0070, 0300, "-4")
    oPrinter:Box( 0070, 0150, 0100, 0300, "-4")

    oPrinter:Box( 0040, 0300, 0055, 0450, "-4")
    oPrinter:Box( 0055, 0300, 0070, 0450, "-4")
    oPrinter:Box( 0070, 0300, 0085, 0450, "-4")
    oPrinter:Box( 0085, 0300, 0100, 0450, "-4")

    oPrinter:Box( 0035, 0450, 0110, 0570, "-4") //Espacio logo derecha
    oPrinter:SayBitmap(40,0451,cFileLog2,117,067) //LOGO DERECHA

    oPrinter:Say(0050,0160,UPPER("PROCESO DE DESPACHOS"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0080,0160,UPPER("TRASLADO ENTRE BODEGAS"),oFont08,1400,CLR_BLACK)

    oPrinter:Say(0050,0310,UPPER("Empresa: PROGEN S.A."),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0065,0310,UPPER("Cra. 3 # 56-07"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0080,0310,UPPER("Soacha, Cundinamarca"),oFont08,1400,CLR_BLACK)
    oPrinter:Say(0095,0310,UPPER("Página: " + cvaltochar(nPagatu) + " de " + cvaltochar(nPag)),oFont08,1400,CLR_BLACK)

    oPrinter:Box(0120,0030, 0180, 0180, "-4")
    oPrinter:Box(0120,0180, 0180, 0400, "-4")
    oPrinter:Box(0120,0400, 0180, 0480, "-4")
    oPrinter:Box(0120,0480, 0180, 0570, "-4")
    oPrinter:Fillrect({0121,0481,0179,0569},oBrushG)

    //   oPrinter:Box(0150,0030, 0180, 0120, "-4")
    //   oPrinter:Box(0150,0120, 0180, 0290, "-4")
    //   oPrinter:Box(0150,0290, 0180, 0390, "-4")
    //   oPrinter:Box(0150,0390, 0180, 0480, "-4")
    //   oPrinter:Box(0150,0480, 0180, 0570, "-4")
    //   oPrinter:Fillrect({0151,0031,0179,0119},oBrushG)
    //   oPrinter:Fillrect({0151,0121,0179,0289},oBrushG)
    //   oPrinter:Fillrect({0151,0291,0179,0389},oBrushG)
    //   oPrinter:Fillrect({0151,0391,0179,0479},oBrushG)
    //   oPrinter:Fillrect({0151,0481,0179,0569},oBrushG)

    oPrinter:Say(0130,0040,UPPER("Origen"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0190,UPPER("Destino"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0410,UPPER("Fecha"),oFont14b,1400,CLR_BLACK)
    //oPrinter:Say(0130,0340,UPPER("Fecha"),oFont14b,1400,CLR_BLACK)
    oPrinter:Say(0130,0490,UPPER("No.Solicitud"),oFont14b,1400,CLR_BLACK)
    // oPrinter:Say(0160,0040,"Tipo Vehículo",oFont12,1400,CLR_BLACK)
    // oPrinter:Say(0160,0130,"Conductor",oFont12,1400,CLR_BLACK)
    // oPrinter:Say(0160,0300,"Placa vehículo",oFont12,1400,CLR_BLACK)
    // oPrinter:Say(0160,0400,"T° vehic.",oFont12,1400,CLR_BLACK)
    // oPrinter:Say(0160,0485,"Sello seguridad",oFont12,1400,CLR_BLACK)
    //1 ORIGEN, 2 DESTINO, 3 FECHA, 4 SOLICITANTE, 5 TIPO VEHICULO, 6 CONDUCTOR, 7 PLACA, 8 TEMP, 9 SELLO
    oPrinter:Say(0140,0040,cvaltochar("CRA. 3 # 56-07"),oFont12,1400,CLR_BLACK)
    oPrinter:Say(0150,0040,UPPER("Soacha, Cundinamarca"),oFont10,1400,CLR_BLACK)
    if len(alltrim(aDat[1][2]))>=35
        oPrinter:Say(0140,0190,cvaltochar(substr(aDat[1][2],1,35)),oFont12,1400,CLR_BLACK)
        oPrinter:Say(0150,0190,cvaltochar(substr(aDat[1][2],36,70)),oFont12,1400,CLR_BLACK)
        oPrinter:Say(0160,0190,cvaltochar(substr(aDat[1][2],71,100)),oFont12,1400,CLR_BLACK)
        //oPrinter:Say(0160,0190,cvaltochar(substr(aDat[1][2],24,30)),oFont12,1400,CLR_BLACK)
    else
        oPrinter:Say(0140,0190,cvaltochar(aDat[1][2]),oFont12,1400,CLR_BLACK)
    ENDIF
    oPrinter:Say(0140,0410,cvaltochar(stod(aDat[1][3])),oFont12,1400,CLR_BLACK)
    oPrinter:Say(0140,0490,cvaltochar(cNroTran),oFont12b,1400,CLR_RED)
    //oPrinter:Say(0170,0040,cvaltochar(aDat[1][5]),oFont12,1400,CLR_BLACK)
    //oPrinter:Say(0170,0130,cvaltochar(aDat[1][6]),oFont12,1400,CLR_BLACK)
    //oPrinter:Say(0170,0300,cvaltochar(aDat[1][7]),oFont12,1400,CLR_BLACK)
    //oPrinter:Say(0170,0400,cvaltochar(aDat[1][8]),oFont12,1400,CLR_BLACK)
    //oPrinter:Say(0170,0485,cvaltochar(aDat[1][9]),oFont12,1400,CLR_BLACK)
Return

Static function Pie()
    /*   oPrinter:Box( 0320, 0030, 0335, 0570, "-4")
    oPrinter:Box( 0335, 0030, 0350, 0570, "-4")
    oPrinter:Box( 0350, 0030, 0365, 0570, "-4") */
    oPrinter:Say(0750,0040,UPPER("Observaciones"),oFont14b,1400,CLR_BLACK)
    // oPrinter:Say(0330,0040,UPPER("Observaciones"),oFont14b,1400,CLR_BLACK)
    if len(alltrim(aDat[1][10]))>115
        oPrinter:Say(0765,0040,cvaltochar(substr(aDat[1][10],1,115)),oFont08,1400,CLR_BLACK)
        oPrinter:Say(0775,0040,cvaltochar(substr(aDat[1][10],116,200)),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(0765,0040,cvaltochar(aDat[1][10]),oFont08,1400,CLR_BLACK)
    endif
    /* if len(alltrim(aDat[1][10]))>115
        oPrinter:Say(0345,0040,cvaltochar(substr(aDat[1][10],1,115)),oFont08,1400,CLR_BLACK)
        oPrinter:Say(0355,0040,cvaltochar(substr(aDat[1][10],116,200)),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(0345,0040,cvaltochar(aDat[1][10]),oFont08,1400,CLR_BLACK)
    endif*/


    //oPrinter:Box( 0365, 0030, 0395, 0300, "-4")
    //oPrinter:Box( 0365, 0300, 0395, 0570, "-4")
    oPrinter:Say(0795,0040,"Enviado Por",oFont12,1400,CLR_BLACK)
    oPrinter:Say(0795,0310,"Recibido Por",oFont12,1400,CLR_BLACK)
    oPrinter:Say(0805,0040,cvaltochar(aDat[1][4]),oFont08,1400,CLR_BLACK)
    /*oPrinter:Say(0375,0040,"Enviado Por",oFont12,1400,CLR_BLACK)
    oPrinter:Say(0375,0310,"Recibido Por",oFont12,1400,CLR_BLACK)
    oPrinter:Say(0385,0040,cvaltochar(aDat[1][4]),oFont08,1400,CLR_BLACK) JP*/

    //    oPrinter:Box( 0400, 0030, 0415, 0210, "-4")
    //    oPrinter:Box( 0400, 0210, 0415, 0390, "-4")
    //    oPrinter:Box( 0400, 0390, 0415, 0570, "-4")
    //    oPrinter:Fillrect({0401,0031,0414,0209},oBrushG)
    //    oPrinter:Fillrect({0401,0211,0414,0389},oBrushG)
    //    oPrinter:Fillrect({0401,0391,0414,0569},oBrushG)
    //    oPrinter:Say(0410,0080,"ELABORÓ",oFont12b,1400,CLR_BLACK)
    //    oPrinter:Say(0410,0260,"REVISÓ",oFont12b,1400,CLR_BLACK)
    //    oPrinter:Say(0410,0450,"APROBÓ",oFont12b,1400,CLR_BLACK)

    //    oPrinter:Box( 0415, 0030, 0430, 0210, "-4")
    //    oPrinter:Box( 0415, 0210, 0430, 0390, "-4")
    //    oPrinter:Box( 0415, 0390, 0430, 0570, "-4")
    //    oPrinter:Say(0425,0070,"Lider de procesos",oFont12b,1400,CLR_BLACK)
    //    oPrinter:Say(0425,0250,"Lider de Despachos",oFont12b,1400,CLR_BLACK)
    //    oPrinter:Say(0425,0440,"Gerencia General",oFont12b,1400,CLR_BLACK)


    nLinha := 370

    oPrinter:EndPage()
Return

Static function relleno(id,nLinha)
    local ix :=id
    local code :=alltrim(aDet[ix][6])
    local desc :=alltrim(aDet[ix][1])
    local unio := code+' - '+desc

    oPrinter:Say(nLinha+15,0040,cvaltochar(ix),oFont08b,1400,CLR_BLACK)


    if len(alltrim(unio))>34
        if len(alltrim(unio))>65
            oPrinter:Say(nLinha+14,0060,substr(unio,1,34),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+23,0060,substr(unio,35,64),oFont07,1400,CLR_BLACK)
            oPrinter:Say(nLinha+33,0060,substr(unio,65,94),oFont07,1400,CLR_BLACK)
        else
            oPrinter:Say(nLinha+15,0060,substr(unio,1,34),oFont08,1400,CLR_BLACK)
            oPrinter:Say(nLinha+25,0060,substr(unio,35,64),oFont08,1400,CLR_BLACK)

        ENDIF
    else
        oPrinter:Say(nLinha+15,0060,aDet[ix][1],oFont08,1400,CLR_BLACK)
    ENDIF

    // oPrinter:Say(nLinha+15,0211,aDet[ix][2],oFont08,1400,CLR_BLACK)
    if len(alltrim(aDet[ix][2]))>4
        oPrinter:Say(nLinha+15,0211,aDet[ix][2],oFont08,1400,CLR_BLACK)

    else
        oPrinter:Say(nLinha+15,0218,aDet[ix][2],oFont08,1400,CLR_BLACK)
    ENDIF


    if len(alltrim(aDet[ix][10]))>13
        oPrinter:Say(nLinha+15,0242,substr(aDet[ix][10],1,13),oFont07,1400,CLR_BLACK)
        oPrinter:Say(nLinha+25,0242,alltrim(substr(aDet[ix][10],14,27)),oFont07,1400,CLR_BLACK)

    else
        oPrinter:Say(nLinha+15,0242,aDet[ix][10],oFont08,1400,CLR_BLACK)
    ENDIF



    if len(alltrim(aDet[ix][3]))>18
        oPrinter:Say(nLinha+15,0272,substr(aDet[ix][3],1,18),oFont08,1400,CLR_BLACK)
        oPrinter:Say(nLinha+25,0272,substr(aDet[ix][3],19,36),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(nLinha+15,0272,aDet[ix][3],oFont08,1400,CLR_BLACK)
    ENDIF



    oPrinter:Say(nLinha+15,0385,aDet[ix][4],oFont08,1400,CLR_BLACK)


    if len(alltrim(aDet[ix][5]))<=25
        oPrinter:Say(nLinha+15,0455,cvaltochar(aDet[ix][5]),oFont08,1400,CLR_BLACK)
    else
        oPrinter:Say(nLinha+15,0455,cvaltochar(substr(aDet[ix][5],1,25)),oFont08,1400,CLR_BLACK)
        oPrinter:Say(nLinha+25,0455,cvaltochar(substr(aDet[ix][5],26,70)),oFont08,1400,CLR_BLACK)
    endif
return

Static function filas(cab,nLinha)

    local ca :=cab
    oPrinter:Box( nLinha, 0030, nLinha+30, 0058, "-4")
    oPrinter:Box( nLinha, 0058, nLinha+30, 0210, "-4")
    oPrinter:Box( nLinha, 0210, nLinha+30, 0240, "-4")
    oPrinter:Box( nLinha, 0240, nLinha+30, 0300, "-4")
    oPrinter:Box( nLinha, 0300, nLinha+30, 0380, "-4")
    oPrinter:Box( nLinha, 0380, nLinha+30, 0450, "-4")
    oPrinter:Box( nLinha, 0450, nLinha+30, 0570, "-4")



    if  ca==1
        oPrinter:Say(0200+10,0035,"No",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0080,"Descripción Producto",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0215,"Cant",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0245,"Alm Dest",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0310,"Serie",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0390,"Lote",oFont12b,500,CLR_BLACK)
        oPrinter:Say(0200+10,0460,"Observaciòn",oFont12b,500,CLR_BLACK)
    endif

Return nLinha

Static function detalle(Ini,Long)
    Local nLinha := 0200
    Local ix := 0
    Local ca := 1
    Local LongT:=0
    local res:=0
    Local fil:=17
    LongT=Long
    if( Long==1 .or. Long<=fil)
        LongT+=1
    endif
    for ix := Ini to LongT

        if ix <=18

            filas(ca,nLinha)
            ca:=0
            nLinha +=30
        ENDIF
    next ix

    nLinha := 0225
    for ix := Ini to Long
        //1 PRODUCTO, 2 CANTIDAD, 3 OP (VACIO), 4 PESO, 5 TEMP, 6 VENCIMIENTO

        if ix <=fil
            relleno(ix,nLinha)
            nLinha += 30
        ENDIF

    next ix


    if Long>fil
        res=pagadi(18,Long,Long)
        fil+=18
    endif

    while fil<=Long

        res=pagadi(fil,Long,res)
        fil+=17

    ENDDO

    if nLinha>=0745
        Encab()
    endif
    Pie()
    nLinha := 0415
Return

Static function pagadi(id,Long,falt)

    local nLinha :=0200
    local ca:=1
    local ix:=0
    local de:=id
    local en:=id-1
    local con:=1
    local res:=0
    local fal:=falt



    // Pie()
    Encab()

    for ix := en to Long
        if con<=18
            filas(ca,nLinha)
            ca:=0
            nLinha +=30
            con+=1

        endif
    next ix

    con:= 0
    nLinha := 0225

    for ix := de to Long
        if con<=16
            relleno(ix,nLinha)
            nLinha +=30
            con+=1
            res+=1

        endif

    next ix
    con:=0
return fal-res

Static function consdat()  //CONSULTA DATOS ENCABEZADO TRANSFERENCIA: EMISION Y USUARIO
    Local aRet := {}
    Local cSql := ""
    Local cAlias := GetNextAlias()

    X31UpdTable("NNS")

    cSql := " SELECT *  "
    cSql += " FROM " + RetSqlName("NNS") + " NNS "
    cSql += " WHERE NNS.D_E_L_E_T_=''  "
    cSql += " AND NNS_COD = '" + cvaltochar(cNroTran) + "' "

    TCQUERY cSql NEW ALIAS &cAlias
    DbSelectArea((cAlias))
    (cAlias)->(DbGoTop())
    While 	(cAlias)->( ! Eof() )
        //ORIGEN, DESTINO, FECHA, SOLICITANTE, TIPO VEHICULO, CONDUCTOR, PLACA, TEMP, SELLO, OBS
        aadd(aRet,{(cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_DATA, ;
            UsrFullName((cAlias)->NNS_SOLICT), ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XDESTI, ;
            (cAlias)->NNS_XOBS})

        (cAlias)->(DbSkip())
    End

    DbSelectArea((cAlias))
    (cAlias)->(DbCloseArea())
Return aRet

Static function consdet()  //CONSULTA DATOS DEL DETALLE DE LA TRANSFERENCIA
    Local aRet := {}
    Local cSql := ""
    Local cAlias := GetNextAlias()

    X31UpdTable("NNT")

    cSql := " SELECT  NNT.*,NNRD.NNR_DESCRI DESTINO, NNRL.NNR_DESCRI LOCAL "
    cSql += " FROM " + RetSqlName("NNT") + " NNT "
    cSql += " INNER JOIN " + RetSqlName("NNR") + " NNRL "
    cSql += " ON NNRL.NNR_FILIAL = NNT.NNT_FILIAL "
    cSql += " AND NNT.NNT_LOCAL = NNRL.NNR_CODIGO "
    cSql += " AND NNRL.D_E_L_E_T_ <>'*' "
    cSql += " INNER JOIN " + RetSqlName("NNR") + " NNRD "
    cSql += " ON NNRD.NNR_FILIAL = NNT.NNT_FILIAL "
    cSql += " AND NNT.NNT_LOCLD = NNRD.NNR_CODIGO "
    cSql += " AND NNRD.D_E_L_E_T_ <>'*' "
    cSql += " WHERE NNT.D_E_L_E_T_='' "
    cSql += " AND NNT_COD = '" + cvaltochar(cNroTran) + "' "





    TCQUERY cSql NEW ALIAS &cAlias
    DbSelectArea((cAlias))
    (cAlias)->(DbGoTop())
    While 	(cAlias)->( ! Eof() )
        //1 PRODUCTO, 2 CANTIDAD, 3 SERIE, 4 LOTE, ( 5 OBSERVACION, 6 VENCIMIENTO - Se retiro)
        aadd(aRet,{alltrim(Posicione("SB1",1,xFilial("SB1")+(cAlias)->NNT_PROD,"B1_DESC")) , ;
            cvaltochar((cAlias)->NNT_QUANT), ;
            (cAlias)->NNT_NSERIE, ;
            (cAlias)->NNT_LOTECT, ;
            (cAlias)->NNT_OBS, ;
            (cAlias)->NNT_PROD, ;
            cvaltochar((cAlias)->NNT_QUANT), ;
            cvaltochar((cAlias)->NNT_DTVALI),;
            cvaltochar((cAlias)->NNT_LOCLD),;
            cvaltochar((cAlias)->DESTINO)})


        (cAlias)->(DbSkip())
    End

    DbSelectArea((cAlias))
    (cAlias)->(DbCloseArea())
Return aRet
