From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sat, 18 Sep 2004 08:43:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918.084304.75142669.yoshfuji@linux-ipv6.org>
References: <20040917230803.GJ2678@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@netfilter.org
In-Reply-To: <20040917230803.GJ2678@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040917230803.GJ2678@sunbeam.de.gnumonks.org> (at Sat, 18 Sep 2004 01:08:03 +0200), Harald Welte <laforge@netfilter.org> says:

> I'm experiencing some strange problems on a 2.6.8.1 vanilla kernel.  I
> tried to reproduce it with a minimal system:
:
> (intermixed with a 'ip6tables -A OUTPUT -j LOG' and '-A INPUT -j LOG'
> rules for diagnostics).

It is not minimum with ip6tables. :-)

Anyway, please try the latest bk tree.
There are may fixes in it.

Thanks.

--yoshfuji
