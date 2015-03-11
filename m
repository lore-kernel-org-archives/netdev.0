From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: remove dependency FSL_SOC from MDIO
Date: Wed, 11 Mar 2015 16:38:22 -0400 (EDT)
Message-ID: <20150311.163822.1016494609136830384.davem@davemloft.net>
References: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbbCKUiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:38:23 -0400
In-Reply-To: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 10 Mar 2015 18:31:12 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> FSL_PQ_MDIO and FSL_XGMAC_MDIO are not really depend on FSL_SOC, they
> can build on non-PPC platforms.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next, thanks.
