random() {
    local min=$1
    local max=$2
    local range=$((max - min + 1))
    local rand_num=$(dd if=/dev/urandom bs=1 count=4 2>/dev/null | od -A n -t u4 | tr -d ' ')
    echo $((rand_num % range + min))
}

# https://github.com/amnezia-vpn/amnezia-client/blob/d800a95a1dc72652dab173f6267bbebce9a83239/client/ui/models/protocols/awgConfigModel.h#L10-L11
messageInitiationSize=148
messageResponseSize=92

# https://github.com/amnezia-vpn/amnezia-client/blob/d800a95a1dc72652dab173f6267bbebce9a83239/client/ui/controllers/installController.cpp#L101-L125
junkPacketCount=$(random 2 5)
junkPacketMinSize=10
junkPacketMaxSize=50

s1=$(random 15 150)
s2=$(random 15 150)

while [ $((s1 + messageInitiationSize)) -eq $((s2 + messageResponseSize)) ]; do
    s2=$(random 15 150)
done

initPacketJunkSize=$s1
responsePacketJunkSize=$s2

initPacketMagicHeader=$(random 5 2147483647)
responsePacketMagicHeader=$(random 5 2147483647)
underloadPacketMagicHeader=$(random 5 2147483647)
transportPacketMagicHeader=$(random 5 2147483647)

echo "Jc = $junkPacketCount"
echo "Jmin = $junkPacketMinSize"
echo "Jmax = $junkPacketMaxSize"
echo "S1 = $initPacketJunkSize"
echo "S1 = $responsePacketJunkSize"
echo "H1 = $initPacketMagicHeader"
echo "H2 = $responsePacketMagicHeader"
echo "H3 = $underloadPacketMagicHeader"
echo "H4 = $transportPacketMagicHeader"
