From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
Date: Wed, 04 Sep 2013 14:58:16 -0400 (EDT)
Message-ID: <20130904.145816.1990856496857762166.davem@davemloft.net>
References: <20130903001331.GA8820@order.stressinduktion.org>
	<20130904.141301.41040920905693536.davem@davemloft.net>
	<20130904185145.GC13136@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michele@acksyn.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, sasha.levin@oracle.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab3IDS6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:58:18 -0400
In-Reply-To: <20130904185145.GC13136@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 4 Sep 2013 20:51:45 +0200

> Sorry I forgot to mention that this patch is also applicable to solve
> this issue in the longterm 3.10 kernel. Maybe this should go to stable?

I did queue it up for -stable already.
