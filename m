From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/12) skge: remove unneeded include's
Date: Thu, 3 Mar 2005 11:34:13 -0800
Message-ID: <20050303113413.1bcd7476@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of unnecessary include's

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:15:44.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:17:25.000000000 -0800
@@ -30,13 +30,10 @@
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/dma-mapping.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
-#include <linux/udp.h>
-#include <linux/tcp.h>
 #include <linux/delay.h>
 #include <linux/crc32.h>
 #include <asm/irq.h>
