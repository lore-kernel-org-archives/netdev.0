From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 3/5] r8169: removal of unused #define
Date: Tue, 22 Feb 2005 00:56:11 +0100
Message-ID: <20050221235611.GC31723@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <20050221235301.GA31723@electric-eye.fr.zoreil.com> <20050221235450.GB31723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050221235450.GB31723@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removal of unused #define

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-420 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-420	2005-02-18 21:24:40.664919294 +0100
+++ b/drivers/net/r8169.c	2005-02-18 22:19:14.888302521 +0100
@@ -113,8 +113,6 @@ static int multicast_filter_limit = 32;
 /* MAC address length*/
 #define MAC_ADDR_LEN	6
 
-#define TX_FIFO_THRESH 256	/* In bytes */
-
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */

_
