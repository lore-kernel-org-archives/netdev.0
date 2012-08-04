From: Nick Alcock <nick.alcock@oracle.com>
Subject: [PATCH iproute2] Add missing space preventing the installation of tc.8 and tc-codel.8.
Date: Sat, 04 Aug 2012 15:35:27 +0100
Message-ID: <87ipcyiv2o.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:21592 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab2HDOfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 10:35:32 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by rcsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q74EZUgN000574
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 14:35:31 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q74EZUFQ028891
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 14:35:30 GMT
Received: from abhmt117.oracle.com (abhmt117.oracle.com [141.146.116.69])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q74EZTBY001002
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 09:35:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
---
 man/man8/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 1b671a4..c344094 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -3,7 +3,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
 	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
-	tc-tbf.8 tc.8tc-codel.8 tc-fq_codel.8 tc-sfb.8 tc-netem.8 tc-choke.8 \
+	tc-tbf.8 tc.8 tc-codel.8 tc-fq_codel.8 tc-sfb.8 tc-netem.8 tc-choke.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-tunnel.8 ip-rule.8 ip-ntable.8 \
 	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
-- 
1.7.11.2.155.g5ceeb62
