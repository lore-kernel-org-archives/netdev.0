From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Do not assume that PHY reset is active low
Date: Sun, 29 Dec 2013 22:27:18 -0500 (EST)
Message-ID: <20131229.222718.757539531655830933.davem@davemloft.net>
References: <1387894561-31494-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org,
	p.zabel@pengutronix.de, netdev@vger.kernel.org,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3L3D1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:27:19 -0500
In-Reply-To: <1387894561-31494-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 24 Dec 2013 12:16:01 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> We should not assume that the PHY reset is always active low.
> 
> Retrieve this information from the device tree instead, so that the PHY reset
> can work on both cases.
> 
> Reported-by: Philipp Zabel <p.zabel@pengutronix.de>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thank you.
