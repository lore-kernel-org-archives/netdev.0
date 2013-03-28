From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net/macb: fixes to use core on Zynq SoCs
Date: Thu, 28 Mar 2013 14:41:37 -0400 (EDT)
Message-ID: <20130328.144137.1965366538495795999.davem@davemloft.net>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: s.trumtrar@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439Ab3C1Slk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:41:40 -0400
In-Reply-To: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Date: Thu, 28 Mar 2013 10:07:04 +0100

> The Cadence GEM is also licensed for the Xilinx Zynq7000 SoCs.
> As Xilinx uses other reset defaults, some fixes are necessary to have it
> working there. And as the Zynq is dualcore, the clk_enables/disables now need
> to be atomic.
> 
> Changes in v2:
> 	- only 3/3 was changed to correctly use the atomic clk_[en|dis]able

Series applied, thanks.
