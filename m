From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/6]: [CASSINI]: Bump driver version and release date.
Date: Fri, 04 Jan 2008 00:35:12 -0800 (PST)
Message-ID: <20080104.003512.18469292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752910AbYADIqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:46:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Bump driver version and release date.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index c3220e4..3a9bb17 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -142,8 +142,8 @@
 
 #define DRV_MODULE_NAME		"cassini"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4"
-#define DRV_MODULE_RELDATE	"1 July 2004"
+#define DRV_MODULE_VERSION	"1.5"
+#define DRV_MODULE_RELDATE	"4 Jan 2007"
 
 #define CAS_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
-- 
1.5.4.rc2.17.g257f

