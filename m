From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] phy: micrel: Add definitions for common Micrel PHY
 registers
Date: Wed, 14 Aug 2013 13:17:46 +0800
Message-ID: <20130814051743.GG16915@S2101-09.ap.freescale.net>
References: <1376405940-17141-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dinh.linux@gmail.com>, Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Victor <linux@maxim.org.za>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: <dinguyen@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:33746
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430Ab3HNFRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 01:17:45 -0400
Content-Disposition: inline
In-Reply-To: <1376405940-17141-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 09:58:59AM -0500, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Hi Shawn,
> 
> Can you apply this patch to your tree for 3.12?
> 

I need David's Ack to send the patch through IMX tree.

Shawn

> Thanks,
> 
> Dinh Nguyen (1):
>   phy: micrel: Add definitions for common Micrel PHY registers
> 
>  arch/arm/mach-at91/board-dt-sama5.c |   17 ++++++-----------
>  arch/arm/mach-imx/mach-imx6q.c      |   13 ++++++++-----
>  include/linux/micrel_phy.h          |    6 ++++++
>  3 files changed, 20 insertions(+), 16 deletions(-)
> 
> Cc: Shawn Guo <shawn.guo@linaro.org>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: David S. Miller <davem@davemloft.net>
> CC: Andrew Victor <linux@maxim.org.za>
> CC: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> 
> -- 
> 1.7.9.5
> 
> 
