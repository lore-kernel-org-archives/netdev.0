From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.4-rc1] pcnet32 correct names for changes
Date: Tue, 2 Mar 2004 11:27:44 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403021927.i22JRiJ11750@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch corrects the names of contributors of changes to the pcnet32
driver.

--- linux-2.6.4-rc1/drivers/net/good.pcnet32.c	Tue Mar  2 09:44:22 2004
+++ linux-2.6.4-rc1/drivers/net/pcnet32.c	Tue Mar  2 11:24:43 2004
@@ -225,10 +225,12 @@
  * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
  * 	   Added timer for cable connection state changes.
  * v1.28   20 Feb 2004 Don Fry <brazilnut@us.ibm.com>
- *	   Jon Lewis <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
+ *	   Jon Mason <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
  *	   Now uses ethtool_ops, netif_msg_* and generic_mii_ioctl.
  *	   Fixes bogus 'Bus master arbitration failure', pci_[un]map_single
  *	   length errors, and transmit hangs.  Cleans up after errors in open.
+ *	   Jim Lewis <jklewis@us.ibm.com> added ethernet loopback test.
+ *	   Thomas Munck Steenholdt <tmus@tmus.dk> non-mii ioctl corrections.
  */
 

-- 
Don Fry
brazilnut@us.ibm.com
