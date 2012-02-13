From: Divy Le Ray <divy@chelsio.com>
Subject: [patch net-next] cxgb3: update firmware version
Date: Mon, 13 Feb 2012 12:28:46 -0800
Message-ID: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, dwmw2@infradead.org,
	nhorman@tuxdriver.com, divy@chelsio.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

This patch is sent in conjunction with the cxgb3 firmware update submission on linux-firmware.
(https://lkml.org/lkml/2012/2/13/27)

Cheers,
Divy

From: Divy Le Ray <divy@chelsio.com>

This patch updates the firmware version cxgb3 is requesting to 7.12.0.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/ethernet/chelsio/cxgb3/version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/chelsio/cxgb3/version.h b/drivers/net/ethernet/chelsio/cxgb3/version.h
index 8bda06e..165bfb9 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/version.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/version.h
@@ -35,10 +35,10 @@
 #define DRV_DESC "Chelsio T3 Network Driver"
 #define DRV_NAME "cxgb3"
 /* Driver version */
-#define DRV_VERSION "1.1.4-ko"
+#define DRV_VERSION "1.1.5-ko"
 
 /* Firmware version */
 #define FW_VERSION_MAJOR 7
-#define FW_VERSION_MINOR 10
+#define FW_VERSION_MINOR 12
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
