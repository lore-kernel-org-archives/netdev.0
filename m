From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: Mon, 23 Feb 2004 20:01:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223.200101.39143636.yoshfuji@linux-ipv6.org>
References: <20040222234750.GA78924@colin2.muc.de>
	<20040222232601.481b8c57.davem@redhat.com>
	<20040223105359.GA91938@colin2.muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, mostrows@styx.uwaterloo.ca,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <20040223105359.GA91938@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040223105359.GA91938@colin2.muc.de> (at 23 Feb 2004 11:53:59 +0100,Mon, 23 Feb 2004 11:53:59 +0100), Andi Kleen <ak@muc.de> says:

> -#define SK_WMEM_MAX	65535
> -#define SK_RMEM_MAX	65535
> +#define SK_WMEM_MAX    131072
> +#define SK_RMEM_MAX	131072

131071?

--yoshfuji
