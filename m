From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] iw_cxgb3 Fix copyrights in the iw_cxgb3 driver.
Date: Thu, 15 Feb 2007 13:54:22 -0600
Message-ID: <1171569262.13282.59.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general <openib-general@openib.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:57812 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161080AbXBOTyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 14:54:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix copyrights in the iw_cxgb3 driver.

Remove the Open Grid Computing copyright.  It shouldn't be there.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_dbg.c      |    1 -
 drivers/infiniband/hw/cxgb3/cxio_hal.c      |    1 -
 drivers/infiniband/hw/cxgb3/cxio_hal.h      |    1 -
 drivers/infiniband/hw/cxgb3/cxio_resource.c |    1 -
 drivers/infiniband/hw/cxgb3/cxio_resource.h |    1 -
 drivers/infiniband/hw/cxgb3/cxio_wr.h       |    1 -
 drivers/infiniband/hw/cxgb3/iwch.c          |    1 -
 drivers/infiniband/hw/cxgb3/iwch.h          |    1 -
 drivers/infiniband/hw/cxgb3/iwch_cm.c       |    1 -
 drivers/infiniband/hw/cxgb3/iwch_cm.h       |    1 -
 drivers/infiniband/hw/cxgb3/iwch_cq.c       |    1 -
 drivers/infiniband/hw/cxgb3/iwch_ev.c       |    1 -
 drivers/infiniband/hw/cxgb3/iwch_mem.c      |    1 -
 drivers/infiniband/hw/cxgb3/iwch_provider.c |    1 -
 drivers/infiniband/hw/cxgb3/iwch_provider.h |    1 -
 drivers/infiniband/hw/cxgb3/iwch_qp.c       |    1 -
 drivers/infiniband/hw/cxgb3/iwch_user.h     |    1 -
 17 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_dbg.c b/drivers/infiniband/hw/cxgb3/cxio_dbg.c
index 5a7306f..75f7b16 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_dbg.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_dbg.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 82fa720..114ac3b 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.h b/drivers/infiniband/hw/cxgb3/cxio_hal.h
index 1b97e80..8ab04a7 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/cxio_resource.c b/drivers/infiniband/hw/cxgb3/cxio_resource.c
index 997aa32..65bf577 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_resource.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_resource.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/cxio_resource.h b/drivers/infiniband/hw/cxgb3/cxio_resource.h
index a6bbe83..a2703a3 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_resource.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_resource.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/cxio_wr.h b/drivers/infiniband/hw/cxgb3/cxio_wr.h
index 103fc42..90d7b89 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_wr.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_wr.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch.c b/drivers/infiniband/hw/cxgb3/iwch.c
index 4611afa..0315c9d 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.c
+++ b/drivers/infiniband/hw/cxgb3/iwch.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch.h b/drivers/infiniband/hw/cxgb3/iwch.h
index 6517ef8..caf4e60 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.h
+++ b/drivers/infiniband/hw/cxgb3/iwch.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index a522b1b..e5442e3 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.h b/drivers/infiniband/hw/cxgb3/iwch_cm.h
index 7c810d9..0c6f281 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cq.c b/drivers/infiniband/hw/cxgb3/iwch_cq.c
index 98b3bdb..d7624c1 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cq.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cq.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_ev.c b/drivers/infiniband/hw/cxgb3/iwch_ev.c
index a6efa8f..54362af 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_ev.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_ev.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_mem.c b/drivers/infiniband/hw/cxgb3/iwch_mem.c
index 2b6cd53..a6c2c4b 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_mem.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_mem.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 6861087..2aef122 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.h b/drivers/infiniband/hw/cxgb3/iwch_provider.h
index 61e3278..2af3e93 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index da13a38..4dda2f6 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/infiniband/hw/cxgb3/iwch_user.h b/drivers/infiniband/hw/cxgb3/iwch_user.h
index c4e7fbe..cb7086f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_user.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_user.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU

