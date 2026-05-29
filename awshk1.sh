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



cat > /usr/local/bin/push_node_a.sh << 'EOF'
#!/bin/bash

API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME="node_a"
CHECK_IP="47.116.126.134"

CHANGE_IP_URL="https://api.aws.sb/ec2-instances/i-0df663a9a54dea6f0/ip-address"
CHANGE_COOLDOWN=90
LAST_CHANGE_FILE="/tmp/node_a_last_change_ip"

get_instance_id() {
  TOKEN_AWS=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)

  if [ -n "$TOKEN_AWS" ]; then
    curl -s -H "X-aws-ec2-metadata-token: $TOKEN_AWS" \
      http://169.254.169.254/latest/meta-data/instance-id
  else
    hostname
  fi
}

get_public_ip() {
  curl -4 -s --max-time 10 https://api.ipify.org
}

check_ping() {
  timeout 3 bash -c "</dev/tcp/${CHECK_IP}/443" >/dev/null 2>&1
}

random_r() {
  tr -dc 'a-z0-9' < /dev/urandom | head -c 11
}

change_ip() {
  NOW=$(date +%s)
  LAST=0

  [ -f "$LAST_CHANGE_FILE" ] && LAST=$(cat "$LAST_CHANGE_FILE")

  if [ $((NOW - LAST)) -lt "$CHANGE_COOLDOWN" ]; then
    return 0
  fi

  R=$(random_r)

  echo "$(date) change ip..." >> /var/log/nodecenter.log

  curl -s -X PATCH "${CHANGE_IP_URL}?r=${R}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Origin: https://aws.sb" \
    -H "X-Auth-Token: e85a4ba72df64a2c90f97ef45b2dc211" \
    -H "X-Region-Name: ap-southeast-1" \
    -H "X-Share-Group-Token: 80f5d1a89773428f9dc51d7d1946fcf2" \
    -d '{"ipAddress":""}' \
    --max-time 30 >> /var/log/nodecenter.log 2>&1

  echo "" >> /var/log/nodecenter.log
  echo "$NOW" > "$LAST_CHANGE_FILE"

  sleep 30
}

NODE_ID=$(get_instance_id)

push_ip() {
  PUBLIC_IP=$(get_public_ip)
  [ -z "$PUBLIC_IP" ] && return 1

  if check_ping; then
    PING_OK=true
  else
    PING_OK=false

    change_ip

    PUBLIC_IP=$(get_public_ip)
    [ -z "$PUBLIC_IP" ] && return 1
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

chmod +x /usr/local/bin/push_node_a.sh

cat > /etc/systemd/system/nodecenter-node_a.service << 'EOF'
[Unit]
Description=NodeCenter Push Service for node_a
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/push_node_a.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodecenter-node_a.service
systemctl restart nodecenter-node_a.service
systemctl status nodecenter-node_a.service --no-pager
