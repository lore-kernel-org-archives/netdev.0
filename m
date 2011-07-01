From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Fri, 01 Jul 2011 15:31:10 -0700 (PDT)
Message-ID: <20110701.153110.1360455002202861127.davem@davemloft.net>
References: <4E0D43C3.5090502@redhat.com>
	<20110701.000646.268663722441785795.davem@davemloft.net>
	<1309558703.7277.78.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab1GAWbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 18:31:14 -0400
In-Reply-To: <1309558703.7277.78.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 01 Jul 2011 15:18:23 -0700

> These are inlined and dependent on CONFIG_NET_POLL_CONTROLLER
> in drivers/net/Kconfig so doesn't netpoll_send_skb_on_dev need
> to be SYMBOL_EXPORTed?

Right I noticed this when I read the rest of the thread
where this was discussed.
