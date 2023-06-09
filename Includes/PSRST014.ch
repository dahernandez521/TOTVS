#ifdef SPANISH
	#define STR0001 "Detalle de la Situaci�n del Stock"
	#define STR0002 "Este informe emite la situaci�n de los saldos y la valuci�n "
	#define STR0003 "de cada producto en stock."
	#define STR0004 " "
	#define STR0005 " Por Producto       "
	#define STR0006 " Por Tipo           "
	#define STR0007 " Por Descripcion    "
	#define STR0008 " Por Grupo          "
	#define STR0009 " Por Almac�n        "
	#define STR0010 "A Rayas"
	#define STR0011 "Administracion"
	#define STR0012 "Seleccionando registros..."
	#define STR0013 "Organizando archivo..."
	#define STR0014 "CODIGO          TP GRUP DESCRIPCION           UM FL DEP.  SALDO       RESERVA PARA     STOCK         ____________VALOR ___________"
	#define STR0015 "                                                          EN STOCK    REQ/PV/RESERVA   DISPONIBLE       EN STOCK        RESERVADO "
	#define STR0016 "Total del "
	#define STR0017 "Tipo"
	#define STR0018 "Grupo"
	#define STR0019 "Total unidad medida  : "
	#define STR0020 "Total general: "
	#define STR0021 "ANULADO POR EL OPERADOR."
	#define STR0022 "Registro(s) procesado(s)"
	#define STR0023 ": Preparacion..."
	#define STR0024 "Costo Unificado"
	#define STR0025 "Con el parametro MV_CUSFIL activado se debe observar el completamiento de las siguintes preguntas:"
	#define STR0026 'Agrupa Por Deposito/Sucursal/Empresa? -> Pueden utilizarse solo las opciones "Sucursal" o "Empresa"'
	#define STR0027 'Deposito De? -> Solamente "**"'
	#define STR0028 'Deposito A? -> Solamente "**"'
	#define STR0029 'Orden de Impresion -> Todas, excepto "DEPOSITO"'
	#define STR0030 "Los parametros no estan debidamente configurados. �Imprime informe de esa Forma ?"
	#define STR0031 "Imprime"
	#define STR0032 "Cancela"
	#define STR0033 "Subtotal por Almac�n"
	#define STR0034 "    DESCRIPCION"
	#define STR0035 "    DE ALMACEN"
	#define STR0036 "CODIGO"
	#define STR0037 "TP"
	#define STR0038 "GRUP"
	#define STR0039 "DESCRIPCION"
	#define STR0040 "UM"
	#define STR0041 "SC"
	#define STR0042 "ALMC"
	#define STR0043 "SALDO"
	#define STR0044 "EN STOCK"
	#define STR0045 "RESERVA PARA"
	#define STR0046 "REQ/PV/RESERVA"
	#define STR0047 "STOCK"
	#define STR0048 "DISPONIBLE"
	#define STR0049 "VALOR"
	#define STR0050 "RESERVADO"
	#define STR0051 "DESCRIPCION"
	#define STR0052 "DEL ALMACEN"
	#define STR0053 "Saldos en Stock"
#else
	#ifdef ENGLISH
		#define STR0001 "Inventory Status Report"
		#define STR0002 "This report prints Balance and Reserve Status of each product in"
		#define STR0003 "Stock, and also the available Balance, that is, the differences "
		#define STR0004 "subtracted allocations."
		#define STR0005 " By Code            "
		#define STR0006 " By Type            "
		#define STR0007 " By Description     "
		#define STR0008 " By Group           "
		#define STR0009 " By Warehouse       "
		#define STR0010 "Z.Form "
		#define STR0011 "Management   "
		#define STR0012 "Selecting Records...     "
		#define STR0013 "Sorting File...       "
		#define STR0014 "CODE            TP GRP  DESCRIPTION           UM BC WRH   BALANCE     ALLOCATION TO      AVAILABLE     ____________VALUE ___________"
		#define STR0015 "                                                          IN STOCK    REQ/SO/RESERV.     STOCK            IN STOCK        ALLOCATED "
		#define STR0016 "Total of "
		#define STR0017 "Type"
		#define STR0018 "Group"
		#define STR0019 "Total Unit meas. : "
		#define STR0020 "Grand Total:"
		#define STR0021 "CANCELLED BY THE OPERATOR.  "
		#define STR0022 "Record(s) processed "
		#define STR0023 ": Preparation.."
		#define STR0024 "Unified Cost"
		#define STR0025 "When the parameter MV_CUSFIL is activated, the following questions filling are supposed to be observed:"
		#define STR0026 'Do you want to group per warehouse/branch/company? -> "Branch" or "Company" are the unique options to be used'
		#define STR0027 'From Warehouse? -> Only "**"'
		#define STR0028 'To Warehouse? -> Only "**"'
		#define STR0029 'Printing Order -> All, except "WAREHOUSE"'
		#define STR0030 "Parameters are not properly set up.Do you want to print the report anyway?"
		#define STR0031 "Print"
		#define STR0032 "Cancel"
		#define STR0033 "SubTotal by warehous"
		#define STR0034 "    DESCRIPT."
		#define STR0035 "  OF WAREHOUSE"
		#define STR0036 "CODE  "
		#define STR0037 "TP"
		#define STR0038 "GRP."
		#define STR0039 "DESCRIPT."
		#define STR0040 "UM"
		#define STR0041 "FL"
		#define STR0042 "WARH"
		#define STR0043 "BALAN"
		#define STR0044 "IN STOCK  "
		#define STR0045 "ALLOCAT. FOR"
		#define STR0046 "REQ/SO/RESERVE"
		#define STR0047 "STOCK"
		#define STR0048 "AVAILABLE "
		#define STR0049 "VALUE"
		#define STR0050 "ALLOCATED"
		#define STR0051 "DESCRIPT."
		#define STR0052 "OF WAREHOU"
		#define STR0053 "Balances in stock"
	#else
		Static STR0001 := "Relacao da Posicao do Estoque"
		Static STR0002 := "Este relatorio emite a posicao dos saldos e empenhos de cada  produto"
		#define STR0003  "em estoque. Ele tambem mostrara' o saldo disponivel ,ou seja ,o saldo"
		Static STR0004 := "subtraido dos empenhos."
		Static STR0005 := " Por Codigo         "
		Static STR0006 := " Por Tipo           "
		Static STR0007 := " Por Descricao      "
		Static STR0008 := " Por Grupo          "
		Static STR0009 := " Por Armazem        "
		Static STR0010 := "Zebrado"
		Static STR0011 := "Administracao"
		Static STR0012 := "Selecionando Registros..."
		Static STR0013 := "Organizando Arquivo..."
		Static STR0014 := "CODIGO          TP GRUP DESCRICAO             UM FL ARMZ  SALDO       EMPENHO PARA       ESTOQUE       ____________VALOR ___________"
		Static STR0015 := "                                                          EM ESTOQUE  REQ/PV/RESERVA     DISPONIVEL      EM ESTOQUE        EMPENHADO"
		#define STR0016  "Total do "
		#define STR0017  "Tipo"
		#define STR0018  "Grupo"
		Static STR0019 := "Total Unidade Medida : "
		Static STR0020 := "Total Geral : "
		Static STR0021 := "CANCELADO PELO OPERADOR."
		Static STR0022 := "Registro(s) processado(s)"
		Static STR0023 := ": Preparacao..."
		#define STR0024  "Custo Unificado"
		Static STR0025 := "Com o parametro MV_CUSFIL ativado o preenchimento das seguintes perguntas deve ser observado:"
		Static STR0026 := 'Aglutina Por Almoxarifado/Filial/Empresa? -> Somente podem ser utilizadas as opcoes "Filial" ou "Empresa"'
		Static STR0027 := 'Armazem De? -> Somente "**"'
		Static STR0028 := 'Armazem Ate? -> Somente "**"'
		Static STR0029 := 'Ordem de Impressao -> Todas, exceto "ARMAZEM"'
		Static STR0030 := "Os parametros nao estao devidamente configurados. Imprime relatorio dessa forma ?"
		Static STR0031 := "Imprime"
		#define STR0032  "Cancela"
		Static STR0033 := "SubTotal por Armazem"
		Static STR0034 := "    DESCRICAO"
		Static STR0035 := "    DO ARMAZEM"
		Static STR0036 := "CODIGO"
		Static STR0037 := "TP"
		Static STR0038 := "GRUP"
		Static STR0039 := "DESCRI��O"
		Static STR0040 := "UM"
		Static STR0041 := "FL"
		Static STR0042 := "ARMZ"
		Static STR0043 := "SALDO"
		Static STR0044 := "EM ESTOQUE"
		Static STR0045 := "EMPENHO PARA"
		Static STR0046 := "REQ/PV/RESERVA"
		Static STR0047 := "ESTOQUE"
		Static STR0048 := "DISPONIVEL"
		Static STR0049 := "VALOR"
		Static STR0050 := "EMPENHADO"
		Static STR0051 := "DESCRI��O"
		Static STR0052 := "DO ARMAZEM"
		Static STR0053 := "Saldos em Estoque"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0001 := "Rela��o Da Posi��o Do Stock"
			STR0002 := "Este relat�rio emite a posi��o dos saldos e aloca��es de cada  produto"
			STR0004 := "Subtra�do das aloca��es."
			STR0005 := " por c�digo         "
			STR0006 := " por tipo           "
			STR0007 := " por descri��o      "
			STR0008 := " por grupo          "
			STR0009 := " por armaz�m        "
			STR0010 := "C�digo de barras"
			STR0011 := "Administra��o"
			STR0012 := "A Seleccionar Registos..."
			STR0013 := "A Organizar Ficheiro..."
			STR0014 := "C�digo          tp grup descri��o             um fl armz  saldo       aloca��o para       stock       ____________valor ___________"
			STR0015 := "                                                          Em Stock  Req/pv/reserva     Dispon�vel      Em Stock        Alocado"
			STR0019 := "Total unidade medida : "
			STR0020 := "Total crial : "
			STR0021 := "Cancelado Pelo Operador."
			STR0022 := "Registo(s) processado(s)"
			STR0023 := ": Prepara��o..."
			STR0025 := "Com o par�metro mv_cusfil activado o preenchimento das seguintes perguntas deve ser observado:"
			STR0026 := 'aGlutina por almoxarifado/filial/empresa? -> somente podem ser utilizadas as op��es "filial" ou "empresa"'
			STR0027 := 'aRmaz�m de? -> somente "**"'
			STR0028 := 'aRmaz�m ate? -> somente "**"'
			STR0029 := 'oRdem de impress�o -> todas, exceto "armaz�m"'
			STR0030 := "Os par�metros n�o est�o devidamente configurados. imprimir relat�rio assim mesmo ?"
			STR0031 := "Imprimir"
			STR0033 := "Subtotal Por Armaz�m"
			STR0034 := "    Descri��o"
			STR0035 := "    Do Armaz�m"
			STR0036 := "C�digo"
			STR0037 := "Tp."
			STR0038 := "Grup"
			STR0039 := "Descri��o"
			STR0040 := "Um"
			STR0041 := "Fl"
			STR0042 := "Armz"
			STR0043 := "Saldo"
			STR0044 := "Em Stock"
			STR0045 := "Aloca��o Para"
			STR0046 := "Req/pv/reserva"
			STR0047 := "Stock"
			STR0048 := "Dispon�vel"
			STR0049 := "Valor"
			STR0050 := "Empenhado"
			STR0051 := "Descri��o"
			STR0052 := "Do Armaz�m"
			STR0053 := "Saldos Em Stock"
		ElseIf cPaisLoc == "PTG"
			STR0001 := "Rela��o Da Posi��o Do Stock"
			STR0002 := "Este relat�rio emite a posi��o dos saldos e aloca��es de cada  produto"
			STR0004 := "Subtra�do das aloca��es."
			STR0005 := " por c�digo         "
			STR0006 := " por tipo           "
			STR0007 := " por descri��o      "
			STR0008 := " por grupo          "
			STR0009 := " por armaz�m        "
			STR0010 := "C�digo de barras"
			STR0011 := "Administra��o"
			STR0012 := "A Seleccionar Registos..."
			STR0013 := "A Organizar Ficheiro..."
			STR0014 := "C�digo          tp grup descri��o             um fl armz  saldo       aloca��o para       stock       ____________valor ___________"
			STR0015 := "                                                          Em Stock  Req/pv/reserva     Dispon�vel      Em Stock        Alocado"
			STR0019 := "Total unidade medida : "
			STR0020 := "Total crial : "
			STR0021 := "Cancelado Pelo Operador."
			STR0022 := "Registo(s) processado(s)"
			STR0023 := ": Prepara��o..."
			STR0025 := "Com o par�metro mv_cusfil activado o preenchimento das seguintes perguntas deve ser observado:"
			STR0026 := 'aGlutina por almoxarifado/filial/empresa? -> somente podem ser utilizadas as op��es "filial" ou "empresa"'
			STR0027 := 'aRmaz�m de? -> somente "**"'
			STR0028 := 'aRmaz�m ate? -> somente "**"'
			STR0029 := 'oRdem de impress�o -> todas, exceto "armaz�m"'
			STR0030 := "Os par�metros n�o est�o devidamente configurados. imprimir relat�rio assim mesmo ?"
			STR0031 := "Imprimir"
			STR0033 := "Subtotal Por Armaz�m"
			STR0034 := "    Descri��o"
			STR0035 := "    Do Armaz�m"
			STR0036 := "C�digo"
			STR0037 := "Tp."
			STR0038 := "Grup"
			STR0039 := "Descri��o"
			STR0040 := "Um"
			STR0041 := "Fl"
			STR0042 := "Armz"
			STR0043 := "Saldo"
			STR0044 := "Em Stock"
			STR0045 := "Aloca��o Para"
			STR0046 := "Req/pv/reserva"
			STR0047 := "Stock"
			STR0048 := "Dispon�vel"
			STR0049 := "Valor"
			STR0050 := "Empenhado"
			STR0051 := "Descri��o"
			STR0052 := "Do Armaz�m"
			STR0053 := "Saldos Em Stock"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
