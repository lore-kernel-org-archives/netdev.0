From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mv643xx: use GFP_ATOMIC while atomic
Date: Wed, 18 Feb 2009 17:37:35 -0800 (PST)
Message-ID: <20090218.173735.219377998.davem@davemloft.net>
References: <20090215092618.GA12280@Chamillionaire.breakpoint.cc>
	<20090216145430.GW17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian@breakpoint.cc, jeff@garzik.org, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbZBSBhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:37:51 -0500
In-Reply-To: <20090216145430.GW17914@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 16 Feb 2009 15:54:30 +0100

> On Sun, Feb 15, 2009 at 01:26:18AM -0800, Sebastian Andrzej Siewior wrote:
> 
> > dev_set_rx_mode() grabs netif_addr_lock_bh():
> > 
 ...
> > Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> 
> Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
