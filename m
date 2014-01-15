From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 11/11] be2net: update driver version to 10.0.x
Date: Wed, 15 Jan 2014 13:23:41 +0530
Message-ID: <1389772421-24925-12-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20742 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbaAOHt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:26 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 93826ae..8d09615 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -34,7 +34,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"4.9.224.0u"
+#define DRV_VER			"10.0.600.0u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
1.7.1
