From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sun, 28 Apr 2013 01:11:44 -0400 (EDT)
Message-ID: <20130428.011144.1722290947259121116.davem@davemloft.net>
References: <20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, l.stach@pengutronix.de, netdev@vger.kernel.org,
	Frank.Li@freescale.com, festevam@gmail.com, shawn.guo@linaro.org
To: r.schwebel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3D1FLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 01:11:47 -0400
In-Reply-To: <20130427090545.GY1366@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Schwebel <r.schwebel@pengutronix.de>
Date: Sat, 27 Apr 2013 11:05:45 +0200

> Please consider to merge the reverts. Otherwhise FEC will be broken
> in 3.9.

The amount of effort you put into this email, and complaining,
far exceed that necessary to help Frank write a fix.

I've already told you how I want to see this resolved, and you
haven't given me any new information, so my point of view has
not changed.
