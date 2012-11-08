From: David Miller <davem@davemloft.net>
Subject: Re: net/smsc911x: problems after commit 3ac3546e [Always wait for
 the chip to be ready]
Date: Thu, 08 Nov 2012 01:57:54 -0500 (EST)
Message-ID: <20121108.015754.967579869456342727.davem@davemloft.net>
References: <CAKh2mn7XsJjGxctHs5F3d+Av3GpeJW9veH5=S=Y2y_qGf33R4g@mail.gmail.com>
	<20121106.123623.676046673605774326.davem@davemloft.net>
	<20121108064627.GA25027@patelk@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@shawell.net, linus.walleij@linaro.org,
	robert.marklund@stericsson.com, netdev@vger.kernel.org
To: kamlakant.patel@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab2KHG55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 01:57:57 -0500
In-Reply-To: <20121108064627.GA25027@patelk@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Date: Thu, 8 Nov 2012 12:16:28 +0530

> smsc driver is disabled in our bootloader and it is not changing the
> state of the smsc registers at any stage, so it is not a bootloader
> issue.

What puts that chip into a non-default byte swapping mode then?
