From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next v3 5/6] bnx2x: update year to 2011 and version to
 1.62.12-0
Date: Thu, 5 May 2011 12:51:13 +0300
Message-ID: <1304589073.17528.5.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1466 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab1EEKAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 06:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h             |    6 +++---
 drivers/net/bnx2x/bnx2x_cmn.c         |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.h         |    2 +-
 drivers/net/bnx2x/bnx2x_dcb.c         |    2 +-
 drivers/net/bnx2x/bnx2x_dcb.h         |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c     |    2 +-
 drivers/net/bnx2x/bnx2x_fw_defs.h     |    2 +-
 drivers/net/bnx2x/bnx2x_fw_file_hdr.h |    2 +-
 drivers/net/bnx2x/bnx2x_hsi.h         |    2 +-
 drivers/net/bnx2x/bnx2x_init.h        |    2 +-
 drivers/net/bnx2x/bnx2x_init_ops.h    |    2 +-
 drivers/net/bnx2x/bnx2x_main.c        |    2 +-
 drivers/net/bnx2x/bnx2x_reg.h         |    2 +-
 drivers/net/bnx2x/bnx2x_stats.c       |    2 +-
 drivers/net/bnx2x/bnx2x_stats.h       |    2 +-
 15 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 86e23c7..22a2045 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -22,8 +22,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.62.11-0"
-#define DRV_MODULE_RELDATE      "2011/01/31"
+#define DRV_MODULE_VERSION      "1.62.12-0"
+#define DRV_MODULE_RELDATE      "2011/03/20"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 9632f85..8c63cb7 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index b50570c..cdaf64e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index 9a24d79..919d6fa 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.c: Broadcom Everest network driver.
  *
- * Copyright 2009-2010 Broadcom Corporation
+ * Copyright 2009-2011 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index 71b8eda..369d592 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.h: Broadcom Everest network driver.
  *
- * Copyright 2009-2010 Broadcom Corporation
+ * Copyright 2009-2011 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 14ed2aa..611a21e 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1,6 +1,6 @@
 /* bnx2x_ethtool.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_fw_defs.h b/drivers/net/bnx2x/bnx2x_fw_defs.h
index f4e5b1c..9fe3678 100644
--- a/drivers/net/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
index f807262..f4a07fb 100644
--- a/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_file_hdr.h: FW binary file header structure.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index be503cc..6381a54 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_init.h b/drivers/net/bnx2x/bnx2x_init.h
index fa6dbe3..d539920 100644
--- a/drivers/net/bnx2x/bnx2x_init.h
+++ b/drivers/net/bnx2x/bnx2x_init.h
@@ -1,7 +1,7 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *               Structures and macroes needed during the initialization.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_init_ops.h b/drivers/net/bnx2x/bnx2x_init_ops.h
index 66df29f..aafd023 100644
--- a/drivers/net/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x/bnx2x_init_ops.h
@@ -2,7 +2,7 @@
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 3ddc436..c8e5ff0 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1,6 +1,6 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 1c89f19..eb959be 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 3445ded..e535bfa 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -1,6 +1,6 @@
 /* bnx2x_stats.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x/bnx2x_stats.h b/drivers/net/bnx2x/bnx2x_stats.h
index 596798c..45d14d8 100644
--- a/drivers/net/bnx2x/bnx2x_stats.h
+++ b/drivers/net/bnx2x/bnx2x_stats.h
@@ -1,6 +1,6 @@
 /* bnx2x_stats.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2010 Broadcom Corporation
+ * Copyright (c) 2007-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.7.2.2




