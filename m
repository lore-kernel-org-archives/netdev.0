From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix non tbi phy access
Date: Mon, 14 Nov 2011 01:45:11 -0500 (EST)
Message-ID: <20111114.014511.962880729020099283.davem@davemloft.net>
References: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab1KNGp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 01:45:29 -0500
In-Reply-To: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Mon, 14 Nov 2011 08:21:30 +0200

> Since 952c5ca1 (fsl_pq_mdio: Clean up tbi address configuration) .probe returns
> -EBUSY when the "tbi-phy" node is missing. Fix this.
> 
> Cc: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied, thanks.
