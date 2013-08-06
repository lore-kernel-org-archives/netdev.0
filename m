From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/7] be2net: update driver version
Date: Tue, 6 Aug 2013 09:27:21 +0530
Message-ID: <1375761441-22343-8-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38644 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3HFD4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:56:40 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index c827b1b..11c815d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -34,7 +34,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"4.6.62.0u"
+#define DRV_VER			"4.9.134.0u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
1.7.1
