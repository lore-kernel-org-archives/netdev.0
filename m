From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 7/7] be2net: bump the driver version number
Date: Fri, 23 Jul 2010 17:35:36 +0530
Message-ID: <20100723120524.GA25060@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:28450 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757799Ab0GWMFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 08:05:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 434bc4b..e06369c 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -33,7 +33,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.102.147u"
+#define DRV_VER			"2.103.175u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.7.0.4

