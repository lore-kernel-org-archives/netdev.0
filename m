From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 23/25] ixgb: cleanup header
Date: Tue, 08 Jul 2008 15:52:58 -0700
Message-ID: <20080708225258.6925.35463.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58387 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972AbYGHWxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:53:06 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

cleaned up some spacing in defines

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb.h |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 6cb4dde..5e8a605 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -89,18 +89,16 @@ struct ixgb_adapter;
 
 
 /* TX/RX descriptor defines */
-#define DEFAULT_TXD	 256
-#define MAX_TXD   	4096
-#define MIN_TXD	  64
+#define DEFAULT_TXD      256
+#define MAX_TXD         4096
+#define MIN_TXD           64
 
 /* hardware cannot reliably support more than 512 descriptors owned by
  * hardware descriptor cache otherwise an unreliable ring under heavy
  * receive load may result */
-/* #define DEFAULT_RXD	   1024 */
-/* #define MAX_RXD	   4096 */
-#define DEFAULT_RXD	512
-#define MAX_RXD	512
-#define MIN_RXD	 64
+#define DEFAULT_RXD      512
+#define MAX_RXD          512
+#define MIN_RXD           64
 
 /* Supported Rx Buffer Sizes */
 #define IXGB_RXBUFFER_2048  2048

