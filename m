From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/2 2.6.28] cxgb3 - extend copyrights to 2008
Date: Mon, 13 Oct 2008 10:15:30 -0700
Message-ID: <20081013171530.23354.34609.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15928 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757219AbYJMRPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 13:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Update copyright banner to 2008.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h          |    2 +-
 drivers/net/cxgb3/ael1002.c          |    2 +-
 drivers/net/cxgb3/common.h           |    2 +-
 drivers/net/cxgb3/cxgb3_ctl_defs.h   |    2 +-
 drivers/net/cxgb3/cxgb3_defs.h       |    2 +-
 drivers/net/cxgb3/cxgb3_ioctl.h      |    2 +-
 drivers/net/cxgb3/cxgb3_main.c       |    2 +-
 drivers/net/cxgb3/cxgb3_offload.c    |    2 +-
 drivers/net/cxgb3/cxgb3_offload.h    |    2 +-
 drivers/net/cxgb3/firmware_exports.h |    2 +-
 drivers/net/cxgb3/l2t.c              |    2 +-
 drivers/net/cxgb3/l2t.h              |    2 +-
 drivers/net/cxgb3/mc5.c              |    2 +-
 drivers/net/cxgb3/sge.c              |    2 +-
 drivers/net/cxgb3/t3_cpl.h           |    2 +-
 drivers/net/cxgb3/t3_hw.c            |    2 +-
 drivers/net/cxgb3/t3cdev.h           |    2 +-
 drivers/net/cxgb3/version.h          |    2 +-
 drivers/net/cxgb3/vsc8211.c          |    2 +-
 drivers/net/cxgb3/xgmac.c            |    2 +-
 20 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 455ef52..bc8e241 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 744fac0..5c3c05d 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2005-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2005-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 593fb64..e312d31 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2005-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2005-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 6ad9240..1d8d46e 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index 45e9216..47e5376 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2006-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
index 3e8d5fa..b19e437 100644
--- a/drivers/net/cxgb3/cxgb3_ioctl.h
+++ b/drivers/net/cxgb3/cxgb3_ioctl.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index f31985d..1ace41a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 0f6fd63..265aa8a 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2006-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_offload.h b/drivers/net/cxgb3/cxgb3_offload.h
index 7a37913..d514e50 100644
--- a/drivers/net/cxgb3/cxgb3_offload.h
+++ b/drivers/net/cxgb3/cxgb3_offload.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2006-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/firmware_exports.h b/drivers/net/cxgb3/firmware_exports.h
index b75ddd8..0d9b0e6 100644
--- a/drivers/net/cxgb3/firmware_exports.h
+++ b/drivers/net/cxgb3/firmware_exports.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2004-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2004-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index b2c5314..4407ac9 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/l2t.h b/drivers/net/cxgb3/l2t.h
index 42ce65f..fd3eb07 100644
--- a/drivers/net/cxgb3/l2t.h
+++ b/drivers/net/cxgb3/l2t.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/cxgb3/mc5.c
index 4c4d6e8..3b5517b 100644
--- a/drivers/net/cxgb3/mc5.c
+++ b/drivers/net/cxgb3/mc5.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 8791941..c6480be 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2005-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2005-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index 917970e..852c399 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2004-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2004-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 4da5b09..968f64b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index 0a21cfb..be55e9a 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2007 Chelsio Communications.  All rights reserved.
+ * Copyright (C) 2006-2008 Chelsio Communications.  All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 29db711..46e20ee 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2003-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/cxgb3/vsc8211.c
index 306c2dc..33f956b 100644
--- a/drivers/net/cxgb3/vsc8211.c
+++ b/drivers/net/cxgb3/vsc8211.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2005-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2005-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index ffdc0a1..9d77869 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2005-2007 Chelsio, Inc. All rights reserved.
+ * Copyright (c) 2005-2008 Chelsio, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU

