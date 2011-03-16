From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/2] be2net: Bump up the version number
Date: Wed, 16 Mar 2011 13:21:00 -0500
Message-ID: <20110316182100.GA6274@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:33874 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752106Ab1CPSWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 14:22:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 7721699..f803c58 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -33,7 +33,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.103.175u"
+#define DRV_VER			"4.0.100u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.7.1

