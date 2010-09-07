From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/30] net: ppp_async: semaphore cleanup
Date: Tue, 07 Sep 2010 09:28:53 -0700 (PDT)
Message-ID: <20100907.092853.104061734.davem@davemloft.net>
References: <20100907124636.880953480@linutronix.de>
	<20100907125055.460765783@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mingo@elte.hu, peterz@infradead.org, hch@infradead.org,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757942Ab0IGQ2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 12:28:36 -0400
In-Reply-To: <20100907125055.460765783@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 07 Sep 2010 14:32:22 -0000

> Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: David S. Miller <davem@davemloft.net>
