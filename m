From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-12-07
Date: Tue, 09 Dec 2014 16:49:34 -0500 (EST)
Message-ID: <20141209.164934.2076716794543215133.davem@davemloft.net>
References: <5484E3C3.5030205@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbaLIVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:49:40 -0500
In-Reply-To: <5484E3C3.5030205@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 08 Dec 2014 00:33:23 +0100

> this is a pull request of 8 patches for net-next/master.
> 
> Andri Yngvason contributes 4 patches in which the CAN state change
> handling is consolidated and unified among the sja1000, mscan and
> flexcan driver. The three patches by Jeremiah Mahler fix spelling
> mistakes and eliminate the banner[] variable in various parts. And a
> patch by me that switches on sparse endianess checking by default.

Pulled, thanks Marc.
