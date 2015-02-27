From: Ebben Aries <exa@fb.com>
Subject: [PATCH] iproute: ip-gue/ip-fou manpages
Date: Fri, 27 Feb 2015 09:27:39 -0700
Message-ID: <1425054459-12874-1-git-send-email-exa@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ebben Aries <exa@fb.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26417 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760AbbB0Q1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 11:27:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing GUE/FOU manpages to Makefile

Signed-off-by: Ebben Aries <exa@fb.com>
---
 man/man8/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index e998928..152747a 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -6,7 +6,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
-	ip-addrlabel.8 ip-l2tp.8 \
+	ip-addrlabel.8 ip-fou.8 ip-gue.8 ip-l2tp.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
 	ip-netns.8 ip-ntable.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
 	ip-tcp_metrics.8 ip-netconf.8 ip-token.8
-- 
2.2.1
