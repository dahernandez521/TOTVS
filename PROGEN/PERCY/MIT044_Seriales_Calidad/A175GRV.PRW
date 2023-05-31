#Include "Rwmake.ch"
#Include "Protheus.ch"

// PE despues de gravar

User Function A175GRV

    local _aItensSDB    := {}
    local aCabSDA       := {}
    local aItSDB        := {}
    local nitem         := 1
    local _zAlias       := getNextAlias()

    Private lMsErroAuto := .f.

	// DB_FILIAL, DB_PRODUTO, DB_LOCAL, DB_NUMSEQ, DB_DOC, DB_SERIE, DB_CLIFOR, DB_LOJA, DB_ITEM

    SDA->( dbSetOrder(1) )
    
    sql := "SELECT D7_SEQ,D7_PRODUTO,D7_TIPO,D7_QTDE,D7_NUMSEQ,D7_LOCDEST,D7_NUMERO,"
    sql += "       D7_DOC,D7_SERIE,D7_FORNECE,D7_LOJA,D7_LOCALIZ,D7_NUMSERI,R_E_C_N_O_ AS ID"
    sql += "  FROM " + RetSqlName("SD7")
    sql += " WHERE D7_FILIAL='" + xFilial("SD7") + "'"
    sql += "   AND D7_PRODUTO='"+SD7->D7_PRODUTO+"'"
    sql += "   AND D7_LOCDEST='"+SD7->D7_LOCDEST+"'"
    sql += "   AND D7_DOC='"+SD7->D7_DOC+"'"
    sql += "   AND D7_SERIE='"+SD7->D7_SERIE+"'"
    sql += "   AND D7_NUMERO='"+SD7->D7_NUMERO+"'"
    sql += "   AND D7_FORNECE='"+SD7->D7_FORNECE+"'"
    sql += "   AND D7_LOJA='"+SD7->D7_LOJA+"'"
    sql += "   AND D_E_L_E_T_=' '"
    sql += "   AND D7_TIPO='1'"
    sql += " ORDER BY D7_SEQ"

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,sql),_zAlias,.T.,.T.) 

    If (_zAlias)->(!EOF())

        vnum := 1
    
        while (_zAlias)->(!EOF())

            SD7->( dbgoto( (_zAlias)->ID ) )

            cproduto    := SD7->D7_PRODUTO
            clocal      := SD7->D7_LOCDEST
            cnumseq     := SD7->D7_NUMSEQ
            cdoc        := SD7->D7_NUMERO
            cserie      := SD7->D7_SERIE
            cproveedor  := SD7->D7_FORNECE
            cloja       := SD7->D7_LOJA

            //if SDA->( MsSeek( xFilial("SDA")+cproduto+clocal+cnumseq+cdoc+cserie+cproveedor+cloja ) )
            if SDA->( MsSeek( xFilial("SDA")+cproduto+clocal+cnumseq+cdoc+cserie ) )

                if SDA->DA_SALDO > 0

                    cNumSerie := SD7->D7_NUMSERI
                    //if empty(cNumSerie)
                    //    cNumSerie := "V"+strzero(vnum,3)
                    //    vnum++
                    //endif

                    nitem := 1

                    _aItensSDB := {}
                    aCabSDA := {}
                    aItSDB := {}

                    aCabSDA	:=	{	{"DA_PRODUTO"	, SD7->D7_PRODUTO       ,Nil },;
                                    {"DA_NUMSEQ"	, SD7->D7_NUMSEQ	    ,Nil };
                                }

                    aItSDB	:= {	{"DB_ITEM"		, strzero(nitem,tamSX3("DB_ITEM")[1])	,Nil	},;
                                    {"DB_PRODUTO"	, SD7->D7_PRODUTO   					,Nil	},;
                                    {"DB_LOCAL"		, SD7->D7_LOCDEST     					,Nil	},;
                                    {"DB_LOCALIZ"	, SD7->D7_LOCALIZ     					,Nil	},;
                                    {"DB_DATA"		, dDataBase								,Nil	},;
                                    {"DB_QUANT"		, SD7->D7_QTDE       					,Nil	},;
                                    {"DB_NUMSERI"	, cNumSerie           					,Nil	};
                                }
                            
                    aadd(_aItensSDB,aitSDB)

                    MATA265( aCabSDA, _aItensSDB, 3)
                    If lMsErroAuto
                        MostraErro()
                    Else
                        //MsgAlert("Processamento Ok!","TOTVS")
                    Endif

                endif

            endif

            (_zAlias)->( DBSkip() )

        enddo

    endif

    (_zAlias)->( DBCloseArea() )

Return
