From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 4/5 2.5] e100: driver version update
Date: Fri, 15 Oct 2004 06:53:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150557180.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.c.new
--- netdev-2.6/drivers/net/e100.c	2004-10-07 13:58:59.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-07 13:59:00.000000000 -0700
@@ -155,7 +155,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT		"-NAPI"
-#define DRV_VERSION		"3.1.4"DRV_EXT
+#define DRV_VERSION		"3.2.3-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
