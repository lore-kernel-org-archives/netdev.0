From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb3: request 7.10 firmware
Date: Mon, 21 Jun 2010 18:54:53 -0700
Message-ID: <20100622015453.3202.70275.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The driver requests FW 7.10
Bump up driver version.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 9d0bd9d..8bda06e 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -35,10 +35,10 @@
 #define DRV_DESC "Chelsio T3 Network Driver"
 #define DRV_NAME "cxgb3"
 /* Driver version */
-#define DRV_VERSION "1.1.3-ko"
+#define DRV_VERSION "1.1.4-ko"
 
 /* Firmware version */
 #define FW_VERSION_MAJOR 7
-#define FW_VERSION_MINOR 4
+#define FW_VERSION_MINOR 10
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
