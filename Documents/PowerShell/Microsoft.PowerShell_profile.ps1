########################################
# PowerShell Profile — zsh互換表示
########################################

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

#region PSReadLine
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Chord 'Ctrl+s' -Function ForwardSearchHistory
}
#endregion

#region 非同期Git情報 (zsh-async相当)
$script:_gitInfoCache = ''
$script:_gitInfoJob = $null
$script:_gitInfoDir = ''
$script:_gitState = [hashtable]::Synchronized(@{ Generation = 0 })

$script:_gitInfoScriptBlock = {
    param($dir, $width, $state, $gen)
    Set-Location -LiteralPath $dir
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if (-not $branch) { return '' }

    $staged = ''
    $unstaged = ''
    $status = git status --porcelain 2>$null
    if ($status) {
        foreach ($line in $status -split "`n") {
            if ($line.Length -lt 2) { continue }
            if ($line[0] -match '[MADRC]')  { $staged   = "`e[33m!" }
            if ($line[1] -match '[MADRC?]') { $unstaged = "`e[31m+" }
        }
    }
    $result = "`e[32m${staged}${unstaged}[${branch}]`e[0m"

    # 世代が一致する場合のみRPROMPTを描画（コマンド実行後の誤描画を防止）
    if ($state.Generation -eq $gen) {
        $gitPlain = $result -replace "`e\[[0-9;]*m", ''
        $col = $width - $gitPlain.Length
        [Console]::Write("`e7`e[1A`e[${col}G${result}`e[0m`e8")
    }

    return $result
}

function Update-GitInfoAsync {
    if ($script:_gitInfoJob) {
        if ($script:_gitInfoJob.State -eq 'Completed') {
            $script:_gitInfoCache = Receive-Job -Job $script:_gitInfoJob 2>$null
            Remove-Job -Job $script:_gitInfoJob -Force 2>$null
            $script:_gitInfoJob = $null
        } elseif ($script:_gitInfoJob.State -in 'Failed', 'Stopped') {
            Remove-Job -Job $script:_gitInfoJob -Force 2>$null
            $script:_gitInfoJob = $null
            $script:_gitInfoCache = ''
        }
    }

    if ($script:_gitInfoDir -ne $PWD.Path) {
        if (-not $script:_gitInfoJob) { $script:_gitInfoCache = '' }
        $script:_gitInfoDir = $PWD.Path
    }

    # 世代をインクリメント
    $script:_gitState.Generation++

    if (-not $script:_gitInfoJob) {
        $script:_gitInfoJob = Start-ThreadJob -ScriptBlock $script:_gitInfoScriptBlock `
            -ArgumentList $PWD.Path, [Console]::WindowWidth, $script:_gitState, $script:_gitState.Generation
    }
}
#endregion

#region プロンプト
function prompt {
    $lastSuccess = $?
    Update-GitInfoAsync

    if ($lastSuccess) { $userColor = "`e[32m" } else { $userColor = "`e[31m" }
    $reset = "`e[0m"
    $blue  = "`e[34m"

    $userName = $env:USERNAME ?? $env:USER ?? 'user'
    $hostName = [System.Net.Dns]::GetHostName()
    $time = Get-Date -Format 'HH:mm:ss'

    $currentPath = $PWD.Path
    if ($currentPath.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
        $currentPath = '~' + $currentPath.Substring($HOME.Length)
    }
    $currentPath = $currentPath -replace '\\', '/'

    $gitPart = $script:_gitInfoCache

    $left = "${userColor}${userName}${reset}@${blue}${hostName}${reset}(${time}) ${currentPath}"

    if ($gitPart) {
        $gitPlain = $gitPart -replace "`e\[[0-9;]*m", ''
        $col = [Console]::WindowWidth - $gitPlain.Length
        "${left}`e[${col}G${gitPart}${reset}`n> "
    } else {
        "${left}`n> "
    }
}
#endregion

#region エイリアス
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function Invoke-Eza      { eza -a --icons @args }
    function Invoke-EzaLong  { eza -ltr --color=auto --icons @args }
    function Invoke-EzaAll   { eza -la --color=auto --icons @args }
    function Invoke-EzaList  { eza -l --color=auto --icons @args }

    Set-Alias -Name ls  -Value Invoke-Eza      -Option AllScope -Force
    Set-Alias -Name l   -Value Invoke-EzaLong  -Option AllScope -Force
    Set-Alias -Name lst -Value Invoke-EzaLong  -Option AllScope -Force
    Set-Alias -Name la  -Value Invoke-EzaAll   -Option AllScope -Force
    Set-Alias -Name ll  -Value Invoke-EzaList  -Option AllScope -Force
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vi -Value nvim -Option AllScope -Force
}
#endregion

#region cd時の自動ls (chpwd相当)
function Set-LocationAndList {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments)]
        [string[]]$Path
    )
    if ($Path) { Set-Location @Path } else { Set-Location $HOME }
    if ($PWD.Path -ne $HOME) {
        if (Get-Command eza -ErrorAction SilentlyContinue) {
            eza -a --group-directories-first
        } else {
            Get-ChildItem -Force
        }
    }
}
Set-Alias -Name cd -Value Set-LocationAndList -Option AllScope -Force
#endregion

$env:EDITOR = 'nvim'
