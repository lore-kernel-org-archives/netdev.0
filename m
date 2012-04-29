From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/at91_ether: use gpio_to_irq for phy IRQ line
Date: Sat, 28 Apr 2012 21:49:28 -0400 (EDT)
Message-ID: <20120428.214928.225764794994822879.davem@davemloft.net>
References: <3ad9b1273c4f30d42dcc3bdf6d03470111246f14.1335435759.git.nicolas.ferre@atmel.com>
	<cfc991548b5b73c8038f41877da1cd0104945cf5.1335435759.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, avictor.za@gmail.com,
	plagnioj@jcrosoft.com
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab2D2Bvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 21:51:45 -0400
In-Reply-To: <cfc991548b5b73c8038f41877da1cd0104945cf5.1335435759.git.nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 26 Apr 2012 12:30:43 +0200

> Use the gpio_to_irq() function to retrieve the phy IRQ line
> from the GPIO pin specification.
> This fix is needed now that we have moved to irqdomains on AT91.
> 
> Reported-by: Jamie Iles <jamie@jamieiles.com>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied to net-next.
