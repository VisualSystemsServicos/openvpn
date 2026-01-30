#!/bin/bash

echo "Baixando arquivos..."

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/ta.key" -o /etc/openvpn/client/ta.key
echo "Arquivo ta.key baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/connect_vpn.sh" -o /etc/openvpn/client/connect_vpn.sh && chmod +x /etc/openvpn/client/connect_vpn.sh
echo "Arquivo connect_vpn.sh baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/configura_openvpn.sh" -o /etc/openvpn/client/configura_openvpn.sh && chmod +x /etc/openvpn/client/configura_openvpn.sh
echo "Arquivo configura_openvpn.sh baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/config.ovpn" -o /etc/openvpn/client/config.ovpn
echo "Arquivo config.ovpn baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/ca.crt" -o /etc/openvpn/client/ca.crt
echo "Arquivo ca.crt baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/bravolog.key" -o /etc/openvpn/client/bravolog.key
echo "Arquivo bravolog.key baixado com sucesso!"

curl -sL "https://raw.githubusercontent.com/visualsystemsservicos/openvpn/main/bravolog.crt" -o /etc/openvpn/client/bravolog.crt
echo "Arquivo bravolog.crt baixado com sucesso!"

echo "Tentando iniciar VPN..."

sh /etc/openvpn/client/connect_vpn.sh