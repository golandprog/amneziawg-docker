random() {
    echo $(($RANDOM % $(($2 - $1 + 1)) + $1))
}

if [ -d "awg" ]; then
    echo "Folder 'awg' already exists!"
    echo "Please remove this folder before running this script!"
    exit
fi

# Build app
docker build -t amneziawg .

# Prepare environment
AWG_SERVER_PORT=$(random 1024 49151)
SUBNET=10.$(random 0 255).$(random 0 255)
MAGICAL_VALUES=$(./generate_magical_values.sh)

# Generate .env file
cp .env.example .env
sed -i -E "s/AWG_SERVER_PORT=(.*)/AWG_SERVER_PORT=${AWG_SERVER_PORT}/" .env

# Generate WG keys
WIREGUARD_SERVER_PRIVATE_KEY=$(docker run --rm --entrypoint /bin/sh amneziawg -c "wg genkey")
WIREGUARD_SERVER_PUBLIC_KEY=$(docker run --rm --entrypoint /bin/sh amneziawg -c "echo $WIREGUARD_SERVER_PRIVATE_KEY | wg pubkey")
echo ${WIREGUARD_SERVER_PUBLIC_KEY} > publickey

# Generate wg0.conf file
mkdir -p awg
cat > awg/wg0.conf <<EOF
[Interface]
PrivateKey = ${WIREGUARD_SERVER_PRIVATE_KEY}
Address = ${SUBNET}.1/32
ListenPort = 51820
PostUp = iptables -t nat -A POSTROUTING -s ${SUBNET}.0/24 -o eth0 -j MASQUERADE; iptables -A INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT;
PostDown = iptables -t nat -D POSTROUTING -s ${SUBNET}.0/24 -o eth0 -j MASQUERADE; iptables -D INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT;
${MAGICAL_VALUES}

#[Peer]
#PublicKey = <put_pub_key_here>
#AllowedIPs = ${SUBNET}.<put_octet_here>/32
#PersistentKeepalive = 25

EOF

# Run WG
docker compose up -d

# Echo example
echo ""
echo "--- Client configuration example: ---"
echo ""
cat <<EOF
[Interface]
PrivateKey = <put_client_private_key_here>
Address = ${SUBNET}.<put_octet_here>/32
${MAGICAL_VALUES}

[Peer]
PublicKey = ${WIREGUARD_SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = <put_server_ip_here>:${AWG_SERVER_PORT}
PersistentKeepalive = 25
EOF

# Echo end
echo ""
echo "------------"
echo ""
echo "Please edit awg/wg0.conf file to add peers, then run 'docker compose restart'"
echo ""
