From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4 : Update copyright year on all cxgb4 files
Date: Thu, 19 Jun 2014 15:22:11 -0700
Message-ID: <1403216531-7874-6-git-send-email-anish@chelsio.com>
References: <1403216531-7874-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35735
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965955AbaFSXYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 19:24:38 -0400
In-Reply-To: <1403216531-7874-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   | 2 +-
 11 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 9d69c3e..7b5425c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 74b0ce5..02a0ebf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 55e9daf..d719dec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 8a96572..9604139 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
index 85eb5c7..a30126c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index dd4355d..8bae1aa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2a9da07..6665cd4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 71b799b..35e3d8e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 973eb11..abb4580 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 225ad8a..3360025 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index e83c94b..4a6ae4d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2009-2014 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
-- 
2.0.0
