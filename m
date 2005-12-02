From: "JaniD++" <djani22@dynamicweb.hu>
Subject: Re: 2.6.15-rc3: adduser: unable to lock password file
Date: Fri, 2 Dec 2005 12:26:34 +0100
Message-ID: <011401c5f733$46a3cd60$0400a8c0@dcccs>
References: <016c01c5f6cc$0e28e6d0$0400a8c0@dcccs> <1133481721.9597.37.camel@lade.trondhjem.org> <00f801c5f72e$df2e58c0$0400a8c0@dcccs> <20051202110805.GA7224@stiffy.osknowledge.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932728AbVLBLbr@vger.kernel.org>
To: "Marc Koschewski" <marc@osknowledge.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > OK, i will try it, if i can.... (this is a productive online system,
maybe
> > next reboot)
>
> I'd rather suggest to _not_ run -rc kernels on productive systems. :)

Thanks for the warning! :-)

I know it, already.
But have no choice. :(
The older kernels didnt know what i have needed! :-/

eg: i try the 2.6.15-rc3 because 2.6.14.2 gives me this messages:

KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
nfs: server 192.168.2.100 not responding, still trying
nfs: server 192.168.2.100 not responding, still trying
nfs: server 192.168.2.100 not responding, still trying
nfs: server 192.168.2.100 not responding, still trying
nfs: server 192.168.2.100 not responding, still trying
NETDEV WATCHDOG: eth0: transmit timed out
e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
nfs: server 192.168.2.100 OK
nfs: server 192.168.2.100 OK
nfs: server 192.168.2.100 OK
nfs: server 192.168.2.100 OK
nfs: server 192.168.2.100 OK

So, i really did not see different! :-D

Cheers,

Janos

>
> Marc
