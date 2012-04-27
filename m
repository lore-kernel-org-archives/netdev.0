From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/3] be2net: update the driver version
Date: Thu, 26 Apr 2012 20:42:46 -0500
Message-ID: <20120427014246.GA761@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:56123 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757962Ab2D0BnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 21:43:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4bc18ef..c3ee910 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -33,7 +33,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"4.2.116u"
+#define DRV_VER			"4.2.220u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.7.5.4
