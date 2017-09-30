#deploy.sh version 1.0  [ for DNA v0.6alpha-61-gb1b0 or later ]
#!/bin/bash

#==========================================================#
NodeCount=4
Default_Wallet_Pwd="pwd"
#==========================================================#
HttpInfoPortBase=10333
HttpRestPortBase=10334
HttpWsPortBase=10335
HttpJsonPortBase=10336
HttpLocalPortBase=10337
NodePortBase=10338
#---------------------------------------------------------------------------------------------------#
PortInterval=100		#Each node port base interval
#==========================================================#
LocalAddr="127.0.0.1"
#---------------------------------------------------------------------------------------------------#
RemoteSeed1="10.0.0.5"
RemoteSeed2="10.0.0.6"
RemoteSeed3="10.0.0.7"
RemoteSeed4="10.0.0.8"
#==========================================================#
set +x
export TEST="$(pwd)"
#---------------------------------------------------------------------------------------------------#

function Config(){
	PubKey1=""
	PubKey2=""
	PubKey3=""
	PubKey4=""

	rm -rf dnaTest && mkdir dnaTest
	cp ../node ../nodectl ../config.json ./
	cp node nodectl config.json dnaTest/
	cd dnaTest

	for((n=1;n<=$NodeCount;n++));do
		mkdir node$n
		cp node nodectl config.json node$n/
		
		cd node$n
		if [ $n == 1 ];then
			PubKey1=`./nodectl wallet -c -p $Default_Wallet_Pwd | grep "public key:" | awk '{print $3}'`
			echo BookKeeper1: $PubKey1
		elif [ $n == 2 ];then
			PubKey2=`./nodectl wallet -c -p $Default_Wallet_Pwd | grep "public key:" | awk '{print $3}'`
			echo BookKeeper2: $PubKey2
		elif [ $n == 3 ];then
			PubKey3=`./nodectl wallet -c -p $Default_Wallet_Pwd | grep "public key:" | awk '{print $3}'`
			echo BookKeeper3: $PubKey3
		elif [ $n == 4 ];then
			PubKey4=`./nodectl wallet -c -p $Default_Wallet_Pwd | grep "public key:" | awk '{print $3}'`
			echo BookKeeper4: $PubKey4
		else
			PubKey=`./nodectl wallet -c -p $Default_Wallet_Pwd | grep "public key:" | awk '{print $3}'`
		fi
		cd ..
	done

	sed -i.bak '/SeedList/,/]/{//!d}' config.json
	if [ $1 == 0 ];then
		sed -i.bak '/SeedList/a\      "'${LocalAddr}':'$[NodePortBase+PortInterval*3]'"'  config.json
		sed -i.bak '/SeedList/a\      "'${LocalAddr}':'$[NodePortBase+PortInterval*2]'",' config.json
		sed -i.bak '/SeedList/a\      "'${LocalAddr}':'$[NodePortBase+PortInterval*1]'",' config.json
		sed -i.bak '/SeedList/a\      "'${LocalAddr}':'${NodePortBase}'",' config.json		
	elif [ $1 == 1 ];then
		sed -i.bak '/SeedList/a\      "'${RemoteSeed4}':'${NodePortBase}'"'  config.json
		sed -i.bak '/SeedList/a\      "'${RemoteSeed3}':'${NodePortBase}'",' config.json
		sed -i.bak '/SeedList/a\      "'${RemoteSeed2}':'${NodePortBase}'",' config.json
		sed -i.bak '/SeedList/a\      "'${RemoteSeed1}':'${NodePortBase}'",' config.json		
		PortInterval=0
	fi

	sed -i.bak '/BookKeepers/,/]/{//!d}' config.json
	sed -i.bak '/BookKeepers/a\      "'${PubKey1}'",\n      "'${PubKey2}'",\n      "'${PubKey3}'",\n      "'${PubKey4}'"'  config.json
	rm -rf config.json.bak
	
	for((n=1;n<=$NodeCount;n++));do
		cp config.json node$n/
		cd node$n

		portInterval=$[n*PortInterval-PortInterval]
		sed -i.bak  's#"HttpInfoPort".*,#"HttpInfoPort": '$[HttpInfoPortBase+portInterval]',#' config.json
		sed -i.bak  's#"HttpRestPort".*,#"HttpRestPort": '$[HttpRestPortBase+portInterval]',#' config.json
		sed -i.bak  's#"HttpWsPort".*,#"HttpWsPort": '$[HttpWsPortBase+portInterval]',#' config.json
		sed -i.bak  's#"HttpJsonPort".*,#"HttpJsonPort": '$[HttpJsonPortBase+portInterval]',#' config.json
		sed -i.bak  's#"HttpLocalPort".*,#"HttpLocalPort": '$[HttpLocalPortBase+portInterval]',#' config.json
		sed -i.bak  's#"NodePort".*,#"NodePort": '$[NodePortBase+portInterval]',#' config.json
		rm -rf config.json.bak

		cd ..
	done
	rm -rf node nodectl config.json
}

function localFront(){
	if [ $1 == 0 ];then
		cd ${TEST}
		tmux new-session -s my_session './deploy.sh lf 1'
	elif [ $1 == 1 ];then
		cd ${TEST}/dnaTest/node1
		tmux split-window -h "echo pwd | ./node"
		tmux select-pane -L

		cd ../node2
		tmux split-window -v "echo pwd | ./node"
		tmux select-pane -U

		cd ../node3
		tmux split-window -h "echo pwd | ./node"
		tmux select-pane -L

		cd ../node4 && echo pwd | ./node
	fi
}

function localBack(){
	for((n=1;n<=$NodeCount;n++));do
		cd ${TEST}/dnaTest/node$n
		#nohup ./node>/dev/null 2>&1 &
		echo pwd | ./node&
	done
	stty tostop
}

function localConfig(){
	Config 0
}

function remoteConfig(){
	Config 1
}

: << !
function remoteBack(){
	echo -e '#!/bin/bash\necho pwd | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node1/start.sh
	echo -e '#!/bin/bash\necho pwd | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node2/start.sh
	echo -e '#!/bin/bash\necho pwd | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node3/start.sh
	echo -e '#!/bin/bash\necho pwd | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node4/start.sh

	ssh goonchain@"${Remote1}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
	ssh goonchain@"${Remote2}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
	ssh goonchain@"${Remote3}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
	ssh goonchain@"${Remote4}" "sudo killall -9 node && sudo rm -rf dnaTest/*"

	scp -C -r dnaTest/node1 goonchain@"${Remote1}":/home/goonchain/dnaTest
	scp -C -r dnaTest/node2 goonchain@"${Remote2}":/home/goonchain/dnaTest
	scp -C -r dnaTest/node3 goonchain@"${Remote3}":/home/goonchain/dnaTest
	scp -C -r dnaTest/node4 goonchain@"${Remote4}":/home/goonchain/dnaTest

	ssh goonchain@"${Remote1}" "cd dnaTest/node1/ && bash start.sh > /dev/null 2>&1 &"
	ssh goonchain@"${Remote2}" "cd dnaTest/node2/ && bash start.sh > /dev/null 2>&1 &"
	ssh goonchain@"${Remote3}" "cd dnaTest/node3/ && bash start.sh > /dev/null 2>&1 &"
	ssh goonchain@"${Remote4}" "cd dnaTest/node4/ && bash start.sh > /dev/null 2>&1 &"
}
!

function usage(){
	echo "Usage:"
	echo "    ./deploy.sh lc       localconfig          "
	echo "    ./deploy.sh rc       remoteconfig          "
	echo "    ./deploy.sh lf       localfront          "
	echo "    ./deploy.sh lf nc    localfront, no reconfiguration "
	echo "    ./deploy.sh lb       localback           "
	echo "    ./deploy.sh lb nc    localback,  no reconfiguration "
	echo
	exit
}

if [ ! $1 ];then
	usage
fi

case $1 in
	"lc")
		echo "LocalConfig";
			localConfig;
	;;
	"lf")
		echo "LocalFrontRun";
		if [ ! $2 ];then
			localConfig;
			localFront 0;
		elif [ $2 == "nc" ];then
			localFront 0
		elif [ $2 == 1 ];then
			localFront 1;
		fi
	;;
	"lb")
		echo "LocalBackRun";
		if [ ! $2 ];then
			localConfig;
			localBack;
		elif [ $2 == "nc" ];then
			localBack;
		fi
	;;
	"rc")
		echo "RemoteConfig";
			remoteConfig;
	;;
	*)
		usage;
	;;
esac
