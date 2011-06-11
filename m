From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Sat, 11 Jun 2011 16:25:25 -0700 (PDT)
Message-ID: <20110611.162525.724377461693377896.davem@davemloft.net>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	hsweeten@visionengravers.com, rmallon@gmail.com, ynezz@true.cz
To: mika.westerberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab1FKX0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:26:42 -0400
In-Reply-To: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@iki.fi>
Date: Sat, 11 Jun 2011 21:39:54 +0300

> Since the driver uses the DMA API, we should pass it valid DMA masks.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Tested-by: Petr Stetiar <ynezz@true.cz>

Applied.
