[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try {
    $SapGuiAuto = New-Object -ComObject 'SapGui.ScriptingCtrl.1'
    $app = $SapGuiAuto.GetScriptingEngine()
    Write-Output "64bit - 연결수: $($app.Connections.Count)"
    for ($c = 0; $c -lt $app.Connections.Count; $c++) {
        $conn = $app.Connections($c)
        Write-Output "Conn[$c]: $($conn.Description)"
        for ($s = 0; $s -lt $conn.Children.Count; $s++) {
            $sess = $conn.Children($s)
            Write-Output "  Sess: $($sess.Info.SystemName)/$($sess.Info.User)"
        }
    }
} catch { Write-Output "ERROR: $_" }
