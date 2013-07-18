From: Pavel Machek <pavel@denx.de>
Subject: Re: [PATCH] phy: micrel: Add definitions for common Micrel PHY
 registers
Date: Thu, 18 Jul 2013 13:17:12 +0200
Message-ID: <20130718111712.GA1021@amd.pavel.ucw.cz>
References: <1373929730-28130-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dinh.linux@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>,
	Andrew Victor <linux@maxim.org.za>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:60152 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757780Ab3GRLRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 07:17:15 -0400
Content-Disposition: inline
In-Reply-To: <1373929730-28130-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 2013-07-15 18:08:50, dinguyen@altera.com wrote:
> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Add defines for common Micrel PHY setups so that other platforms
> can use them. Update imx61 and sama5 hardware to use the micrel_phy.h
> PHY defines.

Looks good to me.

> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Shawn Guo <shawn.guo@linaro.org>
> CC: Andrew Victor <linux@maxim.org.za>
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> CC: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>

Reviewed-by: Pavel Machek <pavel@denx.de>
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
