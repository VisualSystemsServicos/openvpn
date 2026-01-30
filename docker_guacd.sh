
#!/bin/bash

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
