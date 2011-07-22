From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] acenic: include NET_SKB_PAD headroom to incoming skbs
Date: Thu, 21 Jul 2011 23:25:01 -0700 (PDT)
Message-ID: <20110721.232501.1187843432422240228.davem@davemloft.net>
References: <1311312533.3886.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab1GVGZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 02:25:03 -0400
In-Reply-To: <1311312533.3886.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Jul 2011 07:28:53 +0200

> Some workloads need some headroom (NET_SKB_PAD) to avoid expensive
> reallocations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
