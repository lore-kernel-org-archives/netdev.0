From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax88796: depend on HAS_IOMEM not on individual ARCHs
Date: Tue, 22 Feb 2011 12:37:32 -0800 (PST)
Message-ID: <20110222.123732.70186533.davem@davemloft.net>
References: <20110222.111856.102538007.davem@davemloft.net>
	<1298405998-6214-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750920Ab1BVUg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 15:36:58 -0500
In-Reply-To: <1298405998-6214-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 22 Feb 2011 21:19:58 +0100

> Reported-by: David Miller <davem@davemloft.net>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> 
> Hello David,
> 
> this patch is available in the git repository at:
>   git://git.pengutronix.de/git/mkl/linux-2.6.git net/ax88796
> 
> based on the patches already merged into net-next.

I would like you to actually build test this.

I know it's going to cause allmodconfig build errors on sparc64,
for example.
