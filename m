From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove unused tcp_fin() parameters
Date: Thu, 20 Oct 2011 17:44:24 -0400 (EDT)
Message-ID: <20111020.174424.1612732575369559136.davem@davemloft.net>
References: <1319145084.2854.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab1JTVo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:44:27 -0400
In-Reply-To: <1319145084.2854.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 23:11:24 +0200

> tcp_fin() only needs socket pointer, we can remove skb and th params.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
