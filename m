From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/2] be2net: update driver version to 4.6.x
Date: Mon, 4 Feb 2013 12:00:12 +0530
Message-ID: <42fd6572-899c-485e-a90c-5115c9919cc9@CMEXHTCAS1.ad.emulex.com>
References: <1359959412-8209-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:21494 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab3BDG1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 01:27:39 -0500
In-Reply-To: <1359959412-8209-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4eba17b..4010cb7 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -34,7 +34,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"4.4.161.0u"
+#define DRV_VER			"4.6.62.0u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.7.1
