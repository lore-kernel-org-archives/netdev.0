From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cleanup some rcu_dereference_raw
Date: Fri, 12 Aug 2011 03:01:55 -0700 (PDT)
Message-ID: <20110812.030155.219819448476798812.davem@davemloft.net>
References: <1313127052.2669.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab1HLKB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 06:01:57 -0400
In-Reply-To: <1313127052.2669.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Aug 2011 07:30:52 +0200

> RCU api had been completed and rcu_access_pointer() or
> rcu_dereference_protected() are better than generic
> rcu_dereference_raw()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
