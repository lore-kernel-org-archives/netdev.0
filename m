From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][v2] net/fsl: remove irq assignment from xgmac_mdio
Date: Fri, 02 Jan 2015 15:40:19 -0500 (EST)
Message-ID: <20150102.154019.771127657945218434.davem@davemloft.net>
References: <1419928080-2492-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbbABUkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:40:22 -0500
In-Reply-To: <1419928080-2492-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 30 Dec 2014 16:28:00 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Which is wrong and not used, so no extra space needed by
> mdiobus_alloc_size(), use mdiobus_alloc() instead.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next.
