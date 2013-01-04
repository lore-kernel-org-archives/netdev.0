From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1 net-next] NET: FEC: dynamtic check DMA desc buff
 type
Date: Fri, 04 Jan 2013 15:16:06 -0800 (PST)
Message-ID: <20130104.151606.181887747842513051.davem@davemloft.net>
References: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, s.hauer@pengutronix.de,
	linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	netdev@vger.kernel.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab3ADXQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 18:16:07 -0500
In-Reply-To: <1357265063-30528-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Fri, 4 Jan 2013 10:04:23 +0800

> MX6 and mx28 support enhanced DMA descriptor buff to support 1588
> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descriptor buff.
> Check fec type and choose correct DMA descriptor buff type.
> 
> Remove static config CONFIG_FEC_PTP.
> ptp function will be auto detected.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
