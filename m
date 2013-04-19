From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Fri, 19 Apr 2013 13:38:25 -0400 (EDT)
Message-ID: <20130419.133825.1727571575417364801.davem@davemloft.net>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com,
	shawn.guo@linaro.org, festevam@gmail.com
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3DSRi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:38:28 -0400
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Fri, 19 Apr 2013 16:36:01 +0200

> As it's way too late in the cycle to try and fix this up just revert the
> relevant patches for now.

I disagree, fix this properly, the revert is more intrusive.
