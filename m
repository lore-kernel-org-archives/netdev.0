From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.5 3/3] e100: Driver version number update
Date: Mon, 18 Oct 2004 03:24:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410180312160.20965-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.new.c
--- netdev-2.6/drivers/net/e100.c	2004-10-15 12:27:00.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-15 12:27:01.000000000 -0700
@@ -155,7 +155,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT		"-NAPI"
-#define DRV_VERSION		"3.1.4-k2"DRV_EXT
+#define DRV_VERSION		"3.2.3-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
