From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 10/10] bnx2x: Update version to 1.72.0 and
 copyrights
Date: Thu, 26 Jan 2012 18:01:54 +0200
Message-ID: <1327593714-18358-11-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4709 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab2AZQCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:02:09 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h   |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    2 +-
 .../ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h   |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h  |    2 +-
 20 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 06bbef7..7d184fb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -23,8 +23,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.70.35-0"
-#define DRV_MODULE_RELDATE      "2011/11/10"
+#define DRV_MODULE_VERSION      "1.72.00-0"
+#define DRV_MODULE_RELDATE      "2012/01/26"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8fdd71b..6e6a684 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index a6ef3ef..c7c7bf1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 5051cf3..9a9bd3a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.c: Broadcom Everest network driver.
  *
- * Copyright 2009-2011 Broadcom Corporation
+ * Copyright 2009-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 2ab9254..06c7a04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.h: Broadcom Everest network driver.
  *
- * Copyright 2009-2011 Broadcom Corporation
+ * Copyright 2009-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
index b983825..3e4cff9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
@@ -1,6 +1,6 @@
 /* bnx2x_dump.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2011 Broadcom Corporation
+ * Copyright (c) 2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 06cb244..137968d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1,6 +1,6 @@
 /* bnx2x_ethtool.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 998652a..e5c5982 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
index f4a07fb..4bed52b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_file_hdr.h: FW binary file header structure.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 3e30c86..78b77de 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index 4d748e7..29f5c3c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -1,7 +1,7 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *               Structures and macroes needed during the initialization.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index f05ee2f..fe66d90 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -2,7 +2,7 @@
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 2091e5d..2102ad5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1,4 +1,4 @@
-/* Copyright 2008-2011 Broadcom Corporation
+/* Copyright 2008-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index e02a68a..9cc7baf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -1,4 +1,4 @@
-/* Copyright 2008-2011 Broadcom Corporation
+/* Copyright 2008-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index cdce766..fea9615 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1,6 +1,6 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 8ade7bd..c95d9dc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 69465c3..ac15f74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -1,6 +1,6 @@
 /* bnx2x_sp.c: Broadcom Everest network driver.
  *
- * Copyright 2011 Broadcom Corporation
+ * Copyright (c) 2011-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index f33bc57..71e039b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -1,6 +1,6 @@
 /* bnx2x_sp.h: Broadcom Everest network driver.
  *
- * Copyright 2011 Broadcom Corporation
+ * Copyright (c) 2011-2012 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index bc0121a..7b9b304 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1,6 +1,6 @@
 /* bnx2x_stats.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 9c28db1..7e97968 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -1,6 +1,6 @@
 /* bnx2x_stats.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2011 Broadcom Corporation
+ * Copyright (c) 2007-2012 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.7.1
