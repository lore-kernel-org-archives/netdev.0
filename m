From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 10/10] be2net: update the driver version to 10.6.0.2
Date: Mon,  4 May 2015 02:47:22 -0400
Message-ID: <1430722042-26449-11-git-send-email-sathya.perla@emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752278AbbEDG7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:50 -0400
In-Reply-To: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 3e37b59..1eafc07 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -35,7 +35,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.6.0.1"
+#define DRV_VER			"10.6.0.2"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
2.2.0
