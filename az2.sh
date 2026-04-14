#!/bin/bash



S=ee OPTIMIZE=1 bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t bd8ab679-2475-4ef2-bcb1-8cdcee750838 -u https://ny.hiccupc.xyz"
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
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
sysctl -w net.ipv4.tcp_autocorking=0
sysctl -w net.ipv4.tcp_min_rtt_wlen=60
sysctl -w net.ipv4.tcp_tso_win_divisor=1
sysctl -w net.ipv4.tcp_notsent_lowat=262144
tc qdisc replace dev eth root fq
tc qdisc del dev eth root
tc -s qdisc show dev eth




wget -qO- https://raw.githubusercontent.com/uk0/lotspeed/main/install.sh | sudo bash
lotspeed preset aggressive
lotspeed set lotserver_adaptive 0
lotspeed set lotserver_rate 80000000
lotspeed set lotserver_gain 40
lotspeed set lotserver_beta 896
lotspeed set lotserver_max_cwnd 8000
lotspeed set lotserver_min_cwnd 64
sysctl -w net.ipv4.tcp_no_metrics_save=1

cat > /usr/local/bin/push_node_az2.sh << 'EOF'
#!/bin/bash
API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME="node_az2"
CHECK_IP="47.116.126.134"
LOG_FILE="/var/log/push_node_az2.log"

log() {
  echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"
}

get_instance_id() {
  # Azure IMDS
  curl -s -H "Metadata:true" \
    "http://169.254.169.254/metadata/instance/compute/vmId?api-version=2021-02-01&format=text" \
    || hostname
}

get_public_ip() {
  curl -4 -s --max-time 5 https://api.ipify.org || \
  curl -4 -s --max-time 5 https://ifconfig.me || \
  curl -4 -s --max-time 5 https://ipv4.icanhazip.com
}

check_ping() {
  ping -c 1 -W 2 "$CHECK_IP" >/dev/null 2>&1
}

NODE_ID=$(get_instance_id)
log "service started, NODE_ID=$NODE_ID"

push_ip() {
  PUBLIC_IP=$(get_public_ip | tr -d ' \n\r')

  if [ -z "$PUBLIC_IP" ]; then
    log "PUBLIC_IP empty"
    return 1
  fi

  if check_ping; then
    PING_OK=true
  else
    PING_OK=false
  fi

  RESP=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\":\"$TOKEN\",
      \"name\":\"$NODE_NAME\",
      \"node_id\":\"$NODE_ID\",
      \"ip\":\"$PUBLIC_IP\",
      \"ping_ok\":$PING_OK
    }")

  log "push ip=$PUBLIC_IP ping_ok=$PING_OK resp=$RESP"
}

while true; do
  push_ip || true
  sleep 10
done
EOF

chmod +x /usr/local/bin/push_node_az2.sh

cat > /etc/systemd/system/nodecenter-node_az2.service << 'EOF'
[Unit]
Description=NodeCenter Push Service for node_az2
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/push_node_az2.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodecenter-node_az2.service
systemctl restart nodecenter-node_az2.service
systemctl status nodecenter-node_az2.service --no-pager
