#Include "Rwmake.ch"
#Include "Protheus.ch"

// PE despues de gravar

User Function A175CQ

    local nX            := 0
    local _aItensSDB    := {}
    local aCabSDA       := {}
    local aItSDB        := {}
    local _zAlias       := getNextAlias()
    local nitem         := 1

    Private lMsErroAuto := .f.

	// DB_FILIAL, DB_PRODUTO, DB_LOCAL, DB_NUMSEQ, DB_DOC, DB_SERIE, DB_CLIFOR, DB_LOJA, DB_ITEM
	sql := "SELECT MAX(DB_ITEM) AS ITEM"
	sql += "  FROM " + RetSqlName("SDB")
	sql += " WHERE DB_FILIAL='" + xFilial("SDB") + "'"
	sql += "   AND DB_PRODUTO='"+SD7->D7_PRODUTO+"'"
	sql += "   AND DB_LOCAL='"+SD7->D7_LOCAL+"'"
	sql += "   AND DB_NUMSEQ='"+SD7->D7_NUMSEQ+"'"
	sql += "   AND DB_DOC='"+SD7->D7_DOC+"'"
	sql += "   AND DB_SERIE='"+SD7->D7_SERIE+"'"
	sql += "   AND DB_CLIFOR='"+SD7->D7_FORNECE+"'"
	sql += "   AND DB_LOJA='"+SD7->D7_LOJA+"'"
	sql += "   AND D_E_L_E_T_=' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_zAlias,.T.,.T.) 

	If (_zAlias)->(!EOF())
		nitem := VAL((_zAlias)->ITEM)+1
	Endif

    (_zAlias)->( DBCloseArea() )
    
    For nX := 1 to Len(aCols)

        If aCols[nX][2]==1

            _aItensSDB := {}
            aCabSDA := {}
            aItSDB := {}

            aCabSDA	:=	{	{"DA_PRODUTO"	, SD7->D7_PRODUTO       ,Nil },;
                            {"DA_NUMSEQ"	, SD7->D7_NUMSEQ	    ,Nil };
                        }

            aItSDB	:= {	{"DB_ITEM"		, strzero(nitem,tamSX3("DB_ITEM")[1])	,Nil	},;
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
                nitem++
                MsgAlert("Processamento Ok!","TOTVS")
            Endif

        endif

    next nX

Return
