From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net: fec: build fec.c and fec_ptp.c to
 one module
Date: Mon, 25 Mar 2013 12:15:22 -0400 (EDT)
Message-ID: <20130325.121522.198735535139409128.davem@davemloft.net>
References: <1364173422-7865-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, lznuaa@gmail.com,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757896Ab3CYQPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:15:24 -0400
In-Reply-To: <1364173422-7865-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Mon, 25 Mar 2013 09:03:42 +0800

> fec_ptp.ko can't run individually
> rename fec.c to fec_main.c
> Build fec.o and fec_ptp.o into one fec.ko
> Remove unnessary EXPORT_SYMBOL in fec_ptp
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied, thanks.
