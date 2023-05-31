#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STHWMS00  ºAutor  ³Percy Arias,SISTHEL º Data ³  07/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pre Lanzamientos de RA                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function STHWMS00()

	local clAlias	:= "ZZZ"
	Local aCores	:=	{	{ "ZZZ->ZZZ_STATUS='0'"		, 'ENABLE'		},;
							{ "ZZZ->ZZZ_STATUS='1'"		, 'DISABLE'		},;
							{ "ZZZ->ZZZ_STATUS='2'"		, 'BR_AZUL'		}}

	private cCadastro 	:= "Seriales Masivos"
	private aRotina := {	{ "Buscar"		,	"AxPesqui"		,0,1} ,;
							{ "Visualizar"	,	"AxVisual"		,0,2} ,;
	             		 	{ "Incluir"		,	"AxInclui"		,0,3} ,;
	             		 	{ "Modificar"	,	"AxAltera"		,0,4} ,;
 	             		 	{ "Borrar"		,	"AxDeleta"		,0,5} ,;
 	             		 	{ "Leyenda"		,	"u_STHLEY00"	,0,6};
                        }

	dbSelectArea( clAlias )
	dbSetOrder(1)
	dbGoTop()
	
	mBrowse( 6, 1,22,75,clAlias,,,,,,aCores)

Return

User Function STHLEY00()
     
    local _xArea := getArea()
	local aLegenda := {}

	aAdd(aLegenda,{"ENABLE" 	,"Pendiente de Ubicar"})
	aAdd(aLegenda,{"DISABLE"	,"Finalizado"})
	aAdd(aLegenda,{"BR_AZUL"	,"Ubicado"})

	BrwLegenda("Ubicaiones","Leyenda", aLegenda )
	
	RestArea(_xArea)

Return
