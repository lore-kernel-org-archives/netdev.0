From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 23:31:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910.233157.362649106.yoshfuji@linux-ipv6.org>
References: <20040910133637.GA20088@postel.suug.ch>
	<20040910.230038.322907649.yoshfuji@linux-ipv6.org>
	<20040910142804.GC20088@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch, davem@davemloft.net
In-Reply-To: <20040910142804.GC20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040910142804.GC20088@postel.suug.ch> (at Fri, 10 Sep 2004 16:28:04 +0200), Thomas Graf <tgraf@suug.ch> says:

> > Please use sizeof(ifname) instead.
> 
> Thanks for the hint.
> 
> Allows changing of device name via rtnetlink. Last bit needed to do full
> link configuration via rtnetlink.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks. Ack.
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji
