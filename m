From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] MAINTAINERS: Update Open vSwitch entry.
Date: Fri,  2 Jan 2015 10:24:58 -0800
Message-ID: <1420223098-1591-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:38346 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750745AbbABSZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 13:25:04 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so24586467pad.10
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 10:25:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS development is moved to netdev mailing list. Update tree and
list in MAINTAINERS file.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 MAINTAINERS |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ddb9ac8..5c976cc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7008,9 +7008,11 @@ F:	arch/openrisc/
 
 OPENVSWITCH
 M:	Pravin Shelar <pshelar@nicira.com>
+L:	netdev@vger.kernel.org
 L:	dev@openvswitch.org
 W:	http://openvswitch.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
 S:	Maintained
 F:	net/openvswitch/
 
-- 
1.7.1
