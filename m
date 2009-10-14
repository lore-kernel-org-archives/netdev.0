From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH 2/2] be2net: Bump the driver version number.
Date: Wed, 14 Oct 2009 17:54:46 +0530
Message-ID: <20091014122436.GA12216@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2742 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758918AbZJNMZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 08:25:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump the version number to 2.101.260

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 151e73e..9fd66dc 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -32,7 +32,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.101.205"
+#define DRV_VER			"2.101.260"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.6.0.4

