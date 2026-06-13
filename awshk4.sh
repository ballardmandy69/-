#!/bin/bash



S=ee  bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t bd8ab679-2475-4ef2-bcb1-8cdcee750838 -u https://ny.hiccupc.xyz"
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
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
sysctl -w net.ipv4.tcp_autocorking=0
sysctl -w net.ipv4.tcp_min_rtt_wlen=60
sysctl -w net.ipv4.tcp_tso_win_divisor=2
sysctl -w net.ipv4.tcp_pacing_ss_ratio=220
sysctl -w net.ipv4.tcp_pacing_ca_ratio=150
sysctl -w net.ipv4.tcp_notsent_lowat=131072
sysctl -w net.ipv4.tcp_limit_output_bytes=8388608
sysctl -w net.ipv4.tcp_mtu_probing=2
sysctl -w net.ipv4.tcp_base_mss=1360
sysctl -w net.ipv4.tcp_probe_interval=60
sysctl -w net.ipv4.tcp_probe_threshold=8
sysctl -w net.ipv4.tcp_no_metrics_save=1
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5




wget -qO- https://raw.githubusercontent.com/uk0/lotspeed/main/install.sh | sudo bash
lotspeed preset aggressive
lotspeed set lotserver_adaptive 0
lotspeed set lotserver_rate 45000000
lotspeed set lotserver_gain 28
lotspeed set lotserver_beta 820
lotspeed set lotserver_max_cwnd 6000
lotspeed set lotserver_min_cwnd 32
sysctl -w net.ipv4.tcp_no_metrics_save=1

cat > /usr/local/bin/push_node_hk.sh << 'EOF'
#!/bin/bash

API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME_V4="node_hk"
NODE_NAME_V6="node_hk6"
CHECK_IP_V4="47.116.126.134"

CHANGE_COOLDOWN=90
LAST_CHANGE_FILE="/tmp/node_hk_last_change_ip"
LOG_FILE="/var/log/nodecenter_node_hk.log"

AWS_SB_AUTH_TOKEN="e85a4ba72df64a2c90f97ef45b2dc211"
AWS_SB_SHARE_GROUP_TOKEN="711485a7d8634926b47ca0d994e08c5a"

log() {
  echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"
}

get_aws_token() {
  curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"
}

get_instance_id() {
  local TOKEN_AWS
  TOKEN_AWS=$(get_aws_token || true)

  if [ -n "$TOKEN_AWS" ]; then
    curl -s -H "X-aws-ec2-metadata-token: $TOKEN_AWS" \
      http://169.254.169.254/latest/meta-data/instance-id
  else
    hostname
  fi
}

get_region_from_share_api() {
  local INSTANCE_ID="$1"

  curl -s "https://api.aws.sb/ec2-instance-shares?r=$(tr -dc 'a-z0-9' </dev/urandom | head -c 11)" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Origin: https://aws.sb" \
    -H "X-Auth-Token: ${AWS_SB_AUTH_TOKEN}" \
    -H "X-Share-Group-Token: ${AWS_SB_SHARE_GROUP_TOKEN}" \
    | grep -oP '{[^}]*"instanceId"\s*:\s*"'$INSTANCE_ID'"[^}]*"regionName"\s*:\s*"\K[^"]+'
}

get_public_ipv4() {
  curl -4 -s --max-time 5 https://api.ipify.org || \
  curl -4 -s --max-time 5 https://ifconfig.me || \
  curl -4 -s --max-time 5 https://ipv4.icanhazip.com
}

get_public_ipv6() {
  curl -6 -s --max-time 5 https://api64.ipify.org || \
  curl -6 -s --max-time 5 https://ifconfig.co || \
  curl -6 -s --max-time 5 https://ipv6.icanhazip.com
}

check_ping_v4() {
  ping -c 1 -W 2 "$CHECK_IP_V4" >/dev/null 2>&1
}

random_r() {
  tr -dc 'a-z0-9' < /dev/urandom | head -c 11
}

change_ip() {
  local NOW LAST REGION_NAME CHANGE_IPV4_URL CHANGE_IPV6_URL NODE_ID
  local R_IPV4 R_IPV6 IPV4_RESP IPV6_RESP

  NOW=$(date +%s)
  LAST=0
  [ -f "$LAST_CHANGE_FILE" ] && LAST=$(cat "$LAST_CHANGE_FILE")

  if [ $((NOW - LAST)) -lt "$CHANGE_COOLDOWN" ]; then
    return 0
  fi

  NODE_ID=$(get_instance_id)

  if [ -z "$NODE_ID" ]; then
    log "node_hk change ip skipped: NODE_ID empty"
    return 1
  fi

  REGION_NAME=$(get_region_from_share_api "$NODE_ID")

  if [ -z "$REGION_NAME" ]; then
    log "node_hk change ip skipped: region not found for instance=${NODE_ID}"
    return 1
  fi

  CHANGE_IPV4_URL="https://api.aws.sb/ec2-instances/${NODE_ID}/ip-address"
  CHANGE_IPV6_URL="https://api.aws.sb/ec2-instances/${NODE_ID}/ipv6/addresses"
  R_IPV4=$(random_r)
  R_IPV6=$(random_r)

  log "node_hk change ip... instance=${NODE_ID} region=${REGION_NAME}"

  IPV4_RESP=$(curl -s -X PATCH "${CHANGE_IPV4_URL}?r=${R_IPV4}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Origin: https://aws.sb" \
    -H "X-Auth-Token: ${AWS_SB_AUTH_TOKEN}" \
    -H "X-Region-Name: ${REGION_NAME}" \
    -H "X-Share-Group-Token: ${AWS_SB_SHARE_GROUP_TOKEN}" \
    -d '{"ipAddress":""}' \
    --max-time 30 2>&1)

  IPV6_RESP=$(curl -s -X PUT "${CHANGE_IPV6_URL}?r=${R_IPV6}" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Origin: https://aws.sb" \
    -H "X-Auth-Token: ${AWS_SB_AUTH_TOKEN}" \
    -H "X-Region-Name: ${REGION_NAME}" \
    -H "X-Share-Group-Token: ${AWS_SB_SHARE_GROUP_TOKEN}" \
    --max-time 30 2>&1)

  log "node_hk ipv4 change resp=${IPV4_RESP}"
  log "node_hk ipv6 allocate resp=${IPV6_RESP}"

  echo "$NOW" > "$LAST_CHANGE_FILE"
  sleep 30
}

push_one() {
  local NODE_NAME="$1"
  local NODE_ID="$2"
  local IP="$3"
  local PING_OK="$4"

  [ -z "$IP" ] && return 1

  curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\":\"$TOKEN\",
      \"name\":\"$NODE_NAME\",
      \"node_id\":\"$NODE_ID\",
      \"ip\":\"$IP\",
      \"ping_ok\":$PING_OK
    }" >/dev/null 2>&1
}

while true; do
  NODE_ID=$(get_instance_id | tr -d ' \n\r')
  IPV4=$(get_public_ipv4 | tr -d ' \n\r')
  IPV6=$(get_public_ipv6 | tr -d ' \n\r')

  if check_ping_v4; then
    PING_OK_V4=true
  else
    PING_OK_V4=false
    change_ip
    NODE_ID=$(get_instance_id | tr -d ' \n\r')
    IPV4=$(get_public_ipv4 | tr -d ' \n\r')
    IPV6=$(get_public_ipv6 | tr -d ' \n\r')
  fi

  PING_OK_V6=true

  push_one "$NODE_NAME_V4" "$NODE_ID" "$IPV4" "$PING_OK_V4"
  push_one "$NODE_NAME_V6" "$NODE_ID" "$IPV6" "$PING_OK_V6"

  sleep 10
done
EOF

chmod +x /usr/local/bin/push_node_hk.sh

cat > /etc/systemd/system/nodecenter-node_hk.service << 'EOF'
[Unit]
Description=NodeCenter Push Service for node_hk and node_hk6
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/push_node_hk.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodecenter-node_hk.service
systemctl restart nodecenter-node_hk.service
systemctl status nodecenter-node_hk.service --no-pager -l
