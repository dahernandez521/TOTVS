#Include "Rwmake.ch"
#Include "Protheus.ch"

// PE despues de gravar

User Function A175CQ

    local nX            := 0
    local _aItensSDB    := {}
    local aCabSDA       := {}
    local aItSDB        := {}
    local _aTotItem     := {}
    local _aItem        := {}
    local _aCabec       := {}
    local cCodigoTM     := getNewpar("ST_TIPMOV","001")
    local nz            := 1

    Private lMsErroAuto := .f.
    
    For nX := 1 to Len(aCols)

        If aCols[nX][2]==1

            _aItem := {}

			if nz==1

                nz++
                cCorrel := GetSxeNum("SD3","D3_DOC")

				_aCabec := {	{"D3_TM"		,cCodigoTM		, NIL},;
								{"D3_DOC"		,cCorrel		, NIL},;
								{"D3_EMISSAO"	,dDatabase		, NIL}} 
			endif

			_aItem := {		{"D3_FILIAL"	,xFilial("SD3")		 					,NIL},;
							{"D3_COD"		,SD7->D7_PRODUTO						,NIL},;
							{"D3_QUANT"		,aCols[nX][4]							,NIL},;
							{"D3_LOCAL"		,aCols[nX][10]							,NIL},;
							{"D3_DTLANC"	,dDatabase								,NIL},;
							{"D3_LOCALIZ"	,aCols[nX][17]							,NIL},;
                            {"D3_NUMSERI"	,aCols[nX][18]      					,Nil}};
										
			Aadd( _aTotItem, _aItem )
		
		endif
		
	Next i

	lMsErroAuto := .f.

	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCabec,_aTotItem,3 )

	If lMsErroAuto
		Mostraerro() 
	else
		APMSGINFO("Procesamirneo COncluido", "SISTHEL")
	EndIf



            //CriaSDA(cAlias,nQuant,NIL,NIL,nQuant2UM,lApropri)
            
/*             _aItensSDB := {}
            aCabSDA := {}
            aItSDB := {}

            aCabSDA	:=	{	{"DA_PRODUTO"	, SD7->D7_PRODUTO       ,Nil },;
                            {"DA_LOCAL"		, SD7->D7_LOCAL         ,Nil },;
                            {"DA_QTDORI"	, SD7->D7_SALDO         ,Nil },;
                            {"DA_SALDO"		, SD7->D7_SALDO         ,Nil },;
                            {"DA_DATA"		, dDataBase             ,Nil },;
                            {"DA_DOC"		, SD7->D7_DOC           ,Nil },;
                            {"DA_SERIE"		, SD7->D7_SERIE         ,Nil },;
                            {"DA_CLIFOR"	, SD7->D7_FORNECE       ,Nil },;
                            {"DA_LOJA"		, SD7->D7_LOJA          ,Nil },;
                            {"DA_NUMSEQ"	, SD7->D7_NUMSEQ	    ,Nil };
                        }

            aItSDB	:= {	{"DB_ITEM"		, strzero(nX,tamSX3("DB_ITEM")[1])	    ,Nil	},;
                            {"DB_PRODUTO"	, SD7->D7_PRODUTO   					,Nil	},;
                            {"DB_LOCAL"		, aCols[nX][10]     					,Nil	},;
                            {"DB_LOCALIZ"	, aCols[nX][17]     					,Nil	},;
                            {"DB_DATA"		, dDataBase								,Nil	},;
                            {"DB_QUANT"		, aCols[nX][4]       					,Nil	},;
                            {"DB_NUMSERI"	, aCols[nX][18]      					,Nil	};
                        }
                    
            aadd(_aItensSDB,aitSDB)

            MATA265( aCabSDA, _aItensSDB, 3)
            If lMsErroAuto
                MostraErro()
            Else
                MsgAlert("Processamento Ok!","TOTVS")
            Endif
 */        

Return
