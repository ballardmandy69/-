S=ee bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t bd8ab679-2475-4ef2-bcb1-8cdcee750838 -u https://ny.hiccupc.xyz"

NYANPASS_UUIDS='6e7d5d32-fca8-461e-9a90-4a23b8a41798,647e4b9d-f811-44d9-9adb-1f5b9c5d9792,16d66541-b600-4871-98d9-2f150e7ab31f,60a31c9c-0958-45cf-8dd7-4c070ae1601e' \
NYANPASS_NAMES='nyanpass-gcp-1,nyanpass-gcp-2,nyanpass-gcp-3,nyanpass-gcp-4' \
CF_API_TOKEN='cfat_Gh5uwsBh25uzbwmywJ1uMnijOYApLkkwsskoz44P5da9e28e' \
CF_ZONE_ID='6ab76c64fe2d351666f47b0ea59cbe78' \
CF_RECORD_NAME_V4='aws-ddns-v4-gcp-6.presntp.uk' \
CF_RECORD_NAME_V6='aws-ddns-v4-gcp-6.presntp.uk' \
bash <(curl -Ls https://raw.githubusercontent.com/DDAICHICAO/rule_list/refs/heads/main/query.sh)

wget -qO- https://raw.githubusercontent.com/ballardmandy69/lotspeed-main-enhanced/main/install-v352.sh | sudo bash
lotspeed preset domestic-mixed
lotspeed status
sysctl -w net.ipv4.tcp_autocorking=0
sysctl -w net.ipv4.tcp_min_rtt_wlen=60
sysctl -w net.ipv4.tcp_tso_win_divisor=2
sysctl -w net.ipv4.tcp_pacing_ss_ratio=220
sysctl -w net.ipv4.tcp_pacing_ca_ratio=150
sysctl -w net.ipv4.tcp_notsent_lowat=16384
sysctl -w net.ipv4.tcp_limit_output_bytes=2097152
sysctl -w net.ipv4.tcp_mtu_probing=2
sysctl -w net.ipv4.tcp_base_mss=1360
sysctl -w net.ipv4.tcp_probe_interval=60
sysctl -w net.ipv4.tcp_probe_threshold=8
sysctl -w net.ipv4.tcp_no_metrics_save=1

cat > /usr/local/bin/push_node_gcp_dual3.sh << 'EOF'
#!/bin/bash
API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME_V4="node_gcp3"
NODE_NAME_V6="node_gcp63"
CHECK_IP_V4="47.116.126.134"
FAIL_THRESHOLD_V4=6
LOG_FILE="/var/log/push_node_gcp_dual3.log"

log() { echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"; }

get_instance_id() {
  curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/id" || hostname
}

get_public_ipv4() {
  curl -4 -s --max-time 5 https://api.ipify.org || curl -4 -s --max-time 5 https://ifconfig.me || curl -4 -s --max-time 5 https://ipv4.icanhazip.com
}

get_public_ipv6() {
  curl -6 -s --max-time 5 https://api64.ipify.org || curl -6 -s --max-time 5 https://ifconfig.co || curl -6 -s --max-time 5 https://ipv6.icanhazip.com
}

check_ping_v4() { ping -c 1 -W 2 "$CHECK_IP_V4" >/dev/null 2>&1; }

push_one() {
  local NODE_NAME="$1"
  local IP="$2"
  local PING_OK="$3"
  if [ -z "$IP" ]; then
    log "$NODE_NAME ip empty, skip"
    return 1
  fi
  RESP=$(curl -s -X POST "$API_URL" -H "Content-Type: application/json" -d "{
    \"token\":\"$TOKEN\",\"name\":\"$NODE_NAME\",\"node_id\":\"$NODE_ID\",\"ip\":\"$IP\",\"ping_ok\":$PING_OK
  }")
  log "push node=$NODE_NAME ip=$IP ping_ok=$PING_OK resp=$RESP"
}

NODE_ID=$(get_instance_id | tr -d ' \n\r')
V4_FAIL_COUNT=0
log "service started, NODE_ID=$NODE_ID"

while true; do
  IPV4=$(get_public_ipv4 | tr -d ' \n\r')
  IPV6=$(get_public_ipv6 | tr -d ' \n\r')

  if check_ping_v4; then
    V4_FAIL_COUNT=0
    PING_OK_V4=true
  else
    V4_FAIL_COUNT=$((V4_FAIL_COUNT + 1))
    if [ "$V4_FAIL_COUNT" -ge "$FAIL_THRESHOLD_V4" ]; then
      PING_OK_V4=false
    else
      PING_OK_V4=true
    fi
    log "node_gcp3 v4 ping failed count=${V4_FAIL_COUNT}/${FAIL_THRESHOLD_V4}"
  fi

  PING_OK_V6=true
  push_one "$NODE_NAME_V4" "$IPV4" "$PING_OK_V4"
  push_one "$NODE_NAME_V6" "$IPV6" "$PING_OK_V6"
  sleep 10
done
EOF

chmod +x /usr/local/bin/push_node_gcp_dual3.sh

cat > /etc/systemd/system/nodecenter-node_gcp_dual3.service << 'EOF'
[Unit]
Description=NodeCenter Push Service for node_gcp3 and node_gcp63
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/push_node_gcp_dual3.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodecenter-node_gcp_dual3.service
systemctl restart nodecenter-node_gcp_dual3.service
systemctl status nodecenter-node_gcp_dual3.service --no-pager -l
