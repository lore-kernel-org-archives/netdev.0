From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] IPv6 updates
Date: Sun, 13 Jan 2013 20:32:55 -0500 (EST)
Message-ID: <20130113.203255.1305411796615468589.davem@davemloft.net>
References: <50F2CCA0.4080500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3ANBdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 20:33:02 -0500
In-Reply-To: <50F2CCA0.4080500@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Jan 2013 00:02:56 +0900

> Hello.
> 
> YOSHIFUJI Hideaki (7):
>   ipv6: Introduce ip6_flow_hdr() to fill version, tclass and flowlabel.
>   ipv6: Introduce ip6_flowinfo() to extract flowinfo (tclass +
>     flowlabel).
>   ipv6: Use ipv6_get_dsfield() instead of ipv6_tclass().
>   ipv6: Make ipv6_is_mld() inline and use it from ip6_mc_input().
>   ipv6 route: Use ipv6_addr_hash() in rt6_info_hash_nhsfn().
>   ipv6 xfrm: Use ipv6_addr_hash() in xfrm6_tunnel_spi_hash_byaddr().
>   ipv6: Store Router Alert option in IP6CB directly.

Series applied, thanks.
