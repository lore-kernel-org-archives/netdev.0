From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 8/8] sfc: Bump version to 3.1
Date: Tue, 01 Mar 2011 01:23:49 +0000
Message-ID: <1298942629.3069.187.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12169 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1CABX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:23:59 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All features originally planned for version 3.1 (and some that
weren't) have been implemented.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 9ea6cc2..215d5c5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -41,7 +41,7 @@
  *
  **************************************************************************/
 
-#define EFX_DRIVER_VERSION	"3.0"
+#define EFX_DRIVER_VERSION	"3.1"
 
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
-- 
1.5.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

