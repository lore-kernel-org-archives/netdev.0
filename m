From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] MAINTAINERS: add second list for IRDA
Date: Tue, 23 Nov 2010 19:10:13 +0100
Message-ID: <1290535813-7487-1-git-send-email-w.sang@pengutronix.de>
Cc: Wolfram Sang <w.sang@pengutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56795 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab0KWSKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 13:10:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The irda-users-list is currently almost dead and subscribers-only. Adding
netdev increases the audience which might help to not overlook a bugreport
(again).

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: David Miller <davem@davemloft.net>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8b6ca96..2596a78 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3261,6 +3261,7 @@ F:	net/ipx/
 IRDA SUBSYSTEM
 M:	Samuel Ortiz <samuel@sortiz.org>
 L:	irda-users@lists.sourceforge.net (subscribers-only)
+L:	netdev@vger.kernel.org
 W:	http://irda.sourceforge.net/
 S:	Maintained
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git
-- 
1.7.2.3

