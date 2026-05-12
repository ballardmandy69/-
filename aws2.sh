#!/bin/bash


S=zumo  bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t f96ba212-3920-4160-a5bc-f5b2f218c50e -u https://zumo.moe"
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


lotspeed set lotserver_rate 50000000
lotspeed set lotserver_gain 32
lotspeed set lotserver_beta 896
lotspeed set lotserver_max_cwnd 8000
lotspeed set lotserver_min_cwnd 48
sysctl -w net.ipv4.tcp_no_metrics_save=1
sysctl -w net.ipv4.tcp_autocorking=1
sysctl -w net.ipv4.tcp_min_rtt_wlen=20
sysctl -w net.ipv4.tcp_tso_win_divisor=1
sysctl -w net.ipv4.tcp_pacing_ss_ratio=260
sysctl -w net.ipv4.tcp_pacing_ca_ratio=120
sysctl -w net.ipv4.tcp_notsent_lowat=131072   
sysctl -w net.ipv4.tcp_mtu_probing=1
sysctl -w net.ipv4.tcp_probe_interval=60
sysctl -w net.ipv4.tcp_probe_threshold=8



apt update && apt install -y jq cron netcat-openbsd iputils-ping util-linux && curl -kfsSL https://tools.airport-v2.com/node-ddns/abc.sh | bash
