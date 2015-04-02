From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 12/16] IB/mlx5: Fix Mellanox copyright note
Date: Thu,  2 Apr 2015 17:07:30 +0300
Message-ID: <1427983654-971-13-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36057 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbbDBOIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:11 -0400
Received: by wgra20 with SMTP id a20so86551207wgr.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:09 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/ah.c       | 2 +-
 drivers/infiniband/hw/mlx5/cq.c       | 2 +-
 drivers/infiniband/hw/mlx5/doorbell.c | 2 +-
 drivers/infiniband/hw/mlx5/mad.c      | 2 +-
 drivers/infiniband/hw/mlx5/main.c     | 2 +-
 drivers/infiniband/hw/mlx5/mem.c      | 2 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h  | 2 +-
 drivers/infiniband/hw/mlx5/mr.c       | 2 +-
 drivers/infiniband/hw/mlx5/odp.c      | 2 +-
 drivers/infiniband/hw/mlx5/qp.c       | 2 +-
 drivers/infiniband/hw/mlx5/srq.c      | 2 +-
 drivers/infiniband/hw/mlx5/user.h     | 2 +-
 12 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/ah.c b/drivers/infiniband/hw/mlx5/ah.c
index 39ab0caefdf9..66080580e24d 100644
--- a/drivers/infiniband/hw/mlx5/ah.c
+++ b/drivers/infiniband/hw/mlx5/ah.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index f78249c48173..6efd9f73ff60 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/doorbell.c b/drivers/infiniband/hw/mlx5/doorbell.c
index ece028fc47d6..a0e4e6ddb71a 100644
--- a/drivers/infiniband/hw/mlx5/doorbell.c
+++ b/drivers/infiniband/hw/mlx5/doorbell.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index 657af9a1167c..9cf9a37bb5ff 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index cc4ac1e583b2..45816b10af5e 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
index 611a9fdf2f38..40df2cca0609 100644
--- a/drivers/infiniband/hw/mlx5/mem.c
+++ b/drivers/infiniband/hw/mlx5/mem.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 83f22fe297c8..8f94f69fbea5 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index cd9822eeacae..71c593583864 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index a2c541c4809a..5099db08afd2 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index c2f43d378cb5..4d7024b899cb 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 90bc9ff62fe7..02d77a29764d 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/mlx5/user.h b/drivers/infiniband/hw/mlx5/user.h
index d0ba264ac1ed..76fb7b927d37 100644
--- a/drivers/infiniband/hw/mlx5/user.h
+++ b/drivers/infiniband/hw/mlx5/user.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ * Copyright (c) 2013-2015, Mellanox Technologies. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
-- 
2.3.1
