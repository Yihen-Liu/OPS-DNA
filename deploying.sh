#for DNA v0.6alpha-61-gb1b0 or later
#!/bin/bash
#to update:
#1.script parameter instruction
#2.port config
#3.sed match

set +x
export TEST="$(pwd)"

RemoteNode1Addr="35.189.161.152"
RemoteNode2Addr="35.189.161.152"
RemoteNode3Addr="35.189.161.152"
RemoteNode4Addr="35.189.161.152"

function Config(){
    rm -rf dnaTest && mkdir dnaTest
    cp ../node ../nodectl ../config.json dnaTest/
    cd dnaTest && mkdir node1 node2 node3 node4

    sed -i.bak '/13.125.0.7/d' config.json
    sed -i.bak '/52.79.125.166/d' config.json
    sed -i.bak '/52.79.103.97/d' config.json

    if [ $1 == 1 ];then
        echo RemoteConfig
        sed -i.bak 's#"35.189.182.223:10338",#"'${RemoteNode1Addr}':10338",#g' config.json
        sed -i.bak 's#"35.189.166.234:30338",#"'${RemoteNode2Addr}':20338",#g' config.json
        sed -i.bak 's#"35.189.161.152:50338",#"'${RemoteNode3Addr}':30338"#g'   config.json
    elif [ $1 == 0 ];then
        echo LocalConfig
        sed -i.bak 's#"35.189.182.223:10338",#"127.0.0.1:10338",#g' config.json
        sed -i.bak 's#"35.189.166.234:30338",#"127.0.0.1:20338",#g' config.json
        sed -i.bak 's#"35.189.161.152:50338",#"127.0.0.1:30338"#g'   config.json
    fi

    ./nodectl wallet -c -p passwordtest -n wallet.dat
    pubKey1=`./nodectl wallet -l -p passwordtest -n wallet.dat | grep "public key:" | awk '{print $3}'`
    mv wallet.dat node1/

    ./nodectl wallet -c -p passwordtest -n wallet.dat
    pubKey2="$(./nodectl wallet -l -p passwordtest -n wallet.dat | grep "public key:" | awk '{print $3}')"
    mv wallet.dat node2/

    ./nodectl wallet -c -p passwordtest -n wallet.dat
    pubKey3="$(./nodectl wallet -l -p passwordtest -n wallet.dat | grep "public key:" | awk '{print $3}')"
    mv wallet.dat node3/

    ./nodectl wallet -c -p passwordtest -n wallet.dat
    pubKey4="$(./nodectl wallet -l -p passwordtest -n wallet.dat | grep "public key:" | awk '{print $3}')"
    mv wallet.dat node4/

: << !
    sed -i.bak 's/"BookKeepers": \[/"BookKeepers": \[\
        ''"'"$pubKey4"'"''/g'  config.json
    sed -i.bak 's/"BookKeepers": \[/"BookKeepers": \[\
        ''"'"$pubKey3"'",''/g' config.json
    sed -i.bak 's/"BookKeepers": \[/"BookKeepers": \[\
        ''"'"$pubKey2"'",''/g' config.json
    sed -i.bak 's/"BookKeepers": \[/"BookKeepers": \[\
        ''"'"$pubKey1"'",''/g' config.json
!
    sed -i.bak 's#03ad8f4a837f7a02adedcea920b30c5c99517aabc7d2695d93ac572b9c2106d4c2#'"$pubKey1"'#g' config.json
    sed -i.bak 's#0293bafa2df4813ae999bf42f35a38bcb9ec26a252fd28dc0ccab56c671cf784e6#'"$pubKey2"'#g' config.json
    sed -i.bak 's#02aec70e084e4e5d36ed2db54aa708a6bd095fbb663929850986a5ec22061e1be2#'"$pubKey3"'#g' config.json
    sed -i.bak 's#02758623d16774f3c5535a305e65ea949343eab06888ee2e7633b4f3f9d78d506c#'"$pubKey4"'#g' config.json

    cp node nodectl config.json node1/
    cp node nodectl config.json node2/
    cp node nodectl config.json node3/
    cp node nodectl config.json node4/
    sleep 1

    rm -rf node config.json.bak Log/
    mv nodectl config.json ../

    sed -i.bak 's#"HttpRestPort": 20334,#"HttpRestPort": 10334,#g' node1/config.json
    sed -i.bak 's#"HttpWsPort":20335,#"HttpWsPort": 10335,#g' node1/config.json
    sed -i.bak 's#"HttpJsonPort": 20336,#"HttpJsonPort": 10336,#g' node1/config.json
    sed -i.bak 's#"HttpLocalPort": 20337,#"HttpLocalPort": 10337,#g' node1/config.json
    sed -i.bak 's#"NodePort": 20338,#"NodePort": 10338,#g' node1/config.json
    rm -rf node1/config.json.bak

    sed -i.bak 's#"HttpRestPort": 20334,#"HttpRestPort": 20334,#g' node2/config.json
    sed -i.bak 's#"HttpWsPort":20335,#"HttpWsPort": 20335,#g' node2/config.json
    sed -i.bak 's#"HttpJsonPort": 20336,#"HttpJsonPort": 20336,#g' node2/config.json
    sed -i.bak 's#"HttpLocalPort": 20337,#"HttpLocalPort": 20337,#g' node2/config.json
    sed -i.bak 's#"NodePort": 20338,#"NodePort": 20338,#g' node2/config.json
    rm -rf node2/config.json.bak

    sed -i.bak 's#"HttpRestPort": 20334,#"HttpRestPort": 30334,#g' node3/config.json
    sed -i.bak 's#"HttpWsPort":20335,#"HttpWsPort": 30335,#g' node3/config.json
    sed -i.bak 's#"HttpJsonPort": 20336,#"HttpJsonPort": 30336,#g' node3/config.json
    sed -i.bak 's#"HttpLocalPort": 20337,#"HttpLocalPort": 30337,#g' node3/config.json
    sed -i.bak 's#"NodePort": 20338,#"NodePort": 30338,#g' node3/config.json
    rm -rf node3/config.json.bak

    sed -i.bak 's#"HttpRestPort": 20334,#"HttpRestPort": 40334,#g' node4/config.json
    sed -i.bak 's#"HttpWsPort":20335,#"HttpWsPort": 40335,#g' node4/config.json
    sed -i.bak 's#"HttpJsonPort": 20336,#"HttpJsonPort": 40336,#g' node4/config.json
    sed -i.bak 's#"HttpLocalPort": 20337,#"HttpLocalPort": 40337,#g' node4/config.json
    sed -i.bak 's#"NodePort": 20338,#"NodePort": 40338,#g' node4/config.json
    rm -rf node4/config.json.bak
}

function localFront(){
    if [ $1 == 0 ];then
        cd ${TEST}
        tmux new-session -s my_session './deploy.sh lf 1'
    elif [ $1 == 1 ];then
        cd ${TEST}/dnaTest/node1
        tmux split-window -h "echo passwordtest | ./node"
        tmux select-pane -L

        cd ../node2
        tmux split-window -v "echo passwordtest | ./node"
        tmux select-pane -U

        cd ../node3
        tmux split-window -h "echo passwordtest | ./node"
        tmux select-pane -L

        cd ../node4 && echo passwordtest | ./node
    fi
}

function localBack(){
: << !
    cd ${TEST}/dnaTest/node1
    nohup ./node>/dev/null 2>&1 &
    cd ${TEST}/dnaTest/node2
    nohup ./node>/dev/null 2>&1 &
    cd ${TEST}/dnaTest/node3
    nohup ./node>/dev/null 2>&1 &
    cd ${TEST}/dnaTest/node4
    nohup ./node>/dev/null 2>&1 &
!

    cd ${TEST}/dnaTest/node1
    echo passwordtest | ./node&

    cd ${TEST}/dnaTest/node2
    echo passwordtest | ./node&

    cd ${TEST}/dnaTest/node3
    echo passwordtest | ./node&

    cd ${TEST}/dnaTest/node4
    echo passwordtest | ./node&

    stty tostop
}


function localConfig(){
    Config 0
}

function remoteConfig(){
    Config 1
}

function remoteBack(){
    echo -e '#!/bin/bash\necho passwordtest | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node1/start.sh
    echo -e '#!/bin/bash\necho passwordtest | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node2/start.sh
    echo -e '#!/bin/bash\necho passwordtest | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node3/start.sh
    echo -e '#!/bin/bash\necho passwordtest | '"./node&"'\nstty tostop\nexit 0' > dnaTest/node4/start.sh

    ssh goonchain@"${RemoteNode1Addr}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
    ssh goonchain@"${RemoteNode2Addr}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
    ssh goonchain@"${RemoteNode3Addr}" "sudo killall -9 node && sudo rm -rf dnaTest/*"
    ssh goonchain@"${RemoteNode4Addr}" "sudo killall -9 node && sudo rm -rf dnaTest/*"

    scp -C -r dnaTest/node1 goonchain@"${RemoteNode1Addr}":/home/goonchain/dnaTest
    scp -C -r dnaTest/node2 goonchain@"${RemoteNode2Addr}":/home/goonchain/dnaTest
    scp -C -r dnaTest/node3 goonchain@"${RemoteNode3Addr}":/home/goonchain/dnaTest
    scp -C -r dnaTest/node4 goonchain@"${RemoteNode4Addr}":/home/goonchain/dnaTest

    ssh goonchain@"${RemoteNode1Addr}" "cd dnaTest/node1/ && bash start.sh > /dev/null 2>&1 &"
    ssh goonchain@"${RemoteNode1Addr}" "cd dnaTest/node2/ && bash start.sh > /dev/null 2>&1 &"
    ssh goonchain@"${RemoteNode1Addr}" "cd dnaTest/node3/ && bash start.sh > /dev/null 2>&1 &"
    ssh goonchain@"${RemoteNode1Addr}" "cd dnaTest/node4/ && bash start.sh > /dev/null 2>&1 &"
}

if [ ! $1 ];then
    echo "Usage:"
    echo "    ./deploy.sh lf      or   ./deploy.sh localfront          "
    echo "    ./deploy.sh lf nc   or   ./deploy.sh localfront noconfig "
    echo "    ./deploy.sh lb      or   ./deploy.sh localback           "
    echo "    ./deploy.sh lb nc   or   ./deploy.sh localback  noconfig "
    echo
    exit
fi

case $1 in
    "localfront" | "lf")
        echo "localfront";
        if [ ! $2 ];then
            localConfig;
            localFront 0;
        elif [ $2 == nc ];then
            localFront 0
        elif [ $2 == 1 ];then
            localFront 1;
        fi
    ;;
    "localback" | "lb")
        echo "localback";
        if [ ! $2 ];then
            localConfig;
            localBack;
        elif [ $2 == nc ];then
            localBack;
        fi
    ;;
    "remoteback" | "rb")
        echo "remoteback";
        remoteConfig;
        cd ${TEST}
        remoteBack;
    ;;
esac
