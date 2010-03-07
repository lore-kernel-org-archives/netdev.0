From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] netfilter: Remove stale declaration for
 ip6_masked_addrcmp().
Date: Sun, 07 Mar 2010 15:27:19 -0800 (PST)
Message-ID: <20100307.152719.53364949.davem@davemloft.net>
References: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 7 Mar 2010 17:39:13 +0900

> Commit f2ffd9ee... ("[NETFILTER]: Move ip6_masked_addrcmp to
> include/net/ipv6.h") replaced ip6_masked_addrcmp() with
> ipv6_masked_addr_cmp().  Function definition went away.
> 
> Let's remove its declaration as well in header file.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patrick, I assume you'll get this one too.

Thanks.
