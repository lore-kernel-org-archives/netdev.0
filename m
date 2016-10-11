From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 8/9] man pages: Add tc-ife to Makefile
Date: Tue, 11 Oct 2016 07:00:47 -0400
Message-ID: <1476183648-25850-9-git-send-email-jhs@emojatatu.com>
References: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33894 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcJKLNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:13:14 -0400
Received: by mail-it0-f66.google.com with SMTP id e203so1384892itc.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 04:13:14 -0700 (PDT)
In-Reply-To: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 9213769..4ad96ce 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -16,7 +16,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
 	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
-	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 \
+	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
 
 all: $(TARGETS)
-- 
1.9.1
