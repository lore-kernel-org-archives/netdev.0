From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 13:47:21 +0100
Message-ID: <20050129124720.GZ31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050128230327.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050128230327.GV31837@postel.suug.ch> 2005-01-29 00:03
> --- linux-2.6.11-rc2-bk4.orig/include/linux/netlink.h	2005-01-26 18:19:27.000000000 +0100
> +++ linux-2.6.11-rc2-bk4/include/linux/netlink.h	2005-01-28 23:06:02.000000000 +0100

It is also needed for 2.4 and applies with some fuzz.
