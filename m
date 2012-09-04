From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Tue, 04 Sep 2012 12:16:56 -0400 (EDT)
Message-ID: <20120904.121656.2025365336670723686.davem@davemloft.net>
References: <1346626385.2563.44.camel@edumazet-glaptop>
	<1346629684.2563.78.camel@edumazet-glaptop>
	<1346745325.13121.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, hvtaifwkbgefbaei@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757377Ab2IDQRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 12:17:02 -0400
In-Reply-To: <1346745325.13121.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Sep 2012 09:55:25 +0200

> This patch was marked "Not applicable" in Patchwork
> ( http://patchwork.ozlabs.org/patch/181275/ )
> 
> It seems a mistake, since it should be applied ?

Not applicable can mean "doesn't go through my tree"

This is netfilter stuff, so please submit it via the
netfilter folks :-)
