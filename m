From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.25] pcnet32 correct names for changes
Date: Tue, 2 Mar 2004 11:28:46 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403021928.i22JSkv11760@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch corrects the names of contributors of changes to the pcnet32
driver.

--- linux-2.4.25/drivers/net/good.pcnet32.c	Wed Feb 25 12:07:48 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Tue Mar  2 11:24:03 2004
@@ -224,10 +224,12 @@
  *	   FD auto negotiate error workaround for xSeries250
  *	   clean up and using new mii module
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
