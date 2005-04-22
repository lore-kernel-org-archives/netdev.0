From: cranium2003 <cranium2003@yahoo.com>
Subject: Help getting Neighbour table overflow a lot messages
Date: Fri, 22 Apr 2005 03:37:48 -0700 (PDT)
Message-ID: <20050422103749.43324.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
   I want to know what happed to my system RedHat
linux 9. I brought kernel in tar.gz format from other
pc rebuild it and recompile it after that i am getting
following messages. I have configured 2.4.20,
2.4.30,2.6.11 kernels and the kernel after which it
happened is 2.4.20.
NET: 3809 messages suppressed.
Neighbour table overflow.
NET: 2663 messages suppressed.
Neighbour table overflow.
NET: 10553 messages suppressed.
Neighbour table overflow.
NET: 11910 messages suppressed.
Neighbour table overflow.
NET: 11324 messages suppressed.
Neighbour table overflow.
NET: 11294 messages suppressed.
Neighbour table overflow.
NET: 1778 messages suppressed.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
Neighbour table overflow.
NET: 33 messages suppressed.
Neighbour table overflow.

 Please help. My ifconfig is
         eth0      Link encap:Ethernet  HWaddr
00:08:A1:43:61:F5
          inet addr:192.168.1.1  Bcast:192.168.1.255 
Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500 
Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0
frame:0
          TX packets:43 errors:0 dropped:0 overruns:0
carrier:0
          collisions:0 txqueuelen:100     RX bytes:0
(0.0 b)  TX bytes:2580 (2.5 Kb)
          Interrupt:9 Base address:0x7c00

eth1      Link encap:Ethernet  HWaddr
00:80:48:C3:11:94
          inet addr:10.1.1.30  Bcast:10.255.255.255 
Mask:255.0.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500 
Metric:1
          RX packets:1739765 errors:0 dropped:0
overruns:0 frame:1
          TX packets:270 errors:0 dropped:0 overruns:0
carrier:0
          collisions:60 txqueuelen:100
          RX bytes:109742910 (104.6 Mb)  TX
bytes:24318 (23.7 Kb)
          Interrupt:11 Base address:0xdc00

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:15 errors:0 dropped:0 overruns:0
frame:0
          TX packets:15 errors:0 dropped:0 overruns:0
carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1344 (1.3 Kb)  TX bytes:1344 (1.3
Kb)


Thanks,
cranium.


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
