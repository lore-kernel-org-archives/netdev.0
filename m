From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6] Use dev_get_flags() while building inet6 ifinfo
 message
Date: Tue, 15 Mar 2005 09:26:10 +0900 (JST)
Message-ID: <20050315.092610.112709648.yoshfuji@linux-ipv6.org>
References: <20050315001417.GB3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: tgraf@suug.ch, davem@davemloft.net
In-Reply-To: <20050315001417.GB3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050315001417.GB3086@postel.suug.ch> (at Tue, 15 Mar 2005 01:14:17 +0100), Thomas Graf <tgraf@suug.ch> says:

> Use dev_get_flags() in inet6_fill_ifinfo() to fetch interface flags
> to ensure correctly reporting IFF_PROMISC and IFF_ALLMULTI flags.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

sane to me.

--yoshfuji
