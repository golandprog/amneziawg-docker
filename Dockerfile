# https://github.com/amnezia-vpn/amnezia-client/blob/d800a95a1dc72652dab173f6267bbebce9a83239/client/server_scripts/awg/Dockerfile

FROM amneziavpn/amnezia-wg:latest

LABEL maintainer="AmneziaVPN"

#Install required packages
RUN apk add --no-cache bash curl dumb-init
RUN apk --update upgrade --no-cache

RUN mkdir -p /opt/amnezia
# --- MODIFICATION START ---
# --- OLD SECTION
#RUN echo -e "#!/bin/bash\ntail -f /dev/null" > /opt/amnezia/start.sh
# --- NEW SECTION ---
RUN echo -e "#!/bin/bash\nwg-quick up /etc/wireguard/wg0.conf\ntail -f /dev/null" >> /opt/amnezia/start.sh
# --- MODIFICATION END ---
RUN chmod a+x /opt/amnezia/start.sh

# Tune network  
RUN echo -e " \n\
  fs.file-max = 51200 \n\
  \n\
  net.core.rmem_max = 67108864 \n\
  net.core.wmem_max = 67108864 \n\
  net.core.netdev_max_backlog = 250000 \n\
  net.core.somaxconn = 4096 \n\
  \n\
  net.ipv4.tcp_syncookies = 1 \n\
  net.ipv4.tcp_tw_reuse = 1 \n\
  net.ipv4.tcp_tw_recycle = 0 \n\
  net.ipv4.tcp_fin_timeout = 30 \n\
  net.ipv4.tcp_keepalive_time = 1200 \n\
  net.ipv4.ip_local_port_range = 10000 65000 \n\
  net.ipv4.tcp_max_syn_backlog = 8192 \n\
  net.ipv4.tcp_max_tw_buckets = 5000 \n\
  net.ipv4.tcp_fastopen = 3 \n\
  net.ipv4.tcp_mem = 25600 51200 102400 \n\
  net.ipv4.tcp_rmem = 4096 87380 67108864 \n\
  net.ipv4.tcp_wmem = 4096 65536 67108864 \n\
  net.ipv4.tcp_mtu_probing = 1 \n\
  net.ipv4.tcp_congestion_control = hybla \n\
  # for low-latency network, use cubic instead \n\
  # net.ipv4.tcp_congestion_control = cubic \n\
  " | sed -e 's/^\s\+//g' | tee -a /etc/sysctl.conf && \
  mkdir -p /etc/security && \
  echo -e " \n\
  * soft nofile 51200 \n\
  * hard nofile 51200 \n\
  " | sed -e 's/^\s\+//g' | tee -a /etc/security/limits.conf  

ENTRYPOINT [ "dumb-init", "/opt/amnezia/start.sh" ]
CMD [ "" ]
