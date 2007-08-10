From: akpm@linux-foundation.org
Subject: [patch 09/28] Clean up duplicate includes in net/tipc/
Date: Fri, 10 Aug 2007 14:11:54 -0700
Message-ID: <200708102111.l7ALBsvm009397@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55240 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942362AbXHJVMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/tipc/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/tipc/port.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/tipc/port.c~clean-up-duplicate-includes-in-net-tipc net/tipc/port.c
--- a/net/tipc/port.c~clean-up-duplicate-includes-in-net-tipc
+++ a/net/tipc/port.c
@@ -41,7 +41,6 @@
 #include "addr.h"
 #include "link.h"
 #include "node.h"
-#include "port.h"
 #include "name_table.h"
 #include "user_reg.h"
 #include "msg.h"
_
