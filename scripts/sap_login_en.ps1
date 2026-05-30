[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    $SapGuiAuto = New-Object -ComObject "SapGui.ScriptingCtrl.1"
    $app = $SapGuiAuto.GetScriptingEngine()
    try { $app.HistoryEnabled = $false } catch {}

    Write-Output "연결 수: $($app.Connections.Count)"

    $session = $null
    for ($c = 0; $c -lt $app.Connections.Count; $c++) {
        $conn = $app.Connections($c)
        for ($s = 0; $s -lt $conn.Children.Count; $s++) {
            $sess = $conn.Children($s)
            Write-Output "세션[$c/$s]: System=$($sess.Info.SystemName) User=$($sess.Info.User) Lang=$($sess.Info.Language)"
            $session = $sess
        }
    }

    if (-not $session) { Write-Output "세션 없음"; exit 1 }

    $wnd = $session.findById("wnd[0]")
    Write-Output "현재 화면: $($wnd.Text)"

    Write-Output "로그오프 중..."
    $session.findById("wnd[0]/tbar[0]/okcd").Text = "/nex"
    $session.findById("wnd[0]").sendVKey(0)
    Start-Sleep -Seconds 3

    Write-Output "EN으로 재로그인..."
    $session.findById("wnd[0]/usr/txtRSYST-MANDT").Text = "100"
    $session.findById("wnd[0]/usr/txtRSYST-BNAME").Text = "<SAP_USER>"
    $session.findById("wnd[0]/usr/pwdRSYST-BCODE").Text = "<SAP_PASSWORD>"
    $session.findById("wnd[0]/usr/txtRSYST-LANGU").Text = "EN"
    $session.findById("wnd[0]/tbar[0]/btn[0]").Press()
    Start-Sleep -Seconds 4

    $wnd = $session.findById("wnd[0]")
    Write-Output "로그인 후 화면: $($wnd.Text)"
    Write-Output "User: $($session.Info.User) / Lang: $($session.Info.Language)"
    Write-Output "LOGIN_OK"

} catch {
    Write-Output "ERROR: $_"
}
