From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] vxge: update MAINTAINERS
Date: Mon,  7 Mar 2011 11:02:01 -0600
Message-ID: <1299517321-4567-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, Jon Mason <jdmason@kudzu.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:38916 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1CGRCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 12:02:08 -0500
Received: by yia27 with SMTP id 27so1677220yia.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 09:02:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exar has exited the 10G Ethernet NIC market, orphaning both the s2io and
vxge drivers.  With the promise of free hardware, I'll take over
maintainership.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 MAINTAINERS |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 75760e7..c069c45 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4284,10 +4284,7 @@ S:	Maintained
 F:	net/sched/sch_netem.c
 
 NETERION 10GbE DRIVERS (s2io/vxge)
-M:	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
-M:	Sivakumar Subramani <sivakumar.subramani@exar.com>
-M:	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
-M:	Jon Mason <jon.mason@exar.com>
+M:	Jon Mason <jdmason@kudzu.us>
 L:	netdev@vger.kernel.org
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/Linux?Anonymous
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/X3100Linux?Anonymous
-- 
1.7.0.4

