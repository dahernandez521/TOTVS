#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*-------------------------------------------------!
!RUTINA MVC PARA REGISTRO DE USUARIOS PORTAL VENTAS!
!                 JAVIER ROCHA                     !
--------------------------------------------------*/


User Function AdmPort()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ5')
	oBrowse:SetDescription('Administrador Portal Ventas')
	oBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AdmPort' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.AdmPort' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.AdmPort' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Borrar'     ACTION 'VIEWDEF.AdmPort' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.AdmPort' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.AdmPort' OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStruZZ5 := FWFormStruct(1,"ZZ5")
	Local oStruZZ6 := FWFormStruct(1,"ZZ6")
	Local aZZ6Rel		:= {}

	oModel := MPFormModel():New("CLIEXUSU")
	oModel:addFields('ZZ5MASTER',,oStruZZ5)
	oModel:addGrid('ZZ6DETAIL','ZZ5MASTER',oStruZZ6)

	aAdd(aZZ6Rel, {'ZZ6_FILIAL'	, 'xFilial( "ZZ6" )'})
	aAdd(aZZ6Rel, {'ZZ6_CODUSU'	, 'ZZ5_CODUSU'		})
	oModel:SetRelation('ZZ6DETAIL', aZZ6Rel, ZZ6->(IndexKey(1))) // IndexKey -> Quiero ordenar y luego filtrar
	oModel:GetModel('ZZ6DETAIL'):SetOptional(.T.)  //Se indica que la tabla relacionada puede ir sin registros para guardar

	oModel:GetModel('ZZ6DETAIL'):SetUniqueLine({"ZZ6_CODUSU"})	// No repita informaci�n o combinaciones {"CAMPO1", "CAMPO2", "CAMPOX"}
	oModel:GetModel('ZZ6DETAIL'):SetDescription( 'Clientes' )
	oModel:SetPrimaryKey({})


Return oModel

Static Function ViewDef()
	Local oModel := ModelDef()
	Local oView
	Local oStrZZ5:= FWFormStruct(2, 'ZZ5')
	Local oStrZZ6:= FWFormStruct(2, 'ZZ6', {|cField| !(AllTrim(Upper(cField)) $ "ZZ6_CODUSU")})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_USU' , oStrZZ5,'ZZ5MASTER' )
	oView:AddGrid('FORM_CLIE' , oStrZZ6,'ZZ6DETAIL')

	oView:CreateHorizontalBox( 'BOX_FORM_USU', 40)
	oView:CreateHorizontalBox( 'BOX_FORM_CLIE', 60)

	oView:SetOwnerView('FORM_USU','BOX_FORM_USU')
	oView:SetOwnerView('FORM_CLIE','BOX_FORM_CLIE')


Return oView
