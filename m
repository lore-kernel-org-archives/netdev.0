From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 21/21] ntb_netdev: Update Version
Date: Sat, 19 Jan 2013 02:02:35 -0700
Message-ID: <1358586155-23322-22-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update NTB netdev version to 0.7

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/net/ntb_netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 02213a8..6ea1a7b 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -51,7 +51,7 @@
 #include <linux/pci.h>
 #include <linux/ntb.h>
 
-#define NTB_NETDEV_VER	"0.6"
+#define NTB_NETDEV_VER	"0.7"
 
 MODULE_DESCRIPTION(KBUILD_MODNAME);
 MODULE_VERSION(NTB_NETDEV_VER);
-- 
1.7.9.5
