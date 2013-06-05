From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: fec: add fallback to random MAC address
Date: Tue, 04 Jun 2013 17:00:48 -0700 (PDT)
Message-ID: <20130604.170048.1466547214154240887.davem@davemloft.net>
References: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@denx.de
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab3FEAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:00:49 -0400
In-Reply-To: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Mon,  3 Jun 2013 12:38:39 +0200

> If no valid MAC address could be obtained from the hardware,
> fall back to a randomly generated one.
> 
> Signed-off-by: Pavel Machek <pavel@denx.de>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Applied.
