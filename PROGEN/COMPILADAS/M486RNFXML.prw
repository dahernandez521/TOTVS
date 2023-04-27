#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矼486RNFXML  � Autor � Dora Vega             � Data � 10.07.17 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Generacion de XML para guia de remision para trasmision      潮�
北�          � electronica de Peru,de acuerdo a esquema estandar UBL 2.1    潮�
北�          � para ser enviado a TSS para su envio a la SUNAT. (PER)       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � M486RNFXML(cFil, cSerie, cNumDoc, cCliente, cLoja)           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cFil .- Sucursal que emitio el documento.                    潮�
北�          � cSerie .- Numero o Serie del Documento.                      潮�
北�          � cNumDoc .- Numero de documento.                              潮�
北�          � cCliente .- Codigo del cliente.                              潮�
北�          � cLoja .- Codigo de la tienda del cliente.                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � MATA486                                                      潮�
北媚哪哪哪哪牧哪穆哪哪哪哪履哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador   � Data   � BOPS/FNC  �  Motivo da Alteracao                潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矹onathan Glz  �31/08/17矰MINA-38   砈e modifica funcion fGenXMLRNF para  潮�
北�              �        �           硁egenerar de manera correcta el nodo 潮�
北�              �        �           砪on se pondra la firma digital.      潮�
北矼.Camargo     �11/10/19矰MINA-7508 矨pertuna PE M486EGR                  潮�  
北矹os� Gonz醠ez �19/02/20矰MINA-8156 砊ratamiento para camposen tabla SM0  潮� 
北矻uis Enr韖uez �25/03/11矰MINA-11774砈e agrega nodo cac:Contact para co-  潮�
北�              �        �           砽ocar elemento cbc:ElectronicMail con潮�
北�              �        �           砮l valor del campo E1_EMAIL. (PER)   潮�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�/*/
Function M486RNFXML(cFil, cSerie, cNumDoc, cCliente, cLoja)
	Local cXML      := ""
	Local aEncab    := {}	
	Local aArea     := getArea()
	Local nTamDoc   := TamSX3("F2_DOC")[1]
	Local aDetalle  := {}
	Local aTransla  := {}
	Local cMotTras  := ""
	Local cRUCTrans := ""
	Local cDirTrans := ""
	Local cCPTras   := ""
	Local cNomTrans := ""
	Local cNoIdCond := ""
	Local cNomCondu := ""
	Local cApeCondu := ""
	Local cTpIdCond := ""
	Local nPeso     := 0
	Local cModTras  := ""
	Local cFecEmi   := ""
	Local aUUIDRel  := {}
	Local nI        := 0	
	Local cFilSA1 := xfilial("SA1")
	Local cFilSA4 := xfilial("SA4")
	Local cFilDA3 := xfilial("DA3")
	Local cFilDA4 := xfilial("DA4")
	
	Private cCRLF   := (chr(13)+chr(10))
	Private aDocRel := {}
    Private cCPEnt  := ""
    Private cDirEnt := ""
    Private cPaisEnt:= ""
    Private cMatVehi:= ""
    
	dbSelectArea("SF2") 
	SF2->(dbSetORder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
	If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja))
		cFolio := SF2->F2_SERIE2 + "-" + Alltrim(substr(SF2->F2_DOC,(nTamDoc-7),8)) //Serie-Correlativo
		cFecEmi := StrZero(Year(SF2->F2_EMISSAO),4) + "-" + StrZero(MONTH(SF2->F2_EMISSAO),2) + "-" + StrZero(DAY(SF2->F2_EMISSAO),2) //Fecha de emisi髇
		nPeso    := SF2->F2_PBRUTO //Peso Bruto Total
		cMotTras := SF2->F2_MODTRAD //Motivo de traslado
		cFecIniTra :=  StrZero(Year(SF2->F2_FECDSE),4) + "-" + StrZero(MONTH(SF2->F2_FECDSE),2) + "-" + StrZero(DAY(SF2->F2_FECDSE),2) //Fecha de inicio del traslado
				
		aEncab  := {cFolio, cFecEmi, nPeso}
		
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
		If SA1->(dbSeek(cFilSA1 + SF2->F2_CLIENT + SF2->F2_LOJENT))
			cCPEnt := SA1->A1_CEPE
			cDirEnt := Alltrim(SA1->A1_ENDENT)
			dbSelectArea("SYA")
			SYA->(dbSetOrder(1)) //YA_FILIAL + YA_CODGI
			If SYA->(dbSeek(xFilial("SYA") + SA1->A1_PAIS))
				cPaisEnt := SYA->YA_CODERP
			EndIf			
		EndIf
		
		//Transportadora
		dbSelectArea("SA4") 
		SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
		If SA4->(dbSeek(cFilSA4 + SF2->F2_TRANSP))
			cRUCTrans := Trim(SA4->A4_CGC)
			cDirTrans := Trim(SA4->A4_END)
			cCPTras   := SA4->A4_CEP
			cNomTrans := SA4->A4_NOME
			cModTras  := SA4->A4_TIPOTRA			
		EndIf
		
		//Transportadora
		dbSelectArea("SA4") 
		SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
		If SA4->(dbSeek(cFilSA4 + SF2->F2_TRANSP))
			cRUCTrans := Trim(SA4->A4_CGC)
			cDirTrans := Trim(SA4->A4_END)
			cCPTras   := SA4->A4_CEP
			cNomTrans := SA4->A4_NOME				
		EndIf		

		//Veh韈ulo
		dbSelectArea("DA3") 
		DA3->(dbSetOrder(1)) //DA3_FILIAL + DA3_COD
		If DA3->(dbSeek(cFilDA3 + SF2->F2_VEICULO))
			cMatVehi := Alltrim(DA3->DA3_PLACA)
			//Conductor
			dbSelectArea("DA4") 
			DA4->(dbSetOrder(1)) //DA4_FILIAL + DA4_COD
			If DA4->(dbSeek(cFilDA4 + DA3->DA3_MOTORI))
				cNoIdCond  := Alltrim(DA4->DA4_RG)
				cNomCondu  := Alltrim(DA4->DA4_PRNOME) + " " + Alltrim(DA4->DA4_SENOME)
				cApeCondu  := Alltrim(DA4->DA4_APATER) + " " + Alltrim(DA4->DA4_AMATER)
				cTpIdCond  := Alltrim(DA4->DA4_TIPOID)
			EndIf
		EndIf						

		aTransla := {cRUCTrans, cNomTrans, cModTras, cMotTras, cCPTras, cNoIdCond, cFecIniTra, cNomCondu, cApeCondu, cTpIdCond}
		
		//Datos de traslado  
		 M486XMLTRA(cNumDoc, cSerie, cCliente, cLoja, @aDetalle)
		 
		 //Documentos relacionados
		 aUUIDRel := StrTokArr(SF2->F2_UUIDREL, cCRLF) 
		 
		 For nI := 1 To Len(aUUIDRel)
		 	aAdd(aDocRel, StrTokArr(aUUIDRel[nI], "/"))
		 Next nI

		//Genera XML
		cXML := fGenXMLRNF(cCliente,cLoja,aEncab, aDetalle, aTransla)
	EndIf	
		
	RestArea(aArea)	
Return cXML

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � fGenXMLRNF � Autor � Dora Vega             � Data � 10.07.17 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Genera estructura XML para guia de remision de acuerdo al    潮�
北�          � al estandar UBL 2.1 (PERU)                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � fGenXMLRNF(cCliente,cLoja,aEncab,aDetalle, aTransla)         潮� 
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCliente .- Codigo del cliente.                              潮�
北�          � cLoja .- Codigo de la tienda del cliente.                    潮�
北�          � aEncab .- Arreglo con datos para encabezado de XML.          潮�
北�          � aDetalle .-  Arreglo con datos de detalle de guia de remision潮�
北�          � aTransla .- Arreglo con datos del Traslado.                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � cXML .- String con estructura de XML para guia de remision.  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � M486RNFXML                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function fGenXMLRNF(cCliente,cLoja,aEncab,aDetalle, aTransla)
	Local cXML  := ""
	Local nX     := 0
	Private lRSM := ALLTRIM(SuperGetMV("MV_PROVFE",,"")) == "RSM"
	
	cXML := '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + cCRLF
	cXML += '<DespatchAdvice' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#" ' + cCRLF 
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + cCRLF 
	cXML += '	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF 
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"' + cCRLF 
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF
	cXML += '	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF
	cXML += '	xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF
	cXML += '	xmlns="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2">' + cCRLF
  
	//Adicionales
	cXML += '	<ext:UBLExtensions>' + cCRLF
	If lRSM
		// Puntos de Entrada que son habiles solamente cuando se usa RSM
		If ExistBlock("M486EGR") 
			cXML += ExecBlock("M486EGR",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cCliente,cLoja})
		EndIf
	EndIf
	cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF  
	cXML += '		</ext:UBLExtension>' + cCRLF
	cXML += '	</ext:UBLExtensions>' + cCRLF	
    
    //Identificacion del Documento
    cXML += '	<cbc:UBLVersionID>2.1</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>1.0</cbc:CustomizationID>' + cCRLF
	cXML += '	<cbc:ID>' + aEncab[1] + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + aEncab[2] + '</cbc:IssueDate>' + cCRLF 
	cXML += '	<cbc:DespatchAdviceTypeCode>09</cbc:DespatchAdviceTypeCode>' + cCRLF 
//	cXML += '	<cbc:Note>' + Alltrim(aEncab[3]) + '</cbc:Note>' + cCRLF 

    //Documentos relacionados
    If Len(aDocRel) > 0
    	For nX := 1 To Len(aDocRel)
    		cXML += '	<cac:AdditionalDocumentReference>' + cCRLF
    		cXML += '		<cbc:ID>' + aDocRel[nX][2] + '</cbc:ID>' + cCRLF
    		cXML += '		<cbc:DocumentTypeCode>' + aDocRel[nX][1] + '</cbc:DocumentTypeCode>' + cCRLF
      		cXML += '	</cac:AdditionalDocumentReference>' + cCRLF
    	Next nX
    EndIf
	
	//Firma Electronica
	cXML += M486XmlFE()
	
	aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_ENDENT", "M0_CEPENT", "M0_CGC", "M0_NOME"} ) 
	
	//Emisor
	cXML += '	<cac:DespatchSupplierParty>' + cCRLF
	cXML += '		<cbc:CustomerAssignedAccountID schemeID="6">' + RTRIM(aDatosSM0[3][2]) + '</cbc:CustomerAssignedAccountID>' + cCRLF 
	cXML += '		<cac:Party>' + cCRLF
	cXML += '			<cac:PartyLegalEntity>' + cCRLF
	cXML += '				<cbc:RegistrationName><![CDATA[' + RTRIM(aDatosSM0[4][2]) + ']]></cbc:RegistrationName>' + cCRLF 
	cXML += '			</cac:PartyLegalEntity>' + cCRLF
	cXML += '		</cac:Party>' + cCRLF
	cXML += '	</cac:DespatchSupplierParty>' + cCRLF 
	
	//Receptor
	cXML += M486RECRNF(cCliente, cLoja) 
	
	//Datos de env韔
	cXML += '	<cac:Shipment>' + cCRLF
	cXML += '		<cbc:ID>01</cbc:ID>' + cCRLF 
	cXML += '		<cbc:HandlingCode>'+ Alltrim(aTransla[4]) +'</cbc:HandlingCode>' + cCRLF 
	cXML += '		<cbc:Information><![CDATA[' + Alltrim(ObtColSAT("S020",Alltrim(aTransla[4]),1,2,3,50)) + ']]></cbc:Information>' + cCRLF 
	cXML += '		<cbc:GrossWeightMeasure unitCode="KGM">'+ IIf(aEncab[3],Alltrim(Transform(aEncab[3],"999999.99")),"0.00") +'</cbc:GrossWeightMeasure>' + cCRLF
	If Alltrim(aTransla[4]) == "08" //Motivos Importaci髇
		cXML += '		<cbc:TotalTransportHandlingUnitQuantity>1</cbc:TotalTransportHandlingUnitQuantity>' + cCRLF
	EndIf 
	cXML += '		<cbc:SplitConsignmentIndicator>false</cbc:SplitConsignmentIndicator>' + cCRLF 
	cXML += '		<cac:ShipmentStage>' + cCRLF
	cXML += '			<cbc:ID>1</cbc:ID>' + cCRLF 
	cXML += '			<cbc:TransportModeCode>'+ Alltrim(aTransla[3]) +'</cbc:TransportModeCode>' + cCRLF 
	cXML += '			<cac:TransitPeriod>' + cCRLF
	cXML += '				<cbc:StartDate>' + Alltrim(aTransla[7]) + '</cbc:StartDate>' + cCRLF 
	cXML += '			</cac:TransitPeriod>' + cCRLF
	If Alltrim(aTransla[3]) == "01" //Transporte p鷅lico
		cXML += '			<cac:CarrierParty>' + cCRLF
		cXML += '				<cac:PartyIdentification>' + cCRLF
		cXML += '					 <cbc:ID schemeID="6">' + Alltrim(aTransla[1]) + '</cbc:ID>' + cCRLF 
		cXML += '				</cac:PartyIdentification>' + cCRLF
		cXML += '				<cac:PartyName>' + cCRLF
		cXML += '					 <cbc:Name><![CDATA[' + Alltrim(aTransla[2]) + ']]></cbc:Name>' + cCRLF 
		cXML += '				</cac:PartyName>' + cCRLF        
		cXML += '			</cac:CarrierParty> ' + cCRLF
	ElseIf Alltrim(aTransla[3]) == "02" //Transporte privado
		cXML += '			<cac:TransportMeans>' + cCRLF
		cXML += '				<cac:RoadTransport>' + cCRLF
		cXML += '					 <cbc:LicensePlateID>' + cMatVehi + '</cbc:LicensePlateID>' + cCRLF 
		cXML += '				</cac:RoadTransport>' + cCRLF 
		cXML += '			</cac:TransportMeans>' + cCRLF
		cXML += '			<cac:DriverPerson>' + cCRLF
		cXML += '				<cbc:ID schemeID="' + aTransla[10] + '">' + Alltrim(aTransla[6]) + '</cbc:ID>' + cCRLF 
		cXML += '				<cbc:FirstName>' + aTransla[8] + '</cbc:FirstName>' + cCRLF 
		cXML += '				<cbc:FamilyName>' + aTransla[9] + '</cbc:FamilyName>' + cCRLF 
		cXML += '			</cac:DriverPerson>' + cCRLF		
	EndIf		
	cXML += '		</cac:ShipmentStage>' + cCRLF
	
	//Direccion punto de llegada 	
	cXML += '		<cac:Delivery>' + cCRLF
	cXML += '			<cac:DeliveryAddress>' + cCRLF
		cXML += '			<cbc:ID>' + Alltrim(cCPEnt) + '</cbc:ID>' + cCRLF 
		cXML += '			<cbc:StreetName>' + Alltrim(cDirEnt) + '</cbc:StreetName>' + cCRLF 
		cXML += '			<cbc:CityName>' + Alltrim(ObtColSAT("S013",Alltrim(cCPEnt),1,6,7,50)) + '</cbc:CityName>' + cCRLF //Provincia
		cXML += '			<cbc:CountrySubentity>' + Alltrim(ObtColSAT("S013",Alltrim(cCPEnt),1,6,57,30)) + '</cbc:CountrySubentity>' + cCRLF //Departamento
		cXML += '			<cbc:District>' + Alltrim(ObtColSAT("S013",Alltrim(cCPEnt),1,6,87,30)) + '</cbc:District>' + cCRLF //Distrito
		cXML += '		    <cac:Country>' + cCRLF	
		cXML += '				<cbc:IdentificationCode>PE</cbc:IdentificationCode>' + cCRLF 
		cXML += '		    </cac:Country>' + cCRLF
	cXML += '			</cac:DeliveryAddress>' + cCRLF 
	cXML += '		</cac:Delivery>' + cCRLF
	
	//Direccion del punto de partida
    If Len(aDatosSM0) > 0
	    cXML += '		<cac:OriginAddress>' + cCRLF
		cXML += '			<cbc:ID>' + Alltrim(aDatosSM0[2][2]) + '</cbc:ID>' + cCRLF 
		cXML += '			<cbc:StreetName>' + Alltrim(aDatosSM0[1][2]) + '</cbc:StreetName>' + cCRLF 
		cXML += '			<cbc:CityName>' + Alltrim(ObtColSAT("S013",Alltrim(aDatosSM0[2][2]),1,6,7,50)) + '</cbc:CityName>' + cCRLF //Provincia
		cXML += '			<cbc:CountrySubentity>' + Alltrim(ObtColSAT("S013",Alltrim(aDatosSM0[2][2]),1,6,57,30)) + '</cbc:CountrySubentity>' + cCRLF //Departamento
		cXML += '			<cbc:District>' + Alltrim(ObtColSAT("S013",Alltrim(aDatosSM0[2][2]),1,6,87,30)) + '</cbc:District>' + cCRLF //Distrito
		cXML += '		    <cac:Country>' + cCRLF	
		cXML += '				<cbc:IdentificationCode>' + Alltrim(cPaisEnt) + '</cbc:IdentificationCode>' + cCRLF 
		cXML += '		    </cac:Country>' + cCRLF
		cXML += '		</cac:OriginAddress>' + cCRLF
		cXML += '	</cac:Shipment>' + cCRLF
	EndIf
	
    For nX :=1 To Len(aDetalle)
	    cXML += '	<cac:DespatchLine>' + cCRLF
		cXML += '		<cbc:ID>' + aDetalle[nX][1] + '</cbc:ID>' + cCRLF
		cXML += '		<cbc:DeliveredQuantity unitCode="'+ Alltrim(aDetalle[nX][3]) +'">' + Alltrim(Transform(aDetalle[nX][2],"9999999.99"))  + '</cbc:DeliveredQuantity>' + cCRLF
		cXML += '		<cac:OrderLineReference>' + cCRLF
		cXML += '			<cbc:LineID>' + aDetalle[nX][1] + '</cbc:LineID>' + cCRLF
		cXML += '		</cac:OrderLineReference>' + cCRLF
		cXML += '		<cac:Item>' + cCRLF
		cXML += '			<cbc:Name><![CDATA[' + Alltrim(aDetalle[nX][4] )+ ']]></cbc:Name>' + cCRLF
		cXML += '			<cac:SellersItemIdentification>' + cCRLF
		cXML += '				<cbc:ID>' + Alltrim(aDetalle[nX][5]) + '</cbc:ID>' + cCRLF
		cXML += '			</cac:SellersItemIdentification>' + cCRLF
		cXML += '		</cac:Item>' + cCRLF
	    cXML += '	</cac:DespatchLine>' + cCRLF
    Next nX

	cXML += '</DespatchAdvice>' + cCRLF

Return cXML

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � M486RECRNF � Autor � Dora Vega             � Data � 10.07.17 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Genera estructura de Receptor para XML de acuerdo al estandar潮�
北�          � UBL 2.1 (PERU)                                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � M486RECRNF(cCliente,cLoja)                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCliente .- Codigo del cliente.                              潮�
北�          � cLoja .- Codigo de la tienda del cliente.                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � cXMLRec .- Nodo de receptor para XML de estandar UBL 2.1     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � fGenXMLRNF                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function M486RECRNF(cCliente,cLoja)
	Local cXMLRec   := ""
	Local cCRLF	    := (chr(13)+chr(10))
	Local cFilSA1   := xFilial("SA1")
	Local aArea     := getArea()
	Local cTipDocId := ""
	Local cNoId     := ""
		
	//Receptor
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
	If SA1->(dbSeek(cFilSA1 + cCliente + cLoja)) 
		cTipDocId := Alltrim(SA1->A1_TIPDOC)
		If cTipDocId $ "6"
			cNoId := RTRIM(SA1->A1_CGC)
		Else
			cNoId := RTRIM(SA1->A1_PFISICA)
		EndIf			
		cXMLRec += '	<cac:DeliveryCustomerParty>' + cCRLF
		cXMLRec += '		<cbc:CustomerAssignedAccountID schemeID="'+ cTipDocId +'">' + RTRIM(cNoId) + '</cbc:CustomerAssignedAccountID>' + cCRLF
		cXMLRec += '		<cac:Party>' + cCRLF
		cXMLRec += '			<cac:PartyLegalEntity>' + cCRLF
		cXMLRec += '				<cbc:RegistrationName><![CDATA[' + RTRIM(SA1->A1_NOME) + ']]></cbc:RegistrationName>' + cCRLF 
		cXMLRec += '			</cac:PartyLegalEntity>' + cCRLF
		If lRSM .And. !Empty(SA1->A1_EMAIL)
			cXMLRec += '			<cac:Contact>' + cCRLF
			cXMLRec += '				<cbc:ElectronicMail><![CDATA[' + RTRIM(SA1->A1_EMAIL) + ']]></cbc:ElectronicMail>' + cCRLF 
			cXMLRec += '			</cac:Contact>' + cCRLF
		EndIf
		cXMLRec += '		</cac:Party>' + cCRLF
		cXMLRec += '	</cac:DeliveryCustomerParty>' + cCRLF	
	EndIf
	RestArea(aArea)
Return cXMLRec

/*/苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � M486XMLTRA � Autor � Dora Vega             � Data � 13/07/17 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砄btiene los datos del Traslado para la guia de remision.(PERU)潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � M486XMLTRA(cDoc, cSerie, cCliente, cLoja, aDetalle)          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cDoc .- Numero de documento.                                 潮�
北�          � cSerie .- Numero o Serie del Documento.                      潮�
北�          � cCliente .- Codigo del cliente.                              潮�
北�          � cLoja .- Codigo de la tienda del cliente.                    潮�
北�          � aDetalle .-  Arreglo con datos de detalle de guia de remision潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � Nil                                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � M486RNFXML                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌/*/
Static Function  M486XMLTRA(cDoc,cSerie,cCliente,cLoja,aDetalle)
	Local aArea     := getArea()
	Local cAliasXML := getNextAlias()	
	Local cUniMed   := ""
	Local cCampos   := ""
	Local cTablas   := ""	
	Local cCond     := ""
	
	cCampos  += "% SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_LOJA, SD2.D2_CLIENTE, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_PESO, "
	cCampos  += " SB1.B1_DESC, SB1.B1_UM, SD2.D2_PEDIDO, SD2.D2_ITEM %"
	cTablas  := "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SB1") + " SB1 %"
	cCond    := "% SD2.D2_DOC = '" + cDoc + "' AND SD2.D2_SERIE = '" + cSerie + "'"
	cCond    += " AND SD2.D2_CLIENTE = '" + cCliente + "' AND SD2.D2_LOJA = '" + cLoja + "'"
	cCond    += " AND SD2.D2_COD = SB1.B1_COD "
	cCond	 += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cCond	 += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cCond	 += " AND SB1.D_E_L_E_T_  = ' ' "
	cCond	 += " AND SD2.D_E_L_E_T_  = ' ' %"
		
	BeginSql alias cAliasXML
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
	EndSql	
	
	dbSelectArea(cAliasXML)

	(cAliasXML)->(DbGoTop())

	While (cAliasXML )->(!Eof())
		cUniMed := M486UNIMED((cAliasXML)->B1_UM)	
		aAdd(aDetalle,{(cAliasXML)->D2_ITEM,(cAliasXML)->D2_QUANT,cUniMed, (cAliasXML)->B1_DESC,(cAliasXML)->D2_COD})
		(cAliasXML)->(dbskip())
	EndDo	
	(cAliasXML)->(dbCloseArea())
	RestArea(aArea)
Return Nil
