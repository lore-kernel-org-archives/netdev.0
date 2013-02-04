From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 1/1] qlcnic: Updating copyright information.
Date: Mon,  4 Feb 2013 17:33:07 -0500
Message-ID: <1360017187-31459-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24228 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756349Ab3BDWyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 17:54:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

We recently refactored the driver source, this patch will take care of
updating copyright date and adding it to newly added files.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 Documentation/networking/LICENSE.qlcnic            |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    7 +++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    7 +++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    7 +++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |    7 +++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    7 +++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    7 +++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    6 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |    7 +++++++
 16 files changed, 63 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/LICENSE.qlcnic b/Documentation/networking/LICENSE.qlcnic
index e7fb2c6..2ae3b64 100644
--- a/Documentation/networking/LICENSE.qlcnic
+++ b/Documentation/networking/LICENSE.qlcnic
@@ -1,4 +1,4 @@
-Copyright (c) 2009-2011 QLogic Corporation
+Copyright (c) 2009-2013 QLogic Corporation
 QLogic Linux qlcnic NIC Driver
 
 You may modify and redistribute the device driver code under the
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 457ca8e..3a840e7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 65233c8..cdcbbb0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #include "qlcnic.h"
 #include <linux/if_vlan.h>
 #include <linux/ipv6.h>
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 2b44eb1..b62017b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #ifndef __QLCNIC_83XX_HW_H
 #define __QLCNIC_83XX_HW_H
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index c9e24a8..2890c92 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #include "qlcnic.h"
 #include "qlcnic_hw.h"
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index b3ef33a..b0c3de9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #include "qlcnic.h"
 #include "qlcnic_hw.h"
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 7372964..4a3bd64 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index f65fd7b..6320d55 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 74f7711..44197ca 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 88a2330..539a624 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 9673e2b..ed52b9c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #ifndef __QLCNIC_HW_H
 #define __QLCNIC_HW_H
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index aa71eba..d2c6480 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index d00f628..bb4311e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 #include <net/ip.h>
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 6a59a11..67acffe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1,6 +1,6 @@
 /*
  * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
+ * Copyright (c) 2009-2013 QLogic Corporation
  *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 6281cbd..2f9f8e6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1,3 +1,9 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
 
 #include "qlcnic.h"
 #include "qlcnic_hdr.h"
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 5045063..987fb6f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1,3 +1,10 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c) 2009-2013 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
-- 
1.7.1
