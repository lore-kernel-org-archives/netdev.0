From: <dinguyen@altera.com>
Subject: [PATCH] phy: micrel: Add definitions for common Micrel PHY registers
Date: Tue, 13 Aug 2013 09:58:59 -0500
Message-ID: <1376405940-17141-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dinh Nguyen <dinguyen@altera.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Victor <linux@maxim.org.za>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: <dinh.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:33724 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758148Ab3HMO6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Hi Shawn,

Can you apply this patch to your tree for 3.12?

Thanks,

Dinh Nguyen (1):
  phy: micrel: Add definitions for common Micrel PHY registers

 arch/arm/mach-at91/board-dt-sama5.c |   17 ++++++-----------
 arch/arm/mach-imx/mach-imx6q.c      |   13 ++++++++-----
 include/linux/micrel_phy.h          |    6 ++++++
 3 files changed, 20 insertions(+), 16 deletions(-)

Cc: Shawn Guo <shawn.guo@linaro.org>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: David S. Miller <davem@davemloft.net>
CC: Andrew Victor <linux@maxim.org.za>
CC: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org

-- 
1.7.9.5
