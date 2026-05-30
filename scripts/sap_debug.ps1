[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    $SapGuiAuto = New-Object -ComObject "SapGui.ScriptingCtrl.1"
    $app = $SapGuiAuto.GetScriptingEngine()
    Write-Output "ScriptingEngine type: $($app.GetType().FullName)"
    Write-Output "Connections count: $($app.Connections.Count)"

    Write-Output "OpenConnection 시도..."
    $conn = $null
    try {
        $conn = $app.OpenConnection("/H/<SAP_HOST>/S/<SAP_PORT>", $true)
        Write-Output "conn null? $($conn -eq $null)"
        if ($conn) { Write-Output "conn type: $($conn.GetType().FullName)" }
    } catch {
        Write-Output "시도 오류: $_"
    }

    Start-Sleep -Seconds 3
    Write-Output "연결 후 count: $($app.Connections.Count)"

    if ($app.Connections.Count -gt 0) {
        $c = $app.Connections(0)
        Write-Output "연결됨: $($c.Description)"
        $s = $c.Children(0)
        $wnd = $s.findById("wnd[0]")
        Write-Output "현재 화면: $($wnd.Text)"
    }

} catch {
    Write-Output "FATAL ERROR: $_"
}
