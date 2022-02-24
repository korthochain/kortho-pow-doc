#!/bin/bash

#添加选择
	 	
MINER="miner"		 
CPUNUM=100
CONFIGFILE="./miner_linux/config/korthoConf.yaml"
MINERPATH="./miner_linux"
DOWNLOAD="download"

killMiner(){
	PID=$(ps -ef | grep "./$MINER" | grep -v "grep" | awk '{print $2}')
    for id in $PID;do
       	sudo -S kill -9 $id 
        echo "killed $id"
	done
}

select ch in "安装(请输入 1)" "升级(请输入 2)" "修改配置(请输入 3)" "重启挖矿(请输入 4)" "停止挖矿(请输入 5)"  "退出(请输入 6)"
do
case $ch in
	"安装(请输入 1)")
	
	echo "开始安装"

	killMiner
	
	sudo -S rm -rf $MINERPATH	
	
	if [ ! -d "./$DOWNLOAD" ]; then
		mkdir "$DOWNLOAD"
	fi
	
	read -p "请输入安装包版本号(例如：005,015,115):" v
		
	echo "version: miner_linux_$v.zip"
		
	wget -P ./$DOWNLOAD "https://www.kortho.org/file/linux/miner_linux_$v.zip"
		
	unzip "./download/miner_linux_$v.zip" -d ./

	if [ ! -d "./$MINERPATH" ]; then
		echo "error: download or unzip failed $MINERPATH not exist."
		break
	fi

	read -p "请输入矿工地址:" miner_addr

	cat "./$MINERPATH/种子节点.txt"
	echo ""
		
	read -p "请上面地址中复制一个种子节点:" seed_addr

	read -p "是否有公网IP(y/n):" answer
	

	if [[ $answer = "Y" || $answer = "y" ]];then
		
		read -p "请输入本节点公网IP:" public_ip						
		
		sed -i '/miningaddr*/c\  miningaddr: '$miner_addr'' $CONFIGFILE
		
		sed -i '/greamhost*/c\  greamhost: '$seed_addr'' $CONFIGFILE 			
		
		sed -i '/jionmembers*/c\  jionmembers: '$seed_addr'' $CONFIGFILE
		
		sed -i '/advertiseaddr*/c\  advertiseaddr: '$public_ip'' $CONFIGFILE		
	
		cd "./$MINERPATH"
	
		chmod +x ./$MINER
		
		setsid sudo -S ./$MINER -n=$CPUNUM -s=1
	else
		sed -i '/miningaddr*/c\  miningaddr: '$miner_addr'' $CONFIGFILE
		
		sed -i '/greamhost:*/c\  greamhost: '$seed_addr'' $CONFIGFILE	

		cd "./$MINERPATH"
			   
		chmod +x ./$MINER 
		
		setsid sudo -S ./$MINER -n=$CPUNUM -s=1 -m=1		
	fi
	break
	;;

	"升级(请输入 2)")
	
	read -p "升级需要暂时停止挖矿，是否现在停止(y/n):" answer
	
	if [[ $answer = "y" || $answer = "Y" ]];then
		killMiner
	else
		echo "终止升级，已退出."
		break
	fi
	
	echo "开始升级..."

	if [ ! -d "./$DOWNLOAD" ]; then
		echo "error: $DOWNLOAD not exist."
		break
	fi

	if [ ! -d "./$MINERPATH" ]; then
		echo "error: $MINERPATH not exist."
		break
	fi

	read -p "是否清除本地数据(y/n):" del

	if [[ $del = "Y" || $del = "y" ]];then
		sudo -S rm -rf "$MINERPATH/kortho.db"
	fi

	rm -rf "./tmp"
		
	read -p "请输入要升级的版本号(例如：005,015,115):" v
	
	echo "version: miner_linux_$v.zip"
		
	wget -P ./$DOWNLOAD "https://www.kortho.org/file/linux/miner_linux_$v.zip"
		
	unzip -o "./$DOWNLOAD/miner_linux_$v.zip" -d "tmp"
	
	cp -f "./tmp/miner_linux/miner" "./$MINERPATH"
	
	cd "./$MINERPATH"
	
	chmod +x ./$MINER
	
	read -p "准备重新启动，是否有公网IP(y/n):" answer
	
	if [[ $answer = "Y" || $answer = "y" ]];then

		setsid sudo -S ./$MINER -n=$CPUNUM -s=1 
	else

		setsid sudo -S ./$MINER -n=$CPUNUM -s=1 -m=1
	fi	
	break
	;;
	

	"修改配置(请输入 3)")

	read -p "是否修改矿工地址(y/n):" answer

        if [[ $answer = "Y" || $answer = "y" ]];then
        	read -p "请输入新矿工地址:" mdminer
                sed -i '/miningaddr*/c\  miningaddr: '$mdminer'' $CONFIGFILE
        fi


	read -p "是否有公网IP(y/n):" answerPub
	
	read -p "是否修改种子节点(y/n):" answer
		
	if [[ $answer = "Y" || $answer = "y" ]];then

		cat "./$MINERPATH/种子节点.txt"
		echo ""
		
		read -p "请从上面地址中复制一个新种子节点:" mdseed
		
		if [[ $answerPub = "Y" || $answerPub = "y" ]];then
			sed -i '/greamhost*/c\  greamhost: '$mdseed'' $CONFIGFILE
	                
			sed -i '/jionmembers*/c\  jionmembers: '$mdseed'' $CONFIGFILE
		else

			sed -i '/greamhost*/c\  greamhost: '$mdseed'' $CONFIGFILE
		fi
	fi

	read -p "配置修改完成，是否现在重启挖矿(y/n):" answer

	if [[ $answer = "Y" || $answer = "y" ]];then
		killMiner

		cd "./$MINERPATH"
		
		if [[ $answerPub = "Y" || $answerPub = "y" ]];then
			
			setsid sudo -S ./$MINER -n=$CPUNUM -s=1 
		else

			setsid sudo -S ./$MINER -n=$CPUNUM -s=1 -m=1
		fi
	else
		echo "配置修改完成，请稍后重启挖矿程序"

	fi
	break
	;;

	"重启挖矿(请输入 4)")
	echo "正在重启..."

	killMiner
	
	cd "./$MINERPATH"
	
	read -p "是否有公网IP(y/n):" answerPub
	
	if [[ $answerPub = "Y" || $answerPub = "y" ]];then
		setsid sudo -S ./$MINER -n=$CPUNUM -s=1 
	else
		setsid sudo -S ./$MINER -n=$CPUNUM -s=1 -m=1
	fi
	break
	;;

	"停止挖矿(请输入 5)")
	read -p "停止挖矿，请确认(y/n)" confirm
	
	if [[ $confirm = "Y" || $confirm = "y" ]];then
		killMiner
		echo "程序已停止。"
	else
		echo "程序未停止."
	fi
	break
	;;

	"退出(请输入 6)")
	echo "已退出"
	break
	;;
	
	*)
	echo "未知命令"
	;;
	esac
done;


