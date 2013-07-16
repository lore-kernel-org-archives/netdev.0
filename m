From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] phy: micrel: Add definitions for common Micrel PHY
 registers
Date: Tue, 16 Jul 2013 08:11:22 +0800
Message-ID: <20130716001120.GE23589@S2101-09.ap.freescale.net>
References: <1373929730-28130-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dinh.linux@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Victor <linux@maxim.org.za>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Pavel Machek <pavel@denx.de>
To: <dinguyen@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:7967 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755165Ab3GPALa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 20:11:30 -0400
Content-Disposition: inline
In-Reply-To: <1373929730-28130-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 15, 2013 at 06:08:50PM -0500, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Add defines for common Micrel PHY setups so that other platforms
> can use them. Update imx61 and sama5 hardware to use the micrel_phy.h
> PHY defines.
> 
> Also add support for the KSZ9021RLRN PHY.
> 
> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Shawn Guo <shawn.guo@linaro.org>

Acked-by: Shawn Guo <shawn.guo@linaro.org>
