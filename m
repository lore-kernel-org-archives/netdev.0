From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Wed, 22 Sep 2004 12:06:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922.120630.96674716.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
	<20040920.152012.114156249.yoshfuji@linux-ipv6.org>
	<20040921195752.015e3d1d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com,
        usagi-users@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040921195752.015e3d1d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040921195752.015e3d1d.davem@davemloft.net> (at Tue, 21 Sep 2004 19:57:52 -0700), "David S. Miller" <davem@davemloft.net> says:

> On Mon, 20 Sep 2004 15:20:12 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > This behavior lives for years (AFAIK),
> > and we haven't got so many reports 
> > because people usually bring loopback device first.
> > 
> > I think the following message will help people, anyway.
> 
> If ipv6 has a dependency upon this, why doesn't it just
> bring the device up itself at this moment if necessary?

Okay, I'll make a patch for this.

--yoshfuji
