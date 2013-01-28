From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] can: rework skb reserved data handling
Date: Mon, 28 Jan 2013 18:17:48 -0500 (EST)
Message-ID: <20130128.181748.1980658030876326536.davem@davemloft.net>
References: <5106C47D.9000704@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3A1XRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:17:50 -0500
In-Reply-To: <5106C47D.9000704@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Mon, 28 Jan 2013 19:33:33 +0100

> Added accessor and skb_reserve helpers for struct can_skb_priv.
> Removed pointless skb_headroom() check.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> CC: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thanks.
