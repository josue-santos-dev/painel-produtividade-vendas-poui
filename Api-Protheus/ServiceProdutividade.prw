#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"

WSRESTFUL serviceProdutividade DESCRIPTION "API de integração da Produtividade dos Vendedores" FORMAT "application/json,text/html"

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL
	WSDATA search       AS STRING  OPTIONAL
	WSDATA periodo      AS STRING  OPTIONAL
	WSDATA status       AS STRING  OPTIONAL
	WSDATA cod_vendedor AS STRING  OPTIONAL

	WSMETHOD GET ListProdutividade;
		DESCRIPTION "Retorna lista de Produtividade dos vendedores";
		WSSYNTAX "Produtividade";
		PATH "Produtividade";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET PercentualPositivados;
		DESCRIPTION "Retorna os percentuais de positivação do Período para o DashBoard de Produtividade";
		WSSYNTAX "PercPositivados";
		PATH "PercPositivados";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET PeriodosGerados;
		DESCRIPTION "Retorna os períodos gerados até o Mês/Ano atual ";
		WSSYNTAX "PeriodosGerados";
		PATH "PeriodosGerados";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET QuantidadesPeriodo;
		DESCRIPTION "Retorna as quantidades geradas referentes ao período atual";
		WSSYNTAX "Quantidades";
		PATH "Quantidades";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET PercSupervisor;
		DESCRIPTION "Retorna os percentuais de positivação por supervisor do Período";
		WSSYNTAX "PercSupervisor";
		PATH "PercSupervisor";
		PRODUCES APPLICATION_JSON;


END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListProdutividade
Método GET para listar a Produtividade dos Vendedores
@author Josué Barbosa
@since 04/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET ListProdutividade QUERYPARAM Page WSREST serviceProdutividade
Return getListProdutividade(self)

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getListProdutividade
Função para tratamento da requisição GET
@author Josué Barbosa
@since 04/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getListProdutividade( oWS )

	Local lRet  := .T.
	Local oProdut

	DEFAULT oWS:page         := 1
	DEFAULT oWS:pageSize     := 10
	DEFAULT oWS:search       := ""
	DEFAULT oWS:periodo      := ""
	DEFAULT oWS:cod_vendedor := ""
	DEFAULT oWS:status       := ""

	//ProdutAdapter será nossa classe que implementa fornecer os dados para o WS
	// O primeiro parametro indica que iremos tratar o método GET
	oProdut := ProdutAdapter():new( 'GET' )

	//o método setPage indica qual página deveremos retornar
	//ex.: nossa consulta tem como resultado 100 produtos, e retornamos sempre uma listagem de 10 itens por página.
	// a página 1 retorna os itens de 1 a 10
	// a página 2 retorna os itens de 11 a 20
	// e assim até chegar ao final de nossa listagem de 100 produtos
	oProdut:setPage(oWS:page)
	// setPageSize indica que nossa página terá no máximo 10 itens
	oProdut:setPageSize(oWS:pageSize)
	// Esse método irá processar as informações
	oProdut:GetListProdutividade(oWS:search,oWS:periodo,oWS:cod_vendedor,oWS:status)
	//Se tudo ocorreu bem, retorna os dados via Json
	If oProdut:lOk
		cRet := AjustaJson(oProdut:getJSONResponse())
		oWS:SetResponse(cRet)
	Else
		//Ou retorna o erro encontrado durante o processamento
		SetRestFault(oProdut:GetCode(),oProdut:GetMessage())
		lRet := .F.
	EndIf
	//faz a desalocação de objetos e arrays utilizados
	oProdut:DeActivate()
	oProdut := nil

Return lRet

/*/{Protheus.doc} ProdutAdapter
    (long_description)
    @author Josué Barbosa
    @since 04/02/2023
    @version 1.0
    /*/

	CLASS ProdutAdapter FROM FwAdapterBaseV2

		METHOD New()
		METHOD GetListProdutividade()

	ENDCLASS

Method New( cVerb ) Class ProdutAdapter
	_Super:New( cVerb, .T.)
Return

Method GetListProdutividade(_cSearch,_cPeriodo,_cVendedor,_cStatus ) Class ProdutAdapter

	Local aArea 	AS ARRAY
	Local cWhere	AS CHAR

	aArea   := FwGetArea()

	//Adiciona o mapa de campos Json/ResultSet
	AddMapFields( self, "GetListProdutividade" )

	//Informa a Query a ser utilizada pela API
	::SetQuery( GetQuery("GetListProdutividade") )

	//Informa a clausula Where da Query
	cWhere := " ZP1.D_E_L_E_T_ <> '*' "

	If !Empty(_cSearch)

		cWhere += " AND ( "
		cWhere += " ZP1_PERIOD LIKE	'%"+Alltrim(_cSearch)+"%' OR	"
		cWhere += " ZP1_VEND   LIKE	'%"+Alltrim(_cSearch)+"%' OR	"
		cWhere += " ZP1_NOME LIKE	'%"+Alltrim(_cSearch)+"%'		    "
		cWhere += " ) "

	Endif

	If !Empty(_cPeriodo)
		cWhere += " AND ZP1_PERIOD IN "+FormatIn(_cPeriodo,",")
	Endif

	If !Empty(_cVendedor)
		cWhere += " AND ZP1_VEND IN "+FormatIn(_cVendedor,",")
	Endif

	If !Empty(_cStatus)
		cWhere += " AND ZP1_STATUS IN "+FormatIn(_cStatus,",")
	Endif

	::SetWhere( cWhere )

	//Informa a ordenação a ser Utilizada pela Query
	::SetOrder( "ZP1_PERIOD" )

	//Executa a consulta, se retornar .T. tudo ocorreu conforme esperado
	If ::Execute()
		// Gera o arquivo Json com o retorno da Query
		::FillGetResponse()
	EndIf

	FwrestArea(aArea)

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AddMapFields
Função para geração do mapa de campos
@param oSelf, object, Objeto da prórpia classe
@author  Josué barbosa
@since   04/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddMapFields( oSelf, _cMetodo )

	If _cMetodo == "GetListProdutividade"

		oSelf:AddMapFields( 'PERIODO'               , 'ZP1_PERIOD'  , .T., .T., { 'ZP1_PERIOD'   , 'C', TamSX3( 'ZP1_PERIOD' )[1], 0 } )
		oSelf:AddMapFields( 'COD_VENDEDOR'	        , 'ZP1_VEND'    , .T., .F., { 'ZP1_VEND'     , 'C', TamSX3( 'ZP1_VEND' )[1], 0 } )
		oSelf:AddMapFields( 'NOME_VENDEDOR'	        , 'ZP1_NOME'    , .T., .F., { 'ZP1_NOME'     , 'C', TamSX3( 'ZP1_NOME' )[1], 0 } )
		oSelf:AddMapFields( 'QTD_CLIENTES'	        , 'ZP1_QTDCLI'  , .T., .F., { 'ZP1_QTDCLI'   , 'N', TamSX3( 'ZP1_QTDCLI' )[1], TamSX3( 'ZP1_QTDCLI' )[2] } )
		oSelf:AddMapFields( 'QTD_POSITIVADOS'	      , 'ZP1_POSITV'  , .T., .F., { 'ZP1_POSITV'   , 'N', TamSX3( 'ZP1_POSITV' )[1], TamSX3( 'ZP1_POSITV' )[2] } )
		oSelf:AddMapFields( 'QTD_NPOSITIVADOS'      , 'ZP1_NPOSIT'  , .T., .F., { 'ZP1_NPOSIT'   , 'N', TamSX3( 'ZP1_NPOSIT' )[1], TamSX3( 'ZP1_NPOSIT' )[2] } )
		oSelf:AddMapFields( 'QTD_NOVOS_CLIENTES'    , 'ZP1_NOVCLI'  , .T., .F., { 'ZP1_NOVCLI'   , 'N', TamSX3( 'ZP1_NOVCLI' )[1], TamSX3( 'ZP1_NOVCLI' )[2] } )
		oSelf:AddMapFields( 'QTD_CLIENTES_ATIVOS'   , 'ZP1_QCLATV'  , .T., .F., { 'ZP1_QCLATV'   , 'N', TamSX3( 'ZP1_QCLATV' )[1], TamSX3( 'ZP1_QCLATV' )[2] } )
		oSelf:AddMapFields( 'QTD_CLIENTES_INATIVOS' , 'ZP1_QCLINA'  , .T., .F., { 'ZP1_QCLINA'   , 'N', TamSX3( 'ZP1_QCLINA' )[1], TamSX3( 'ZP1_QCLINA' )[2] } )
		oSelf:AddMapFields( 'STATUS'                , 'ZP1_STATUS'  , .T., .F., { 'ZP1_STATUS'   , 'C', TamSX3( 'ZP1_STATUS' )[1], 0 } )

	Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Retorna a query usada no serviço
@param oSelf, object, Objeto da prórpia classe
@author  Josué Barbosa
@since   10/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetQuery(_cMetodo)

	Local cQuery := ""

	If _cMetodo == "GetListProdutividade"

		cQuery := " SELECT #QueryFields#"
		cQuery +=   " FROM "+RetSqlname("ZP1")+" ZP1 "
		cQuery += " WHERE #QueryWhere#"

	Endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET PercentualPositivados
Método GET para retorno de produtividade do período (%)
@author Josué Barbosa
@since 29/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
	WSMETHOD GET PercentualPositivados WSRECEIVE periodo WSREST serviceProdutividade

	Local ojResponse   := JsonObject():New()
	Local oJsonSeries  := JsonObject():New()
	Local aJsonSeries  := {}
	Local nPercP       := 0
	Local nPercN       := 0

	Default ::periodo := Left(DTOS(Date()),6)

	cTabQry := GetNextAlias()

	xPeriodo := ::periodo

	cQuery := " SELECT ZP1_PERIOD AS PERIODO,                "
	cQuery += "        SUM(ZP1_QTDCLI) AS TOTAL_CLIENTE,     "
	cQuery += "        SUM(ZP1_POSITV) AS TOTAL_POSITIVADO,  "
	cQuery += "        SUM(ZP1_NPOSIT) AS TOTAL_N_POSITIVADO "
	cQuery += " FROM "+RetSqlName("ZP1")
	cQuery += " WHERE ZP1_PERIOD = '"+xPeriodo+"'            "
	cQuery += "   AND D_E_L_E_T_ <> '*'                  "
	cQuery += " GROUP BY ZP1_PERIOD                          "

	oState := FWPreparedStatement():New()
	oState:SetQuery(cQuery)

	MPSysOpenQuery(cQuery,cTabQry)
	oState:Destroy()

	While (cTabQry)->(!EOF())

		If (cTabQry)->TOTAL_POSITIVADO > (cTabQry)->TOTAL_N_POSITIVADO
			nPercP := Round((((cTabQry)->TOTAL_POSITIVADO / (cTabQry)->TOTAL_CLIENTE) * 100),2)
			nPercN := 100 - nPercP
		Else
			nPercN := Round((((cTabQry)->TOTAL_N_POSITIVADO / (cTabQry)->TOTAL_CLIENTE) * 100),2)
			nPercP := 100 - nPercN
		Endif


		(cTabQry)->(DbSkip())

	End

	(cTabQry)->(DbCloseArea())

	//Define o Título do Gráfico
	ojResponse["title"] := "% Positivação do Período - "+MesExtenso(STOD(xPeriodo+"01"))+"/"+Left(xPeriodo,4)

	oJsonSeries['label']   := "Positivados"
	oJsonSeries['data']    := nPercP
	oJsonSeries['tooltip'] := "% de clientes positivados no período"

	aAdd(aJsonSeries, oJsonSeries)
	oJsonSeries := JsonObject():New()

	oJsonSeries['label'] := 'Não Positivados'
	oJsonSeries['data']  := nPercN
	oJsonSeries['tooltip'] := "% de clientes 'Não' positivados no período"

	aAdd(aJsonSeries, oJsonSeries)

	ojResponse["series"] := aJsonSeries

	cJson := ojResponse:ToJson()

	//::SetContentType("application/json")
	::SetContentType("application/json; charset=iso-8859-1")
	::SetResponse(cJson)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET PercSupervisor
Método GET para retorno de positivação por supervisor
@author Josué Barbosa
@since 29/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
	WSMETHOD GET PercSupervisor WSRECEIVE periodo WSREST serviceProdutividade

	Local ojResponse    := JsonObject():New()
	Local oJsonSeries   := JsonObject():New()
	Local aJsonSeries   := {}
	Local nPercP        := 0
	Local nPercN        := 0
	Local aPositivacao  := {{"Positivados",{}},;
		{"Não Positivados",{}}}
	Local aSupervisores := {}

	Default ::periodo := Left(DTOS(Date()),6)

	cTabQry := GetNextAlias()

	xPeriodo := ::periodo

	cQuery := " SELECT SUPERVISOR,                                     "
	cQuery += "        TOTAL_CLIENTE,                                  "
	cQuery += "        TOTAL_POSITIVADO,                               "
	cQuery += "        TOTAL_N_POSITIVADO,                             "
	cQuery += "        TOTAL_NOVOS_CLIENTES                            "
	cQuery += " FROM                                                   "
	cQuery += "   (SELECT CASE                                         "
	cQuery += "               WHEN A3_NOME IS NOT NULL THEN A3_NOME    "
	cQuery += "               ELSE 'OUTROS'                            "
	cQuery += "           END AS SUPERVISOR,                           "
	cQuery += "           A3_NOME AS NOME,                             "
	cQuery += "           SUM(ZP1_QTDCLI) AS TOTAL_CLIENTE,            "
	cQuery += "           SUM(ZP1_POSITV) AS TOTAL_POSITIVADO,         "
	cQuery += "           SUM(ZP1_NPOSIT) AS TOTAL_N_POSITIVADO,       "
	cQuery += "           SUM(ZP1_NOVCLI) AS TOTAL_NOVOS_CLIENTES      "
	cQuery += "    FROM "+RetSqlName("ZP1")+" ZP1                      "
	cQuery += "    LEFT JOIN "+RetSqlName("SA3")+" SA3 ON (A3_COD = ZP1_SUPERV        "
	cQuery += "                             AND SA3.D_E_L_E_T_ <> '*') "
	cQuery += "    WHERE ZP1_PERIOD = '"+xPeriodo+"'                   "
	cQuery += "      AND ZP1.D_E_L_E_T_ <> '*'                         "
	cQuery += "    GROUP BY ZP1_SUPERV,                                "
	cQuery += "             A3_NOME) TRB                               "
	cQuery += " ORDER BY (TOTAL_POSITIVADO/ TOTAL_CLIENTE) DESC        "

	oState := FWPreparedStatement():New()
	oState:SetQuery(cQuery)

	MPSysOpenQuery(cQuery,cTabQry)
	oState:Destroy()

	While (cTabQry)->(!EOF())

		AADD(aSupervisores,Alltrim((cTabQry)->SUPERVISOR))

		If (cTabQry)->TOTAL_POSITIVADO > (cTabQry)->TOTAL_N_POSITIVADO
			nPercP := Round((((cTabQry)->TOTAL_POSITIVADO / (cTabQry)->TOTAL_CLIENTE) * 100),2)
			nPercN := 100 - nPercP
		Else
			nPercN := Round((((cTabQry)->TOTAL_N_POSITIVADO / (cTabQry)->TOTAL_CLIENTE) * 100),2)
			nPercP := 100 - nPercN
		Endif

		AADD(aPositivacao[1][2],nPercP)
		AADD(aPositivacao[2][2],nPercN)

		(cTabQry)->(DbSkip())

	End

	(cTabQry)->(DbCloseArea())

	//Define o Título do Gráfico
	ojResponse["title"] := "Ranking positivação por supervisor (%) - "+MesExtenso(STOD(xPeriodo+"01"))+"/"+Left(xPeriodo,4)

	ojResponse["categories"] := aSupervisores

	oJsonSeries['label']   := "Positivados"
	oJsonSeries['data']    := aPositivacao[1][2]

	aAdd(aJsonSeries, oJsonSeries)
	oJsonSeries := JsonObject():New()

	oJsonSeries['label'] := 'Não Positivados'
	oJsonSeries['data']  := aPositivacao[2][2]

	aAdd(aJsonSeries, oJsonSeries)

	ojResponse["series"] := aJsonSeries

	cJson := ojResponse:ToJson()

	//::SetContentType("application/json")
	::SetContentType("application/json; charset=iso-8859-1")
	::SetResponse(cJson)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET PeriodosGerados
Método GET para retorno dos períodos gerados
@author Josué Barbosa
@since 29/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
	WSMETHOD GET PeriodosGerados WSREST serviceProdutividade

	Local ojResponse   := JsonObject():New()
	Local aPeriodos    := {}

	cTabQry := GetNextAlias()

	cQuery := " SELECT ZP1_PERIOD, COUNT(*) FROM "+RetSqlName("ZP1")
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY ZP1_PERIOD "
	cQuery += " ORDER BY ZP1_PERIOD "

	oState := FWPreparedStatement():New()
	oState:SetQuery(cQuery)

	MPSysOpenQuery(cQuery,cTabQry)
	oState:Destroy()

	While (cTabQry)->(!EOF())

		aadd(aPeriodos,(cTabQry)->ZP1_PERIOD)

		(cTabQry)->(DbSkip())

	End

	(cTabQry)->(DbCloseArea())

	ojResponse["items"] := aPeriodos

	cJson := ojResponse:ToJson()

	//::SetContentType("application/json")
	::SetContentType("application/json; charset=iso-8859-1")
	::SetResponse(cJson)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Quantidades
Método GET para retorno dos períodos gerados
@author Josué Barbosa
@since 29/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
	WSMETHOD GET Quantidades WSRECEIVE periodo WSREST serviceProdutividade

	Local ojResponse   := JsonObject():New()
	Local xPeriodo     := ""
	Local lRegistro    := .F.
	Local ojQuantiddes

	Default ::periodo := Left(DTOS(Date()),6)

	cTabQry := GetNextAlias()

	xPeriodo := ::periodo

	cQuery := " SELECT ZP1_PERIOD AS PERIODO,                   "
	cQuery += "        SUM(ZP1_QTDCLI) AS TOTAL_CLIENTE,        "
	cQuery += "        SUM(ZP1_POSITV) AS TOTAL_POSITIVADO,     "
	cQuery += "        SUM(ZP1_NPOSIT) AS TOTAL_N_POSITIVADO,   "
	cQuery += "      SUM(ZP1_NOVCLI) AS TOTAL_NOVOS_CLIENTES,   "
	cQuery += "      SUM(ZP1_QCLATV) AS TOTAL_CLIENTES_ATIVOS,  "
	cQuery += "      SUM(ZP1_QCLINA) AS TOTAL_CLIENTES_INATIVOS "
	cQuery += " FROM "+RetSqlName("ZP1")
	cQuery += " WHERE ZP1_PERIOD = '"+xPeriodo+"'            "
	cQuery += "   AND D_E_L_E_T_ <> '*'                  "
	cQuery += " GROUP BY ZP1_PERIOD                          "

	oState := FWPreparedStatement():New()
	oState:SetQuery(cQuery)

	MPSysOpenQuery(cQuery,cTabQry)
	oState:Destroy()

	While (cTabQry)->(!EOF())

		ojQuantiddes := JsonObject():New()
		ojQuantiddes['periodo'] := xPeriodo
		ojQuantiddes['quantidade_clientes']          := (cTabQry)->TOTAL_CLIENTE
		ojQuantiddes['quantidade_positivados']       := (cTabQry)->TOTAL_POSITIVADO
		ojQuantiddes['quantidade_n_positivados']     := (cTabQry)->TOTAL_N_POSITIVADO
		ojQuantiddes['quantidade_novos_clientes']    := (cTabQry)->TOTAL_NOVOS_CLIENTES
		ojQuantiddes['quantidade_clientes_ativos']   := (cTabQry)->TOTAL_CLIENTES_ATIVOS
		ojQuantiddes['quantidade_clientes_inativos'] := (cTabQry)->TOTAL_CLIENTES_INATIVOS

		lRegistro := .T.

		(cTabQry)->(DbSkip())

	End

	(cTabQry)->(DbCloseArea())

	If !lRegistro
		ojQuantiddes := JsonObject():New()
		ojQuantiddes['periodo'] := xPeriodo
		ojQuantiddes['quantidade_clientes']          := 0
		ojQuantiddes['quantidade_positivados']       := 0
		ojQuantiddes['quantidade_n_positivados']     := 0
		ojQuantiddes['quantidade_novos_clientes']    := 0
		ojQuantiddes['quantidade_clientes_ativos']   := 0
		ojQuantiddes['quantidade_clientes_inativos'] := 0
	Endif

	ojResponse["items"] := ojQuantiddes

	cJson := ojResponse:ToJson()

	//::SetContentType("application/json")
	::SetContentType("application/json; charset=iso-8859-1")
	::SetResponse(cJson)

Return .t.

Static Function AjustaJson(cJSON)

	Local cRegEx := SuperGetMV("CN_JREGEX", .F., "°#º#ª#&#'#<#>")
	Local aRegex := StrToKarr(cRegEx, "#")
	Local nChar  := 1

	For nChar := 1 To Len(aRegex)
		cJSON := StrTran(cJSON, aRegex[nChar], "")
	Next nChar
	cJSON := FwCutOff(cJSON, .t.)
	cJSON := noAcento(cJSON)
	cJSON := FwNoAccent(cJSON)
	cJSON := EncodeUtf8(cJSON)

Return cJSON
