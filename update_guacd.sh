#!/bin/bash

#########################################################################################
#####################################    UPDATE    ######################################
#########################################################################################

configura_guacd() {
    echo "Configurando diretórios para o Guacd..."

    cd /opt/guacd || { echo "Erro ao acessar /opt/guacd"; exit 1; }

    echo "Executando o contêiner Docker do Guacd..."
    sudo docker run --restart=always --name guacd_vss -d \
        -p 22822:4822 \
        -v /opt/guacd/drive:/drive:rw \
        -v /opt/guacd/record:/var/guacamole/record:rw \
        -v /opt/guacd/text_log:/var/guacamole/text_log:rw \
        -v /opt/guacd/repo_guacamole:/REPO_Guacamole \
        guacamole/guacd:1.6.0

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
    curl -k -H "Authorization: token $token" -o clean_repo_guacamole.sh "$repo_base/clean_repo_guacd.sh"
    curl -k -H "Authorization: token $token" -o kill_services_guacd.sh "$repo_base/kill_services_guacd.sh"
    curl -k -H "Authorization: token $token" -o .env "$repo_base/.env"

    echo "Dando permissão de execução..."
    chmod +x transfer_file_guacd_ftp.sh
    chmod +x clean_repo_guacamole.sh
    chmod +x kill_services_guacd.sh
    chmod 600 .env

    echo "Configurando crontab..."
    (crontab -l 2>/dev/null; echo "*/5 * * * * /opt/scripts/transfer_file_guacd_ftp.sh") | sort -u | crontab -
    (crontab -l 2>/dev/null; echo "*/10 * * * * /opt/scripts/clean_repo_guacamole.sh") | sort -u | crontab -
    (crontab -l 2>/dev/null; echo "*/10 * * * * /opt/scripts/kill_services_guacd.sh") | sort -u | crontab -

    echo "Scripts instalados e cron configurado com sucesso."
}

read -p "Deseja atualizar o Guacd? (s/n): " resposta
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    echo "Iniciando configuração do Guacd..."

    # Verificar se a variável git_token já possui valor
    if [[ -z "$git_token" ]]; then
        # Solicitar o token do GitHub
        read -sp "Digite o token GitHub: " git_token
        echo
    fi

    # Parando e removendo o contêiner existente, se houver
    docker stop guacd_vss
    docker rm guacd_vss

    # Configurando guacd
    configura_guacd

    # Removendo scripts antigos, se existirem
    rm -rf /opt/scripts/transfer_file_guacd_ftp.sh
    rm -rf /opt/scripts/clean_repo_guacd.sh
    rm -rf /opt/scripts/clear_repo_guacd.sh
    rm -rf /opt/scripts/kill_services_guacd.sh

    # Instalando scripts do Guacd e configurando o cron
    instala_scripts_guacd_cron

    echo "Update do Guacd concluída com sucesso!"

    # Remove o script
    sudo rm -rf ./update_guacd.sh

else
    echo "Configuração do Guacd cancelada. Finalizando script."
    # Remove o script
    sudo rm -rf ./update_guacd.sh
fi
