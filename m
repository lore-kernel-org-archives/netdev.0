From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 14/14] be2net: update driver version to 10.4
Date: Thu, 17 Jul 2014 16:20:32 +0530
Message-ID: <1405594232-30818-15-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9075 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756827AbaGQKsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:50 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 25cd3c9..0048ef8 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -34,7 +34,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.2u"
+#define DRV_VER			"10.4u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
1.7.1
