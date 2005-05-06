From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC: 2.6 patch] net/ipv6/ipv6_syms.c: unexport fl6_sock_lookup
Date: Sat, 07 May 2005 08:56:39 +0900 (JST)
Message-ID: <20050507.085639.75977025.yoshfuji@linux-ipv6.org>
References: <20050506232000.GC3590@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@stusta.de, davem@davemloft.net
In-Reply-To: <20050506232000.GC3590@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050506232000.GC3590@stusta.de> (at Sat, 7 May 2005 01:20:00 +0200), Adrian Bunk <bunk@stusta.de> says:

> There is no usage of this EXPORT_SYMBOL in the kernel.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

> --- linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c.old	2005-05-05 22:23:17.000000000 +0200
> +++ linux-2.6.12-rc3-mm3-full/net/ipv6/ipv6_syms.c	2005-05-05 22:23:23.000000000 +0200
> @@ -37,5 +37,4 @@
>  EXPORT_SYMBOL(xfrm6_rcv);
>  #endif
>  EXPORT_SYMBOL(rt6_lookup);
> -EXPORT_SYMBOL(fl6_sock_lookup);
>  EXPORT_SYMBOL(ipv6_push_nfrag_opts);
> 
> 
