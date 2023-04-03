#DEFINE CRLF chr(13)+chr(10)
#DEFINE LF chr(10)
#DEFINE cTitulo 		"Despacho Interno entre Bodegas (Semaforización)"
#DEFINE cTituloNF 		"Legalización Factura/Remisión en Ventas"
#DEFINE cPNGBAR 		"||!!|!¡¡||¨||¡¡!|!!!¡¡|||¨|||||"
#DEFINE cPNGLEGAL 		"LEYENDA"
#DEFINE AMARILLO 		"BR_AMARELO_OCEAN.PNG"
#DEFINE ROJO 			"BR_VERMELHO.PNG"
#DEFINE VERDE 			"BR_VERDE_OCEAN.PNG"
#DEFINE GRIS  			"BR_CINZA.PNG"
#DEFINE NEGRO 			"BR_PRETO.PNG"
#DEFINE MARRON 			"BR_MARROM.PNG"
#DEFINE BLANCO 			"BR_BRANCO.PNG"
#DEFINE AZUL 			"BR_AZUL_OCEAN.PNG"
#DEFINE ROSA			"BR_PINK.PNG"
#DEFINE NARANJA			"BR_LARANJA"
#DEFINE VERDE_C			"VERDE_OSCURO.PNG"
#DEFINE NEGRO           "BR_PRETO"


#DEFINE ESTADO_BLANCO	"1"  // cEstado1	:= '1' // Nuevo, Salida de Materia sin Ingreso aun						"ZX2_ESTADO = '1'",BLANCO 	, "Salida Almacen"
#DEFINE ESTADO_ROJO		"2"  // cEstado2	:= '2' // Ingreso, entrada de Materia, Entrada  Invalida SOBRA			"ZX2_ESTADO = '2'",ROJO		, "Entrada Invalida"
#DEFINE ESTADO_NARANJA	"3"  // cEstado3	:= '3' // Ingreso, entrada de Materia, Entrada, Faltan  Amarillo,     	"ZX2_ESTADO = '3'",NARANJA	, "Espera por Legalizar (Parcial)" 
#DEFINE ESTADO_AMARILLO	"4"  // cEstado3	:= '4' // Ingreso, entrada de Materia, Entrada  completa verde TIPO		"ZX2_ESTADO = '4'",AMARILLO	, "Espera por Legalizar (Parcial)" 
#DEFINE ESTADO_AZUL		"5"  // cEstado4	:= '5' // Ingreso, entrada de Materia, Legalizada Parcailmente			"ZX2_ESTADO = '5'",AZUL		, "Parcialmente Legalizada"
#DEFINE ESTADO_VERDE	"6"  // cEstado5	:= '6' // Legalizada Verde												"ZX2_ESTADO = '6'",VERDE	, "Legalizada"		
#DEFINE ESTADO_VERDEC	"7"  // cEstado5	:= '6' // Legalizada Verde
#DEFINE ESTADO_BLOCK_A	"8"  // cEstado5	:= '8' // Incio Legalizacion AMARILLA
#DEFINE ESTADO_BLOCK_B	"9"  // cEstado5	:= '8' // Incio Legalizacion NARANJA


#DEFINE TP_MOV_GRIS		"1"	 // Nueva Salida de Material
#DEFINE TP_MOV_VERDE	"2"	 // Salida y entrada de materia Cohinciden
#DEFINE TP_MOV_AMARILLO	"3"	 // La cantidad de Salida de Materia es Superior a la entrada
#DEFINE TP_MOV_ROJO		"4"  // La cantidad de Materia de Entrada es superrio a la de Salida

#DEFINE DOCUPRN			"Documento Origen"
#DEFINE DEFECHA 		"De Fecha "
#DEFINE AFECHA			"A Fecha "
#DEFINE DESERIEO		"Desde la Serie Origen"
#DEFINE ASERIE0			"Hasta la Serie Origen"
#DEFINE DESERIED		"Desde la Serie Destino"
#DEFINE ASERIED			"Hasta la Serie Destino"
#DEFINE DEDOCO			"Desde el Documento Origen"
#DEFINE ADOCO			"Hasta el Documento Origen"
#DEFINE DEDOCD			"Desde el Documento Destin"
#DEFINE ADOCD			"Hasta el Documento Destin"

#DEFINE DESERIE			"Desde la Serie Destino"
#DEFINE ASERIE			"Hasta la Serie Destino"
#DEFINE DEDOC			"Desde el Documento Origen"
#DEFINE ADOC			"Hasta el Documento Origen"

#DEFINE DEPROVE         "Del Proveedor"
#DEFINE APROVE          "Al Proveedor"
#DEFINE DETIENDA        "Desde la tienda"
#DEFINE ATIENDA         "Hasta la tienda"

#DEFINE DECLIENTE       "Del Cliente"
#DEFINE ACLIENTE        "Al Cliente"

#DEFINE DIRDESTINO		"Destino"

#DEFINE AcmePagina		"Página: "
#DEFINE AcmeTitRemE		"REMISION DE ENTRADA DE PRODUCTOS"
#DEFINE AcmeSerie		"Serie: "
#DEFINE AcmeNumRem		"Número: "
#DEFINE AcmeFechaEla	"Fecha Elaboración"
#DEFINE AcmeTelefo		"Teléfono: "
#DEFINE AcmePEDIDO		"Pédido: "
#DEFINE AcmeTitRemS		"FORMULARIO DE DESPACHO A CLIENTES"

#DEFINE AcmeHlpTtlResiduo	"Transferencia de Residuos"
#DEFINE AcmeHlpDetResiduo	"Esta opción es únicamente para documentos parcialmente Legalizados"
#DEFINE HelpAcme			"AYUDA"

#DEFINE AcmeHlpSinReg	"Sin Registros"
#DEFINE AcmeHlpSinReg1  "El usuario actual no tiene <B>Serie</B> asociada"
#DEFINE AcmeHlpSinReg2  "Comuniquese con el administrador de Números de Series Acme para asociar una serie a su perfil"
#DEFINE EstaDocTransf	"El Estado de este documento no permite realizar la tranferencia"

#DEFINE EstadoDocLegalVERDEC  	"Documento Parcialmente Legalizado, Residuo Transferido "
#DEFINE EstadoDocLegalVERDE  	"Documento Legalizado"
#DEFINE EstadoDocLegalAZUL	 	"Documento Parcialmente Legalizado, Residuo sin Transferir"
#DEFINE EstadoDocLegalAMARILLO	"Espera por Legalizar (Todos los productos, cantidades)"
#DEFINE EstadoDocLegalNARANJA	"Espera por Legalizar (Algunos Productos Faltantes en la entrada)"
#DEFINE EstadoDocLegalROJO		"Entrada Invalida (Las cantidades de entrada exceden en cantidad)"
#DEFINE EstadoDocLegalBLANCO	"Salida bodega"
#DEFINE EstadoDocLegalBLOCKA	"La Legalización AMARRILLA no completo el proceso"
#DEFINE EstadoDocLegalBLOCKB	"La Legalización NARANJA no completo el proceso"

#DEFINE EstadoNFRojo            "Sin Legalizar"
#DEFINE EstadoNFVerde           "Legalizado"

#DEFINE NFLEGAL		"Legalizado"
#DEFINE NFDFECHA 	"De Fecha "
#DEFINE NFAFECHA	"A Fecha "
#DEFINE NFDSERIE	"Desde la Serie"
#DEFINE NFASERIE	"Hasta la Serie"
#DEFINE NFDDOC		"Desde el Documento"
#DEFINE NFADOC		"Hasta el Documento"
#DEFINE NFDCLT		"Desde el Cliente"
#DEFINE NFACLT		"Hasta el Cliente"
#DEFINE NFDLOJA		"Desde la Tienda"
#DEFINE NFALOJA		"Hasta la Tienda"

