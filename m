From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2012-02-20
Date: Mon, 20 Feb 2012 19:25:18 -0500 (EST)
Message-ID: <20120220.192518.786309842427365426.davem@davemloft.net>
References: <1329735512-29402-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab2BUA0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 19:26:43 -0500
In-Reply-To: <1329735512-29402-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 20 Feb 2012 11:58:31 +0100

> here's a single patch intendet for 3.3. Oliver Hartkopp fixed a problem in
> the generic SJA1000 interrupt handler. If you unplug a PCMCIA or PCIe card,
>  when the CAN bus is under high load, the interrupt handler my
> loop forever, not noticing that the hardware has been removed. I added
> stable to Cc, v3.2 was the first kernel with such a driver.
> 

Pulled, thanks Marc.
