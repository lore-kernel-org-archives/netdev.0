From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix byte stats on eql
Date: Sun, 25 Mar 2012 13:28:26 -0400 (EDT)
Message-ID: <20120325.132826.857771976623477853.davem@davemloft.net>
References: <1332669700.32446.142.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756644Ab2CYR3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 13:29:40 -0400
In-Reply-To: <1332669700.32446.142.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 25 Mar 2012 11:01:40 +0100

> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Please use a driver/subsystem prefix in your Subject lines,
in this case "eql: Fix byte stats." would have been appropriate.

> @@ -345,6 +345,7 @@ static netdev_tx_t eql_slave_xmit(struct sk_buff
> *skb, struct net_device *dev)

Patch corrupted by your email client.
