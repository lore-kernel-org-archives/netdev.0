From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fec: default select FEC_PTP at mx6 platform
Date: Wed, 07 Nov 2012 18:52:46 -0500 (EST)
Message-ID: <20121107.185246.1330887590098677807.davem@davemloft.net>
References: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, richardcochran@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab2KGXww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 18:52:52 -0500
In-Reply-To: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Wed, 7 Nov 2012 14:14:43 +0800

> Remove PPS.
> Limit FEC_PTP option for i.MX chip only.
> FEC_PTP default is on at mx6 platform.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied to net-next.

But please be explicit about which tree your patches are for in the
subject line in the future.
