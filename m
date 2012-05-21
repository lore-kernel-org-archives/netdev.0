From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 3/3] TIPC: Stepping TIPC version to 2.1.0
Date: Mon, 21 May 2012 01:59:14 -0400
Message-ID: <1337579954-17161-3-git-send-email-jon.maloy@ericsson.com>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com, erik.hugne@ericsson.com,
	allan.stephens@windriver.com, maloy@donjonn.com,
	Jon Maloy <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm2.access.bullet.mail.mud.yahoo.com ([66.94.237.203]:37539
	"HELO nm2.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751546Ab2EUGF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 02:05:26 -0400
In-Reply-To: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Catch-up with out-of-tree version is done. We can go ahead
with more development.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 2a9bb99..3ab29bf 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/core.h: Include file for TIPC global declarations
  *
- * Copyright (c) 2005-2006, Ericsson AB
+ * Copyright (c) 2005-2006, 2012, Ericsson AB
  * Copyright (c) 2005-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -56,7 +56,7 @@
 #include <linux/vmalloc.h>
 
 
-#define TIPC_MOD_VER "2.0.0"
+#define TIPC_MOD_VER "2.1.0"
 
 struct tipc_msg;	/* msg.h */
 struct print_buf;	/* log.h */
-- 
1.7.9.5
