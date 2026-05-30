Dim SapGuiAuto
Dim app
On Error Resume Next
Set SapGuiAuto = GetObject("SAPGUI")
If Err.Number <> 0 Then
    WScript.Echo "GetObject SAPGUI error: " & Err.Description
    Err.Clear
End If
Set app = SapGuiAuto.GetScriptingEngine
If IsNull(app) Or IsEmpty(app) Then
    WScript.Echo "app is null"
Else
    WScript.Echo "Connections: " & app.Connections.Count
End If
