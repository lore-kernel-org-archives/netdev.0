From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sun, 19 Sep 2004 11:11:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919.111141.42341294.yoshfuji@linux-ipv6.org>
References: <20040918.084304.75142669.yoshfuji@linux-ipv6.org>
	<20040918220211.GI6005@sunbeam.de.gnumonks.org>
	<20040918180647.6be57884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, usagi-users@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040918180647.6be57884.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040918180647.6be57884.davem@davemloft.net> (at Sat, 18 Sep 2004 18:06:47 -0700), "David S. Miller" <davem@davemloft.net> says:

> On Sun, 19 Sep 2004 00:02:11 +0200
> Harald Welte <laforge@gnumonks.org> wrote:
> 
> > Now I'm stuck with another issue:  The interfaces suddenly no logner
> > get any link-local addresses:
> 
> Probably due to this change.
> 
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/09/10 14:50:26-07:00 yoshfuji@linux-ipv6.org 
> #   [IPV6]: Deprecate all-on-link assumption

I don't think so.
I've run TAHI test on post-rc2 kernel, 
and the result is as I expected.
I haven't met such issues...  hmm...

--yoshfuji
