From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 3/3 2.5] e100 driver version number update
Date: Fri, 17 Sep 2004 02:54:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170210540.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e100.c linux-2.5/drivers/net/e100.c.new
--- linux-2.5/drivers/net/e100.c	2004-09-09 14:51:31.000000000 -0700
+++ linux-2.5/drivers/net/e100.c.new	2004-09-09 14:51:32.000000000 -0700
@@ -154,8 +154,8 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.0.27-k2"DRV_EXT
+#define DRV_EXT		"-NAPI"
+#define DRV_VERSION		"3.1.4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
