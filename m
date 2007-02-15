From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] cxgb3 Fix copyrights in the cxgb3 driver.
Date: Thu, 15 Feb 2007 13:53:09 -0600
Message-ID: <1171569189.13282.57.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Divy Le Ray <divy@chelsio.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:57820 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161105AbXBOTxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 14:53:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix copyrights in the cxgb3 driver.

Remove the Open Grid Computing copyright.  It shouldn't be there.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/cxgb3/cxgb3_defs.h    |    1 -
 drivers/net/cxgb3/cxgb3_offload.c |    1 -
 drivers/net/cxgb3/cxgb3_offload.h |    1 -
 drivers/net/cxgb3/l2t.c           |    1 -
 drivers/net/cxgb3/l2t.h           |    1 -
 drivers/net/cxgb3/t3cdev.h        |    1 -
 6 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index 16e0049..e14862b 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006-2007 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index c6b7266..b2cf5f6 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006-2007 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/cxgb3_offload.h b/drivers/net/cxgb3/cxgb3_offload.h
index 0e6beb6..f15446a 100644
--- a/drivers/net/cxgb3/cxgb3_offload.h
+++ b/drivers/net/cxgb3/cxgb3_offload.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2006-2007 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006-2007 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 3c0cb85..d660af7 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006-2007 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/l2t.h b/drivers/net/cxgb3/l2t.h
index ba5d2cb..d790013 100644
--- a/drivers/net/cxgb3/l2t.h
+++ b/drivers/net/cxgb3/l2t.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (c) 2003-2007 Chelsio, Inc. All rights reserved.
- * Copyright (c) 2006-2007 Open Grid Computing, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index 9af3bcd..fa4099b 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -1,6 +1,5 @@
 /*
  * Copyright (C) 2006-2007 Chelsio Communications.  All rights reserved.
- * Copyright (C) 2006-2007 Open Grid Computing, Inc.  All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU

