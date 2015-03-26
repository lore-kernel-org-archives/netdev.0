From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/3] be2net: bump up the driver version to 10.6.0.1
Date: Thu, 26 Mar 2015 03:05:10 -0400
Message-ID: <1427353510-24790-4-git-send-email-sathya.perla@emulex.com>
References: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:14143 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbbCZHBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:01:15 -0400
In-Reply-To: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a2fe1f3..4b0494b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -35,7 +35,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.4u"
+#define DRV_VER			"10.6.0.1"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
2.2.0
