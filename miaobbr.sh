#!/bin/bash

echo "欢迎使用黑喵bbr脚本，请选择你需要的bbr："
echo "1. neko内部版bbr【海外+大陆】"
echo "2. Sam原味bbr【AWS专用】"
echo "3. Su佬特调bbr【大陆】"
echo "4. Kevin默认bbr【大陆】"
echo "5. 杨总常用bbr【温和】"

read -p "请输入选项（1-5）：" choice

case $choice in
  1)
    curl neko.nnr.moe/ii.sh -Ls | bash
    ;;
  2)
    cat > /etc/sysctl.conf <<EOF
    kernel.msgmnb=65536
    kernel.msgmax=65536
    kernel.shmmax=68719476736
    kernel.shmall=4294967296
    vm.swappiness=1
    vm.dirty_background_bytes=52428800
    vm.dirty_bytes=52428800
    vm.dirty_ratio=0
    vm.dirty_background_ratio=0

    net.core.rps_sock_flow_entries=65536 

    fs.file-max=1000000
    fs.inotify.max_user_instances=131072

    net.ipv4.conf.all.route_localnet=1
    net.ipv4.ip_forward=1
    net.ipv4.conf.all.forwarding=1
    net.ipv4.conf.default.forwarding=1




    net.ipv4.conf.all.accept_redirects=0
    net.ipv4.conf.default.accept_redirects=0
    net.ipv4.conf.all.secure_redirects=0
    net.ipv4.conf.default.secure_redirects=0
    net.ipv4.conf.all.send_redirects=0
    net.ipv4.conf.default.send_redirects=0
    net.ipv4.conf.default.rp_filter=0
    net.ipv4.conf.all.rp_filter=0

    net.ipv4.tcp_syncookies=1
    net.ipv4.tcp_retries1=3
    net.ipv4.tcp_retries2=5
    net.ipv4.tcp_orphan_retries=1
    net.ipv4.tcp_syn_retries=3
    net.ipv4.tcp_synack_retries=3
    net.ipv4.tcp_tw_reuse=1
    net.ipv4.tcp_fin_timeout=10
    net.ipv4.tcp_max_tw_buckets=262144
    net.ipv4.tcp_max_syn_backlog=4194304
    net.core.netdev_max_backlog=4194304
    net.core.somaxconn=65536
    net.ipv4.tcp_notsent_lowat=16384

    net.ipv4.tcp_keepalive_time=300
    net.ipv4.tcp_keepalive_probes=3
    net.ipv4.tcp_keepalive_intvl=60

    net.ipv4.tcp_fastopen=3
    net.ipv4.tcp_autocorking=0
    net.ipv4.tcp_slow_start_after_idle=0
    net.ipv4.tcp_no_metrics_save=1
    net.ipv4.tcp_ecn=0
    net.ipv4.tcp_frto=0
    net.ipv4.tcp_mtu_probing=0
    net.ipv4.tcp_sack=1
    net.ipv4.tcp_fack=1
    net.ipv4.tcp_window_scaling=1
    net.ipv4.tcp_adv_win_scale=1
    net.ipv4.tcp_moderate_rcvbuf=1
    net.core.rmem_max=134217728
    net.core.wmem_max=134217728
    net.ipv4.tcp_rmem=16384 131072 67108864
    net.ipv4.tcp_wmem=4096 16384 33554432
    net.ipv4.udp_rmem_min=8192
    net.ipv4.udp_wmem_min=8192
    net.ipv4.tcp_mem=262144 1048576 4194304
    net.ipv4.udp_mem=262144 1048576 4194304
    net.ipv4.tcp_congestion_control=bbr
    net.core.default_qdisc=fq
    net.ipv4.ip_local_port_range=10000 65535
    net.ipv4.ping_group_range=0 2147483647
EOF
    sysctl -p
    ;;
  3)
    cat > /etc/sysctl.conf <<EOF
    fs.file-max = 65535
    vm.swappiness = 0
    net.core.rmem_max = 67108864
    net.core.wmem_max = 67108864
    net.core.netdev_max_backlog = 250000
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_timestamps = 1
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.tcp_fin_timeout = 30
    net.ipv4.tcp_keepalive_time = 1200
    net.ipv4.ip_local_port_range = 1024 65535
    net.ipv4.tcp_max_syn_backlog = 10240
    net.core.somaxconn = 65535
    net.ipv4.tcp_abort_on_overflow = 1
    net.ipv4.tcp_max_tw_buckets = 5000
    net.ipv4.tcp_fastopen = 3
    net.ipv4.tcp_mem = 164205  218941  328410
    net.ipv4.tcp_rmem = 4096 131072 67108864
    net.ipv4.tcp_wmem = 4096 65536 67108864
    net.ipv4.tcp_mtu_probing = 1
    net.ipv4.tcp_slow_start_after_idle = 0
    net.ipv4.ip_forward = 1
    net.core.default_qdisc = fq
    net.ipv4.tcp_congestion_control = bbr
EOF
    cat > /etc/security/limits.conf <<EOF
    root soft nofile 512000
    root hard nofile 512000
    root soft nproc 512000
    root hard nproc 512000
EOF
    sysctl -p
    ;;
  4)
    cat > /etc/sysctl.conf <<EOF
    fs.file-max=1000000
    fs.inotify.max_user_instances=65536

    net.ipv4.conf.all.route_localnet=1
    net.ipv4.ip_forward=1
    net.ipv4.conf.all.forwarding=1
    net.ipv4.conf.default.forwarding=1

    net.ipv6.conf.all.forwarding = 1
    net.ipv6.conf.default.forwarding = 1
    net.ipv6.conf.lo.forwarding = 1
    net.ipv6.conf.all.disable_ipv6 = 0
    net.ipv6.conf.default.disable_ipv6 = 0
    net.ipv6.conf.lo.disable_ipv6 = 0

    net.ipv4.tcp_syncookies=1
    net.ipv4.tcp_retries1=3
    net.ipv4.tcp_retries2=8
    net.ipv4.tcp_orphan_retries=3
    net.ipv4.tcp_syn_retries=3
    net.ipv4.tcp_synack_retries=3
    net.ipv4.tcp_tw_reuse=1
    net.ipv4.tcp_fin_timeout=15
    net.ipv4.tcp_max_tw_buckets=32768
    net.ipv4.tcp_max_syn_backlog=131072
    net.core.netdev_max_backlog=131072
    net.core.somaxconn=32768
    net.ipv4.tcp_notsent_lowat=16384
    net.ipv4.tcp_keepalive_time=300
    net.ipv4.tcp_keepalive_probes=3
    net.ipv4.tcp_keepalive_intvl=30
    net.ipv4.tcp_fastopen=3
    net.ipv4.tcp_autocorking=0
    net.ipv4.tcp_slow_start_after_idle=0
    net.ipv4.tcp_no_metrics_save=1
    net.ipv4.tcp_ecn=0
    net.ipv4.tcp_frto=0
    net.ipv4.tcp_mtu_probing=0
    net.ipv4.tcp_rfc1337=0
    net.ipv4.tcp_sack=1
    net.ipv4.tcp_fack=1
    net.ipv4.tcp_window_scaling=1
    net.ipv4.tcp_adv_win_scale=2
    net.ipv4.tcp_moderate_rcvbuf=1
    net.core.rmem_max=33554432
    net.core.wmem_max=33554432
    net.ipv4.tcp_rmem=4096 87380 33554432
    net.ipv4.tcp_wmem=4096 16384 33554432
    net.ipv4.udp_rmem_min=8192
    net.ipv4.udp_wmem_min=8192
    net.core.netdev_budget=3000
    net.ipv4.tcp_mem=3145728 3932160 4718592
    net.ipv4.udp_mem=262144 1048576 4194304
    net.ipv4.tcp_congestion_control=bbr
    net.core.default_qdisc=fq
    net.ipv4.ping_group_range=0 2147483647
EOF
    sysctl -p
    ;;
  5)
    wget -O tcpx.sh "https://git.io/JYxKU" && chmod +x tcpx.sh && ./tcpx.sh
    ;;
  *)
    echo "无效输入，请输入1-5之间的数字。"
    ;;
esac
