From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2] MAINTAINERS: Update Open vSwitch entry.
Date: Fri,  2 Jan 2015 11:18:21 -0800
Message-ID: <1420226301-1917-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:43191 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752029AbbABT1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:27:07 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so8510216pdb.39
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:27:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS development is moved to netdev mailing list. Update tree and
list in MAINTAINERS file.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 MAINTAINERS |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ddb9ac8..3309895 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7008,11 +7008,12 @@ F:	arch/openrisc/
 
 OPENVSWITCH
 M:	Pravin Shelar <pshelar@nicira.com>
+L:	netdev@vger.kernel.org
 L:	dev@openvswitch.org
 W:	http://openvswitch.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git
 S:	Maintained
 F:	net/openvswitch/
+F:	include/uapi/linux/openvswitch.h
 
 OPL4 DRIVER
 M:	Clemens Ladisch <clemens@ladisch.de>
-- 
1.7.1
