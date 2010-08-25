From: David Miller <davem@davemloft.net>
Subject: Re: Spurious "TCP: too many of orphaned sockets", unable to
 allocate sockets
Date: Wed, 25 Aug 2010 02:28:18 -0700 (PDT)
Message-ID: <20100825.022818.193697635.davem@davemloft.net>
References: <20100825.005929.15250658.davem@davemloft.net>
	<20100825.012058.116362511.davem@davemloft.net>
	<1282726057.2487.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org, miltonm@bga.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825Ab0HYJ2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 05:28:04 -0400
In-Reply-To: <1282726057.2487.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Aug 2010 10:47:37 +0200

> tcp_too_many_orphans() might be a bit large to still be inlined ...

We can look into that once this propagates to net-next-2.6

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for reviewing.
