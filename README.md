# ZarinPal-Sample-For-B4A
ZarinPal Payment Request Sample for Basic4Android

- Add Libraries In Project
```
	JSON
	OKHttp
	OkHttpUtils2
	Reflection
 ```
 - Add ZarinpalPurchase.bas Module To Project
 - Set Your Application Scheme in Actvity for Handling Callback: 
```XML
    AddActivityText(<HANDLER-ACTIVITY-NAME>,
      <intent-filter>
          <action android:name="android.intent.action.VIEW"/>

          <category android:name="android.intent.category.DEFAULT"/>
          <category android:name="android.intent.category.BROWSABLE"/>

          <data android:scheme="<YOUR-APP-SCHEME>"/>
      </intent-filter> 
     )
 ```
###Example For Payment Request And Callback Handler:
- You should declare this variable on Process_Globals
```
  Dim ZP As ZarinpalPurchase
```
- Then you have to write these two lines at the Activity_Resume
```
  If Not(ZP.IsInitialized) Then ZP.Initialize("ZP",Me)
  ZP.VerificationPayment(Activity.GetStartingIntent)
```
- Payment Request
```
  Sub PayBtn_Click
	  Dim Payment As ZPaymentRequest
	  Payment.Initialize
	  Payment.Amount = 100
	  Payment.MerchantID = MerchantID
	  Payment.Description = "In App Purchase Test SDK"
	  Payment.Email = "sseedd524@gmail.com"	'Optional Parameters
	  Payment.Mobile = "09116745428"			'Optional Parameters
	  Payment.CallbackURL = "yourapp://app"	'Your App Scheme
	  ZP.StartPayment(Payment)
  End Sub
```
- Callback Handlers
```
  Sub ZP_ResultPaymentRequest(Result As ResultPaymentRequest)
	  If Result.Status = 100 Then
		  StartActivity(Result.Intent)
	  Else
		  ToastMessageShow("Your Payment Failure :(",False)
	  End If
  End Sub

  Sub ZP_ResultVerificationPayment(Result As ResultVerificationPayment)
	  If Result.IsPaymentSuccess Then
		  ToastMessageShow("Your Payment is Success :) " & Result.RefId,False)
  	Else
	  	ToastMessageShow("Your Payment is Failure :(",False)
  	End If
  End Sub
```
