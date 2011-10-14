From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/4] include/linux/can: the mailinglist moved to vger.kernel.org
Date: Fri, 14 Oct 2011 10:43:37 +0200
Message-ID: <1318581817-12352-5-git-send-email-mkl@pengutronix.de>
References: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54808 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab1JNInl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 04:43:41 -0400
In-Reply-To: <1318581817-12352-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 include/linux/can.h         |    2 +-
 include/linux/can/bcm.h     |    2 +-
 include/linux/can/core.h    |    2 +-
 include/linux/can/dev.h     |    2 +-
 include/linux/can/error.h   |    2 +-
 include/linux/can/gw.h      |    2 +-
 include/linux/can/netlink.h |    2 +-
 include/linux/can/raw.h     |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/can.h b/include/linux/can.h
index bb047dc..d0d7028 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -8,7 +8,7 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
index e96154d..cc2f800 100644
--- a/include/linux/can/bcm.h
+++ b/include/linux/can/bcm.h
@@ -7,7 +7,7 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 5ce6b5d..12b2878 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -8,7 +8,7 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index cc0bb49..bf5fa49 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -8,7 +8,7 @@
  *
  * Copyright (C) 2008 Wolfgang Grandegger <wg@grandegger.com>
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  */
 
 #ifndef CAN_DEV_H
diff --git a/include/linux/can/error.h b/include/linux/can/error.h
index 5958074..9aa0dfb 100644
--- a/include/linux/can/error.h
+++ b/include/linux/can/error.h
@@ -7,7 +7,7 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/gw.h b/include/linux/can/gw.h
index 5527b54..37cd710 100644
--- a/include/linux/can/gw.h
+++ b/include/linux/can/gw.h
@@ -7,7 +7,7 @@
  * Copyright (c) 2011 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 34542d3..e497cd8 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -5,7 +5,7 @@
  *
  * Copyright (c) 2009 Wolfgang Grandegger <wg@grandegger.com>
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
diff --git a/include/linux/can/raw.h b/include/linux/can/raw.h
index b2a0f87..f825c94 100644
--- a/include/linux/can/raw.h
+++ b/include/linux/can/raw.h
@@ -8,7 +8,7 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
+ * Send feedback to <linux-can@vger.kernel.org>
  *
  */
 
-- 
1.7.4.1
