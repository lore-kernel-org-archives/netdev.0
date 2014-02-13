From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix macvtap type name in Kconfig
Date: Thu, 13 Feb 2014 15:49:02 -0500 (EST)
Message-ID: <20140213.154902.1116887258017661458.davem@davemloft.net>
References: <1392064851-25879-1-git-send-email-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jlu@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaBMUtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:49:04 -0500
In-Reply-To: <1392064851-25879-1-git-send-email-jlu@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Luebbe <jlu@pengutronix.de>
Date: Mon, 10 Feb 2014 21:40:51 +0100

> The netlink kind (and iproute2 type option) is actually called
> 'macvtap', not 'macvlan'.
> 
> Signed-off-by: Jan Luebbe <jlu@pengutronix.de>

Applied, thank you.
