#include 'protheus.ch'
#DEFINE ENTER CHR(13)+CHR(10)
/*/{Protheus.doc} M486OWSCOL
Punto de entrada para enviar campos extra para layout Fact Eletronica Colombia
@type function
@version 
@author M&H 
@Uso : progen
@since 01/03/2023  // DOC SOPORTE  NIT+DV
@return return_type, return_description       // MV_CFDIAMB, MV_WSRTSS , MV_TKN_EMP, MV_TKN_PAS
/*/ 
User Function M486OWSCOL
	Local aArea     	:= GetArea()
	Local cSerieDoc 	:= PARAMIXB[1] //Serie
	Local cNumDoc   	:= PARAMIXB[2] //Número de Documento
	Local cCodCli   	:= PARAMIXB[3] //Código de Cliente
	Local cCodLoj   	:= PARAMIXB[4] //Código de la Tienda
	Local oXML      	:= PARAMIXB[5] //Objeto del XML
	Local nOpc      	:= PARAMIXB[6] //1=Nivel documento 2=Nivel detalle
	Local oWS       	:= PARAMIXB[7] //Objeto de web services
	Local cCodProd  	:= ""
	Local cSDITem   	:= ""
	Local aCabDatos		:= {}
	Local cWebCl 		:= " "
	Local cNumTel 		:= " "
	Local cpaisCli  	:= " "//
	Local cCodDpto  	:= " "//
	Local aAreaSA1		:= SA1->(GetArea())
	Local cTempalte		:= " "//Template de factura venta, ncc o exportación
	LOcal cTipDocT		:= " "//Tipo de documento transmitido: 01 NF, 91 ncc y 02 Nf Exp
	Local cExtra11I 	:= " "
	Local cExtra11V		:= " " 
	Local cExtra11IEn	:=" "
	Local cExtra112En	:=" "
	Local cExtra11VEn	:=" " 
	Local cExtra13I 	:= " "
	Local cExtra13V		:= " " 
	Local cExtra13IEn	:= " "
	Local cExtra13VEn	:= " "
	Local cObsFa		:= " "
	Local CPerDesc1 	:= " % "
	Local CPerDesc2		:= " % "	
	Local nXA			:= 0
	Local aEmail		:= {}
	Local cAmbiente  	:= SuperGetMV("MV_CFDIAMB" ,.F. , "2" )
	Local cProgenNF2   	:= SuperGetMV("MV_XPROGEN" ,.F. , "2" )
	Local cTesObGta 	:= GetMV("MV_XTSOBGT",,"")
	Local cTesObsCli 	:= GetMV("MV_XTOBCL",,"")
	Local cFechaEmision	:= ""
	Local cVencimiento	:= ""
	Local nValunitSD1	:= 0
	
	If nOpc == 1 //Encabezado
		oWs:ccantidadDecimales = '3'  // Para trasmision a 3 digitos el campo cantidad
		cTipDocT	:= OWS:CTIPODOCUMENTO
		
		IF nTDTras == 6  // PARA DOC SOPORTE / REEMPLAZAR LOS VALORES DE NIT QUE TRAE DESDE LA RUTINA STANDARD DOC SOPORTE
				SA2->(dbSetOrder(1))  //A2_FILIAL+A2_COD+A2_LOJA
				SA2->(dbSeek(xFilial("SA2")+cCodCli+cCodLoj))
				oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacion 	:= ALLTRIM(SA2->A2_CGC)//+ALLTRIM(SA2->A2_XDV)
				oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacionDV 	:= ALLTRIM(SA2->A2_XDV)
				oWSCli:cnumeroDocumento							 			:= ALLTRIM(SA2->A2_CGC)//+ALLTRIM(SA2->A2_XDV)
				oWSCli:cnumeroIdentificacionDV								:= ALLTRIM(SA2->A2_XDV)
		
		ELSE 

			cExtra11I  	:= "RESPONSABLE DE I.V.A"
			cExtra11II 	:= "Consulte nuestra Politica de Proteccion de Datos en www.progen.com.co"
			cExtra11V  	:= DecodeUTF8("<![CDATA[NO EFECTUAR RETENCION A TITULO DE RENTA E ICA <br> AUTORRETENEDOR RENTA RESOLUCION 000041 JULIO 16/1992 <br> AUTORRETENEDOR ICA RESOLUCION 01 ENERO 2/2017 <br>   <br>]]>", "cp1252")
			
			cExtra11IEn := "RESPONSABLE DE I.V.A"
			cExtra112En := "DATA PROTECTION: See our Data Protection Policy on www.progen.com.co"
			cExtra11VEn := DecodeUTF8("<![CDATA[DATA PROTECTION: See our Data Protection Policy on www.progen.com.co <br>.   <br>]]>", "cp1252")
			
			cExtra13I  	:= "OPCIONES PARA REALIZAR EL PAGO.IMPORTANTE : Envíar el soporte del pago al correo cartera@progen.com.co"
			cExtra13V   := DecodeUTF8("<![CDATA[Por PSE ingresando a nuestra web www.progen.com.co o consignacion a las cuentas: <br> BANCOLOMBIA Cta.Corriente No. 13803226741 Recaudo Empresarial Convenio 3319 <br> DAVIVIENDA cuenta Ahorros No.0004900108079 Convenio 0049108079 <br> BANCO BOGOTA Cta.Corriente No.123282188 Formato Sistema Nacional Rec.Empresarial ]]>", "cp1252")  
		
			cExtra13IEn := "INSTRUCTIONS FOR BANK TRANSFER"
			cExtra13VEn := DecodeUTF8("<![CDATA[Beneficiary PRODUCCIONES GENERALES,S.A. PROGEN,S.A. Account # Beneficiary 102016240 <br> Bank of Beneficiary Itau (Panama) S.A Swift BCTOPAPA Adress Calle 53 Este Marbella World Trade Center Floor 19th Ciudad de Panama <br> Corresponsal Bank Citibank N.A. - New York Swift CITIUS33 ABA 021000089 Account (Corresponsal Bank) 36225789  ,]]>", "cp1252")  

			//Tempalte a usar
			IF (ALLTRIM(cEspecie)<>'NCC')
				IF cTipDocT == "02"
					cTempalte	:= "co-progenFE-52"//Exportacion co-progenFE-40
				ELSE
					cTempalte	:= "co-progenFV-64"//Nacional co-progenFV-59
				ENDIF
			ELSE   
				cTempalte	:= "co-progenNC-17" // NCC  co-progenNC-15
			ENDIF
		
			oWS:oWSextras:=Service_ArrayOfExtras():new() //AH
			oWSextra:=Service_Extras():new()
			oWSextra:ccontrolInterno1     := "TEMPLATE"
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "333221"
			oWSextra:cpdf                 := "1"
			oWSextra:cvalor               := cTempalte
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)

			aCabDatos := CabDatos()
			
			oWSextra:=Service_Extras():new()
			oWSextra:ccontrolInterno1     := "Descuento"
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170001"
			oWSextra:cpdf                 := "1"
			oWSextra:cvalor               :=  TRANSFORM(aCabDatos[1][12],"@E 999,999,999.99")
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)

			//extra para 5170008
			oWSextra:=Service_Extras():new()
			oWSextra:ccontrolInterno1     := "valor del subtotal"
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170008"
			oWSextra:cpdf                 := "1"
			oWSextra:cvalor               := TRANSFORM(aCabDatos[1][16],"@E 999,999,999.99") 
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)
		
			//extra para 5170003
			oWSextra:=Service_Extras():new()
			oWSextra:ccontrolInterno1     := "Total"
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170003"
			oWSextra:cpdf                 := "1"
			oWSextra:cvalor               := TRANSFORM(aCabDatos[1][2],"@E 999,999,999.99")
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)
			
			//extra para  5170016
			oWSextra:=Service_Extras():new()
			oWSextra:ccontrolInterno1     := "Total Antes IVA"
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170016"
			oWSextra:cpdf                 := "1"
			oWSextra:cvalor               := TRANSFORM(aCabDatos[1][7],"@E 999,999,999.99")   
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)

			//Extra para 5170010
			cWebCl	:= "www.progen.com.co"
			oWSExtDet:= Service_Extras():NEW()// pagina web
			oWSExtDet:ccontrolInterno1  := "pagina web"
			oWSExtDet:cnombre           := "5170010"
			oWSExtDet:cpdf              := "1"
			oWSExtDet:cvalor            := Alltrim(cWebCl)
			oWSExtDet:cxml              := "0"
			aAdd(oWS :oWSextras:oWSextras,oWSExtDet)

			//Extra para 5170012	
			cNumTel	:= "57 1 7306090 / 57 1 7306119"
			oWSExtDet:= Service_Extras():NEW()// Telefono
			oWSExtDet:ccontrolInterno1  := "telVentas"
			oWSExtDet:cnombre           := "5170012"
			oWSExtDet:cpdf              := "1"
			oWSExtDet:cvalor            := Alltrim(cNumTel)
			oWSExtDet:cxml              := "0"
			aAdd(oWS :oWSextras:oWSextras,oWSExtDet)
			
			//Extra para 5170009
			IF cTipDocT == "02"
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := "COUNTRY OF ORIGEN: COLOMBIA "
				oWSextra:ccontrolInterno2     := "INCOTERM VERSION 2020: " + ALLTRIM(aCabDatos[1][13])+ " " + ALLTRIM(aCabDatos[1][14])
				oWSextra:cnombre              := "5170009"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := RTRIM(SYA->YA_DESCR) 
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra)
			ELSE
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := "Country"
				oWSextra:ccontrolInterno2     := ""
				oWSextra:cnombre              := "5170009"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := RTRIM(SYA->YA_DESCR) 
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra)
			END

			If cTipDocT == "02"
				//extra para extra 11
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := cExtra11IEn
				oWSextra:ccontrolInterno2     := cExtra112En
				oWSextra:cnombre              := "5170011"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := cExtra11VEn
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra)  
				
				//extra para extra 13
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := cExtra13IEn
				oWSextra:ccontrolInterno2     := ""
				oWSextra:cnombre              := "5170013"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := cExtra13VEn 
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra)
			else
				//extra para extra 11
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := cExtra11I
				oWSextra:ccontrolInterno2     := cExtra11II
				oWSextra:cnombre              := "5170011"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := cExtra11V
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra) 

				//extra para extra 13
				oWSextra:=Service_Extras():new()
				oWSextra:ccontrolInterno1     := cExtra13I
				oWSextra:ccontrolInterno2     := ""
				oWSextra:cnombre              := "5170013"
				oWSextra:cpdf                 := "1"
				oWSextra:cvalor               := cExtra13V 
				oWSextra:cxml                 := "0"
				aAdd(oWS:oWSextras:oWSextras,oWSextra) 
			EndIf
		
			cFechaEmision	:= dtos(aCabDatos[1][10])
			cVencimiento 	:= aCabDatos[1][24]
			lContado		:= IIF(cFechaEmision==cVencimiento,.T.,.F.)

			//extra para extra 14
			CPerDesc1 := cValToChar(aCabDatos[1][19]) + CPerDesc1
			oWSextra:=Service_Extras():new()
			If !lContado
				oWSextra:ccontrolInterno1     := DToC(aCabDatos[1][22])
				oWSextra:cvalor               := CPerDesc1 
			Else
				oWSextra:cvalor               := "0,00 % "
			Endif	
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170014"
			oWSextra:cpdf                 := "1"
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)
		
			//para extra 15
			CPerDesc2 := cValToChar(aCabDatos[1][20]) + CPerDesc2
			oWSextra:=Service_Extras():new()
			If !lContado
				oWSextra:ccontrolInterno1     := DToC(aCabDatos[1][23])
				oWSextra:cvalor               := CPerDesc2
			Else
				oWSextra:cvalor               := "0,00 % "
			Endif
			oWSextra:ccontrolInterno2     := ""
			oWSextra:cnombre              := "5170015"
			oWSextra:cpdf                 := "1"
			oWSextra:cxml                 := "0"
			aAdd(oWS:oWSextras:oWSextras,oWSextra)
			

			SA1->(dbSetOrder(1))
			If SA1->(msSeek(xFilial("SA1")+cCodCli+cCodLoj))
				cpaisCli    := alltrim(SA1->A1_PAIS)
				IF Empty(cCodDpto)
					cCodDpto    := alltrim(SA1->A1_PAIS)
				EndIf
				IF (cpaisCli <> "169" .AND. cCodDpto == "EX")
					oWS:oWSCliente:oWSdireccionCliente := NIL //
					oWS:oWSCliente:oWSdireccionFiscal := NIL
				ENDIF
			EndIf
		
			//IF cEspecie <> 'NCC'
				If !EMPTY(aCabDatos[1][17]) .or. !EMPTY(aCabDatos[1][18])  // Mensaje Factura Cliente / NCC
						IF !EMPTY(aCabDatos[1][17]) .and. !EMPTY(aCabDatos[1][18])   // Observaciones
								cObsFa := cValToChar(aCabDatos[1][17]) + char(13) + char(10) + aCabDatos[1][18]
						ElseIf !EMPTY(aCabDatos[1][17]) .and. EMPTY(aCabDatos[1][18]) 
								cObsFa := cValToChar(aCabDatos[1][17])	
						ElseIf  EMPTY(aCabDatos[1][17]) .and. !EMPTY(aCabDatos[1][18]) 	
								cObsFa := cValToChar(aCabDatos[1][18])
						ENDIF
						oWS:oWSinformacionAdicional:=Service_ArrayOfstring():New()
						aAdd(oWS:oWSinformacionAdicional:cstring,cObsFa)
				Endif
			//ENDIF
		
		    //Metodo de Pago
			//IF (ALLTRIM(cEspecie)=='NCC') .OR. (cFechaEmision==cVencimiento)
			IF  lContado
				cMetodoPago		:= .T.
				cVencimiento 	:= ""
			Else
				cMetodoPago		:= .F.
				cVencimiento 	:= aCabDatos[1][24]
			EndIf

			If !EMPTY(cVencimiento)
						oWS:oWSMediosDePago:=Service_ArrayOfMediosDePago():New()
						oWSMediosPago:=Service_MediosDePago():New()
						oWSMediosPago:cfechaDeVencimiento:=LEFT(cVencimiento,4)+"-"+SUBSTR(cVencimiento,5,2)+"-"+RIGHT(cVencimiento,2)
						oWSMediosPago:cmedioPago:="ZZZ"
						oWSMediosPago:cmetodoDePago:=IF(cMetodoPago,'1','2') // "2"=Credito
						oWSMediosPago:cnumeroDeReferencia:='01' //alltrim(cSerieDoc)+"-"+ cValToChar(val(cNumDoc))//"01"
						aAdd(oWS:oWSMediosDePago:oWSMediosDePago,oWSMediosPago)
			Else
						oWS:oWSMediosDePago:=Service_ArrayOfMediosDePago():New()
						oWSMediosPago:=Service_MediosDePago():New()
						//oWSMediosPago:cfechaDeVencimiento:=LEFT(cVence,4)+"-"+SUBSTR(cVence,5,2)+"-"+RIGHT(cVence,2)
						oWSMediosPago:cmedioPago:="ZZZ"
						oWSMediosPago:cmetodoDePago:=IF(cMetodoPago ,'1','2') // "2"=Credito
						oWSMediosPago:cnumeroDeReferencia:='01' //alltrim(cSerieDoc)+"-"+ cValToChar(val(cNumDoc))//"01"
						aAdd(oWS:oWSMediosDePago:oWSMediosDePago,oWSMediosPago)
			Endif

			cNumOrdenCom 	:= aCabDatos[1][26]
			cNumPedidos 	:= aCabDatos[1][27]

			oWS:oWSordenDeCompra:=Service_ArrayOfOrdenDeCompra():New()
			oWSOrdenDeCompra:=Service_OrdenDeCompra():New()
			oWSOrdenDeCompra:cnumeroOrden:= cNumPedidos
			oWSOrdenDeCompra:cnumeroPedido:=cNumOrdenCom
			oWSOrdenDeCompra:ccodigoCliente:=ALLTRIM(cCodCli)+"-"+ALLTRIM(cCodLoj)
			aAdd(oWS:oWSordenDeCompra:oWSordenDeCompra,oWSOrdenDeCompra) 

			// PARA ENVIO DE CORREO DESDE THE FACTORY
			If cAmbiente<>'2' .and. cProgenNF2<>'2' // No es Demo
				SA1->(dbSetOrder(1))
				If SA1->(msSeek(xFilial("SA1")+cCodCli+cCodLoj))
					If !Empty(SA1->A1_EMAIL) // Como ejemplo se usa el campo A1_EMAIL (Comentarios de perfil)
						aEmail := StrTokArr(alltrim(SA1->A1_EMAIL), ";") // Las cuentas de correo están separadas por coma
						oWS:oWSCliente:cnotIficar := "SI" // Indicar Sí notIficar
						oWSDest := Service_Destinatario():NEW() // Crea objeto destinatario, el medio de entrega es 0=email
						oWSDest:ccanalDeEntrega := "0"
						oWSDest:oWSemail := Service_ArrayOfstring():NEW() // Crea arreglo de las cuentas de correo
						For nXA := 1 to Len(aEmail)
							aAdd(oWSDest:oWSEmail:cstring, aEmail[nXA]) 
						Next nXA
						oWS:oWSCliente:oWSdestinatario:=Service_ArrayOfDestinatario():new()
						aAdd(oWS:oWSCliente:oWSDestinatario:oWSDestinatario, oWSDest) // Agrega destinatario al objeto principal
					EndIf
				EndIf
			ENDIF

    ENDIF

ElseIf nOpc == 2 //Detalle del documento
	
	IF nTDTras == 6  // PARA EL DOCUMENTO SOPORTE
		  	ows:cestandarCodigoProducto := ows:ccodigoProducto
			cFecAntd := dtos(SF1->F1_EMISSAO)
			oWs:CDESCRIPCION2 	:= LEFT( Alltrim(cFecAntd), 4 )+"-"+SUBSTR(Alltrim(cFecAntd),5,2) + "-" +RIGHT(  Alltrim(cFecAntd), 2 ) 
			oWs:CDESCRIPCION3 	:=  "1"	
	ELSE
		IF (ALLTRIM(cEspecie)=='NF' .OR. ALLTRIM(cEspecie)=='NDC') 
			cCodProd	:= Padr(oWS:ccodigoProducto,TamSX3("D2_COD" )[1],' ')
        	
			//PARA MAS DE 99 ITEMS HAY QUE CAMBIAR EL FATSCOL.INI Y FATSECOL.INI EN LA LINEA
			// LINEA 268 .... Alltrim(Str(Val(SD2->D2_ITEM)))  POR  Alltrim(SD2->D2_ITEM)
			// LUEGO SE DEBE COMENTARIAR LA SIGUIENTE LINEA 
			// cSDITem 	:= Padl(oXML:_CBC_ID:TEXT,TamSX3("D2_ITEM")[1],'0')  
			// Y POR ULTIM LUEGO SE DEBE HABILITA LA SIGUIENTE LINEA
    		cSDITem 	:= oXML:_CBC_ID:TEXT   
			
			dbSelectArea("SD2")
			SD2->(dbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM

           	If SD2->(dbSeek( xFilial("SD2") + cNumDoc + cSerieDoc + cCodCli + cCodLoj + cCodProd + cSDITem)) 
				
				//ESTO S PARA QUE EL XML QUE TRANSMITE ALA DIAN LLEVE EL ITEM EN FORMATO NUMERO
				oWSDet:csecuencia := cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))
				oWS:csecuencia 	  := cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))  
				
				oWS:oWSinformacionAdicional:=Service_ArrayOfLineaInformacionAdicional():New()

				// PARA LLEVAR EL NUMERO DEL REMITO EN CADA ITEM
				If LEN(ALLTRIM(SD2->D2_REMITO)) > 0
					oWSAdicion:=Service_LineaInformacionAdicional():New()
					oWSAdicion:ccodigo := "5171"
					oWSAdicion:cnombre := "5171"
					oWSAdicion:csecuencia := "1"
					oWSAdicion:cvalor  := SUBSTR(RTRIM(SD2->D2_REMITO),8,14) 
					aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
				ENDIF
								
				// PARA LOS OBSEQUIOS Y LAS GARANTIAS CARGO IVA PROGEN
				If Alltrim(SD2->D2_TES) $ Alltrim(cTesObGta) 
					oWS:ccodigoTipoPrecio		:="01"
					oWS:cmuestragratis   		:= "1"
					oWS:cprecioreferencia  		:= CvALTOcHAR(D2_TOTAL)
					oWS:cprecioTotalSinImpuestos:= CvALTOcHAR(0.00)
					oWS:cprecioTotal       		:= CvALTOcHAR(0.00)
					oWS:csecuencia   			:= "1"
					oWs:cPrecioventaunitario 	:= CvALTOcHAR(D2_TOTAL)
				EndIf
				


				// PARA LOS OBSEQUIOS Y LAS GARANTIAS CARGO IVA CLIENTES
				If Alltrim(SD2->D2_TES) $ Alltrim(cTesObsCli) 
					oWS:ccodigoTipoPrecio		:="01"
					oWS:cmuestragratis   		:= "1"
					oWS:cprecioreferencia  		:= CvALTOcHAR(D2_TOTAL)
					oWS:cprecioTotalSinImpuestos:= CvALTOcHAR(0.00)
					oWS:cprecioTotal       		:= CvALTOcHAR(0.00)
					oWS:csecuencia   			:= "1"
					oWs:cPrecioventaunitario 	:= CvALTOcHAR(D2_TOTAL)
				EndIf
				

				// PARA EL PRECIO UNITARIO DE LISTA Y EL PRECIO TOAL DE LA LINEA
				oWSAdicion:=Service_LineaInformacionAdicional():New()
				oWSAdicion:ccodigo 		:= "5173"
				oWSAdicion:cnombre 		:= TRANSFORM(SD2->D2_PRUNIT,"@E 999,999,999.99") 
				oWSAdicion:csecuencia 	:= "1"
				oWSAdicion:cvalor 		:= TRANSFORM((SD2->D2_PRUNIT*SD2->D2_QUANT),"@E 999,999,999.99")
				aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
			
				// PARA EL NUMERO DE ITEM NUMERICO Y LA CANTIDAD CON COMA EN VES DE PUNTO
			   	oWSAdicion:=Service_LineaInformacionAdicional():New()
				oWSAdicion:ccodigo 		:= "5174"
				oWSAdicion:cnombre 		:= "01" 
				oWSAdicion:csecuencia 	:= cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))
				oWSAdicion:cvalor 		:= TRANSFORM(SD2->D2_QUANT,"@E 999,999.999")      // PARA COLOCAR COMA EN LA CABTIDAD
				aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)

				// PARA LA DESCRIPCION DEL PRODUCTO DESDE CADA LINEA DEL PEDIDO
				dbSelectArea("SC6")  
				SC6->(dbSetOrder(1))  // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				SC6->(dbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
				If LEN(SC6->C6_DESCRI) > 1
					oWs:CDESCRIPCION	:= ALLTRIM(SC6->C6_DESCRI)
				EndIf
                	
				// PARA OBSERVACIONES ADICIONALES DESDE CADA LA LINEA DEL PEDIDO
				If LEN(ALLTRIM(SC6->C6_VDOBS)) > 1
					oWs:CSERIALES 	:= ALLTRIM(SC6->C6_VDOBS)
				EndIf
				
				// PARA EL CODIGO Y DESCRIPCION DEL PRODUCTO DEL CLIENTE O REFERENCIA CRUZADA
				dbSelectArea("SA7")
				SA7->(dbSetOrder(1))
				SA7->(dbSeek(XFILIAL("SA7")+cCodCli+cCodLoj+cCodProd)) 
				If LEN(SA7->A7_CODCLI) > 1
					oWs:CDESCRIPCION2 	:= ALLTRIM(SA7->A7_CODCLI)	+ " - " + ALLTRIM(SA7-> A7_DESCCLI)
				EndIF

				// PARA DESCRIPCION ADICIONAL DEL PRODUCTO  DESDE EL MAESTRO DE PRODUCTOS
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFILIAL("SB1")+cCodProd)) 
				If LEN(SB1->B1_XDESCRI) > 1
					oWs:CDESCRIPCION3 	:= ALLTRIM(SB1->B1_XDESCRI)
				EndIf
		
				// PARA DESCRIPCION DE LA UNIDAD DE MEDIDA DEL PRODUCTO
				// ESTA INHBILITDA PORQUE LA DIAN SOLO ACEPTA US CODIGOS. EJEMPLO "94"
				//IF LEN(SD2->D2_UM) >= 1  
				//	oWs:CUNIDADMEDIDA := SD2->D2_UM
				//ENDIF
			
			Endif
			SD2->(DBCLOSEAREA(  ))

		ElseIf (ALLTRIM(cEspecie)=="NCC" )       // Notas de credito
			cCodProd	:= Padr(oWS:ccodigoProducto,TamSX3("D1_COD" )[1],' ')
			//cSDITem     := Padl(oXML:_CBC_ID:TEXT  ,TamSX3("D1_ITEM")[1],'0')
			cSDITem 	:= oXML:_CBC_ID:TEXT 

			oWSDet:csecuencia := cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))
			oWS:csecuencia 	  := cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))  
				
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
            	
			If SD1->(dbSeek( xFilial("SD1") + cNumDoc + cSerieDoc + cCodCli + cCodLoj + cCodProd + cSDITem))
				
				nValunitSD1	:= (SD1->D1_VUNIT+SD1->D1_VALDESC)/SD1->D1_QUANT
				
				oWS:oWSinformacionAdicional:=Service_ArrayOfLineaInformacionAdicional():New()
				oWSAdicion:=Service_LineaInformacionAdicional():New()
				oWSAdicion:ccodigo 		:= "5173"
				oWSAdicion:cnombre 		:= TRANSFORM(nValunitSD1,"@E 999,999,999.99")
				oWSAdicion:csecuencia 	:= "1"
				oWSAdicion:cvalor 		:= TRANSFORM((SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALDESC,"@E 999,999,999.99")
				aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
				

				If ALLTRIM(SD1->D1_REMITO) <> ""
					//oWS:oWSinformacionAdicional:=Service_ArrayOfLineaInformacionAdicional():New()
					oWSAdicion:=Service_LineaInformacionAdicional():New()
					oWSAdicion:ccodigo := "5171"
					oWSAdicion:cnombre := "5171"
					oWSAdicion:csecuencia := "1"
					oWSAdicion:cvalor  := SUBSTR(RTRIM(SD1->D1_REMITO),8,14) 
					aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
				EndIF
				
				// PARA LOS OBSEQUIOS Y LAS GARANTIAS
				If Alltrim(SD1->D1_TES) $ Alltrim(cTesObGta)
					oWS:ccodigoTipoPrecio		:="01"
					oWS:cmuestragratis   		:= "1"
					oWS:cprecioreferencia  		:= CvALTOcHAR(SD1->D1_TOTAL)
					oWS:cprecioTotalSinImpuestos:= CvALTOcHAR(0.00)
					oWS:cprecioTotal       		:= CvALTOcHAR(0.00)
					oWS:csecuencia   			:= "1"
					oWs:cPrecioventaunitario 	:= CvALTOcHAR(SD1->D1_TOTAL)
				EndIf

				If Alltrim(SD1->D1_TES) $ Alltrim(cTesObsCli) 
					oWS:ccodigoTipoPrecio		:="01"
					oWS:cmuestragratis   		:= "1"
					oWS:cprecioreferencia  		:= CvALTOcHAR(SD1->D1_TOTAL)
					oWS:cprecioTotalSinImpuestos:= CvALTOcHAR(0.00)
					oWS:cprecioTotal       		:= CvALTOcHAR(0.00)
					oWS:csecuencia   			:= "1"
					oWs:cPrecioventaunitario 	:= CvALTOcHAR(SD1->D1_TOTAL)
				EndIf
					
				
				// PARA EL PRECIO UNITARIO DE LISTA Y EL PRECIO TOAL DE LA LINEA
				oWSAdicion:=Service_LineaInformacionAdicional():New()
				oWSAdicion:ccodigo 		:= "5173"
				oWSAdicion:cnombre 		:= TRANSFORM(nValunitSD1,"@E 999,999,999.99") 
				oWSAdicion:csecuencia 	:= "1"
				oWSAdicion:cvalor 		:= TRANSFORM((nValunitSD1*SD1->D1_QUANT),"@E 999,999,999.99")
				aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
				
				// PARA EL NUMERO DE ITEM NUMERICO Y LA CANTIDAD CON COMA EN VES DE PUNTO
				oWSAdicion:=Service_LineaInformacionAdicional():New()
				oWSAdicion:ccodigo 		:= "5174"
				oWSAdicion:cnombre 		:= "01" 
				oWSAdicion:csecuencia 	:= cValToChar(decodsoma1(oXML:_CBC_ID:TEXT))
				oWSAdicion:cvalor 		:= TRANSFORM(SD1->D1_QUANT,"@E 999,999.999")      // PARA COLOCAR COMA EN LA CABTIDAD
				aAdd(oWS:oWSinformacionAdicional:oWSLineaInformacionAdicional,oWSAdicion)
				
				// PARA EL CODIGO Y DESCRIPCION DEL PRODUCTO DEL CLIENTE O REFERENCIA CRUZADA
				dbSelectArea("SA7")
				SA7->(dbSetOrder(1))
				SA7->(dbSeek(XFILIAL("SA7")+cCodCli+cCodLoj+cCodProd)) 
				If LEN(SA7->A7_CODCLI) > 1
					oWs:CDESCRIPCION2 	:= ALLTRIM(SA7->A7_CODCLI)	+ " - " + ALLTRIM(SA7->A7_DESCCLI)
				EndIF
				// PARA DESCRIPCION ADICIONAL DEL PRODUCTO  DESDE EL MAESTRO DE PRODUCTOS
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFILIAL("SB1")+cCodProd)) 
				If LEN(SB1->B1_XDESCRI) > 1
					oWs:CDESCRIPCION3 	:= ALLTRIM(SB1->B1_XDESCRI)
				EndIf
             
			Endif
			SD1->(DBCLOSEAREA(  ))
		EndIf
	EndIf
ENDIF //Para JP

	RestArea(aAreaSA1)
	RestArea(aArea)
Return Nil


// funcion que rescata datos necesario para la factura , ncc y ndc en un array
Static function	CabDatos
	Local cSerieDoc 	:= PARAMIXB[1] //Serie
	Local cNumDoc   	:= PARAMIXB[2] //Número de Documento
	Local cCodCli   	:= PARAMIXB[3] //Código de Cliente
	Local cCodLoj   	:= PARAMIXB[4] //Código de la Tienda
	Local aCabDatos		:= {}
	Local cPedido,nCantD2,nPeso,nSubTotal,CNumItem,nSubTotalD1
	Local cTextoFact	:= ""
	Local dFecDcto1 	:= ""
	Local dFecDcto2 	:= ""
	Local cFechaEmis 	:= ""
	Local cNatOGCNal 	:= GetMV("MV_NATOBGT",,"") // Obsequios, Garantias y Cargos internos. IVA Cargo a Progen
	Local cNatObsCli 	:= GetMV("MV_NATOBCL",,"") // Obsequios con IVA Cargo a Clientes
	Local cNatOGExt  	:= GetMV("MV_NATOBEX",,"") // Muestras al Exterior
	Local nValTotal		:= 0
	Local nSubTotalD2	:= 0
	Local nSubTotAntIva := 0
	Local lMultiPedidos	:= .F.
	

		If (ALLTRIM(cEspecie)=='NF' .OR. ALLTRIM(cEspecie)=='NDC')

				dbSelectArea("SF2")
				dbSelectArea("SD2")
				dbSelectArea("SE4")
				dbSelectArea("SC5")
				dbSelectArea("SE1")

				SF2->(dbSetOrder(2))  // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
				SD2->(dbSetOrder(3))  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				SE4->(dbSetOrder(1))  // E4_FILIAL+E4_CODIGO
				SC5->(dbSetOrder(3))  // C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
				SE1->(dbSetOrder(2))  // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				SF2->(dbSeek(xFilial("SF2")+cCodCli+cCodLoj+cNumDoc+cSerieDoc+"N"+cEspecie))
				SD2->(dbSeek(xFilial("SD2")+cNumDoc+cSerieDoc+cCodCli+cCodLoj))
				SE4->(dbSeek(xFilial("SE4")+SF2->F2_COND))
				SC5->(dbSeek(xFilial("SC5")+cCodCli+cCodLoj+SD2->D2_PEDIDO))
				SE1->(dbSeek(xFilial("SE1")+cCodCli+cCodLoj+cSerieDoc+cNumDoc+SPACE(TamSX3("E1_PARCELA")[1])+cEspecie))
				

				cPedido			:= SD2->D2_PEDIDO
				CNumItem		:= SD2->D2_ITEM
				cCodProd		:= SD2->D2_COD
				nCantD2			:= 0
				nPeso			:= 0
				//nSubTotal		:= 0
				cTextoFact		:= SC5->C5_MENNOTA
				dFecVctotoReal	:= SE1->E1_VENCREA
				nSubTotAntIva	:= SF2->F2_VALMERC
				nTotalDescuento	:= SF2->F2_DESCONT
				nSubTotalD2		:= 0
				cNaturez		:= SF2->F2_NATUREZ
				cnumPedido		:= SD2->D2_PEDIDO
				cFechaEmis 		:= SF2->F2_EMISSAO	
			

				// SUMO LOS ITEMS DE LA FACTURA DE OSEQUIOS PARA CALCULAR EL VALOR DE LA MERCADERIA, EL SUBTOTAL Y EL TOTAL 
				While  SD2->(!Eof()) .AND. SD2->D2_DOC == cNumDoc .and. SD2->D2_SERIE == cSerieDoc .and. SD2->D2_CLIENTE == cCodCli .and. SD2->D2_LOJA == cCodLoj .and. SD2->D2_ESPECIE == cEspecie  //.and. SD2->D2_COD == cCodProd
					nSubTotalD2 	:= nSubTotalD2 + (SD2->D2_TOTAL+SD2->D2_DESCON)
					//lMultiPedidos	:= IF(cnumPedido <> SD2->D2_PEDIDO, .T., .F.)	
					SD2->(dbSkip())
				ENDDO
				nSubTotal 		:= 0
				nSubTotal		:= nSubTotalD2
				nTotalDescuento	:= SF2->F2_DESCONT
				//nSubTotAntIva := (nSubTotal - nTotalDescuento)

				IF ALLTRIM(cNaturez) $ cNatOGCNal 		// MV_NATOBGT : OBSEQ, GARANTIA, CONSUMO INT. NACIONAL IVA A PROGEN
					//nSubTotal 		:= nSubTotalD2
					nSubTotAntIva 	:= nSubTotal - nTotalDescuento
					nValTotal		:= SF2->F2_VALBRUT
				ELSEIF ALLTRIM(cNaturez) $ cNatObsCli 	// MV_NATOBCL : OBSEQUIOS IVA AL CLIENTE
					//nSubTotal 		:= nSubTotalD2
					nSubTotAntIva 	:= nSubTotal - nTotalDescuento
					nValTotal		:= SF2->F2_VALIMP1 - SF2->F2_VALIMP2
				ELSEIF ALLTRIM(cNaturez) $ cNatOGExt 	// MV_NATOBEX : MUESTRA AL EXTERIOR POR REQ. DE LA DIAN
					//nSubTotal 		:= nSubTotalD2
					nSubTotAntIva 	:= nSubTotal - nTotalDescuento
					nValTotal		:= nSubTotal
				ELSE 									// FACTURA NACIONAL, FACTURA EXTERIOR
					nSubTotal		:= SF2->F2_VALMERC + SF2->F2_DESCONT 
					nSubTotAntIva	:= SF2->F2_VALMERC
					nValTotal		:= SF2->F2_VALMERC + SF2->F2_VALIMP1 - SF2->F2_VALIMP2
				ENDIF
				
					
			    IF !(lMultiPedidos)    
					cnumPedido	:= IF(EMPTY(Alltrim(SC5->C5_NUM))    ," ",Alltrim(SC5->C5_NUM))
					cnumOrden	:= IF(EMPTY(Alltrim(SC5->C5_XORCOMP))," ",Alltrim(SC5->C5_XORCOMP))
				ELSE	
					cnumPedido	:= "Varios"
					cnumOrden	:= "Varios"
				ENDIF

				cBuscaSE1:=xFilial("SE1")+ cCodCli + cCodLoj + cSerieDoc + cNumDoc+SPACE(TamSX3("E1_PARCELA")[1])+cEspecie             
				dVence:=POSICIONE("SE1",2,cBuscaSE1,"E1_VENCTO")

				If !Empty(dVence) 
					cVence			:= dtos(dVence)
					dFecVctotoReal 	:= SE1->E1_VENCREA
					dFecDcto1		:= DaySub(SE1->E1_VENCREA, SE4->E4_DIADESC)
					dFecDcto2		:= DaySub(SE1->E1_VENCREA, SE4->E4_XDIADES)
				Else
					cVence			:= dtos(SF2->F2_EMISSAO)
					dFecVctotoReal 	:= SF2->F2_EMISSAO
					dFecDcto1 		:= SF2->F2_EMISSAO
					dFecDcto2 		:= SF2->F2_EMISSAO
				Endif


				aAdd(aCabDatos,{SF2->F2_COND,;  			//1
				nValTotal,;									//2
				SF2->F2_BASIMP1,;							//3
				SF2->F2_VALIMP1,;							//4
				SF2->F2_BASIMP1,;							//5
				SE4->E4_COND,;								//6
				nSubTotAntIva,;								//7 
				cPedido,;									//8
				SF2->F2_XOBS,; 								//9
				cFechaEmis,;								//10
				nPeso,;										//11
				nTotalDescuento,;							//12 
				SC5->C5_INCOTER,;							//13
				SC5->C5_XPUERTO,;							//14
				" ",;										//15
				nSubTotal,;									//16
				SC5->C5_MENNOTA,;							//17
				SC5->C5_XTEXCLI,;							//18
				SE4->E4_DESCFIN,;							//19
				SE4->E4_XDESCFI,;							//20
				dFecVctotoReal,;							//21  
				dFecDcto1,;									//22
				dFecDcto2,;									//23
				cVence,;									//24
				" ",;										//25
				cnumOrden,;									//26
				cnumPedido})								//27

				SF2->(DbCloseArea())
				SD2->(DbCloseArea())
				SE4->(DbCloseArea())
				SC5->(DbCloseArea())
				SE1->(DbCloseArea())
			
	Else  //NCC  YILE

				dbSelectArea("SF1")
				dbSelectArea("SD1")
				dbSelectArea("SE4")
				dbSelectArea("SE1")

				SF1->(dbSetOrder(1))  //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				SD1->(dbSetOrder(1))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				SE4->(dbSetOrder(1))  //E4_FILIAL+E4_CODIGO
				SE1->(dbSetOrder(2))  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

				SF1->(dbSeek(xFilial("SF1")+cNumDoc+cSerieDoc+cCodCli+cCodLoj+'D'))
				SD1->(dbSeek(xFilial("SD1")+cNumDoc+cSerieDoc+cCodCli+cCodLoj))
				SE4->(dbSeek(xFilial("SE4")+SF1->F1_COND))
				SE1->(dbSeek(xFilial("SE1")+cCodCli+cCodLoj+cSerieDoc+cNumDoc))

				
				CNumItem		:= SD1->D1_ITEM
				cCodProd		:= SD1->D1_COD
				cNaturez		:= SF1->F1_NATUREZ
				nSubTotalc		:= SF1->F1_VALMERC+SF1->F1_DESCONT
				dFecVctotoReal	:= SE1->E1_VENCREA
				nSubTotalD1 	:= 0
				cFechaEmis 		:= SF1->F1_EMISSAO

				
				While  SD1->(!Eof()) .and. SD1->D1_DOC == cNumDoc .and. SD1->D1_SERIE == cSerieDoc .and. SD1->D1_FORNECE == cCodCli .and. SD1->D1_LOJA == cCodLoj .and. SD1->D1_ESPECIE == cEspecie
					nSubTotalD1 := nSubTotalD1 + (SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALDESC
					SD1->(dbSkip())
				ENDDO
				nSubTotal 		:= 0
				nSubTotal		:= nSubTotalD1
				nTotalDescuento	:= SF1->F1_DESCONT
				//nSubTotAntIva := (nSubTotal - nTotalDescuento)
					
				IF ALLTRIM(cNaturez) $ cNatOGCNal 		// NCC OBSEQ, GARANTIA, CONSUMO INT. NACIONAL
					//nSubTotal 		:= nSubTotalD1
					nSubTotAntIva 	:= (nSubTotal - nTotalDescuento)
					//nValTotal		:= (SF1->F1_VALIMP1 - SF1->F1_VALIMP2)
					nValTotal		:=  SF1->F1_VALBRUT
				ELSEIF ALLTRIM(cNaturez) $ cNatObsCli 	// NCC OBSEQUIOS IVA AL CLIENTE
					//nSubTotal 		:= nSubTotalD1
					nSubTotAntIva 	:= nSubTotal - nTotalDescuento
					nValTotal		:= SF1->F1_VALIMP1 - SF1->F1_VALIMP2
				ELSEIF (ALLTRIM(cNaturez) $ cNatOGExt) 	// NCC MUESTRA AL EXTERIOR POR REQ. DE LA DIAN
					//nSubTotal 		:= nSubTotalD1
					nSubTotAntIva 	:= (nSubTotal - nTotalDescuento)
					nValTotal		:= nSubTotal
				ELSE 	// NCC NACIONALES Y EXTERIOR
					nSubTotal		:= SF1->F1_VALMERC + SF1->F1_DESCONT 
					nSubTotAntIva	:= SF1->F1_VALMERC
					nValTotal		:= SF1->F1_VALMERC + SF1->F1_VALIMP1 - SF1->F1_VALIMP2
				ENDIF
				
				cBuscaSE1:=xFilial("SE1")+ cCodCli + cCodLoj + cSerieDoc + cNumDoc+SPACE(TamSX3("E1_PARCELA")[1])+cEspecie             
				dVence:=POSICIONE("SE1",2,cBuscaSE1,"E1_VENCTO")
				cVence:=dtos(dVence)

				If !Empty(dVence) 
					cVence			:= dtos(dVence)
					dFecVctotoReal 	:= SE1->E1_VENCREA
					dFecDcto1		:= DaySub(SE1->E1_VENCREA, SE4->E4_DIADESC)
					dFecDcto2		:= DaySub(SE1->E1_VENCREA, SE4->E4_XDIADES)
				Else
					cVence			:= dtos(SF1->F1_EMISSAO)
					dFecVctotoReal 	:= SF1->F1_EMISSAO
					dFecDcto1 		:= SF1->F1_EMISSAO
					dFecDcto2 		:= SF1->F1_EMISSAO
				Endif
			
				
				//cPedido    := ""
				//nCantD2    := 0
				nPeso      := 0
				cnumOrden  := "-"
				cnumOrden  := "-"
				cnumPedido := "-"
				
				aAdd(aCabDatos,{ SF1->F1_COND,;  			//1
				nValTotal,;									//2
				SF1->F1_BASIMP1,;							//3
				SF1->F1_VALIMP1,;							//4
				SF1->F1_BASIMP1+SF1->F1_VALIMP1,;			//5
				SE4->E4_COND,;								//6
				nSubTotAntIva,; 							//7  
				" ",;										//8
				SF1->F1_MOTIVO,; 							//9
				cFechaEmis,;								//10
				nPeso,;										//11
				nTotalDescuento,;							//12
				SF1->F1_INCOTER,;							//13
				" ",;										//14
				ALLTRIM(SF1->F1_TIPOPE),;					//15
				nSubTotal,;									//16
				SF1->F1_MOTIVO,;							//17
				" ",;										//18
				SE4->E4_DESCFIN,;							//19
				SE4->E4_XDESCFI,;							//20
				SE1->E1_VENCREA,;							//21
				SE1->E1_EMISSAO,;							//22
				SE1->E1_EMISSAO,;							//23
				cVence,;									//24
				" ",;										//25
				cnumOrden,;									//26
				cnumPedido})								//27
				
				SF1->(DbCloseArea())
				SD1->(DbCloseArea())
				SE4->(DbCloseArea())
				SE1->(DbCloseArea())
				//Return aCabDatos

	EndIf

Return aCabDatos

Static Function MemoToStr(TxtMemo)
	Local cStrReturn := TxtMemo
	cStrReturn  := Strtran(cStrReturn,chr(13),' ')
	cStrReturn  := Strtran(cStrReturn,chr(10),' ')
	cStrReturn  := Strtran(cStrReturn,chr(9),' ')
Return cStrReturn


Static Function formatValEnv(nValFormat,tpformat)
	Local cValformatado     := " "
	DEFAULT nValFormat := 0

	cValformatado   := transform(nValFormat,"@E 999,999,999,999.99")
	cValformatado   := STRTRAN(cValformatado, ".", ";")
	cValformatado   := STRTRAN(cValformatado, ",", ".")
	If tpformat = 1
		cValformatado   := STRTRAN(cValformatado, ";", ",")
	Else
		cValformatado   := STRTRAN(cValformatado, ";", "")
	EndIf
	cValformatado := Alltrim(cValformatado)
Return cValformatado


