From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/11] sfc: Bump version to 3.2
Date: Wed, 19 Sep 2012 20:18:33 +0100
Message-ID: <1348082313.2636.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20249 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933019Ab2ISTSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:18:36 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The key new feature for 3.2 is PTP support.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 797dbed..c1a010c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -37,7 +37,7 @@
  *
  **************************************************************************/
 
-#define EFX_DRIVER_VERSION	"3.1"
+#define EFX_DRIVER_VERSION	"3.2"
 
 #ifdef DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
