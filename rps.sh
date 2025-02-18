#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="/root/rps.sh"

# 写入脚本内容
cat > "$SCRIPT_NAME" << 'EOF'
#!/bin/bash

# 确保 bc 已安装
command -v bc >/dev/null 2>&1 || yum install bc -y || apt install bc -y

# 设置 RPS sock flow entries
sysctl -w net.core.rps_sock_flow_entries=65536

# 获取 CPU 核心数
cc=$(grep -c processor /proc/cpuinfo)

# 计算每个核心的 flow count
rfc=$(echo 65536/$cc | bc)
for fileRfc in $(find /sys/class/net -type f -path "*/queues/rx-*/rps_flow_cnt" 2>/dev/null)
do
    echo $rfc > "$fileRfc"
done

# 计算 CPU 掩码
c=$(bc -l -q << EOF_BC
a1=l($cc)
a2=l(2)
scale=2
a1/a2
EOF_BC
)

# 取整
c=$(echo "$c" | awk '{print int($1)}')

# 生成 ffff 掩码
cpus=$(printf "%0${c}x" 0 | tr '0' 'f')

# 应用 RPS CPU 掩码
for fileRps in $(find /sys/class/net -type f -path "*/queues/rx-*/rps_cpus" 2>/dev/null)
do
    echo $cpus > "$fileRps"
done
EOF

# 赋予脚本可执行权限
chmod +x "$SCRIPT_NAME"

# 执行脚本
bash "$SCRIPT_NAME"

# 确保 /etc/rc.local 存在并可执行
if [ ! -f /etc/rc.local ]; then
    echo -e "#!/bin/bash\nexit 0" > /etc/rc.local
    chmod +x /etc/rc.local
fi

# 确保 /etc/rc.local 里有 bash /root/rps.sh
if ! grep -q "bash /root/rps.sh" /etc/rc.local; then
    sed -i -e '$i bash /root/rps.sh\n' /etc/rc.local
fi

echo "RPS 已开启"
