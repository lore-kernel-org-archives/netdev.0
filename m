From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 2/2] smsc911x: remove unused #include <linux/version.h>
Date: Sun,  5 Apr 2009 09:53:17 +0800
Message-ID: <1238896397-3572-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:6563 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755908AbZDEBxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 21:53:25 -0400
Received: by ti-out-0910.google.com with SMTP id i7so1505238tid.23
        for <netdev@vger.kernel.org>; Sat, 04 Apr 2009 18:53:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <linux/version.h> in drivers/net/smsc911x.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/smsc911x.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index af8f60c..6da6781 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -43,7 +43,6 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
-#include <linux/version.h>
 #include <linux/bug.h>
 #include <linux/bitops.h>
 #include <linux/irq.h>
-- 
1.6.1.3

