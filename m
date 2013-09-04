From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 5/5] driver/net: enic: update enic maintainers and driver
Date: Wed,  4 Sep 2013 11:17:18 +0530
Message-ID: <1378273638-7780-6-git-send-email-govindarajulu90@gmail.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Cc: benve@cisco.com, ssujith@cisco.com, nistrive@cisco.com,
	umalhi@cisco.com,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 MAINTAINERS                            | 3 ++-
 drivers/net/ethernet/cisco/enic/enic.h | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 705bb96..ecb83cd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2076,7 +2076,8 @@ F:	drivers/usb/chipidea/
 
 CISCO VIC ETHERNET NIC DRIVER
 M:	Christian Benvenuti <benve@cisco.com>
-M:	Roopa Prabhu <roprabhu@cisco.com>
+M:	Sujith Sankar <ssujith@cisco.com>
+M:	Govindarajulu Varadarajan <govindarajulu90@gmail.com>
 M:	Neel Patel <neepatel@cisco.com>
 M:	Nishank Trivedi <nistrive@cisco.com>
 S:	Supported
diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 34b637a..e9f7c65 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.43"
+#define DRV_VERSION		"2.1.1.50"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
-- 
1.8.4
