From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: send unsolicited neighbour advertisements to
 all-nodes
Date: Fri, 09 Nov 2012 16:22:26 -0500 (EST)
Message-ID: <20121109.162226.2213649326256124403.davem@davemloft.net>
References: <20121107021841.GC26398@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761Ab2KIVW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:22:27 -0500
In-Reply-To: <20121107021841.GC26398@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 7 Nov 2012 03:18:41 +0100

> As documented in RFC4861 (Neighbor Discovery for IP version 6) 7.2.6.,
> unsolicited neighbour advertisements should be sent to the all-nodes
> multicast address.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
