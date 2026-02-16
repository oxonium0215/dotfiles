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

#region Git情報取得 (同期)
function Get-GitInfo {
    if (-not (Test-Path .git -PathType Container) -and -not (git rev-parse --git-dir 2>$null)) { return '' }

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
    return "`e[32m${staged}${unstaged}[${branch}]`e[0m"
}
#endregion

#region プロンプト
function prompt {
    $lastSuccess = $?

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

    $left = "${userColor}${userName}${reset}@${blue}${hostName}${reset}(${time}) ${currentPath}"
    $leftPlain = $left -replace "`e\[[0-9;]*m", ''

    $gitPart = Get-GitInfo
    $w = [Console]::WindowWidth

    if ($gitPart) {
        $gitPlain = $gitPart -replace "`e\[[0-9;]*m", ''
        $col = $w - $gitPlain.Length
        if ($col -gt ($leftPlain.Length + 1)) {
            "${left}`e[${col}G${gitPart}${reset}`n> "
        } else {
            "${left} ${gitPart}${reset}`n> "
        }
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

#region cd時の自動ls
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
