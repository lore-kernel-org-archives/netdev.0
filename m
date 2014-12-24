From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: Rearrange loop in net_rx_action
Date: Tue, 23 Dec 2014 23:20:53 -0500 (EST)
Message-ID: <20141223.232053.31234928008201022.davem@davemloft.net>
References: <20141220201453.GA6924@gondor.apana.org.au>
	<E1Y2QRt-0001qq-Lp@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbaLXEUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 23:20:55 -0500
In-Reply-To: <E1Y2QRt-0001qq-Lp@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 21 Dec 2014 07:16:25 +1100

> This patch rearranges the loop in net_rx_action to reduce the
> amount of jumping back and forth when reading the code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
