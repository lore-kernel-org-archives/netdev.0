From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/12) skge: change driver version
Date: Thu, 3 Mar 2005 11:45:05 -0800
Message-ID: <20050303114505.63539ab9@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change driver version to 0.6

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-03 10:36:41.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 10:40:19.000000000 -0800
@@ -41,7 +41,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"0.5"
+#define DRV_VERSION		"0.6"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128
