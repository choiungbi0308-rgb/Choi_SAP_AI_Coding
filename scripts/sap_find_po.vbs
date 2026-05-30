Dim SapGuiAuto, app, conn, session, fso, f

Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("C:\AI-QA\scripts\po_result.txt", True)

Set SapGuiAuto = GetObject("SAPGUI")
Set app = SapGuiAuto.GetScriptingEngine
Set conn = app.Connections(0)
Set session = conn.Children(0)

' SE16N - VBEP
session.FindById("wnd[0]/tbar[0]/okcd").Text = "/nSE16N"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 1500
session.FindById("wnd[0]/usr/ctxtGD-TAB").Text = "VBEP"
session.FindById("wnd[0]").sendVKey(0)
WScript.Sleep 2000

' F8 Execute
session.FindById("wnd[0]").sendVKey(8)
WScript.Sleep 3000

f.WriteLine "Result: " & session.FindById("wnd[0]").Text
f.WriteLine "Status: " & session.FindById("wnd[0]/sbar").Text

f.WriteLine "=== DONE ==="
f.Close
WScript.Echo "Done"
