From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 19/27] sfc: Removed kernel-doc for nonexistent member of
	efx_phy_operations
Date: Fri, 23 Oct 2009 19:32:22 +0100
Message-ID: <1256322743.2785.41.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8869 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbZJWScV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:21 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c8b6998..13bc1b4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -528,7 +528,6 @@ struct efx_mac_operations {
  * @fini: Shut down PHY
  * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
  * @clear_interrupt: Clear down interrupt
- * @blink: Blink LEDs
  * @poll: Poll for hardware state. Serialised by the mac_lock.
  * @get_settings: Get ethtool settings. Serialised by the mac_lock.
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

