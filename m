From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/7] be2net: update driver version to 10.2
Date: Tue, 11 Mar 2014 18:53:09 +0530
Message-ID: <1394544189-20277-8-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37776 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbaCKNUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:20:20 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d08c707..a587c8a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -34,7 +34,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.0.600.0u"
+#define DRV_VER			"10.2u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
1.7.1
