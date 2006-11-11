From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL 2.6.20] IPv6 Updates
Date: Sat, 11 Nov 2006 00:04:37 -0800 (PST)
Message-ID: <20061111.000437.92586023.davem@davemloft.net>
References: <20061110.171514.79983384.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57789
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1947139AbWKKIEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Nov 2006 03:04:39 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061110.171514.79983384.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 10 Nov 2006 17:15:14 -0800 (PST)

> Please consider pulling following changesets from
> "2.6.19-rc5-net-2.6.20-20061110-to-davem" branch at:
> 	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git
> 
> Regards,
> 
> HEADLINES
> ---------
> 
>     [IPV6] ROUTE: Use macros to format /proc/net/ipv6_route.
>     [IPV6] ROUTE: Use &rt->u.dst instead of cast.
>     [IPV6]: Introduce ip6_dst_idev() to get inet6_dev{} stored in dst_entry{}.
>     [IPV6]: Per-interface statistics support.

Pulled, thanks a lot.
