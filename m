From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] net: irda: pxaficp_ir: dmaengine conversion
Date: Mon, 28 Sep 2015 22:33:23 -0700 (PDT)
Message-ID: <20150928.223323.204760891377021307.davem@davemloft.net>
References: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
	<1443293360-16377-3-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbbI2FdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:33:24 -0400
In-Reply-To: <1443293360-16377-3-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 26 Sep 2015 20:49:20 +0200

> Convert pxaficp_ir to dmaengine. As pxa architecture is shifting from
> raw DMA registers access to pxa_dma dmaengine driver, convert this
> driver to dmaengine.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Tested-by: Petr Cvek <petr.cvek@tul.cz>
> ---
> Since v1: removed mach/dma.h include, which is the goal

Applied to net-next.
