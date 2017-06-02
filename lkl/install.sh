cat > /root/lkl/lkl.sh<<-EOF
LD_PRELOAD=/root/lkl/liblkl-hijack.so LKL_HIJACK_NET_QDISC="root|fq" LKL_HIJACK_SYSCTL="net.ipv4.tcp_congestion_control=bbr;net.ipv4.tcp_wmem=4096 16384 30000000" LKL_HIJACK_OFFLOAD="0x9983" LKL_HIJACK_NET_IFTYPE=tap LKL_HIJACK_NET_IFPARAMS=lkl-tap LKL_HIJACK_NET_IP=10.0.0.2 LKL_HIJACK_NET_NETMASK_LEN=24 LKL_HIJACK_NET_GATEWAY=10.0.0.1 haproxy -f /root/lkl/haproxy.cfg
EOF



cat > /root/lkl/run.sh<<-EOF
ip tuntap add lkl-tap mode tap
ip addr add 10.0.0.1/24 dev lkl-tap
ip link set lkl-tap up
sysctl -w net.ipv4.ip_forward=1
iptables -P FORWARD ACCEPT 
iptables -t nat -A POSTROUTING -o venet0 -j MASQUERADE
iptables -t nat -A PREROUTING -i venet0 -p tcp --dport 9000:9999 -j DNAT --to-destination 10.0.0.2
nohup /root/lkl/lkl.sh &
p=\`ping 10.0.0.2 -c 3 | grep ttl\`
if [ \$? -ne 0 ]; then
	echo "success "\$(date '+%Y-%m-%d %H:%M:%S') > /root/lkl/log.log
else
	echo "fail "\$(date '+%Y-%m-%d %H:%M:%S') > /root/lkl/log.log
fi
EOF


chmod +x lkl.sh
chmod +x run.sh

#写入自动启动
if [[ "$release" = "CentOS" && "$ver" = "7" ]]; then
	echo "/root/lkl/run.sh" >> /etc/rc.d/rc.local
	chmod +x /etc/rc.d/rc.local
else
	sed -i "s/exit 0/ /ig" /etc/rc.local
	echo "/root/lkl/run.sh" >> /etc/rc.local
fi


./run.sh

#判断是否启动
p=`ping 10.0.0.2 -c 3 | grep ttl`
if [ "$p" == "" ]; then
	echo "fail"
else
	echo "success"
fi
