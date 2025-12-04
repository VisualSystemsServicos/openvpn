#!/bin/bash

echo "b7&$Lpsb4H1c8$aM4btY3" | sudo -S su - hitfy -c "sudo su -" 


#########################################################################################
##############################    PARAMETROS INICIAIS    ################################
#########################################################################################

# Verifica se os dois argumentos foram fornecidos
if [ $# -lt 2 ]; then
    read -p "Digite o nome do certificado: " cert_name
    read -sp "Digite o Token do GitHub: " git_token
else
    # Recebe parâmetros da linha de execução
    cert_name="$1"
    git_token="$2"
    resposta_guacd="s"
    resposta_openvpn="s"
fi

# Exibe os valores para conferência (opcional)
echo "Nome do certificado: $cert_name"
echo "Token recebido com sucesso."

#########################################################################################
################################    CONFIGURA OPENVPN    ################################
#########################################################################################

# Função para instalar o pacote OpenVPN dependendo da distribuição Linux
instala_pacotes() {
    # Detectar a versão do Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release

        # Verificar o ID da distribuição
        case "$ID" in
        ubuntu | debian | raspbian | kali)
            echo "Sistema baseado em Debian detectado. Pulando a instalação do EPEL."
            ;;
        centos | rhel | fedora | ol | rocky | almalinux)
            # Verificar se o repositório EPEL está instalado
            if ! yum repolist | grep -q "epel"; then
                echo "Repositório EPEL não encontrado. Instalando..."

                case "$VERSION_ID" in
                    6*)
                        epel_url="https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/epel-release-6-8.noarch.rpm"
                        ;;
                    7*)
                        epel_url="https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm"
                        ;;
                    8*)
                        epel_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
                        ;;
                    9*)
                        epel_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm"
                        ;;
                    *)
                        echo "Versão do Linux não suportada para instalação do repositório EPEL."
                        exit 1
                        ;;
                esac

                # Tentar instalar o EPEL diretamente via gerenciador de pacotes
                if ! sudo yum install -y epel-release; then
                    echo "Falha ao instalar o repositório EPEL. Baixando o pacote RPM..."
                    sudo yum install -y "$epel_url"
                fi
            else
                echo "Repositório EPEL já está instalado."
            fi
            ;;
        *)
            echo "Sistema operacional não suportado."
            exit 1
            ;;
        esac
    else
        echo "Arquivo /etc/os-release não encontrado. Não foi possível determinar o sistema operacional."
        exit 1
    fi

    # Verificar se o OpenVPN está instalado
    if ! command -v openvpn &>/dev/null; then
        echo "OpenVPN não encontrado. Instalando o OpenVPN..."
        if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ] || [ "$ID" = "raspbian" ]; then
            sudo apt update && sudo apt install -y openvpn lftp curl
        elif [ "$ID" = "centos" ] || [ "$ID" = "rhel" ] || [ "$ID" = "fedora" ] || [ "$ID" = "ol" ] || [ "$ID" = "rocky" ] || [ "$ID" = "almalinux" ]; then
            sudo yum install -y openvpn lftp curl
        fi
    else
        echo "OpenVPN já está instalado."
    fi
}

# Função para baixar arquivos do GitHub usando curl com verificação de existência
Download_FileFromGitHub() {
    local fileName="$1"
    local destinationPath="$2"
    local token="$3"

    # URL base do repositório (ajuste conforme necessário)
    local repoUrl="https://api.github.com/repos/visualsystemsservicos/certs/contents/$fileName"

    # Verificar se o arquivo existe no repositório
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $token" "$repoUrl")

    if [[ "$response" -eq 404 ]]; then
        echo "Erro: O arquivo $fileName não foi encontrado no repositório."
        exit 1
    elif [[ "$response" -eq 200 ]]; then
        # Baixar o arquivo se ele existir
        curl -H "Authorization: Bearer $token" \
             -H "Accept: application/vnd.github.v3.raw" \
             -o "$destinationPath" \
             "$repoUrl"

        if [[ $? -eq 0 ]]; then
            echo "$fileName baixado com sucesso."
        else
            echo "Erro ao baixar $fileName. Verifique o token e o nome do repositório."
            exit 1
        fi
    else
        echo "Erro: Não foi possível acessar o arquivo $fileName. Código de resposta HTTP: $response."
        exit 1
    fi
}

if [ -z "$resposta_openvpn" ]; then
    read -p "Deseja instalar e configurar o OpenVPN? (s/n): " resposta_openvpn
fi

if [[ "$resposta_openvpn" =~ ^[Ss]$ ]]; then
    echo "Iniciando instalação e configuração do OpenVPN..."

    # Executa a função para instalar os pacotes
    instala_pacotes

    # Validar se o OpenVPN foi instalado corretamente após a execução da função
    if ! command -v openvpn &>/dev/null; then
        echo "Falha ao instalar o OpenVPN. Abortando a execução."
        exit 1
    else
        echo "OpenVPN instalado com sucesso."
    fi

    # Diretório para salvar os arquivos do cliente
    client_dir="/etc/openvpn/client"

    # Criar o diretório caso não exista
    sudo mkdir -p "$client_dir"

    # Lista dos arquivos necessários
    arquivos=("ca.crt" "config.ovpn" "ta.key" "$cert_name.crt" "$cert_name.key" "configura_openvpn.sh" "connect_vpn.sh")

    # Baixar os arquivos do repositório
    for file in "${arquivos[@]}"; do
        Download_FileFromGitHub "$file" "$client_dir/$file" "$git_token"
    done

    # Verificar se os arquivos foram baixados corretamente
    for arquivo in "${arquivos[@]}"; do
        if [ -f "$client_dir/$arquivo" ]; then
            echo "Arquivo $arquivo baixado com sucesso."
        else
            echo "Erro: $arquivo não encontrado no diretório $client_dir."
            exit 1
        fi
    done

    # Mudar permissão e executar o script configura_openvpn.sh com o nome do certificado
    sudo chmod +x "$client_dir/configura_openvpn.sh"
    echo "Executando configura_openvpn.sh com o nome do certificado $cert_name..."
    echo "$cert_name" | sudo "$client_dir/configura_openvpn.sh"

    # Mudar permissão e executar o script connect_vpn.sh
    sudo chmod +x "$client_dir/connect_vpn.sh"
    echo "Conectando à VPN..."
    sudo "$client_dir/connect_vpn.sh"

    echo "Configuração OpenVPN concluída!"

else
    echo "Configuração do OpenVPN cancelada. Pulando para etapa de configuração do Guacd."
fi

#########################################################################################
#################################    CONFIGURA GUACD    #################################
#########################################################################################

instalar_docker() {
    echo "Verificando distribuição e versão..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        ID_LIN=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        VER_ID=$(echo "$VERSION_ID" | cut -d '.' -f1)
    else
        echo "Não foi possível identificar a distribuição Linux."
        return 1
    fi

    echo "Distribuição detectada: $ID_LIN $VER_ID"

    case "$ID_LIN" in
        ubuntu|debian)
            echo "Instalando Docker para $ID_LIN..."
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/$ID_LIN/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$ID_LIN \
              $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo service docker start
            sudo systemctl enable docker
            sudo apt install -y lftp curl
            ;;

        centos|rhel|fedora|ol|rocky|almalinux)
            if [[ "$VER_ID" -eq 7 ]]; then
                echo "Instalando Docker para EL 7..."
                
                # Atualiza repositórios se CentOS 7
                if [[ "$ID_LIN" == "centos" ]]; then
                    echo "Atualizando repositórios para CentOS 7 (Vault)..."
                    cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
[base]
name=CentOS-7 - Base
baseurl=https://vault.centos.org/7.9.2009/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[updates]
name=CentOS-7 - Updates
baseurl=https://vault.centos.org/7.9.2009/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[extras]
name=CentOS-7 - Extras
baseurl=https://vault.centos.org/7.9.2009/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[centosplus]
name=CentOS-7 - CentOSPlus
baseurl=https://vault.centos.org/7.9.2009/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
EOF
                fi

                yum install -y yum-utils device-mapper-persistent-data lvm2 zip unzip
                yum-config-manager --enable ol7_optional_latest || true
                yum-config-manager --enable ol7_addons || true
                yum install -y oraclelinux-developer-release-el7 || true
                yum-config-manager --enable ol7_developer || true
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                systemctl start docker
                systemctl enable docker
                yum install -y lftp curl

            elif [[ "$VER_ID" -eq 8 ]]; then
                echo "Instalando Docker para EL 8..."
                dnf install -y dnf-utils zip unzip
                dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
                dnf remove -y runc || true
                dnf install -y docker-ce --nobest
                systemctl start docker
                systemctl enable docker
                dnf install -y lftp curl

            elif [[ "$VER_ID" -eq 9 ]]; then
                echo "Instalando Docker para EL 9..."
                yum install -y yum-utils
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                systemctl start docker
                systemctl enable docker
                yum install -y lftp curl

            else
                echo "Versão $VER_ID não suportada automaticamente."
                return 1
            fi
            ;;

        *)
            echo "Distribuição $ID_LIN não suportada neste script."
            return 1
            ;;
    esac

    echo "Docker instalado com sucesso!"
}

verifica_docker() {
    echo "Verificando se o Docker está instalado e em execução..."

    if ! command -v docker &>/dev/null; then
        echo "Docker NÃO está instalado."
        return 1
    else
        echo "Docker está instalado."
    fi

    if ! systemctl is-active --quiet docker; then
        echo "Docker NÃO está em execução."
        return 1
    else
        echo "Docker está em execução."
    fi
}

verifica_firewall() {
    porta="22822"

    # Verifica se firewalld está instalado e ativo
    if command -v firewall-cmd &>/dev/null && sudo systemctl is-active --quiet firewalld; then
        echo "firewalld detectado e ativo. Configurando a porta $porta/tcp..."
        sudo firewall-cmd --permanent --add-port=${porta}/tcp
        sudo firewall-cmd --reload
        echo "Porta $porta/tcp adicionada ao firewalld."
        return
    fi

    # Verifica se ufw está instalado e ativo
    if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
        echo "ufw detectado e ativo. Configurando a porta $porta/tcp..."
        sudo ufw allow ${porta}/tcp
        echo "Porta $porta/tcp adicionada ao ufw."
        return
    fi

    echo "Nenhum firewall ativo detectado (firewalld ou ufw). Nenhuma regra aplicada."
}

configura_guacd() {
    echo "Configurando diretórios para o Guacd..."

    sudo mkdir -p /opt/guacd/{drive,record,text_log,repo_guacamole}
    sudo mkdir -p /opt/scripts
    sudo chmod 777 /opt/scripts

    cd /opt/guacd || { echo "Erro ao acessar /opt/guacd"; exit 1; }

    echo "Executando o contêiner Docker do Guacd..."
    sudo docker run --restart=always --name guacd_vss -d \
        -p 22822:4822 \
        -v /opt/guacd/drive:/drive:rw \
        -v /opt/guacd/record:/var/guacamole/record:rw \
        -v /opt/guacd/text_log:/var/guacamole/text_log:rw \
        -v /opt/guacd/repo_guacamole:/REPO_Guacamole \
        guacamole/guacd:1.6.0

    echo "Ajustando permissões dos diretórios..."
    sudo chmod 777 /opt/guacd/{record,text_log,repo_guacamole}
    sudo chown daemon:daemon /opt/guacd/{record,text_log}

    echo "Guacd configurado com sucesso!"
}

instala_scripts_guacd_cron() {
    local dir="/opt/scripts"
    local token="$git_token"
    local repo_base="https://raw.githubusercontent.com/VisualSystemsServicos/scripts_guacd/main"

    mkdir -p "$dir"
    cd "$dir" || { echo "Falha ao acessar $dir"; return 1; }

    echo "Baixando scripts..."
    curl -k -H "Authorization: token $token" -o transfer_file_guacd_ftp.sh "$repo_base/transfer_file_guacd_ftp.sh"
    curl -k -H "Authorization: token $token" -o clean_repo_guacd.sh "$repo_base/clean_repo_guacd.sh"
    curl -k -H "Authorization: token $token" -o .env "$repo_base/.env"

    echo "Dando permissão de execução..."
    chmod +x transfer_file_guacd_ftp.sh
    chmod +x clean_repo_guacd.sh
    chmod 600 .env

    echo "Configurando crontab..."

    # Define o bloco de cron
    CRON_BLOCK=$(cat <<EOF
#### VSS Acesso Seguro
*/5 * * * * /opt/scripts/transfer_file_guacd_ftp.sh
*/10 * * * * /opt/scripts/clean_repo_guacd.sh
EOF
)

    # Só adiciona se o cabeçalho ainda não existir
    if ! crontab -l 2>/dev/null | grep -q "#### VSS Acesso Seguro"; then
        (crontab -l 2>/dev/null; echo "$CRON_BLOCK") | awk '!seen[$0]++' | crontab -
    fi

    echo "Scripts instalados e cron configurado com sucesso."
}

if [ -z "$resposta_guacd" ]; then
    read -p "Deseja configurar o Guacd? (s/n): " resposta_guacd
fi

if [[ "$resposta_guacd" =~ ^[Ss]$ ]]; then
    echo "Iniciando configuração do Guacd..."

    # Verificar se a variável git_token já possui valor
    if [[ -z "$git_token" ]]; then
        # Solicitar o token do GitHub
        read -sp "Digite o token GitHub: " git_token
        echo
    fi

    # Verificação do firewall
    verifica_firewall

    # Verificação e tentativa de instalação do Docker
    echo "Verificando Docker..."
    if ! verifica_docker; then
        echo "Docker não encontrado ou não está em execução. Tentando instalar..."
        instalar_docker

        echo "Reverificando Docker após tentativa de instalação..."
        if ! verifica_docker; then
            echo "Erro: Docker não pôde ser instalado ou iniciado automaticamente."
            exit 1
        fi
    fi

    echo "Docker OK. Continuando com a configuração do Guacd..."

    # Configurando guacd
    configura_guacd

    # Instalando scripts do Guacd e configurando o cron
    instala_scripts_guacd_cron

    echo "Configuração do Guacd concluída com sucesso!"
    echo "Finalizando script de configuração do OpenVPN e Guacd."

    # Remove o script
    sudo rm -rf ./setup_vpn_and_guacd_linux.sh

else
    echo "Configuração do Guacd cancelada. Finalizando script."
    # Remove o script
    sudo rm -rf ./setup_vpn_and_guacd_linux.sh
fi
