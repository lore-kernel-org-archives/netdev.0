From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mpc52xx_phy: Various code cleanups
Date: Wed, 02 Jun 2010 03:45:40 -0700 (PDT)
Message-ID: <20100602.034540.73663475.davem@davemloft.net>
References: <1274264470-2905-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	grant.likely@secretlab.ca
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755213Ab0FBKpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:45:32 -0400
In-Reply-To: <1274264470-2905-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Wed, 19 May 2010 12:21:10 +0200

> - don't free bus->irq (obsoleted by ca816d98170942371535b3e862813b0aba9b7d90)
> - don't dispose irqs (should be done in of_mdiobus_register())
> - use fec-pointer consistently in transfer()
> - use resource_size()
> - cosmetic fixes
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>

Applied, thanks.
