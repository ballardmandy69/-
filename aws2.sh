#!/bin/bash


S=zumo OPTIMIZE=1 bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t f96ba212-3920-4160-a5bc-f5b2f218c50e -u https://zumo.moe"
S=ee OPTIMIZE=1 bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t bd8ab679-2475-4ef2-bcb1-8cdcee750838 -u https://ny.hiccupc.xyz"
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_notsent_lowat=98304
sysctl -w net.ipv4.tcp_limit_output_bytes=2097152 
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_max=33554432
sysctl -w net.ipv4.tcp_rmem="8192 262144 33554432"
sysctl -w net.ipv4.tcp_wmem="4096 262144 33554432"
sysctl -w net.ipv4.tcp_early_retrans=2
sysctl -w net.ipv4.tcp_recovery=3      
sysctl -w net.ipv4.tcp_retries1=2
sysctl -w net.ipv4.tcp_retries2=5
sysctl -w net.ipv4.tcp_syn_retries=3
sysctl -w net.ipv4.tcp_frto=2
sysctl -w net.ipv4.tcp_reordering=10 
sysctl -w net.ipv4.tcp_dsack=1           
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.tcp_sack=1  
sysctl -w net.ipv4.tcp_pacing_ss_ratio=300
sysctl -w net.ipv4.tcp_pacing_ca_ratio=150
sysctl -w net.core.netdev_budget=3000
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5


wget -qO- https://raw.githubusercontent.com/uk0/lotspeed/main/install.sh | sudo bash
lotspeed preset aggressive
lotspeed set lotserver_adaptive 0
lotspeed set lotserver_rate 50000000
lotspeed set lotserver_gain 40
lotspeed set lotserver_beta 896
lotspeed set lotserver_max_cwnd 8000
lotspeed set lotserver_min_cwnd 64
sysctl -w net.ipv4.tcp_no_metrics_save=1


cat > /usr/local/bin/push_node_c.sh << 'EOF'
#!/bin/bash
API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME="node_c"
CHECK_IP="47.116.126.134"

get_instance_id() {
  TOKEN_AWS=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)
  if [ -n "$TOKEN_AWS" ]; then
    curl -s -H "X-aws-ec2-metadata-token: $TOKEN_AWS" http://169.254.169.254/latest/meta-data/instance-id
  else
    hostname
  fi
}

get_public_ip() {
  curl -4 -s --max-time 10 https://api.ipify.org
}

check_ping() {
  ping -c 1 -W 2 "$CHECK_IP" >/dev/null 2>&1
}

NODE_ID=$(get_instance_id)

push_ip() {
  PUBLIC_IP=$(get_public_ip)
  [ -z "$PUBLIC_IP" ] && return 1

  if check_ping; then
    PING_OK=true
  else
    PING_OK=false
  fi

  curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\":\"$TOKEN\",
      \"name\":\"$NODE_NAME\",
      \"node_id\":\"$NODE_ID\",
      \"ip\":\"$PUBLIC_IP\",
      \"ping_ok\":$PING_OK
    }"
}

while true; do
  push_ip >/dev/null 2>&1 || true
  sleep 10
done
EOF

chmod +x /usr/local/bin/push_node_c.sh

cat > /etc/systemd/system/nodecenter-node_c.service << 'EOF'
[Unit]
Description=NodeCenter Push Service for node_c
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/push_node_c.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodecenter-node_c.service
systemctl restart nodecenter-node_c.service
systemctl status nodecenter-node_c.service --no-pager


apt update && apt install -y jq cron netcat-openbsd iputils-ping util-linux && curl -kfsSL https://tools.airport-v2.com/node-ddns/abc.sh | bash
