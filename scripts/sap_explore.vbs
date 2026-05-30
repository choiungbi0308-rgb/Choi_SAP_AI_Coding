Dim SapGuiAuto, app, conn, session, fso, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("C:\AI-QA\scripts\explore_result.txt", True)

Set SapGuiAuto = GetObject("SAPGUI")
Set app = SapGuiAuto.GetScriptingEngine
Set conn = app.Connections(0)
Set session = conn.Children(0)

' ME22N: Other Document popup exploration
f.WriteLine "=== ME22N Other Document Popup ==="
session.FindById("wnd[0]/tbar[0]/okcd").Text = "/nME22N"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

session.FindById("wnd[0]/tbar[0]/btn[5]").Press()
WScript.Sleep 1500

On Error Resume Next
Dim popup
Set popup = session.FindById("wnd[1]")
If Err.Number = 0 Then
    f.WriteLine "Popup title: " & popup.Text
    Dim pCtrl
    For Each pCtrl In popup.Children
        f.WriteLine "  " & pCtrl.Id & " | " & pCtrl.Type & " | [" & pCtrl.Text & "]"
    Next
Else
    Err.Clear
    f.WriteLine "No popup - screen: " & session.FindById("wnd[0]").Text
End If
On Error GoTo 0

f.WriteLine "=== DONE ==="
f.Close
WScript.Echo "Done"
