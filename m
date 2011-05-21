From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] garp: use kfree_rcu()
Date: Sat, 21 May 2011 02:06:31 -0400 (EDT)
Message-ID: <20110521.020631.2280161550569829152.davem@davemloft.net>
References: <1305952290.2862.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab1EUGGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 02:06:35 -0400
In-Reply-To: <1305952290.2862.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 21 May 2011 06:31:30 +0200

> Use kfree_rcu() instead of call_rcu(), remove garp_cleanup_module()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
