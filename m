From: bert hubert <ahu@ds9a.nl>
Subject: Re: analysis of TCP window size issues still around - several reports / SACK involved?
Date: Tue, 6 Jul 2004 14:42:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706124254.GA13395@outpost.ds9a.nl>
References: <6913615.1089117051125.JavaMail.oracle@web265.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        "David S. Miller" <davem@redhat.com>,
        "linux-kernel @ vger. kernel. org Stephen Hemminger" <shemminger@osdl.org>,
        netdev@oss.sgi.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ALESSANDRO.SUARDI@ORACLE.COM
Content-Disposition: inline
In-Reply-To: <6913615.1089117051125.JavaMail.oracle@web265.oracle.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2004 at 06:30:51AM -0600, ALESSANDRO.SUARDI@ORACLE.COM wrote:

> Further data points: -bk18 built with GCC 3.4.1 still hangs talking to
>  most of the world except google.it (redirected from google.com) from my
>  home DSL (US Robotics USR9003 router).

I juist built 2.6.7-mm6 in an attempt to reproduce your problems but I can't
see them, can you check with that version too?

> It _also_ works from my home _if_ I fire up the Cisco VPN client (4.0.4.B)
>  to an Oracle VPN server and access the 'net (kernel.org and all) via our
>  proxies through the VPN.

Is this the 5mb binary kernel module blob version? Can you reproduce the bug
on a system that has never touched this module?

Furthermore, can you email me your IP address and try to connect to
http://ds9a.nl/hi-ahu afterwards I confirm receipt? I want to see the server
side of the story.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
