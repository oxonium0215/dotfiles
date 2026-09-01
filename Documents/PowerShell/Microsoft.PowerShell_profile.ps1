########################################
# PowerShell Profile — zsh互換表示
########################################

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

#region PSReadLine (高速ロード)
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Chord 'Ctrl+s' -Function ForwardSearchHistory
}
#endregion

#region Git情報取得 (高速判定)
function Get-GitInfo {
    # .NET の高速パス走査で .git の有無を判定（非 Git ディレクトリでの git.exe プロセス起動を回避）
    $currentDir = $PWD.Path
    $hasGit = $false
    while ($currentDir) {
        if ([System.IO.Directory]::Exists("$currentDir\.git") -or [System.IO.File]::Exists("$currentDir\.git")) {
            $hasGit = $true
            break
        }
        $parentDir = [System.IO.Path]::GetDirectoryName($currentDir)
        if ($parentDir -eq $currentDir) { break }
        $currentDir = $parentDir
    }
    if (-not $hasGit) { return '' }

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

#region XDG Base Directory (for Neovim and modern CLI tools)
$env:XDG_CONFIG_HOME = "$HOME\.config"
$env:XDG_DATA_HOME   = "$HOME\.local\share"
$env:XDG_CACHE_HOME  = "$HOME\.cache"
$env:XDG_STATE_HOME  = "$HOME\.local\state"
#endregion

#region mise (バージョン・環境変数マネージャー)
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    $possibleMisePaths = @(
        "$env:LOCALAPPDATA\mise\bin",
        "$HOME\.local\bin",
        "$env:LOCALAPPDATA\Programs\mise\bin"
    )
    foreach ($p in $possibleMisePaths) {
        if (Test-Path "$p\mise.exe") {
            $env:PATH = "$p;$env:PATH"
            break
        }
    }
}

# mise の shims ディレクトリを PATH に含める（非対話シェルやサブプロセス向け）
$miseShimsPath = "$HOME\.local\share\mise\shims"
if (Test-Path $miseShimsPath) {
    if (($env:PATH -split ';') -notcontains $miseShimsPath) {
        $env:PATH = "$miseShimsPath;$env:PATH"
    }
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    try {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            (& mise activate pwsh) | Out-String | Invoke-Expression
        } else {
            (& mise activate ps) | Out-String | Invoke-Expression
        }
    } catch {
        # エラー発生時もプロファイルの読み込みを継続
    }
}
#endregion

#region エイリアス
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function Invoke-Eza      { eza -a --icons --group-directories-first @args }
    function Invoke-EzaLong  { eza -ltr --color=auto --icons --group-directories-first @args }
    function Invoke-EzaAll   { eza -la --color=auto --icons --group-directories-first @args }
    function Invoke-EzaList  { eza -l --color=auto --icons --group-directories-first @args }

    Set-Alias -Name ls  -Value Invoke-Eza      -Option AllScope -Force
    Set-Alias -Name l   -Value Invoke-EzaLong  -Option AllScope -Force
    Set-Alias -Name lst -Value Invoke-EzaLong  -Option AllScope -Force
    Set-Alias -Name la  -Value Invoke-EzaAll   -Option AllScope -Force
    Set-Alias -Name ll  -Value Invoke-EzaList  -Option AllScope -Force
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vi -Value nvim -Option AllScope -Force
}

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit -Option AllScope -Force
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
        $entries = @(Get-ChildItem -Force -Path $PWD.Path -ErrorAction SilentlyContinue | Select-Object -First 501)
        if ($entries.Count -gt 500) { return }

        if (Get-Command eza -ErrorAction SilentlyContinue) {
            eza -a --icons --group-directories-first
        } else {
            Get-ChildItem -Force
        }
    }
}
Set-Alias -Name cd -Value Set-LocationAndList -Option AllScope -Force
#endregion

#region ghq + roots + fzf リポジトリ移動
function Invoke-GhqCd {
    if (-not (Get-Command ghq -ErrorAction SilentlyContinue)) {
        Write-Warning "ghq is not installed."
        return
    }

    $repoList = if (Get-Command roots -ErrorAction SilentlyContinue) {
        & ghq list --full-path 2>$null | & roots 2>$null
    } else {
        & ghq list --full-path 2>$null
    }

    if (-not $repoList) {
        Write-Warning "No repositories found in ghq."
        return
    }

    $selected = if (Get-Command fzf -ErrorAction SilentlyContinue) {
        if (Get-Command eza -ErrorAction SilentlyContinue) {
            $repoList | & fzf --reverse --height 40% --prompt "ghq> " --preview "eza --tree --level=2 --git-ignore --color=always {}"
        } else {
            $repoList | & fzf --reverse --height 40% --prompt "ghq> "
        }
    } else {
        $repoList | Out-GridView -Title "Select Repository" -OutputMode Single
    }

    if ($selected) {
        Set-Location $selected
        if (Get-Command eza -ErrorAction SilentlyContinue) {
            eza -a --icons --group-directories-first
        }
    }
}
Set-Alias -Name cdg -Value Invoke-GhqCd -Option AllScope -Force

if (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cdg')
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}
#endregion

$env:EDITOR = 'nvim'
