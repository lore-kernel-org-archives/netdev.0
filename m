From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/16] sfc: Remove unused constant
Date: Thu, 26 Nov 2009 02:09:13 +0000
Message-ID: <1259201353.2806.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31158 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbZKZCJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:09:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 140087f..2c0be6c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -109,9 +109,6 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Size and alignment of special buffers (4KB) */
 #define FALCON_BUF_SIZE 4096
 
-/* Dummy SRAM size code */
-#define SRM_NB_BSZ_ONCHIP_ONLY (-1)
-
 #define FALCON_IS_DUAL_FUNC(efx)		\
 	(falcon_rev(efx) < FALCON_REV_B0)
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

