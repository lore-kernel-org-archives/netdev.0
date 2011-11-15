From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 5/5] net-next:asix: v2 update VERSION only
Date: Mon, 14 Nov 2011 16:52:37 -0800
Message-ID: <1321318357-17723-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@chromium.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update VERSION to reflect previous changes.

Signed-off-by: Grant Grundler <grundler@chromium.org>
---
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -36,7 +36,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
 
-#define DRIVER_VERSION "26-Sep-2011"
+#define DRIVER_VERSION "08-Nov-2011"
 #define DRIVER_NAME "asix"
 
 /* ASIX AX8817X based USB 2.0 Ethernet Devices */
