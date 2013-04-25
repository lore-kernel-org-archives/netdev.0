From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Thu, 25 Apr 2013 15:14:29 -0400 (EDT)
Message-ID: <20130425.151429.1439168768104456280.davem@davemloft.net>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	<20130419.133825.1727571575417364801.davem@davemloft.net>
	<1366893854.4139.17.camel@weser.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	shawn.guo@linaro.org, festevam@gmail.com
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758365Ab3DYTOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:14:31 -0400
In-Reply-To: <1366893854.4139.17.camel@weser.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Thu, 25 Apr 2013 14:44:14 +0200

> The only way to reliably fix all the failures I'm seeing is really
> reverting the changes, as done with this series. So David please
> consider taking the reverts, even while they are a bit intrusive, they
> are the only way to get a 3.9 release out of the door with a working FEC
> driver.

You'll need to formally resubmit it.
