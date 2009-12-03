From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 4/4] be2net: Bump up the driver version number
Date: Thu, 3 Dec 2009 21:49:08 +0530
Message-ID: <20091203161859.GA1405@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:50054 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754018AbZLCQSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:18:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index e71cc59..9e56014 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -32,7 +32,7 @@
 
 #include "be_hw.h"
 
-#define DRV_VER			"2.101.205"
+#define DRV_VER			"2.101.346u"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
 #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-- 
1.6.3.3

