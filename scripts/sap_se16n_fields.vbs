Dim SapGuiAuto, app, conn, session
Dim fso, f

Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("C:\AI-QA\scripts\se16n_fields.txt", True)

Set SapGuiAuto = GetObject("SAPGUI")
Set app = SapGuiAuto.GetScriptingEngine
Set conn = app.Connections(0)
Set session = conn.Children(0)

f.WriteLine "현재 화면: " & session.FindById("wnd[0]").Text

Dim usr
Set usr = session.FindById("wnd[0]/usr")
f.WriteLine "usr 자식 수: " & usr.Children.Count

Dim idx
For idx = 0 To usr.Children.Count - 1
    On Error Resume Next
    Dim ctrl
    Set ctrl = usr.Children(idx)
    f.WriteLine "[" & idx & "] ID=" & ctrl.Id & " | Type=" & ctrl.Type & " | Text=[" & ctrl.Text & "]"
    Err.Clear
Next

f.WriteLine "=== 완료 ==="
f.Close
WScript.Echo "완료"
