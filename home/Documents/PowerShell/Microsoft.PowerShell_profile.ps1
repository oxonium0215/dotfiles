########################################
# PowerShell Profile — zsh互換表示 (高速化版)
########################################

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

#region XDG Base Directory (for Neovim and modern CLI tools)
$env:XDG_CONFIG_HOME = "$HOME\.config"
$env:XDG_DATA_HOME   = "$HOME\.local\share"
$env:XDG_CACHE_HOME  = "$HOME\.cache"
$env:XDG_STATE_HOME  = "$HOME\.local\state"
$env:EDITOR          = 'nvim'
#endregion

#region PSReadLine (高速ロード)
if ($host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineOption -EditMode Vi
        Set-PSReadLineOption -BellStyle None
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -Function ReverseSearchHistory
        Set-PSReadLineKeyHandler -Chord 'Ctrl+s' -Function ForwardSearchHistory
    } catch {}
}
#endregion

#region キャッシュ変数 (起動時DNS/ユーザー名解決のキャッシュ)
$script:cachedUserName = $env:USERNAME ?? $env:USER ?? 'user'
$script:cachedHostName = [System.Environment]::MachineName
#endregion

#region Git情報取得 (高速判定)
function Get-GitInfo {
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

    $time = [System.DateTime]::Now.ToString('HH:mm:ss')

    $currentPath = $PWD.Path
    if ($currentPath.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
        $currentPath = '~' + $currentPath.Substring($HOME.Length)
    }
    $currentPath = $currentPath -replace '\\', '/'

    $left = "${userColor}${script:cachedUserName}${reset}@${blue}${script:cachedHostName}${reset}(${time}) ${currentPath}"
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

#region mise (バージョン・環境変数マネージャー)
# 1. shims を PATH の先頭に追加（最も高速にコマンド解決）
$miseShimsPath = "$HOME\.local\share\mise\shims"
if ([System.IO.Directory]::Exists($miseShimsPath)) {
    if (-not $env:PATH.StartsWith($miseShimsPath)) {
        $env:PATH = "$miseShimsPath;$env:PATH"
    }
}

# 2. mise bin ディレクトリの追加
$miseBinPath = "$env:LOCALAPPDATA\mise\bin"
if ([System.IO.Directory]::Exists($miseBinPath)) {
    if (($env:PATH -split ';') -notcontains $miseBinPath) {
        $env:PATH = "$miseBinPath;$env:PATH"
    }
}

# 3. mise activate (pwsh) を実行
$miseExe = if ([System.IO.File]::Exists("$miseBinPath\mise.exe")) {
    "$miseBinPath\mise.exe"
} elseif ([System.IO.File]::Exists("$HOME\.local\bin\mise.exe")) {
    "$HOME\.local\bin\mise.exe"
} else {
    $null
}

if ($miseExe) {
    try {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            (& $miseExe activate pwsh) | Out-String | Invoke-Expression
        } else {
            (& $miseExe activate ps) | Out-String | Invoke-Expression
        }
    } catch {}
}
#endregion

#region エイリアス & ツールラッパー (起動時 Get-Command を排除して高速化)
function Invoke-EzaWrapper {
    param([string[]]$EzaArgs)
    if ([System.IO.File]::Exists("$HOME\.local\share\mise\shims\eza.exe") -or (Get-Command eza -ErrorAction SilentlyContinue)) {
        & eza @EzaArgs
    } else {
        Get-ChildItem -Force
    }
}

function ls  { Invoke-EzaWrapper @('-a', '--icons', '--group-directories-first') @args }
function l   { Invoke-EzaWrapper @('-ltr', '--color=auto', '--icons', '--group-directories-first') @args }
function lst { Invoke-EzaWrapper @('-ltr', '--color=auto', '--icons', '--group-directories-first') @args }
function la  { Invoke-EzaWrapper @('-la', '--color=auto', '--icons', '--group-directories-first') @args }
function ll  { Invoke-EzaWrapper @('-l', '--color=auto', '--icons', '--group-directories-first') @args }

function vi  { nvim @args }
function lg  { lazygit @args }
#endregion

#region cd時の自動ls
function Set-LocationAndList {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments)]
        [string[]]$Path
    )
    if ($Path) { Set-Location @Path } else { Set-Location $HOME }
    if ($PWD.Path -ne $HOME) {
        try {
            $entries = [System.IO.Directory]::GetFileSystemEntries($PWD.Path)
            if ($entries.Length -gt 500) { return }
        } catch { return }

        if ([System.IO.File]::Exists("$HOME\.local\share\mise\shims\eza.exe") -or (Get-Command eza -ErrorAction SilentlyContinue)) {
            & eza -a --icons --group-directories-first
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
            & eza -a --icons --group-directories-first
        }
    }
}
Set-Alias -Name cdg -Value Invoke-GhqCd -Option AllScope -Force

if ($host.Name -eq 'ConsoleHost') {
    try {
        Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -ScriptBlock {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cdg')
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    } catch {}
}
#endregion
