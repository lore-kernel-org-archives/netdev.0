From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: gro: fix PV6_GRO_CB(skb)->proto problem
Date: Tue, 09 Oct 2012 12:44:52 -0400 (EDT)
Message-ID: <20121009.124452.707329315569805174.davem@davemloft.net>
References: <1349725130.21172.3663.camel@edumazet-glaptop>
	<20121008.154148.2288526275691661749.davem@davemloft.net>
	<1349787985.21172.4305.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab2JIQoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 12:44:54 -0400
In-Reply-To: <1349787985.21172.4305.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Oct 2012 15:06:25 +0200

> Hmm, it appears its a false alarm, you can remove it from stable
> candidates.

Done.

> I'll send a patch to remove this double copy in net-next

Ok.
