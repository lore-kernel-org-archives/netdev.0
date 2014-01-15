From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 07/11] be2net: Remove "10Gbps" from driver description string
Date: Wed, 15 Jan 2014 13:23:37 +0530
Message-ID: <1389772421-24925-8-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20740 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaAOHtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:18 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

As be2net is used even by the 40Gbps Skyhawk-R chip

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4ccaf9a..b74d81d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -42,7 +42,7 @@
 #define OC_NAME_BE		OC_NAME	"(be3)"
 #define OC_NAME_LANCER		OC_NAME "(Lancer)"
 #define OC_NAME_SH		OC_NAME "(Skyhawk)"
-#define DRV_DESC		"Emulex OneConnect 10Gbps NIC Driver"
+#define DRV_DESC		"Emulex OneConnect NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
 #define EMULEX_VENDOR_ID	0x10df
-- 
1.7.1
