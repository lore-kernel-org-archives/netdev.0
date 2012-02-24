From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 5/5] be2net: update driver version
Date: Fri, 24 Feb 2012 10:20:17 +0530
Message-ID: <1330059017-5976-6-git-send-email-sathya.perla@emulex.com>
References: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756149Ab2BXEzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:43 -0500
In-Reply-To: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4b1994d..c357172 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -33,7 +33,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"4.0.100u"
+#define DRV_VER			"4.2.116u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.7.4
