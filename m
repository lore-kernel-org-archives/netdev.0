From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: fix build error
Date: Thu, 24 Nov 2011 00:42:24 -0500 (EST)
Message-ID: <20111124.004224.1561680524524841332.davem@davemloft.net>
References: <1322106438.16201.11.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, buytenh@wantstofly.org,
	netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab1KXFm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 00:42:28 -0500
In-Reply-To: <1322106438.16201.11.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Axel Lin <axel.lin@gmail.com>
Date: Thu, 24 Nov 2011 11:47:18 +0800

> Fix below build error:
>   CC      drivers/net/ethernet/marvell/mv643xx_eth.o
> drivers/net/ethernet/marvell/mv643xx_eth.c: In function 'mv643xx_eth_get_drvinfo':
> drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: 'info' undeclared (first use in this function)
> drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: (Each undeclared identifier is reported only once
> drivers/net/ethernet/marvell/mv643xx_eth.c:1505: error: for each function it appears in.)
> make[4]: *** [drivers/net/ethernet/marvell/mv643xx_eth.o] Error 1
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Applied, thanks.
