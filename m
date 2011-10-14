From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/4] drivers/net/can: the mailinglist moved to vger.kernel.org
Date: Fri, 14 Oct 2011 10:43:35 +0200
Message-ID: <1318581817-12352-3-git-send-email-mkl@pengutronix.de>
References: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54804 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1JNInl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 04:43:41 -0400
In-Reply-To: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c        |    2 +-
 drivers/net/can/sja1000/sja1000.c |    2 +-
 drivers/net/can/sja1000/sja1000.h |    2 +-
 drivers/net/can/slcan.c           |    2 +-
 drivers/net/can/vcan.c            |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 121ede6..63bfbd1 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -8,7 +8,7 @@
  * Public License ("GPL") version 2 as distributed in the 'COPYING'
  * file from the main directory of the linux kernel source.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  *
  * Your platform definition file should specify something like:
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index f501bba..5eb4c95 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -40,7 +40,7 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
index 78bd4ec..a6c388b 100644
--- a/drivers/net/can/sja1000/sja1000.h
+++ b/drivers/net/can/sja1000/sja1000.h
@@ -40,7 +40,7 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 4b70b7e..727b686 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -35,7 +35,7 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index a30b8f4..54cc62a 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -37,7 +37,7 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
-- 
1.7.4.1
