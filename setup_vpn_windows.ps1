# Função para verificar se o OpenVPN está instalado
function Check-Program {
    param (
        [string]$programName,
        [string]$installCommand,
        [string]$programPath
    )
    
    if (-not (Test-Path $programPath)) {
        Write-Host "$programName não encontrado. Instalando..."
        Invoke-Expression $installCommand
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Erro ao instalar $programName. Verifique os logs."
            exit 1
        } else {
            Write-Host "$programName instalado com sucesso."
        }
    } else {
        Write-Host "$programName já está instalado."
    }
}

# Validar OpenVPN
Check-Program -programName "OpenVPN" -installCommand "winget install --id OpenVPNTechnologies.OpenVPN -e --source winget" -programPath "C:\Program Files\OpenVPN\bin\openvpn.exe"

# Solicitar token do GitHub
$token = Read-Host "Insira o token do GitHub"

# Solicitar nome de usuário
$nomeUsuario = Read-Host "Insira o nome de usuário"

# URL base do repositório
$repoUrl = "https://api.github.com/repos/visualsystemsservicos/certs/contents"

# Função para baixar arquivos do GitHub com verificação de existência
function Download-FileFromGitHub {
    param (
        [string]$fileName,
        [string]$destinationPath,
        [string]$token
    )

    # URL da API do GitHub para verificar a existência do arquivo
    $fileUrl = "$repoUrl/$fileName"
    $headers = @{
        Authorization = "Bearer $token"
        Accept        = "application/vnd.github.v3.raw"
    }

    try {
        # Verificar se o arquivo existe no repositório
        $response = Invoke-RestMethod -Uri $fileUrl -Headers $headers -Method Get -ErrorAction Stop

        # Se o arquivo existir, faz o download
        Invoke-WebRequest -Uri $fileUrl -Headers $headers -OutFile $destinationPath
        Write-Host "$fileName baixado com sucesso."
    } catch {
        # Se o arquivo não for encontrado (erro 404), exibe mensagem de erro
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Error "Erro: O arquivo $fileName não foi encontrado no repositório."
        } else {
            Write-Error "Erro ao tentar acessar o arquivo $fileName. Detalhes: $($_.Exception.Message)"
        }
        # Adicionando linha para evitar o fechamento da janela do PowerShell
        Write-Host "Pressione Enter para sair."
        Read-Host
        exit 1
    }
}

# Caminho de destino
$destPath = "C:\Program Files\OpenVPN\config"

# Criar o diretório se não existir
if (-not (Test-Path $destPath)) {
    New-Item -Path $destPath -ItemType Directory | Out-Null
}

# Lista de arquivos a serem baixados
$files = @("ca.crt", "ta.key", "windows.ovpn", "$nomeUsuario.crt", "$nomeUsuario.key")

# Fazer download dos arquivos
foreach ($file in $files) {
    Download-FileFromGitHub -fileName $file -destinationPath "$destPath\$file" -token $token
}

# Modificar o arquivo windows.ovpn
$ovpnFilePath = "$destPath\windows.ovpn"
Add-Content -Path $ovpnFilePath -Value "cert $nomeUsuario.crt"
Add-Content -Path $ovpnFilePath -Value "key $nomeUsuario.key"

Write-Host "Configurações adicionadas ao arquivo windows.ovpn."

# Configurando conexão automática no reinício
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\OpenVPN.lnk"
$configFilePath = "$destPath\windows.ovpn"

if (Test-Path $configFilePath) {
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut($startupPath)
        $shortcut.TargetPath = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"
        $shortcut.Arguments = "--connect windows.ovpn --silent_connection 1"
        $shortcut.WindowStyle = 7
        $shortcut.Save()
        Write-Output "Atalho para OpenVPN criado em $startupPath"
    } catch {
        Write-Output "Erro ao criar o atalho para OpenVPN: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Output "Arquivo de configuração não encontrado: $configFilePath"
    exit 1
}

# Executa o atalho para iniciar o OpenVPN imediatamente
if (Test-Path $startupPath) {
    try {
        Start-Process -FilePath $startupPath
        Write-Output "OpenVPN iniciado a partir do atalho em $startupPath"
    } catch {
        Write-Output "Erro ao iniciar o OpenVPN: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Output "Atalho de inicialização do OpenVPN não encontrado: $startupPath"
    exit 1
}

Write-Output "Instalação e configuração concluídas. O OpenVPN Client será iniciado automaticamente com o sistema. Caso não tenha iniciado, abra o Executar e rode o seguinte comando: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\OpenVPN.lnk"
