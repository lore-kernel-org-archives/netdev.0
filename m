From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/9] ixgb: remove changelog
Date: Fri, 26 May 2006 09:52:11 -0700
Message-ID: <20060526165211.30514.65396.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:35846 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751137AbWEZQrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:47:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


same as e1000 - remove the changelog from the driver code itself.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 037b5c3..aecdc00 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -28,22 +28,6 @@
 
 #include "ixgb.h"
 
-/* Change Log
- * 1.0.96 04/19/05
- * - Make needlessly global code static -- bunk@stusta.de
- * - ethtool cleanup -- shemminger@osdl.org
- * - Support for MODULE_VERSION -- linville@tuxdriver.com
- * - add skb_header_cloned check to the tso path -- herbert@apana.org.au
- * 1.0.88 01/05/05
- * - include fix to the condition that determines when to quit NAPI - Robert Olsson
- * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
- * 1.0.84 10/26/04
- * - reset buffer_info->dma in Tx resource cleanup logic
- * 1.0.83 10/12/04
- * - sparse cleanup - shemminger@osdl.org
- * - fix tx resource cleanup logic
- */
-
 char ixgb_driver_name[] = "ixgb";
 static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 



--
Auke Kok <auke-jan.h.kok@intel.com>
