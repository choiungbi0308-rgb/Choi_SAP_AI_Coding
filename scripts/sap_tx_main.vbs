Dim SapGuiAuto, app, conn, session, fso, f

Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("C:\AI-QA\scripts\tx_result.txt", True)

Set SapGuiAuto = GetObject("SAPGUI")
Set app = SapGuiAuto.GetScriptingEngine
Set conn = app.Connections(0)
Set session = conn.Children(0)

' STEP 1: ME22N - PO Delete
f.WriteLine "=== STEP1: ME22N PO Delete ==="
session.FindById("wnd[0]/tbar[0]/okcd").Text = "/nME22N"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

f.WriteLine "Screen: " & session.FindById("wnd[0]").Text

On Error Resume Next
session.FindById("wnd[0]/tbar[0]/btn[5]").Press()
WScript.Sleep 1000
f.WriteLine "Popup: " & session.FindById("wnd[1]").Text
session.FindById("wnd[1]/usr/ctxtME21N-EBELN").Text = "<PO_NUMBER>"
session.FindById("wnd[1]").sendVKey(0)
WScript.Sleep 2000
If Err.Number <> 0 Then Err.Clear

' Save
session.FindById("wnd[0]").sendVKey(11)
WScript.Sleep 2000
On Error GoTo 0

f.WriteLine "ME22N result: " & session.FindById("wnd[0]/sbar").Text

' STEP 2: VA02 - SO Reason for Rejection
f.WriteLine "=== STEP2: VA02 Reason for Rejection ==="
session.FindById("wnd[0]/tbar[0]/okcd").Text = "/nVA02"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

session.FindById("wnd[0]/usr/ctxtVBAK-VBELN").Text = "<SO_NUMBER>"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

f.WriteLine "VA02 screen: " & session.FindById("wnd[0]").Text
f.WriteLine "=== DONE ==="
f.Close
WScript.Echo "Done - check tx_result.txt"
