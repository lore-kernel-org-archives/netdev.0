From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 dead in -bk11
Date: Tue, 02 Nov 2004 22:53:43 +0900 (JST)
Message-ID: <20041102.225343.06193184.yoshfuji@linux-ipv6.org>
References: <418781EF.7020100@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org,
        davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <418781EF.7020100@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <418781EF.7020100@pobox.com> (at Tue, 02 Nov 2004 07:47:43 -0500), Jeff Garzik <jgarzik@pobox.com> says:

> 
> IPv6 works 100% for my workstations in 2.6.10-rc2-bk2, but fails in 
> 2.6.10-rc2-bk11:
> 
> 	[jgarzik@sata g]$ ping6 www.kame.net
> 	connect: Network is unreachable

Please send me:
 % ifconfig -a
 % netstat -nr --inet6
 % ip -6 addr
 % ip -6 route
 % ip -6 neigh

Thanks.

--yoshfuji @ still trying to debug refcnt etc....
