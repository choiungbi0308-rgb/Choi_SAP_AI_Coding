Dim SapGuiAuto, app, conn, session, fso, f

Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("C:\AI-QA\scripts\docflow_result.txt", True)

Set SapGuiAuto = GetObject("SAPGUI")
Set app = SapGuiAuto.GetScriptingEngine
Set conn = app.Connections(0)
Set session = conn.Children(0)

' ME2S - Purchasing Documents for Sales Order
session.FindById("wnd[0]/tbar[0]/okcd").Text = "/nME2S"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

f.WriteLine "ME2S screen: " & session.FindById("wnd[0]").Text

Dim usr, ctrl
Set usr = session.FindById("wnd[0]/usr")
On Error Resume Next
For Each ctrl In usr.Children
    f.WriteLine "  " & ctrl.Id & " | " & ctrl.Type & " | [" & ctrl.Text & "]"
Next
Err.Clear

On Error GoTo 0
' F8 Execute
session.FindById("wnd[0]").sendVKey(8)
WScript.Sleep 3000

f.WriteLine "Result: " & session.FindById("wnd[0]").Text
f.WriteLine "Status: " & session.FindById("wnd[0]/sbar").Text

f.WriteLine "=== DONE ==="
f.Close
WScript.Echo "Done"
