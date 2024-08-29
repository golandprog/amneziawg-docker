# AmneziaWG Docker Compose

Ported deployment scripts from [Amnezia Client](https://github.com/amnezia-vpn/amnezia-client)

# Running on your server

Lazy way:
1. Run `./deploy.sh`
2. Copy client configuration from terminal to your AmneziaWG client and edit `Interface.Address` and `Peer.Endpoint` values
3. Open `./awg/wg0.conf` file and edit `Peer.PublicKey` and `Peer.AllowedIPs` values

Extended way:
1. Build app `docker build -t amneziawg .`
2. Copy and edit example `cp .env.example .env`
3. Generate private key `docker run --rm --entrypoint /bin/sh amneziawg -c "wg genkey"`
4. Generate public key `docker run --rm --entrypoint /bin/sh amneziawg -c "echo <PRIVATE_KEY_HERE> | wg pubkey"`
5. Generate magic fields ```./generate_magical_values.sh```
6. Make `awg/wg0.conf` file
```
[Interface]
PrivateKey = <PRIVATE_KEY_HERE>
Address = 10.88.0.1/32
ListenPort = <PORT_HERE>
PostUp = iptables -t nat -A POSTROUTING -s 10.88.0.0/24 -o eth0 -j MASQUERADE; iptables -A INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT;
PostDown = iptables -t nat -D POSTROUTING -s 10.88.0.0/24 -o eth0 -j MASQUERADE; iptables -D INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT;
<MAGICAL VALUES HERE>

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY_HERE>
AllowedIPs = 10.88.0.2/32
PersistentKeepalive = 25
```
7. Run AmneziaWG `docker compose up -d`
8. Setup config on your device
```
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY_HERE>
Address = 10.88.0.2/32
<MAGICAL VALUES HERE>

[Peer]
PublicKey = <PUBLIC_KEY_HERE>
AllowedIPs = 0.0.0.0/0
Endpoint = <SERVER_IP>:<PORT_HERE>
PersistentKeepalive = 25
```
