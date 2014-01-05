From: Ariel Elior <ariele@broadcom.com>
Subject: [PATCH net] bnx2x: Introducing 2014 and updating maintainer
Date: Sun, 5 Jan 2014 14:34:33 +0200
Message-ID: <1388925273-12512-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>
To: <ariele@broadcom.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:1027 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaAEMcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 07:32:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    4 ++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    2 +-
 .../ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h   |    4 ++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h  |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h   |    2 +-
 21 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index dad6790..c2ba99f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1,12 +1,12 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 282ebf6..bbfe828 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1,12 +1,12 @@
 /* bnx2x_cmn.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index da8fcaa..273272a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1,12 +1,12 @@
 /* bnx2x_cmn.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index fdace20..459c842 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Dmitry Kravkov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 804b8f6..affc3ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Dmitry Kravkov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 92a467f..b0447f1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1,12 +1,12 @@
 /* bnx2x_ethtool.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 84aecdf..4b98746 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
index f572ae1..e27ee1c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
@@ -1,12 +1,12 @@
 /* bnx2x_fw_file_hdr.h: FW binary file header structure.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Vladislav Zolotarov <vladz@broadcom.com>
  * Based on the original idea of John Wright <john.wright@hp.com>.
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index cf1df8b..8ea84f3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index c2dfea7..bfb111b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -1,13 +1,13 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *               Structures and macroes needed during the initialization.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Modified by: Vladislav Zolotarov <vladz@broadcom.com>
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index 8ab0dd9..0d86077 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -2,13 +2,13 @@
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Vladislav Zolotarov <vladz@broadcom.com>
  */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d3748bf..c54b071 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1,12 +1,12 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 08f8047..290fb3d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index babf7b9..326a3fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Vladislav Zolotarov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 658f4e3..ea91c4d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Vladislav Zolotarov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 6fe52d3..e8556aa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Shmulik Ravid <shmulikr@broadcom.com>
  *	       Ariel Elior <ariele@broadcom.com>
  *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index a5c84a7..8586ed0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Shmulik Ravid <shmulikr@broadcom.com>
  *	       Ariel Elior <ariele@broadcom.com>
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 3b75070..9c2d466 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1,12 +1,12 @@
 /* bnx2x_stats.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index f358450..dec51ff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -1,12 +1,12 @@
 /* bnx2x_stats.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2007-2014 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index e5f7985..e0407d2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Shmulik Ravid <shmulikr@broadcom.com>
  *	       Ariel Elior <ariele@broadcom.com>
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index 208568b..b94fbae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariele@broadcom.com>
  * Written by: Ariel Elior <ariele@broadcom.com>
  */
 #ifndef VF_PF_IF_H
-- 
1.7.1
