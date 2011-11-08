From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: min_pmtu default is 552
Date: Tue, 08 Nov 2011 14:21:52 -0500 (EST)
Message-ID: <20111108.142152.319380711284648099.davem@davemloft.net>
References: <1320779428.2588.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab1KHTV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:21:56 -0500
In-Reply-To: <1320779428.2588.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2011 20:10:28 +0100

> Small fix in Documentation, since min_pmtu is 512 + 20 + 20 = 552
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
