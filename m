From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add skb frag size accessors
Date: Wed, 19 Oct 2011 03:13:43 -0400 (EDT)
Message-ID: <20111019.031343.1993209929822862836.davem@davemloft.net>
References: <1318279267.2567.19.camel@edumazet-laptop>
	<1319007624.16303.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab1JSHNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 03:13:46 -0400
In-Reply-To: <1319007624.16303.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 09:00:24 +0200

> To ease skb->truesize sanitization, its better to be able to localize
> all references to skb frags size.
> 
> Define accessors : skb_frag_size() to fetch frag size, and
> skb_frag_size_{set|add|sub}() to manipulate it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for respinning this Eric.
