From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] man: rtacct: add missing TP marker
Date: Tue,  5 Jul 2016 18:08:50 +0900
Message-ID: <1467709730-17518-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbcGEJI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 05:08:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 man/man8/rtacct.8 | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/rtacct.8 b/man/man8/rtacct.8
index 7cf97aa..01321e6 100644
--- a/man/man8/rtacct.8
+++ b/man/man8/rtacct.8
@@ -35,6 +35,7 @@ Dump absolute values of counters. The default is to calculate increments since t
 .TP
 .B \-s, \-\-noupdate
 Do not update history, so that the next time you will see counters including values accumulated to the moment of this measurement too.
+.TP
 .B \-j, \-\-json
 Display results in JSON format.
 .TP
-- 
2.7.4
