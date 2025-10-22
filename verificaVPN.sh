#! /bin/bash
# Script de validacao da VPN OpenVPNxGuacamole

VPN_GATEWAY="10.255.253.1"
VPN_PORT="1194"
VPN_DIR="/etc/openvpn/client"
VPN_FILES=("ca.crt" "configura_openvpn.sh" "ta.key" "config.ovpn" "connect_vpn.sh")
LOG_FILE="/tmp/verificaVPN.log"

# Redireciona saída padrão e erros para o log + tela
exec > >(tee -a "$LOG_FILE") 2>&1

echo "====================================="
echo " Execução do script em: $(date '+%Y-%m-%d %H:%M:%S')"
echo "====================================="

# Função para verificar placa de rede
check_network_interface() {
    # Verifica interface de rede
    echo "Verificando interface de rede..."
    if ip a | grep -q "$VPN_GATEWAY"; then
        echo "Interface de rede $VPN_GATEWAY encontrada."
        return 0
    else
        echo "Interface de rede $VPN_GATEWAY nao encontrada."
        return 1
    fi
}

# Função para verificar se a VPN está ativa
check_vpn() {
    echo "Verificando se gateway esta comunicando..."
    if ping -c 2 $VPN_GATEWAY > /dev/null 2>&1; then
        echo "Gateway $VPN_GATEWAY esta comunicando."
        return 0
    else
        echo "Gateway $VPN_GATEWAY nao esta comunicando."
        return 1
    fi
}

check_files_vpn() {
    echo -e "Verificando arquivos no diretório $VPN_DIR..."
    local missing=0

    for file in "${VPN_FILES[@]}"; do
        if [ -f "$VPN_DIR/$file" ]; then
            echo "Arquivo encontrado: $file"
        else
            echo "Arquivo ausente: $file"
            missing=1
        fi
    done

    if [ $missing -eq 0 ]; then
        echo "Todos os arquivos necessários estão presentes."
        return 0
    else
        echo "Um ou mais arquivos estão faltando."
        return 1
    fi
}

check_firewall() {
    echo "Verificando firewall local..."
    if command -v ufw &>/dev/null; then
        if ufw status | grep -q "Status: active"; then
            echo "Firewall ativo. Verificando porta $VPN_PORT..."
            if ufw status | grep -q "$VPN_PORT/tcp" && ufw status | grep -q "$VPN_PORT/udp"; then
                echo "Porta $VPN_PORT já liberada"
            else
                echo "Porta $VPN_PORT não está liberada. Liberando agora..."
                sudo ufw allow $VPN_PORT/tcp
                sudo ufw allow $VPN_PORT/udp
                echo "Porta $VPN_PORT liberada no UFW (TCP/UDP)"
            fi
        else
            echo "Firewall inativo"
        fi

    elif systemctl is-active firewalld &>/dev/null; then
        echo "Firewalld ativo. Verificando porta $VPN_PORT..."
        if firewall-cmd --list-ports | grep -q "$VPN_PORT"; then
            echo "Porta $VPN_PORT já liberada"
        else
            echo "Porta $VPN_PORT não está liberada. Liberando agora..."
            sudo firewall-cmd --permanent --add-port=${VPN_PORT}/tcp
            sudo firewall-cmd --permanent --add-port=${VPN_PORT}/udp
            sudo firewall-cmd --reload
            echo "Porta $VPN_PORT liberada no firewalld (TCP/UDP)"
        fi

    else
        echo "Nenhum firewall detectado"
    fi
}

start_process_vpn() {
    echo -e "Subindo serviço do OpenVPN..."
    cd $VPN_DIR || { echo "Diretório $VPN_DIR não encontrado"; exit 1; }

    if [ -x "./connect_vpn.sh" ]; then
        ./connect_vpn.sh &
        sleep 5
        echo "Script de conexão executado"
    else
        echo "Script connect_vpn.sh não encontrado ou sem permissão de execução"
    fi
}

restart_process_vpn() {
    echo -e "Verificando processos do OpenVPN..."
    ps aux | grep "[o]penvpn"

    # Conta quantos processos openvpn existem
    local count=$(pgrep -c openvpn)

    if [ "$count" -eq 0 ]; then
        echo "Nenhum processo OpenVPN ativo. Iniciando..."
        start_process_vpn

    elif [ "$count" -eq 1 ]; then
        local pid=$(pgrep openvpn)
        echo "Apenas 1 processo OpenVPN ativo (PID: $pid). Reiniciando..."
        sudo kill -9 "$pid"
        sleep 2
        echo "Processo $pid encerrado."
        start_process_vpn

    else
        echo "Existem $count processos OpenVPN ativos. Não será encerrado para evitar derrubar outras VPNs."
    fi
}

## Corpo do script

# Verifica placa de rede
check_network_interface
if [ $? -eq 0 ]; then
    echo "Interface de rede encontrada."
    # Verifica se a VPN esta ativa
    check_vpn
    if [ $? -eq 0 ]; then
        echo "VPN esta ativa."
        echo "Script finalizado com VPN ativa."
        exit 0
    fi
fi

# Verifica firewall local
check_firewall

# Verifica se a VPN ficou ativa
check_vpn
    if [ $? -eq 0 ]; then
        echo "VPN esta ativa."
        echo "Script finalizado com VPN ativa."
        exit 0
    fi

# Verifica arquivos da VPN
check_files_vpn
if [ $? -eq 1 ]; then
    echo "Um ou mais arquivos da VPN estão faltando."
    echo "Script finalizado com VPN inativa."
    exit 1
fi

# Reinicia processo da VPN
restart_process_vpn

# Verifica se a VPN ficou ativa
check_vpn
if [ $? -eq 0 ]; then
    echo "VPN esta ativa."
    echo "Script finalizado com VPN ativa."
    exit 0
fi

echo "Script finalizado com VPN inativa."
exit 1