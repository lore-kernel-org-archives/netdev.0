From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: connecting ipv6 nodes throu' ipv4 network ....
Date: 20 Feb 2003 12:13:35 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220121335.22268.qmail@webmail28.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / $B5HF#1QL@\(B" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

as iam in a IPv4 LAN, do i need to setup a tunnel for these IPv6 hosts
to communicate ??

any configuration required ??
-San
------------------------------

On Thu, 20 Feb 2003 YOSHIFUJI Hideaki / $B5HF#1QL@(B wrote :
>In article <20030220114636.21895.qmail@webmail29.rediffmail.com> (at 20 Feb 2003 11:46:36 -0000), "santosh kumar gowda" <ipv6_san@rediffmail.com> says:
>
> > 8: epmac1: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
> >     inet6 3ffe:1234::2/128 scope global
>:
> >     inet6 3ffe:1234::1/128 scope global
>
>use /64 instead.
>
>--yoshfuji
>
>
 
