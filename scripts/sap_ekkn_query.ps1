[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    $SapGuiAuto = [System.Runtime.InteropServices.Marshal]::GetActiveObject("SapGui.ScriptingCtrl.1")
    $app = $SapGuiAuto.GetScriptingEngine()
    try { $app.HistoryEnabled = $false } catch {}

    Write-Output "연결 수: $($app.Connections.Count)"

    $session = $null
    for ($c = 0; $c -lt $app.Connections.Count; $c++) {
        $conn = $app.Connections($c)
        Write-Output "연결[$c]: $($conn.Description)"
        for ($s = 0; $s -lt $conn.Children.Count; $s++) {
            $sess = $conn.Children($s)
            Write-Output "  세션[$s]: System=$($sess.Info.SystemName) User=$($sess.Info.User) Lang=$($sess.Info.Language)"
            $session = $sess
        }
    }

    if (-not $session) { Write-Output "세션 없음"; exit 1 }

    $wnd = $session.findById("wnd[0]")
    Write-Output "현재 화면: $($wnd.Text)"

    if ($wnd.Text -match "SAP" -and $session.Info.User -eq "") {
        Write-Output "로그인 화면 감지 - EN으로 로그인..."
        $session.findById("wnd[0]/usr/txtRSYST-MANDT").Text = "100"
        $session.findById("wnd[0]/usr/txtRSYST-BNAME").Text = "<SAP_USER>"
        $session.findById("wnd[0]/usr/pwdRSYST-BCODE").Text = "<SAP_PASSWORD>"
        $session.findById("wnd[0]/usr/txtRSYST-LANGU").Text = "EN"
        $session.findById("wnd[0]/tbar[0]/btn[0]").Press()
        Start-Sleep -Seconds 4
        Write-Output "로그인 완료: $($session.Info.User) / $($session.Info.Language)"
    } elseif ($session.Info.Language -ne "EN") {
        Write-Output "현재 언어: $($session.Info.Language) - EN으로 재로그인..."
        $session.findById("wnd[0]/tbar[0]/okcd").Text = "/nex"
        $session.findById("wnd[0]").sendVKey(0)
        Start-Sleep -Seconds 3
        $session.findById("wnd[0]/usr/txtRSYST-MANDT").Text = "100"
        $session.findById("wnd[0]/usr/txtRSYST-BNAME").Text = "<SAP_USER>"
        $session.findById("wnd[0]/usr/pwdRSYST-BCODE").Text = "<SAP_PASSWORD>"
        $session.findById("wnd[0]/usr/txtRSYST-LANGU").Text = "EN"
        $session.findById("wnd[0]/tbar[0]/btn[0]").Press()
        Start-Sleep -Seconds 4
        Write-Output "EN 재로그인 완료"
    } else {
        Write-Output "이미 EN 세션 - 바로 진행"
    }

    # SE16N - EKKN 조회
    Write-Output "=== EKKN 조회 시작 ==="
    $session.StartTransaction("SE16N")
    Start-Sleep -Seconds 2

    $session.findById("wnd[0]/usr/ctxtGD-TAB").Text = "EKKN"
    $session.findById("wnd[0]/tbar[0]/btn[0]").Press()
    Start-Sleep -Seconds 2

    $session.findById("wnd[0]/usr/txtGD-SUCHFELD").Text = "VBELN"
    $session.findById("wnd[0]/usr/ctxtGD-SUCHVAL").Text = "5700416643"
    $session.findById("wnd[0]/tbar[1]/btn[8]").Press()
    Start-Sleep -Seconds 3

    $statusBar = $session.findById("wnd[0]/sbar").Text
    Write-Output "상태바: $statusBar"

} catch {
    Write-Output "ERROR: $_"
}
