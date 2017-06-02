

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
