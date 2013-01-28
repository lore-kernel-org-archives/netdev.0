From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH] be2net: Updating Module Author string and log message string to "Emulex Corporation"
Date: Mon, 28 Jan 2013 19:47:01 +0530
Message-ID: <744b8e73-1b6a-476d-b8ad-4a2004f3252c@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:57157 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3A1OQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 09:16:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4eba17b..f1b3df1 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -36,13 +36,13 @@
 
 #define DRV_VER			"4.4.161.0u"
 #define DRV_NAME		"be2net"
-#define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
-#define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-#define OC_NAME			"Emulex OneConnect 10Gbps NIC"
+#define BE_NAME			"Emulex BladeEngine2"
+#define BE3_NAME		"Emulex BladeEngine3"
+#define OC_NAME			"Emulex OneConnect"
 #define OC_NAME_BE		OC_NAME	"(be3)"
 #define OC_NAME_LANCER		OC_NAME "(Lancer)"
 #define OC_NAME_SH		OC_NAME "(Skyhawk)"
-#define DRV_DESC		"ServerEngines BladeEngine 10Gbps NIC Driver"
+#define DRV_DESC		"Emulex OneConnect 10Gbps NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
 #define EMULEX_VENDOR_ID	0x10df
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5c99570..4d6f3c5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -25,7 +25,7 @@
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
 MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
-MODULE_AUTHOR("ServerEngines Corporation");
+MODULE_AUTHOR("Emulex Corporation");
 MODULE_LICENSE("GPL");
 
 static unsigned int num_vfs;
-- 
1.7.9.5
