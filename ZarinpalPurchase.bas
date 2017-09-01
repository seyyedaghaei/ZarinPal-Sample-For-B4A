Type=Class
Version=7.3
ModulesStructureVersion=1
B4A=true
@EndOfDesignText@
#Event : ResultPaymentRequest(Result As ResultPaymentRequest)
#Event : ResultVerificationPayment(Result As ResultVerificationPayment)

Private Sub Class_Globals
	Private MERCHANT_ID_PARAMS = "MerchantID" As String
	Private AMOUNT_PARAMS = "Amount" As String
	Private DESCRIPTION_PARAMS = "Description" As String
	Private CALLBACK_URL_PARAMS = "CallbackURL" As String
	Private MOBILE_PARAMS = "Mobile" As String
	Private EMAIL_PARAMS = "Email" As String
	Private AUTHORITY_PARAMS = "Authority" As String
	Private PAYMENT_GATEWAY_URL = "https://www.zarinpal.com/pg/StartPay/" As String
	Private PAYMENT_REQUEST_URL = "https://www.zarinpal.com/pg/rest/WebGate/PaymentRequest.json" As String
	Private VERIFICATION_PAYMENT_URL = "https://www.zarinpal.com/pg/rest/WebGate/PaymentVerification.json" As String
	Type ResultPaymentRequest(Status As Int,Authority As String,Url As String,Intent As Intent)
	Type ResultVerificationPayment(IsPaymentSuccess As Boolean,RefId As String,Payment As ZPaymentRequest)
	Type ZPaymentRequest(MerchantID As String,Amount As Long,Description As String,CallbackURL As String,Email As String,Mobile As String,Authority As String)
	Private vPayment As ZPaymentRequest
	Private event As String
	Private target As Object
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(EventName As String,TargetModule As Object)
	event = EventName
	target = TargetModule
End Sub

Private Sub getPaymentRequestJson(ZPaymentRequest As ZPaymentRequest) As String
	Dim jg As JSONGenerator
	jg.Initialize(CreateMap(MERCHANT_ID_PARAMS : ZPaymentRequest.MerchantID,AMOUNT_PARAMS : ZPaymentRequest.Amount,DESCRIPTION_PARAMS : _
		ZPaymentRequest.Description,CALLBACK_URL_PARAMS : ZPaymentRequest.CallbackURL,MOBILE_PARAMS : ZPaymentRequest.Mobile, _
		EMAIL_PARAMS : ZPaymentRequest.Email))
	Return jg.ToString
End Sub

Public Sub StartPayment(ZPaymentRequest As ZPaymentRequest)
	Dim SP As HttpJob
	SP.Initialize("StartPayment",Me)
	vPayment = ZPaymentRequest
	SP.PostString(PAYMENT_REQUEST_URL,getPaymentRequestJson(ZPaymentRequest))
	SP.GetRequest.SetContentType("application/json")
End Sub

Private Sub JobDone(Job As HttpJob)
	If Job.Success Then
		Dim jp As JSONParser
		jp.Initialize(Job.GetString)
		Dim Result As Map = jp.NextObject
		Select Job.JobName
			Case "StartPayment"
					Dim Intent As Intent,Url As String = PAYMENT_GATEWAY_URL&Result.Get("Authority")
					Intent.Initialize(Intent.ACTION_VIEW,Url)
					Dim ResultPayment As ResultPaymentRequest
					ResultPayment.Initialize
					ResultPayment.Authority = Result.Get("Authority")
					ResultPayment.Intent = Intent
					ResultPayment.Status = Result.Get("Status")
					ResultPayment.Url = Url
					vPayment.Authority = ResultPayment.Authority
					CallSub2(target,event&"_ResultPaymentRequest",ResultPayment)
			Case "VerificationPayment"
					Dim ResultVarification As ResultVerificationPayment
					ResultVarification.Initialize
					ResultVarification.IsPaymentSuccess = True
					ResultVarification.RefId = Result.Get("RefID")
					ResultVarification.Payment = vPayment
					CallSubDelayed2(target,event&"_ResultVerificationPayment",ResultVarification)
		End Select
	Else
		Select Job.JobName
			Case "StartPayment"
				Dim ResultPayment As ResultPaymentRequest
				ResultPayment.Initialize
				ResultPayment.Authority = Null
				ResultPayment.Intent = Null
				ResultPayment.Status = Result.Get("Status")
				ResultPayment.Url = Null
				CallSubDelayed2(target,event&"_ResultPaymentRequest",ResultPayment)
			Case "VerificationPayment"
				Dim ResultVarification As ResultVerificationPayment
				ResultVarification.Initialize
				ResultVarification.IsPaymentSuccess = False
				ResultVarification.RefId = Null
				ResultVarification.Payment = vPayment
				CallSubDelayed2(target,event&"_ResultVerificationPayment",ResultVarification)
		End Select
	End If
	Job.Release
End Sub

Public Sub VerificationPayment(Intent As Intent)
	If Intent = Null Or Not(Intent.IsInitialized) Then Return
	Dim r As Reflector
	r.Target = Intent
	r.Target = r.RunMethod("getData")
	If r.Target = Null Or vPayment = Null Or Not(r.RunMethod("isHierarchical")) Then Return
	Dim VP As HttpJob
	VP.Initialize("VerificationPayment",Me)
	Dim jg As JSONGenerator
	Dim vAuthority As String = r.RunMethod2("getQueryParameter","Authority","java.lang.String")
	If vAuthority <> vPayment.Authority Or Not(r.RunMethod2("getQueryParameter","Status","java.lang.String") = "OK") Then
		Dim ResultVarification As ResultVerificationPayment
		ResultVarification.Initialize
		ResultVarification.IsPaymentSuccess = False
		ResultVarification.RefId = Null
		ResultVarification.Payment = vPayment
		CallSubDelayed2(target,event&"_ResultVerificationPayment",ResultVarification)
	End If
	jg.Initialize(CreateMap(AUTHORITY_PARAMS : vPayment.Authority,MERCHANT_ID_PARAMS : vPayment.MerchantID,AMOUNT_PARAMS : vPayment.Amount))
	VP.PostString(VERIFICATION_PAYMENT_URL,jg.ToString)
	VP.GetRequest.SetContentType("application/json")
End Sub
