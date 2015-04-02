From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 11/16] net/mlx5_core: Fix Mellanox copyright note
Date: Thu,  2 Apr 2015 17:07:29 +0300
Message-ID: <1427983654-971-12-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35843 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbbDBOIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:09 -0400
Received: by wizk4 with SMTP id k4so16543900wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:07 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c     | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cq.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c    | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mad.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/mr.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/pd.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c       | 2 +-
 include/linux/mlx5/cmd.h                            | 2 +-
 include/linux/mlx5/cq.h                             | 2 +-
 include/linux/mlx5/device.h                         | 2 +-
 include/linux/mlx5/doorbell.h                       | 2 +-
 include/linux/mlx5/driver.h                         | 2 +-
 include/linux/mlx5/mlx5_ifc.h                       | 2 +-
 include/linux/mlx5/qp.h                             | 2 +-
 include/linux/mlx5/srq.h                            | 2 +-
 26 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 63dd75485204..ac0f7bf4be95 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 697d538163f2..e3273faf4568 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
index 43c5f4809526..eb0cf81f5f45 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index 4878025e231c..5210d92e6bc7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index da82991239a8..dbf190d9b9ad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 06f9036acd83..4b4cda3bcc5f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 3e6670c4a7cd..292d76f2a904 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mad.c b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
index fd80ecfa7195..ee1b0b965f34 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mad.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index f29fd5592305..78dfdab1ead4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
index 44837640bd7c..d79fd85d1dd5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index f0c9f9a7a361..a051b906afdf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
index 1a9b75139c2d..1adb300dd850 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index cf8591a0c48d..df2238372ea7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pd.c b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
index 790da5c4ca4f..f2d3aee909e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 72c2d002c3b8..49e90f2612d8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index 575d853dbe05..dc7dbf7e9d98 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
index 38bce93f8314..f9d25dcd03c1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 06801d6f595e..5a89bb1d678a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/cmd.h b/include/linux/mlx5/cmd.h
index 2826a4b6071e..68cd08f02c2f 100644
--- a/include/linux/mlx5/cmd.h
+++ b/include/linux/mlx5/cmd.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index f6b17ac601bd..72ee0d732a26 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 4e5bd813bb9a..abf65c790421 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/doorbell.h b/include/linux/mlx5/doorbell.h
index 163a818411e7..afc78a3f4462 100644
--- a/include/linux/mlx5/doorbell.h
+++ b/include/linux/mlx5/doorbell.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 8d8ca6d9b03b..8fedd39a9a60 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 5f48b8f592c5..cb3ad17edd1f 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 61f7a342d1bf..310b5f7fd6ae 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/include/linux/mlx5/srq.h b/include/linux/mlx5/srq.h
index e1a363a33663..f43ed054a3e0 100644
--- a/include/linux/mlx5/srq.h
+++ b/include/linux/mlx5/srq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
-- 
2.3.1
