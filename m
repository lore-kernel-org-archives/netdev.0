From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 15/21] NTB: Update Version
Date: Sat, 19 Jan 2013 02:02:29 -0700
Message-ID: <1358586155-23322-16-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update NTB version to 0.25

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
index b792ccd..df86882 100644
--- a/drivers/ntb/ntb_hw.c
+++ b/drivers/ntb/ntb_hw.c
@@ -56,7 +56,7 @@
 #include "ntb_regs.h"
 
 #define NTB_NAME	"Intel(R) PCI-E Non-Transparent Bridge Driver"
-#define NTB_VER		"0.24"
+#define NTB_VER		"0.25"
 
 MODULE_DESCRIPTION(NTB_NAME);
 MODULE_VERSION(NTB_VER);
-- 
1.7.9.5
