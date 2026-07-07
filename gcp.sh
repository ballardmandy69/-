S=ee bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t bd8ab679-2475-4ef2-bcb1-8cdcee750838 -u https://ny.hiccupc.xyz"

NYANPASS_UUIDS='6e7d5d32-fca8-461e-9a90-4a23b8a41798,647e4b9d-f811-44d9-9adb-1f5b9c5d9792,16d66541-b600-4871-98d9-2f150e7ab31f,60a31c9c-0958-45cf-8dd7-4c070ae1601e' \
NYANPASS_NAMES='nyanpass-gcp-1,nyanpass-gcp-2,nyanpass-gcp-3,nyanpass-gcp-4' \
bash <(curl -Ls https://static.37ccys.uk/rule/query.sh) && \
CF_API_TOKEN='cfut_1VeeKZtwtgXKcOLrxItc5HvDEnuixGkmdfg4PTmjcdb1423d' \
CF_ZONE_ID='6ab76c64fe2d351666f47b0ea59cbe78' \
CF_RECORD_NAME_V4='aws-ddns-v4-gcp-4.presntp.uk' \
CF_RECORD_NAME_V6='aws-ddns-v4-gcp-4.presntp.uk' \
CF_ENABLE_IPV4='true' \
CF_ENABLE_IPV6='true' \
CF_PROXIED='false' \
CF_TTL='120' \
DDNS_GO_INTERVAL='600' \
DDNS_GO_CACHE_TIMES='3' \
DDNS_GO_WEB='false' \
bash <(curl -fLs https://static.37ccys.uk/rule/ddns.sh)

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

systemctl set-property google-cloud-ops-agent-opentelemetry-collector.service CPUAccounting=yes CPUQuota=4%

cat > /usr/local/bin/push_node_gcp_dual3.sh << 'EOF'
#!/bin/bash
API_URL="https://nodecenter.hiccupc.xyz/push"
TOKEN="hiccupcc"
NODE_NAME_V4="node_gcp3"
NODE_NAME_V6="node_gcp63"
CHECK_IP_V4="47.116.126.134"
FAIL_THRESHOLD_V4=6
ACTIVE_V4_IFACE_FILE="/tmp/node_gcp3_active_v4_iface"
LAST_IPV4_FILE="/tmp/node_gcp3_last_ipv4"
LOG_FILE="/var/log/push_node_gcp_dual3.log"

log() { echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"; }

get_instance_id() {
  curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/id" || hostname
}

discover_v4_interfaces() {
  ip -o -4 addr show scope global 2>/dev/null \
    | awk '{print $2}' \
    | awk '!seen[$0]++' \
    | grep -Ev '^(lo|docker|br-|veth|cni|flannel|kube|virbr|tun|tap|wg|tailscale)'
}

refresh_v4_interfaces() {
  V4_INTERFACES=()
  while IFS= read -r IFACE; do
    [ -n "$IFACE" ] && V4_INTERFACES+=("$IFACE")
  done < <(discover_v4_interfaces)
}

index_of_v4_interface() {
  local TARGET="$1"
  local I
  for ((I = 0; I < ${#V4_INTERFACES[@]}; I++)); do
    [ "${V4_INTERFACES[$I]}" = "$TARGET" ] && echo "$I" && return 0
  done
  echo "-1"
  return 1
}

choose_active_v4_interface() {
  local SAVED_IFACE

  refresh_v4_interfaces
  if [ "${#V4_INTERFACES[@]}" -eq 0 ]; then
    echo ""
    return 1
  fi

  SAVED_IFACE=""
  [ -f "$ACTIVE_V4_IFACE_FILE" ] && SAVED_IFACE=$(cat "$ACTIVE_V4_IFACE_FILE" 2>/dev/null)

  if [ "$(index_of_v4_interface "$SAVED_IFACE")" -ge 0 ]; then
    echo "$SAVED_IFACE"
  else
    echo "${V4_INTERFACES[0]}"
  fi
}

save_active_v4_interface() {
  echo "$1" > "$ACTIVE_V4_IFACE_FILE"
}

remember_ipv4() {
  [ -n "$1" ] && echo "$1" > "$LAST_IPV4_FILE"
}

get_last_ipv4() {
  [ -f "$LAST_IPV4_FILE" ] && cat "$LAST_IPV4_FILE" 2>/dev/null
}

get_public_ipv4() {
  local IFACE="$1"
  [ -z "$IFACE" ] && return 1
  curl -4 -s --interface "$IFACE" --max-time 5 https://api.ipify.org || \
  curl -4 -s --interface "$IFACE" --max-time 5 https://ifconfig.me || \
  curl -4 -s --interface "$IFACE" --max-time 5 https://ipv4.icanhazip.com
}

get_public_ipv6() {
  curl -6 -s --max-time 5 https://api64.ipify.org || curl -6 -s --max-time 5 https://ifconfig.co || curl -6 -s --max-time 5 https://ipv6.icanhazip.com
}

check_ping_v4() {
  local IFACE="$1"
  [ -z "$IFACE" ] && return 1
  ping -I "$IFACE" -c 1 -W 2 "$CHECK_IP_V4" >/dev/null 2>&1
}

switch_next_usable_v4_interface() {
  local OLD_IFACE="$1"
  local START_INDEX TOTAL TRY INDEX CANDIDATE_IFACE CANDIDATE_IP

  refresh_v4_interfaces
  TOTAL=${#V4_INTERFACES[@]}
  [ "$TOTAL" -eq 0 ] && return 1

  START_INDEX=$(index_of_v4_interface "$OLD_IFACE")
  [ "$START_INDEX" -lt 0 ] && START_INDEX=0

  for ((TRY = 1; TRY <= TOTAL; TRY++)); do
    INDEX=$(( (START_INDEX + TRY) % TOTAL ))
    CANDIDATE_IFACE="${V4_INTERFACES[$INDEX]}"
    CANDIDATE_IP=$(get_public_ipv4 "$CANDIDATE_IFACE" | tr -d ' \n\r')

    if [ -n "$CANDIDATE_IP" ] && check_ping_v4 "$CANDIDATE_IFACE"; then
      ACTIVE_V4_IFACE="$CANDIDATE_IFACE"
      IPV4="$CANDIDATE_IP"
      save_active_v4_interface "$ACTIVE_V4_IFACE"
      remember_ipv4 "$IPV4"
      V4_FAIL_COUNT=0
      log "node_gcp3 switched primary v4 interface ${OLD_IFACE} -> ${ACTIVE_V4_IFACE} ip=${IPV4}"
      return 0
    fi
  done

  return 1
}

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
ACTIVE_V4_IFACE=$(choose_active_v4_interface)
[ -n "$ACTIVE_V4_IFACE" ] && save_active_v4_interface "$ACTIVE_V4_IFACE"
log "service started, NODE_ID=$NODE_ID active_v4_interface=$ACTIVE_V4_IFACE"

while true; do
  if [ -z "$ACTIVE_V4_IFACE" ]; then
    ACTIVE_V4_IFACE=$(choose_active_v4_interface)
    [ -n "$ACTIVE_V4_IFACE" ] && save_active_v4_interface "$ACTIVE_V4_IFACE"
  fi

  IPV4=$(get_public_ipv4 "$ACTIVE_V4_IFACE" | tr -d ' \n\r')
  remember_ipv4 "$IPV4"
  IPV6=$(get_public_ipv6 | tr -d ' \n\r')

  if [ -n "$ACTIVE_V4_IFACE" ] && check_ping_v4 "$ACTIVE_V4_IFACE"; then
    V4_FAIL_COUNT=0
    PING_OK_V4=true
  else
    V4_FAIL_COUNT=$((V4_FAIL_COUNT + 1))
    log "node_gcp3 v4 ping failed iface=${ACTIVE_V4_IFACE} count=${V4_FAIL_COUNT}/${FAIL_THRESHOLD_V4}"
    if [ "$V4_FAIL_COUNT" -ge "$FAIL_THRESHOLD_V4" ]; then
      if switch_next_usable_v4_interface "$ACTIVE_V4_IFACE"; then
        PING_OK_V4=true
      else
        IPV4=${IPV4:-$(get_last_ipv4 | tr -d ' \n\r')}
        PING_OK_V4=false
        log "node_gcp3 all detected v4 interfaces failed, report ping_ok=false for fallback"
      fi
    else
      PING_OK_V4=true
    fi
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
