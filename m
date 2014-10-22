From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: initialize bstats syncp
Date: Tue, 21 Oct 2014 21:46:12 -0400 (EDT)
Message-ID: <20141021.214612.996846961347808396.davem@davemloft.net>
References: <20141021092330.GA9863@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbaJVBqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 21:46:14 -0400
In-Reply-To: <20141021092330.GA9863@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 21 Oct 2014 11:23:30 +0200

> Use netdev_alloc_pcpu_stats to allocate percpu stats and initialize syncp.
> 
> Fixes: 22e0f8b9322c "net: sched: make bstats per cpu and estimator RCU safe"
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thank you.
